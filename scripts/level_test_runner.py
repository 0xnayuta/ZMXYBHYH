#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scripts/level_test_runner.py

生产级关卡全自动极速冒烟测试夹具 (Level Test Runner)。

执行通道说明
------------
本夹具走**命令行通道**：在项目根下生成一对临时驱动资源
(`level_smoke_driver.tscn` + `level_smoke_driver.gd`)，用
`godot --headless --path <project> res://level_smoke_driver.tscn` 启动一个持
有完整 Autoload 的游戏进程，由驱动脚本在进程内完成：沙盒隔离 -> 切入关卡 ->
分阶段瞬移与攻击 -> 阶段断言 -> 恢复沙盒 -> 写回 JSON 报告 -> 退出。
夹具随后读取报告、扫描引擎日志做 0/0 门禁，并清理全部临时产物。

之所以不走 MCP：godot-mcp 桥（`addons/godot_mcp`）经 Godot 编辑器调试器协议
（EditorDebuggerPlugin）转发，外部 Python 无法直连；命令行通道无需编辑器与
MCP 客户端即可在 CI 中回归。

核心能力
--------
1. 内存沙盒隔离：动态开启无敌与秒杀，绝不污染玩家物理存档；
2. 引擎倍速加速：测试期间 Engine.time_scale 提升至 N 倍，压缩等待时间；
3. 坐标瞬移闪烁：跨越数千像素跑图耗时，精准直击各阶段刷怪区；
4. 阶段状态机断言：逐一遍历 Stage 1 -> 2 -> 3 -> 4，断言 current_stage 推进；
5. 0/0 门禁：扫描引擎日志，断言 0 SCRIPT ERROR / 0 ERROR / 0 WARNING；
6. 产物自清理：驱动资源、报告文件在夹具退出前全部删除（异常路径亦清理）。
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time
from typing import Any, Dict, List, Optional, Tuple

# ---------------------------------------------------------------------------
# 常量
# ---------------------------------------------------------------------------

DEFAULT_LEVEL = "res://Scene/level/level_1.tscn"
DEFAULT_TIME_SCALE = 3.0
DRIVER_SCENE_NAME = "level_smoke_driver.tscn"
DRIVER_SCRIPT_NAME = "level_smoke_driver.gd"
REPORT_NAME = "level_smoke_report.json"
RUN_LOG_NAME = "level_smoke_run.log"

# 关卡各阶段推进的判定坐标（与 BaseLevel._physics_process 的 stage 阈值一致）
STAGE_STEPS: List[Tuple[int, float]] = [
    (1, 500.0),
    (2, 2000.0),
    (3, 3000.0),
    (4, 4500.0),
]

# Godot 可执行文件探测顺序（环境解耦：可用 --godot 或 GODOT_BIN 覆盖）
GODOT_ENV_VAR = "GODOT_BIN"
GODOT_CANDIDATES = [
    r"E:\Program Files\Godot\Godot_v4.7.2-stable_win64.exe",
    r"E:\Program Files\Godot\Godot_v4.7.2-stable_win64_console.exe",
    "godot",
    "godot4",
]


