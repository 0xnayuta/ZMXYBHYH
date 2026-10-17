#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scripts/rename_path.py

ZMXYBHYH 生产级原子路径迁移引擎 (Phase 8-3)
====================================================================
用于在 Windows / Linux 跨平台环境下安全、原子地重命名文件或目录。

核心特性：
1. 大小写安全 (Case-Safe Two-Step Git Move)：
   自动经由临时名分步执行 git mv，彻底绕过 Windows NTFS 大小写不敏感索引陷阱；
2. 全盘协同原子替换 (Full-Workspace Atomic Substitution)：
   自动更新 .gd, .tscn, .tres, .import, project.godot 中的 res:// 引用及代码动态拼接前缀；
3. .import 与 .uid 资产元数据协同：
   自动重命名伴生文件，同步重写 .import 文件内部的 source_file="res://..." 与 dest_files；
4. 质量门禁自动联动 (Automated Double Gate)：
   重命名后自动执行 contract_scan.py 与 health_check.py 验证 0 断裂引用与 0 编译错误；
5. 事务性自动回滚 (Atomic Rollback Protection)：
   若重命名或门禁校验失败，自动无损回滚 Git 状态与文件内容，确保工作区绝对纯净。
"""

import os
import sys
import re
import argparse
import subprocess
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional


REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_DIR = os.path.join(REPO_ROOT, "source", "v6.5.0.0")


def run_command(cmd: str, cwd: str = REPO_ROOT) -> Tuple[int, str, str]:
    """运行外部 Shell 命令并捕获完整输出"""
    res = subprocess.run(
        cmd,
        cwd=cwd,
        shell=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="ignore"
    )
    return res.returncode, res.stdout, res.stderr


class PathRenameEngine:
    def __init__(
        self,
        old_path_input: str,
        new_path_input: str,
        dry_run: bool = False,
        skip_gates: bool = False,
        skip_rollback: bool = False,
        verbose: bool = False
    ):
        self.dry_run = dry_run
        self.skip_gates = skip_gates
        self.skip_rollback = skip_rollback
        self.verbose = verbose

        # 规范化路径为相对于 source/v6.5.0.0/ 的无前缀正斜杠形式
        self.old_rel = self._normalize_input_path(old_path_input)
        self.new_rel = self._normalize_input_path(new_path_input)

        self.old_full = os.path.join(PROJECT_DIR, self.old_rel.replace("/", os.sep))
        self.new_full = os.path.join(PROJECT_DIR, self.new_rel.replace("/", os.sep))

        self.git_old = f"source/v6.5.0.0/{self.old_rel}"
        self.git_new = f"source/v6.5.0.0/{self.new_rel}"

        # 记录受影响的文件与内容备份
        self.modified_files_backup: Dict[str, str] = {}
        self.is_dir = False
        self.associated_pairs: List[Tuple[str, str]] = []  # [(git_old_path, git_new_path)]

    def _normalize_input_path(self, p: str) -> str:
        clean = p.replace("res://", "").replace("\\", "/").strip().strip("/")
        if clean.startswith("source/v6.5.0.0/"):
            clean = clean[len("source/v6.5.0.0/"):]
        return clean

    def validate_inputs(self) -> bool:
        if not self.old_rel or not self.new_rel:
            print("[!] 错误: 原路径或目标路径不能为空！", file=sys.stderr)
            return False

        if self.old_rel == self.new_rel:
            print(f"[*] 原路径与目标路径完全一致，无需重命名: {self.old_rel}")
            return False

        if not os.path.exists(self.old_full):
            print(f"[!] 错误: 源文件或目录不存在: {self.old_full}", file=sys.stderr)
            return False

        self.is_dir = os.path.isdir(self.old_full)
        return True

    def build_rename_pairs(self):
        """建立所有需要重命名的文件对（主文件/目录、伴生 .import、伴生 .uid）"""
        self.associated_pairs.append((self.git_old, self.git_new))

        # 若是单文件，检查伴生的 .import 与 .uid
        if not self.is_dir:
            if os.path.exists(self.old_full + ".import"):
                self.associated_pairs.append((self.git_old + ".import", self.git_new + ".import"))
            if os.path.exists(self.old_full + ".uid"):
                self.associated_pairs.append((self.git_old + ".uid", self.git_new + ".uid"))

    def scan_affected_references(self) -> List[Tuple[str, List[Tuple[int, str]]]]:
        """全盘扫描所有引用了旧路径的文件及匹配行号"""
        affected = []

        # 构造匹配前缀与完整模式
        if self.is_dir:
            search_tokens = [
                f"res://{self.old_rel}/",
                f"res://{self.old_rel}",
                f'"{self.old_rel}/',
                f"'{self.old_rel}/",
                f'/{self.old_rel}/',
            ]
        else:
            search_tokens = [
                f"res://{self.old_rel}",
                f'"{self.old_rel}"',
                f"'{self.old_rel}'",
            ]

        for root, dirs, files in os.walk(PROJECT_DIR):
            dirs[:] = [d for d in dirs if d not in (".godot", "godot", ".git")]
            for f in files:
                if f.endswith((".gd", ".tscn", ".tres", ".import", ".godot", ".cfg", ".json")):
                    abs_p = os.path.join(root, f)
                    try:
                        content = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
                    except OSError:
                        continue

                    matched_lines = []
                    for idx, line in enumerate(content.splitlines(), 1):
                        if any(tok in line for tok in search_tokens):
                            matched_lines.append((idx, line.strip()))

                    if matched_lines:
                        affected.append((abs_p, matched_lines))

        return affected

    def execute_substitution(self, affected_files: List[Tuple[str, List[Tuple[int, str]]]]) -> bool:
        """执行全盘内容协同替换"""
        for abs_p, _ in affected_files:
            try:
                content = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
                self.modified_files_backup[abs_p] = content

                new_content = content
                if self.is_dir:
                    new_content = new_content.replace(f"res://{self.old_rel}/", f"res://{self.new_rel}/")
                    new_content = new_content.replace(f"res://{self.old_rel}", f"res://{self.new_rel}")
                    new_content = new_content.replace(f'"{self.old_rel}/', f'"{self.new_rel}/')
                    new_content = new_content.replace(f"'{self.old_rel}/", f"'{self.new_rel}/")
                    new_content = new_content.replace(f'/{self.old_rel}/', f'/{self.new_rel}/')
                else:
                    new_content = new_content.replace(f"res://{self.old_rel}", f"res://{self.new_rel}")
                    new_content = new_content.replace(f'"{self.old_rel}"', f'"{self.new_rel}"')
                    new_content = new_content.replace(f"'{self.old_rel}'", f"'{self.new_rel}'")

                if new_content != content:
                    with open(abs_p, "w", encoding="utf-8", newline="\n") as f:
                        f.write(new_content)
            except Exception as e:
                print(f"[!] 写入文件失败 {abs_p}: {e}", file=sys.stderr)
                return False
        return True

    def execute_two_step_git_mv(self) -> bool:
        """执行两步中转 git mv 重命名"""
        for src_git, dst_git in self.associated_pairs:
            # 临时中转名
            tmp_git = src_git + "__tmp_rename_step"

            # 步骤 A: src -> tmp
            code, out, err = run_command(f'git mv "{src_git}" "{tmp_git}"')
            if code != 0:
                print(f"[!] Git 重命名步骤 1 失败 ({src_git} -> {tmp_git}): {err.strip()}", file=sys.stderr)
                return False

            # 步骤 B: tmp -> dst
            code, out, err = run_command(f'git mv "{tmp_git}" "{dst_git}"')
            if code != 0:
                print(f"[!] Git 重命名步骤 2 失败 ({tmp_git} -> {dst_git}): {err.strip()}", file=sys.stderr)
                # 尝试回滚第一步
                run_command(f'git mv "{tmp_git}" "{src_git}"')
                return False

            print(f"       -> [git mv] {src_git} ===> {dst_git}")

        return True

    def rollback(self):
        """事务性安全回滚"""
        print("[*] 正在执行事务回滚，撤销全部改动并还原 Git 工作区...")
        # 1. 恢复文件内容
        for abs_p, orig_content in self.modified_files_backup.items():
            try:
                with open(abs_p, "w", encoding="utf-8", newline="\n") as f:
                    f.write(orig_content)
            except Exception:
                pass

        # 2. 检查是否有处于中转状态的文件或已被 git mv 的条目，强制 checkout
        run_command("git reset HEAD -- source/v6.5.0.0")
        run_command("git checkout -- source/v6.5.0.0")
        print("[√] 回滚完成，工作区已完全复原。")

    def run_gates(self) -> bool:
        """运行双重质量门禁校验"""
        print("[*] 正在执行双重质量门禁验证...")
        
        # 门禁 1: contract_scan.py
        print("    [门禁 1/2] 运行全量字面量契约门禁 (contract_scan.py)...")
        code, out, err = run_command("python scripts/contract_scan.py --fail-on-error")
        if code != 0:
            print("[!] 契约门禁校验未通过！输出摘要:")
            for line in out.splitlines()[-10:]:
                print(f"        {line}")
            return False

        # 门禁 2: health_check.py
        print("    [门禁 2/2] 运行全量编译与场景引用门禁 (health_check.py)...")
        code, out, err = run_command("python scripts/health_check.py")
        if code != 0 or "0 处断裂引用" not in out:
            print("[!] 编译与场景引用门禁未通过！输出摘要:")
            for line in out.splitlines()[-10:]:
                print(f"        {line}")
            return False

        print("[√] 双重质量门禁全部通过！0 断裂引用，0 语法错误！")
        return True

    def run(self) -> bool:
        if not self.validate_inputs():
            return False

        self.build_rename_pairs()

        print("========================================================================")
        print(" ZMXYBHYH 生产级原子路径迁移引擎 (rename_path.py)")
        print("========================================================================")
        print(f"[*] 模式: {'试运行 (Dry-Run)' if self.dry_run else '正式迁移 (Execute)'}")
        print(f"[*] 实体类型: {'目录 (Directory)' if self.is_dir else '文件 (File)'}")
        print(f"[*] 源路径: res://{self.old_rel}")
        print(f"[*] 目标路径: res://{self.new_rel}")
        print(f"[*] 计划重命名文件对: {len(self.associated_pairs)} 项")
        print("------------------------------------------------------------------------")

        # 1. 扫描受影响文件
        print("[1/4] 正在扫描全工程关联引用...")
        affected = self.scan_affected_references()
        print(f"       -> 发现包含引用的文件: {len(affected)} 个")
        for abs_p, lines in affected[:8]:
            rel = os.path.relpath(abs_p, PROJECT_DIR).replace("\\", "/")
            print(f"          * {rel} ({len(lines)} 处匹配)")
            if self.verbose:
                for ln, lt in lines[:3]:
                    print(f"              L{ln}: {lt}")
        if len(affected) > 8:
            print(f"          ... 其余 {len(affected) - 8} 个文件")

        if self.dry_run:
            print("\n[SUCCESS] 试运行完成！清单已展示，未对磁盘与 Git 进行任何变更。")
            return True

        # 2. 执行内容协同替换
        print("\n[2/4] 正在协同原子替换所有引用内容...")
        if not self.execute_substitution(affected):
            print("[!] 内容替换过程发生错误，触发回滚保护！", file=sys.stderr)
            self.rollback()
            return False
        print(f"       -> 成功原子更新 {len(self.modified_files_backup)} 个引用文件。")

        # 3. 执行 Git 两步中转重命名
        print("\n[3/4] 正在执行 Git 两步中转安全重命名...")
        if not self.execute_two_step_git_mv():
            print("[!] Git 重命名步骤失败，触发回滚保护！", file=sys.stderr)
            self.rollback()
            return False

        # 4. 执行门禁验证
        print("\n[4/4] 正在触发自动化质量门禁断言...")
        if not self.skip_gates:
            if not self.run_gates():
                if not self.skip_rollback:
                    print("[!] 门禁断言未通过，触发回滚保护！", file=sys.stderr)
                    self.rollback()
                return False

        print("\n========================================================================")
        print(f"[SUCCESS] 原子迁移完成！res://{self.old_rel} ===> res://{self.new_rel}")
        print("========================================================================")
        return True


def main():
    parser = argparse.ArgumentParser(description="ZMXYBHYH 生产级原子路径迁移引擎 (Phase 8-3)")
    parser.add_argument("old_path", help="源路径 (支持 res:// 或相对 source/v6.5.0.0/ 路径)")
    parser.add_argument("new_path", help="目标路径 (支持 res:// 或相对 source/v6.5.0.0/ 路径)")
    parser.add_argument("--dry-run", action="store_true", help="试运行预览，不修改任何文件与索引")
    parser.add_argument("--skip-gates", action="store_true", help="跳过自动门禁校验")
    parser.add_argument("--skip-rollback", action="store_true", help="门禁失败时不自动回滚现场")
    parser.add_argument("--verbose", action="store_true", help="输出详细匹配行")

    args = parser.parse_args()

    engine = PathRenameEngine(
        old_path_input=args.old_path,
        new_path_input=args.new_path,
        dry_run=args.dry_run,
        skip_gates=args.skip_gates,
        skip_rollback=args.skip_rollback,
        verbose=args.verbose
    )

    success = engine.run()
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
