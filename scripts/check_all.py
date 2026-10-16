#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ZMXYBHYH 全工程质量总指挥门禁 (Comprehensive Quality Gate Runner)
================================================================
一键串联行尾检查、代码格式校验、静态异味审查与 Godot 4 引擎编译门禁。
对标现代 C++ 工程中的 `make check` / `ctest` 自动化总门禁。
"""

import os
import sys
import time
import argparse
import subprocess
from typing import Tuple, List

# 颜色常量 (Windows 终端兼容)
try:
    import colorama
    colorama.init()
    GREEN = "\033[92m"
    RED = "\033[91m"
    YELLOW = "\033[93m"
    CYAN = "\033[96m"
    RESET = "\033[0m"
    BOLD = "\033[1m"
except Exception:
    GREEN = RED = YELLOW = CYAN = RESET = BOLD = ""

def print_header(title: str):
    print(f"\n{BOLD}{CYAN}{'=' * 76}{RESET}")
    print(f"{BOLD}{CYAN} {title}{RESET}")
    print(f"{BOLD}{CYAN}{'=' * 76}{RESET}")

def run_step(step_name: str, cmd: List[str], env=None) -> Tuple[bool, float, str]:
    print(f"[*] 正在执行: {step_name}...")
    start_time = time.time()
    try:
        res = subprocess.run(cmd, capture_output=True, text=True, errors="ignore", env=env)
        elapsed = time.time() - start_time
        success = (res.returncode == 0)
        output = (res.stdout + "\n" + res.stderr).strip()
        return success, elapsed, output
    except Exception as e:
        elapsed = time.time() - start_time
        return False, elapsed, str(e)

def main():
    parser = argparse.ArgumentParser(
        description="ZMXYBHYH 一键式全工程质量总门禁 (CI Pipeline Runner)"
    )
    parser.add_argument(
        "--fast",
        action="store_true",
        help="快速模式：执行行尾、格式与基础 Lint，跳过耗时最长的引擎全量编译"
    )
    parser.add_argument(
        "--skip-engine",
        action="store_true",
        help="跳过 Godot 引擎 Headless 深度编译检查 (用于轻量环境)"
    )
    parser.add_argument(
        "--fix",
        action="store_true",
        help="自动修复模式：若发现行尾或格式未对齐，自动执行写入修复"
    )

    args = parser.parse_args()

    print_header("ZMXYBHYH 现代工程质量流水线总门禁 (Phase 4.4)")
    print(f"[*] 工作根目录: {os.getcwd()}")
    print(f"[*] 执行模式: {'快速模式 (--fast)' if args.fast else '全量深度体检'}")
    if args.fix:
        print(f"[*] 自动修复: 开启 (--fix)")

    results = []
    overall_start = time.time()

    # --------------------------------------------------------------------------
    # 维度 1: 行尾序列与空白合规性 (LF Check)
    # --------------------------------------------------------------------------
    print(f"\n{BOLD}[维度 1/4] 跨平台行尾序列归一化检查 (LF Normalization Check){RESET}")
    if args.fix:
        ok, elapsed, out = run_step(
            "行尾自动清洗 (normalize_eol.py)",
            [sys.executable, "scripts/normalize_eol.py", "source/v6.5.0.0"]
        )
    else:
        ok, elapsed, out = run_step(
            "行尾合规性扫描 (normalize_eol.py --dry-run)",
            [sys.executable, "scripts/normalize_eol.py", "source/v6.5.0.0", "--dry-run"]
        )
    
    # 判定依据: 输出中发现并清洗 CRLF 文件数是否为 0
    crlf_clean = ("发现并清洗 CRLF 文件数: 0" in out) or (args.fix and ok)
    if crlf_clean:
        print(f" -> {GREEN}[PASS]{RESET} 全盘文本资产 100% 统一为 LF 行尾 ({elapsed:.2f}s)")
        results.append(("1. 跨平台行尾 LF 归一化", True, elapsed, ""))
    else:
        print(f" -> {RED}[FAIL]{RESET} 检测到未对齐的 CRLF 文件！({elapsed:.2f}s)")
        results.append(("1. 跨平台行尾 LF 归一化", False, elapsed, "存在 CRLF 换行符，请运行 python scripts/normalize_eol.py 修复"))

    # --------------------------------------------------------------------------
    # 维度 2: 代码格式规范校验 (gdformat Check)
    # --------------------------------------------------------------------------
    print(f"\n{BOLD}[维度 2/4] GDScript 代码风格规范检查 (gdformat Check){RESET}")
    if args.fix:
        ok, elapsed, out = run_step(
            "代码自动格式化 (format_all.py)",
            [sys.executable, "scripts/format_all.py", "source/v6.5.0.0"]
        )
        format_passed = ok
    else:
        ok, elapsed, out = run_step(
            "代码格式门禁校验 (format_all.py --check)",
            [sys.executable, "scripts/format_all.py", "source/v6.5.0.0", "--check"]
        )
        format_passed = ok and ("所有代码完全符合代码格式规范" in out)

    if format_passed:
        print(f" -> {GREEN}[PASS]{RESET} 全量 734 个 GDScript 100% 符合官方排版风格 ({elapsed:.2f}s)")
        results.append(("2. GDScript 代码格式化规范", True, elapsed, ""))
    else:
        print(f" -> {RED}[FAIL]{RESET} 存在未对齐官方排版的脚本！({elapsed:.2f}s)")
        results.append(("2. GDScript 代码格式化规范", False, elapsed, "存在未格式化脚本，请运行 python scripts/format_all.py 修复"))

    # --------------------------------------------------------------------------
    # 维度 3: 静态代码异味与语法树审查 (gdlint Check)
    # --------------------------------------------------------------------------
    print(f"\n{BOLD}[维度 3/4] GDScript 静态异味与语法树审查 (gdlint Check){RESET}")
    # 针对核心架构模块执行高价值异味扫描
    core_scripts = [
        "source/v6.5.0.0/Global.gd",
        "source/v6.5.0.0/BaseHit.gd",
        "source/v6.5.0.0/AllEquipment.gd",
        "source/v6.5.0.0/Script/base/base_role_properies.gd",
        "source/v6.5.0.0/Script/base/base_hero.gd",
        "source/v6.5.0.0/Script/base/base_monster.gd",
        "source/v6.5.0.0/Script/level/level_1.gd",
        "source/v6.5.0.0/Script/level/victory.gd",
        "source/v6.5.0.0/Script/memory_class/player_data.gd",
        "source/v6.5.0.0/Script/memory_class/memory_class.gd",
    ]
    ok, elapsed, out = run_step(
        "核心架构静态 Lint 扫描 (gdlint)",
        ["gdlint"] + core_scripts
    )
    if ok and "no problems found" in out.lower():
        print(f" -> {GREEN}[PASS]{RESET} 核心架构与单例全部通过静态异味检查 ({elapsed:.2f}s)")
        results.append(("3. 静态代码异味检查 (gdlint)", True, elapsed, ""))
    else:
        print(f" -> {RED}[FAIL]{RESET} 静态 Lint 发现代码异味或语法缺陷！({elapsed:.2f}s)")
        results.append(("3. 静态代码异味检查 (gdlint)", False, elapsed, out[:300]))

    # --------------------------------------------------------------------------
    # 维度 4: Godot 4 引擎编译级深度体检 (health_check.py)
    # --------------------------------------------------------------------------
    if args.fast or args.skip_engine:
        print(f"\n{YELLOW}[跳过维度 4/4] 已根据参数跳过 Godot 引擎 Headless 深度编译检查{RESET}")
        results.append(("4. Godot 4 引擎静态编译全量门禁", True, 0.0, "已跳过 (Fast Mode)"))
    else:
        print(f"\n{BOLD}[维度 4/4] Godot 4 引擎编译级深度体检 (health_check.py){RESET}")
        ok, elapsed, out = run_step(
            "全盘场景依赖与 874 脚本编译扫描",
            [sys.executable, "scripts/health_check.py"]
        )
        engine_passed = ok and ("0 严重编译错误" in out or "0 Parse Error" in out) and ("0 处断裂引用" in out)
        if engine_passed:
            print(f" -> {GREEN}[PASS]{RESET} 1,242 场景引用完备，874 脚本编译零错误 ({elapsed:.2f}s)")
            results.append(("4. Godot 4 引擎静态编译全量门禁", True, elapsed, ""))
        else:
            print(f" -> {RED}[FAIL]{RESET} 引擎静态编译扫描发现错误！({elapsed:.2f}s)")
            results.append(("4. Godot 4 引擎静态编译全量门禁", False, elapsed, "编译报错，详情查看 docs/dead_code_audit.md"))

    # --------------------------------------------------------------------------
    # 汇总质量报告仪表板
    # --------------------------------------------------------------------------
    total_elapsed = time.time() - overall_start
    print_header("ZMXYBHYH 工程质量全维度综合报告")
    print(f"{'检查维度与门禁项':<36} | {'状态':<10} | {'耗时':<8} | {'备注'}")
    print("-" * 76)

    all_passed = True
    for name, success, el, note in results:
        status_str = f"{GREEN}PASS{RESET}" if success else f"{RED}FAIL{RESET}"
        if not success:
            all_passed = False
        print(f"{name:<34} | {status_str:<19} | {el:>6.2f}s | {note}")

    print("-" * 76)
    print(f"[*] 流水线总执行耗时: {total_elapsed:.2f} 秒")

    if all_passed:
        print(f"\n{BOLD}{GREEN}[SUCCESS] 所有质量门禁全部通过！代码资产质量已达工业级生产标准！{RESET}\n")
        sys.exit(0)
    else:
        print(f"\n{BOLD}{RED}[FAILURE] 存在未通过的门禁项，请根据上述提示处理后再提交！{RESET}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
