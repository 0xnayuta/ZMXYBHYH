#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
行尾序列清洗与归一化工具 (EOL Normalizer)
=======================================
将指定范围内的源码、场景与文本配置统一归一化为标准 Unix LF (\n) 行尾。
严格保留文件原有编码与语义，杜绝任何字符污染。
"""

import os
import sys
import argparse

TEXT_EXTENSIONS = {
    ".gd", ".tscn", ".tres", ".gdshader", ".cfg",
    ".import", ".json", ".md", ".txt", ".py"
}

EXCLUDE_DIRS = {
    ".git", ".godot", "godot", "venv", ".venv",
    "extracted", "binaries"
}

def normalize_file(file_path: str) -> bool:
    """如果文件包含 CRLF (\\r\\n) 或孤立 CR (\\r)，替换为 LF (\\n) 并写回。返回是否有改动。"""
    try:
        with open(file_path, "rb") as f:
            content = f.read()
    except Exception as e:
        print(f"[ERROR] 读取失败: {file_path} - {e}", file=sys.stderr)
        return False

    if b"\r" not in content:
        return False

    # 规范化：先把 \r\n 转为 \n，再把可能的孤立 \r 转为 \n
    normalized = content.replace(b"\r\n", b"\n").replace(b"\r", b"\n")

    if normalized != content:
        with open(file_path, "wb") as f:
            f.write(normalized)
        return True
    return False

def scan_and_normalize(target_dir: str, dry_run: bool = False):
    print(f"[*] 开始扫描目标路径: {target_dir} (Dry-run: {dry_run})")
    stats = {}
    total_scanned = 0
    total_modified = 0

    for root, dirs, files in os.walk(target_dir):
        # 排除不关心的缓存目录与历史归档
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]

        for file_name in files:
            ext = os.path.splitext(file_name)[1].lower()
            if ext not in TEXT_EXTENSIONS:
                continue

            total_scanned += 1
            file_path = os.path.join(root, file_name)
            
            with open(file_path, "rb") as f:
                content = f.read()
            
            if b"\r" in content:
                stats[ext] = stats.get(ext, 0) + 1
                total_modified += 1
                if not dry_run:
                    normalize_file(file_path)

    print(f"\n[+] 扫描与清洗完成！")
    print(f"    - 总扫描文本文件: {total_scanned}")
    print(f"    - 发现并清洗 CRLF 文件数: {total_modified}")
    print("    - 分类清洗明细:")
    for ext, count in sorted(stats.items(), key=lambda x: -x[1]):
        print(f"      * {ext:<12s}: {count} 个文件")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="ZMXYBHYH 行尾清洗工具")
    parser.add_argument("target", nargs="?", default="source/v6.5.0.0", help="待清洗目录 (默认: source/v6.5.0.0)")
    parser.add_argument("--dry-run", action="store_true", help="只检查不实际修改文件")
    args = parser.parse_args()

    scan_and_normalize(args.target, dry_run=args.dry_run)
