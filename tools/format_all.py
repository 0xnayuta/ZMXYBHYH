#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ZMXYBHYH 全工程 GDScript 自动化格式化流水线工具 (Format All Pipeline)
====================================================================
基于官方推荐的 gdtoolkit (gdformat 4.5.0)，提供工程级代码规范格式化与门禁校验。
对标现代大型工程中的 clang-format 流水线。
"""

import os
import sys
import shutil
import argparse
import subprocess
from pathlib import Path
from typing import List, Tuple

# 排除目录
EXCLUDE_DIRS = {
    ".git", ".godot", "godot", "extracted", "binaries",
    "source/v1.2.0.1", "source/v1.3.3.2"
}

def resolve_gdformat_cmd() -> List[str]:
    """解析并定位 gdformat 可执行命令，优先使用本地独立可执行文件"""
    gdformat_bin = shutil.which("gdformat")
    if gdformat_bin:
        return [gdformat_bin]
    
    # 尝试 uv tool 方式
    uv_bin = shutil.which("uv")
    if uv_bin:
        return [uv_bin, "tool", "run", "--from", "gdtoolkit", "gdformat"]
    
    print("[ERROR] 未找到 gdformat 或 uv 工具！请先运行: uv tool install gdtoolkit", file=sys.stderr)
    sys.exit(1)

def collect_gd_files(target_path: str) -> List[str]:
    """安全递归收集目标路径下的所有有效 .gd 脚本"""
    p = Path(target_path)
    if not p.exists():
        print(f"[ERROR] 目标路径不存在: {target_path}", file=sys.stderr)
        return []

    if p.is_file():
        if p.suffix == ".gd":
            return [str(p.resolve())]
        return []

    collected: List[str] = []
    norm_target = str(p.resolve())

    for root, dirs, files in os.walk(norm_target):
        # 排除只读基线与缓存目录
        dirs[:] = [
            d for d in dirs
            if not any(ex in os.path.join(root, d).replace("\\", "/") for ex in EXCLUDE_DIRS)
        ]

        for f in sorted(files):
            if f.endswith(".gd"):
                full_path = os.path.join(root, f)
                collected.append(full_path)

    return collected

def run_batch(
    cmd_base: List[str],
    batch: List[str],
    line_length: int,
    mode: str
) -> Tuple[int, List[str], List[str]]:
    """执行单个批次的格式化，返回 (退出码, 需要格式化/已格式化列表, 错误列表)"""
    args = list(cmd_base)
    args.extend(["-l", str(line_length)])

    if mode == "check":
        args.append("--check")
    elif mode == "diff":
        args.append("--diff")

    args.extend(batch)

    res = subprocess.run(args, capture_output=True, text=True, errors="ignore")
    
    reformatted = []
    errors = []

    output = (res.stderr + "\n" + res.stdout).strip()
    for line in output.splitlines():
        line_clean = line.strip()
        if line_clean.startswith("would reformat "):
            fp = line_clean[len("would reformat "):].strip()
            reformatted.append(fp)
        elif line_clean.startswith("reformatted "):
            fp = line_clean[len("reformatted "):].strip()
            reformatted.append(fp)
        elif "could not parse" in line_clean.lower() or "syntaxerror" in line_clean.lower():
            errors.append(line_clean)

    if mode == "diff" and output:
        print(output + "\n")
    return res.returncode, reformatted, errors

def main():
    parser = argparse.ArgumentParser(
        description="ZMXYBHYH GDScript 代码格式化流水线 (对标 clang-format)"
    )
    parser.add_argument(
        "target",
        nargs="?",
        default="source/v6.5.0.0",
        help="目标文件或目录路径 (默认: source/v6.5.0.0)"
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="校验模式：不修改文件，仅检查是否符合规范 (CI 门禁模式)"
    )
    parser.add_argument(
        "--diff",
        action="store_true",
        help="差异模式：打印建议修改的代码 diff，不直接写回文件"
    )
    parser.add_argument(
        "--line-length",
        "-l",
        type=int,
        default=120,
        help="最大允许单行字符宽度 (默认: 120)"
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=50,
        help="批处理文件上限，防止超出 Windows 命令行长度限制 (默认: 50)"
    )

    args = parser.parse_args()

    mode = "write"
    if args.diff:
        mode = "diff"
    elif args.check:
        mode = "check"

    cmd_base = resolve_gdformat_cmd()
    files = collect_gd_files(args.target)

    if not files:
        print(f"[!] 在目标路径 '{args.target}' 下未发现任何可处理的 .gd 脚本。")
        sys.exit(0)

    print("=" * 72)
    print(" ZMXYBHYH GDScript 代码格式化流水线 (gdformat 4.5.0)")
    print("=" * 72)
    print(f"[*] 执行模式: {'校验 (Check)' if mode == 'check' else ('差异 (Diff)' if mode == 'diff' else '覆写格式化 (Write)')}")
    print(f"[*] 目标路径: {args.target}")
    print(f"[*] 扫描脚本: {len(files)} 个 .gd 文件")
    print(f"[*] 单行宽度: {args.line_length} 字符")
    print(f"[*] 批次大小: {args.batch_size} 文件/批")
    print("-" * 72)

    total_reformatted = []
    total_errors = []
    overall_exit_code = 0

    total_batches = (len(files) + args.batch_size - 1) // args.batch_size

    for b_idx in range(total_batches):
        start = b_idx * args.batch_size
        end = min(start + args.batch_size, len(files))
        batch = files[start:end]

        ret, reformatted, errors = run_batch(cmd_base, batch, args.line_length, mode)
        total_reformatted.extend(reformatted)
        total_errors.extend(errors)

        if ret != 0:
            overall_exit_code = ret

        # 进度指示
        print(f" -> 处理进度: 批次 [{b_idx+1}/{total_batches}] (已处理 {end}/{len(files)} 文件)...")

    print("=" * 72)
    print(" 格式化流水线执行结果报告")
    print("=" * 72)
    print(f"[+] 总扫描脚本数: {len(files)}")
    print(f"[+] 需规范化/已格式化文件数: {len(total_reformatted)}")
    print(f"[+] 已经符合规范文件数: {len(files) - len(total_reformatted)}")
    print(f"[+] 语法解析错误数: {len(total_errors)}")

    if total_errors:
        print("\n[!] 语法解析异常列表:")
        for err in total_errors:
            print(f"    * {err}")

    if mode == "check" and total_reformatted:
        print("\n[FAIL] 门禁校验失败：以上文件未遵守官方代码格式规范，请运行格式化！")
        sys.exit(1)
    elif mode == "check":
        print("\n[SUCCESS] 门禁校验通过：所有代码完全符合代码格式规范！")
        sys.exit(0)
    else:
        print("\n[SUCCESS] 代码格式化操作完成！")
        sys.exit(0 if not total_errors else 1)

if __name__ == "__main__":
    main()