class LevelTestRunner:
    """关卡冒烟夹具：命令行通道执行 + 报告解析 + 日志门禁。"""

    def __init__(
        self,
        target_level: str = DEFAULT_LEVEL,
        time_scale: float = DEFAULT_TIME_SCALE,
        godot_exe: Optional[str] = None,
        project_dir: Optional[str] = None,
    ) -> None:
        self.target_level = target_level
        self.time_scale = time_scale
        self.repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.project_dir = project_dir or os.path.join(self.repo_root, "source", "v6.5.0.0")
        self.godot_exe = godot_exe or self._resolve_godot_exe()
        self.driver_scene_fp = os.path.join(self.project_dir, DRIVER_SCENE_NAME)
        self.driver_script_fp = os.path.join(self.project_dir, DRIVER_SCRIPT_NAME)
        self.report_fp = os.path.join(self.project_dir, REPORT_NAME)
        self.run_log_fp = os.path.join(self.project_dir, RUN_LOG_NAME)
        # 门禁与诊断都读夹具专属日志（--log-file 指定），不受编辑器实例干扰
        self.log_path = self.run_log_fp

    # -- 环境 ---------------------------------------------------------------

    def _resolve_godot_exe(self) -> str:
        env_bin = os.environ.get(GODOT_ENV_VAR, "").strip()
        if env_bin:
            return env_bin
        for cand in GODOT_CANDIDATES:
            if os.path.sep in cand or cand.endswith(".exe"):
                if os.path.exists(cand):
                    return cand
            else:
                found = shutil.which(cand)
                if found:
                    return found
        raise RuntimeError(
            "未找到 Godot 可执行文件：请通过 --godot 参数或 GODOT_BIN 环境变量指定路径。"
        )

    def _resolve_godot_log_path(self) -> str:
        appdata = os.environ.get("APPDATA", "")
        return os.path.join(appdata, "Godot", "app_userdata", "造梦八荒", "logs", "godot.log")

    # -- 驱动资源生成 -------------------------------------------------------

    def build_driver_script(self) -> str:
        """生成在游戏进程内执行的全流程驱动脚本。"""
        stage_entries = ",\n".join(
            '\t\t{"stage": %d, "x": %.1f}' % (idx, x) for idx, x in STAGE_STEPS
        )
        return f'''extends Node

## 关卡冒烟驱动（由 scripts/level_test_runner.py 生成，执行后即被清理）。
## 在完整 Autoload 环境下运行：沙盒隔离 -> 切关 -> 阶段推进 -> 断言 -> 报告。

const REPORT_PATH := "res://{REPORT_NAME}"
const TARGET_LEVEL := "{self.target_level}"
const TIME_SCALE := {self.time_scale}
const LOAD_TIMEOUT_MS := 45000
const LOAD_MAX_FRAMES := 20000
const HERO_SETTLE_FRAMES := 60
const STAGE_WAIT_FRAMES := 150

const STAGE_STEPS := [
{stage_entries}
]


var _is_worker: bool = false


func _ready() -> void:
	# 驱动以“主场景”身份启动，而 change_scene 会释放主场景自身。
	# 因此这里先复制一个携带同一脚本的常驻 worker 挂到 root 下，
	# 由 worker 承担全部测试逻辑；驱动本体随切关自然退场。
	if not _is_worker:
		var worker: Node = duplicate()
		worker.set("_is_worker", true)
		worker.name = "LevelSmokeWorker"
		get_tree().root.add_child.call_deferred(worker)
		return
	call_deferred("_run_all")


func _run_all() -> void:
	var report: Dictionary = {{
		"target_level": TARGET_LEVEL,
		"time_scale": TIME_SCALE,
		"scene": "",
		"hero": "",
		"stages": [],
		"errors": [],
		"ok": false,
	}}

	# 1. 内存沙盒隔离（不落盘、不改玩家存档）
	PlayerData.player_data["Myself"] = 1
	RoleProp.baseroleprop.Level = 1
	RoleProp.set_basic_prop()
	RoleProp.roleprop.Hp = 9999
	RoleProp.roleprop.SHp = 9999
	Global.cd_path = ""
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE, true)
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INSTANT_KILL, true)
	Engine.time_scale = TIME_SCALE

	# 2. 切入目标关卡（Global.change_scene 走异步加载屏，需等待加载器完成切换）
	Global.change_scene(TARGET_LEVEL)
	var loaded_scene: Node = await _await_level_ready(report)
	if loaded_scene == null:
		_finish(report, 1)
		return
	var scn: Node = loaded_scene
	report["scene"] = String(scn.name)

	# 3. 定位主角
	var hero: Node = scn.get_node_or_null("Hero/Role1")
	if hero == null:
		var hero_root: Node = scn.get_node_or_null("Hero")
		if hero_root != null:
			var kids: Array = []
			for c in hero_root.get_children():
				kids.append(String(c.name))
			report["errors"].append("hero_not_found; Hero children=" + str(kids))
		else:
			report["errors"].append("hero_root_not_found")
		_finish(report, 1)
		return
	report["hero"] = String(hero.name)

	# 4. 逐阶段瞬移 + 攻击 + 断言
	var all_ok: bool = true
	for entry in STAGE_STEPS:
		var target_stage: int = int(entry["stage"])
		var target_x: float = float(entry["x"])
		hero.position.x = target_x
		for method in ["normalhit", "lys", "hmz"]:
			if hero.has_method(method):
				hero.call(method)
		await _wait_frames(STAGE_WAIT_FRAMES)

		var actual_stage: int = int(scn.get("current_stage")) if scn.get("current_stage") != null else -1
		var stage_ok: bool = actual_stage == target_stage
		all_ok = all_ok and stage_ok
		report["stages"].append({{
			"target_stage": target_stage,
			"x": target_x,
			"actual_stage": actual_stage,
			"ok": stage_ok,
		}})

	# 5. 恢复沙盒（保证测试环境纯净）
	Engine.time_scale = 1.0
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE, false)
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INSTANT_KILL, false)
	Global.cd_path = ""

	report["ok"] = all_ok and report["errors"].is_empty()
	_finish(report, 0 if report["ok"] else 1)


func _await_level_ready(report: Dictionary) -> Node:
	## 等待加载屏（LoadScene）完成切换，且目标关卡主角节点就绪。
	## 采用墙钟 + 帧数双重上限，headless 与实机帧率差异下都稳定。
	var deadline_ms: int = Time.get_ticks_msec() + LOAD_TIMEOUT_MS
	var frames: int = 0
	var last_scene_name: String = ""
	var diag: Array = []
	while Time.get_ticks_msec() < deadline_ms and frames < LOAD_MAX_FRAMES:
		await get_tree().process_frame
		frames += 1
		var cs: Node = get_tree().current_scene
		if cs != null:
			last_scene_name = String(cs.name)
		# 每 300 帧采样一次加载屏状态，便于失败时定位卡点
		if frames % 300 == 0:
			var ls: Node = get_tree().root.get_node_or_null("LoadScene")
			var st: String = "no_loadscene"
			if ls != null:
				var bar: Node = ls.get_node_or_null("PanelContainer/loading_bar")
				st = "started=%s changing=%s bar=%s" % [
					str(ls.get("_load_started")),
					str(ls.get("_changing_scene")),
					("%.1f" % float(bar.value)) if bar != null else "n/a",
				]
			diag.append("f=%d scene=%s %s target=%s" % [frames, last_scene_name, st, String(Global.target_scene)])
		if cs == null:
			continue
		if last_scene_name == "LoadScene":
			continue
		# 场景已切换：再等主角节点完成 _ready 构建
		if cs.get_node_or_null("Hero") != null:
			for _i in range(HERO_SETTLE_FRAMES):
				await get_tree().process_frame
			return cs
	if not diag.is_empty():
		report["load_diag"] = diag.slice(maxi(0, diag.size() - 8), diag.size())
	report["errors"].append(
		"level_load_timeout; last_scene=%s frames=%d" % [last_scene_name, frames]
	)
	return null


func _wait_frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame


func _finish(report: Dictionary, exit_code: int) -> void:
	var fa := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if fa != null:
		fa.store_string(JSON.stringify(report, "  "))
		fa.close()
	else:
		push_error("level_smoke: cannot write report to " + REPORT_PATH)
	get_tree().quit(exit_code)
'''

    def build_driver_scene(self) -> str:
        """生成挂载驱动脚本的临时场景（format=3 原生文本格式）。"""
        return f'''[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://{DRIVER_SCRIPT_NAME}" id="1"]

[node name="LevelSmokeDriver" type="Node"]
script = ExtResource("1")
'''

    # -- 执行 ---------------------------------------------------------------

    def _write_driver_resources(self) -> None:
        with open(self.driver_script_fp, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(self.build_driver_script())
        with open(self.driver_scene_fp, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(self.build_driver_scene())

    def cleanup(self) -> None:
        """清理全部临时产物（幂等，异常路径同样安全）。"""
        for fp in (self.driver_scene_fp, self.driver_script_fp, self.report_fp, self.run_log_fp):
            try:
                if os.path.exists(fp):
                    os.remove(fp)
            except OSError:
                pass
        # Godot 为脚本生成的 .uid 伴生文件
        for fp in (self.driver_script_fp + ".uid", self.driver_scene_fp + ".uid"):
            try:
                if os.path.exists(fp):
                    os.remove(fp)
            except OSError:
                pass

    def run(self, timeout_seconds: int = 300) -> Dict[str, Any]:
        """执行一次完整冒烟，返回报告字典（含夹具侧结论）。"""
        assert self.log_path, "日志路径解析失败"
        log_start_size = self._log_size()
        self.cleanup()
        self._write_driver_resources()
        cmd = [
            self.godot_exe,
            "--headless",
            "--path",
            self.project_dir,
            "--log-file",
            self.run_log_fp,
            "--scene",
            "res://" + DRIVER_SCENE_NAME,
        ]
        started = time.time()
        try:
            proc = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="ignore",
                timeout=timeout_seconds,
                cwd=self.project_dir,
            )
            stdout, stderr, returncode = proc.stdout or "", proc.stderr or "", proc.returncode
        except subprocess.TimeoutExpired as exc:
            stdout, stderr, returncode = exc.stdout or "", exc.stderr or "", -1
        elapsed = time.time() - started

        report: Dict[str, Any] = {}
        if os.path.exists(self.report_fp):
            try:
                with open(self.report_fp, encoding="utf-8") as fh:
                    report = json.load(fh)
            except (OSError, json.JSONDecodeError) as exc:
                report = {"errors": [f"report_unreadable: {exc}"]}
        else:
            report = {"errors": ["report_not_written"]}

        report["_runner"] = {
            "exit_code": returncode,
            "elapsed_seconds": round(elapsed, 2),
            "stdout_tail": stdout[-2000:],
            "stderr_tail": stderr[-2000:],
        }

        # 日志门禁：只统计本次运行新增段落
        log_delta = self._read_log_delta(log_start_size)
        report["_runner"]["log"] = {
            "script_errors": len(re.findall(r"SCRIPT ERROR", log_delta)),
            "errors": len(re.findall(r"^ERROR", log_delta, re.M)),
            "warnings": len(re.findall(r"^WARNING", log_delta, re.M)),
            "sample": [ln for ln in log_delta.splitlines() if re.match(r"^(SCRIPT ERROR|ERROR|WARNING)", ln)][:12],
        }
        report["_runner"]["passed"] = bool(
            report.get("ok")
            and report["_runner"]["log"]["script_errors"] == 0
            and report["_runner"]["log"]["errors"] == 0
            and report["_runner"]["log"]["warnings"] == 0
        )
        self.cleanup()
        return report

    def _log_size(self) -> int:
        try:
            return os.path.getsize(self.log_path)
        except OSError:
            return 0

    def _read_log_delta(self, since: int) -> str:
        try:
            with open(self.log_path, encoding="utf-8", errors="ignore") as fh:
                fh.seek(since)
                return fh.read()
        except OSError:
            return ""


def _print_report(report: Dict[str, Any]) -> None:
    runner = report.get("_runner", {})
    print("=" * 72)
    print(" 关卡冒烟测试报告 (Level Smoke Test Report)")
    print("=" * 72)
    print(f"  目标关卡: {report.get('target_level', '?')}   倍速: {report.get('time_scale', '?')}x")
    print(f"  实际场景: {report.get('scene', '?')}   主角节点: {report.get('hero', '?')}")
    print(f"  执行耗时: {runner.get('elapsed_seconds', '?')}s   退出码: {runner.get('exit_code', '?')}")
    print("-" * 72)
    print("  阶段推进:")
    for st in report.get("stages", []):
        flag = "PASS" if st.get("ok") else "FAIL"
        print(
            f"    [{flag}] Stage {st.get('target_stage')} @ x={st.get('x')} "
            f"-> actual={st.get('actual_stage')}"
        )
    if report.get("load_diag"):
        print("  加载诊断:")
        for line in report["load_diag"]:
            print(f"    {line}")
    if report.get("errors"):
        print("  驱动错误:")
        for err in report["errors"]:
            print(f"    - {err}")
    log = runner.get("log", {})
    print("-" * 72)
    print(
        f"  日志门禁: SCRIPT ERROR={log.get('script_errors', '?')} "
        f"ERROR={log.get('errors', '?')} WARNING={log.get('warnings', '?')}"
    )
    for ln in log.get("sample", []):
        print(f"    {ln[:150]}")
    print("=" * 72)
    print("  [PASS] 关卡冒烟全部通过" if runner.get("passed") else "  [FAIL] 关卡冒烟未通过")
    print("=" * 72)


def main() -> int:
    parser = argparse.ArgumentParser(description="ZMXYBHYH 关卡自动化极速冒烟测试夹具")
    parser.add_argument("--level", default=DEFAULT_LEVEL, help="目标测试关卡路径")
    parser.add_argument("--scale", type=float, default=DEFAULT_TIME_SCALE, help="物理加速倍率")
    parser.add_argument("--godot", default=None, help="Godot 可执行文件路径（或设 GODOT_BIN）")
    parser.add_argument("--timeout", type=int, default=300, help="单次冒烟墙钟上限（秒）")
    parser.add_argument("--json", action="store_true", help="仅输出 JSON 报告（CI 友好）")
    args = parser.parse_args()

    try:
        runner = LevelTestRunner(
            target_level=args.level,
            time_scale=args.scale,
            godot_exe=args.godot,
        )
    except RuntimeError as exc:
        print(f"[FAIL] {exc}", file=sys.stderr)
        return 2

    print(f"[*] 关卡极速测试夹具就绪: {args.level} (加速: {args.scale}x)")
    print(f"[*] Godot: {runner.godot_exe}")
    print(f"[*] 日志监控路径: {runner.log_path}")
    report = runner.run(timeout_seconds=args.timeout)
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        _print_report(report)
    return 0 if report.get("_runner", {}).get("passed") else 1


if __name__ == "__main__":
    sys.exit(main())
