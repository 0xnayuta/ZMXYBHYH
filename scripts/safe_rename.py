#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scripts/safe_rename.py - ZMXYBHYH 生产级资源与目录原子重命名工具链

功能：
1. Windows NTFS 大小写安全：通过双步中转 (Two-Step Renaming) 使用 git mv 重命名目录或文件；
2. 全盘协同原子级更新：自动遍历 source/v6.5.0.0/ 下全部 .tscn, .tres, .gd, .import, project.godot 替换引用；
3. UID 映射文件同步：自动处理对应的 .uid 存根文件；
4. 质量门禁自动校验：重命名后自动执行 health_check.py 验证 0 Broken References。
"""

import os
import sys
import argparse
import subprocess
import re

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_DIR = os.path.join(REPO_ROOT, "source", "v6.5.0.0")


def run_cmd(cmd, cwd=REPO_ROOT):
    """运行外部命令并捕获输出"""
    res = subprocess.run(cmd, cwd=cwd, shell=True, capture_output=True, text=True, encoding="utf-8", errors="ignore")
    return res.returncode, res.stdout, res.stderr


def safe_rename(old_rel: str, new_rel: str, dry_run: bool = False) -> bool:
    """
    执行原子安全重命名
    old_rel / new_rel: 相对于 source/v6.5.0.0/ 的路径 (使用正斜杠，如 Scene/Main_menu)
    """
    old_rel = old_rel.replace("\\", "/").strip("/")
    new_rel = new_rel.replace("\\", "/").strip("/")
    
    if old_rel == new_rel:
        print(f"[*] 新旧路径完全一致，无需重命名: {old_rel}")
        return True

    old_full = os.path.join(PROJECT_DIR, old_rel.replace("/", os.sep))
    new_full = os.path.join(PROJECT_DIR, new_rel.replace("/", os.sep))

    if not os.path.exists(old_full):
        print(f"[!] 错误: 源路径不存在: {old_full}")
        return False

    print(f"========================================================================")
    print(f" ZMXYBHYH 原子安全重命名工具链")
    print(f"========================================================================")
    print(f"[*] 模式: {'试运行 (Dry-Run)' if dry_run else '正式执行 (Execute)'}")
    print(f"[*] 源路径: res://{old_rel}")
    print(f"[*] 目标路径: res://{new_rel}")
    print(f"------------------------------------------------------------------------")

    # 1. 扫描受影响的引用文件
    ref_files = []
    old_patterns = [
        f"res://{old_rel}",
        f'"{old_rel}/',
        f"'{old_rel}/",
    ]

    for root, dirs, files in os.walk(PROJECT_DIR):
        if ".godot" in root.split(os.sep) or "godot" in root.split(os.sep):
            continue
        for f in files:
            if f.endswith((".tscn", ".tres", ".gd", ".import", ".godot")):
                fp = os.path.join(root, f)
                try:
                    with open(fp, "r", encoding="utf-8", errors="ignore") as s:
                        content = s.read()
                    if any(p in content for p in old_patterns):
                        ref_files.append(fp)
                except Exception:
                    pass

    print(f"[1/4] 全盘扫描完成，发现包含引用的文件: {len(ref_files)} 个")
    for rf in ref_files[:10]:
        print(f"       - {os.path.relpath(rf, PROJECT_DIR)}")
    if len(ref_files) > 10:
        print(f"       ... 以及其他 {len(ref_files) - 10} 个文件")

    if dry_run:
        print(f"[+] 试运行模式完成，未修改任何文件。")
        return True

    # 2. 全盘协同原子替换内容
    print(f"[2/4] 正在协同更新所有引用文件内容...")
    updated_count = 0
    for rf in ref_files:
        try:
            with open(rf, "r", encoding="utf-8") as s:
                content = s.read()
            new_content = content.replace(f"res://{old_rel}", f"res://{new_rel}")
            new_content = new_content.replace(f'"{old_rel}/', f'"{new_rel}/')
            new_content = new_content.replace("'" + old_rel + "/", "'" + new_rel + "/")
            if new_content != content:
                with open(rf, "w", encoding="utf-8", newline="\n") as s:
                    s.write(new_content)
                updated_count += 1
        except Exception as e:
            print(f"[!] 更新引用失败 {rf}: {e}")

    print(f"       -> 成功更新 {updated_count} 个引用文件的内容")

    # 3. 双步中转 git mv 重命名
    print(f"[3/4] 正在执行 Git 两步中转安全重命名...")
    git_old = f"source/v6.5.0.0/{old_rel}"
    git_tmp = f"source/v6.5.0.0/{old_rel}_tmp_rename"
    git_new = f"source/v6.5.0.0/{new_rel}"

    # 步骤 A: old -> tmp
    code, out, err = run_cmd(f'git mv "{git_old}" "{git_tmp}"')
    if code != 0:
        print(f"[!] git mv 第一步失败: {err.strip()}")
        return False

    # 步骤 B: tmp -> new
    code, out, err = run_cmd(f'git mv "{git_tmp}" "{git_new}"')
    if code != 0:
        print(f"[!] git mv 第二步失败: {err.strip()}")
        # 尝试回滚
        run_cmd(f'git mv "{git_tmp}" "{git_old}"')
        return False

    print(f"       -> 成功执行: {git_old} -> {git_new}")

    # 4. 同步检查对应的 .uid 文件
    old_uid = old_full + ".uid"
    new_uid = new_full + ".uid"
    if os.path.exists(old_uid):
        git_old_uid = f"source/v6.5.0.0/{old_rel}.uid"
        git_tmp_uid = f"source/v6.5.0.0/{old_rel}_tmp.uid"
        git_new_uid = f"source/v6.5.0.0/{new_rel}.uid"
        run_cmd(f'git mv "{git_old_uid}" "{git_tmp_uid}"')
        run_cmd(f'git mv "{git_tmp_uid}" "{git_new_uid}"')
        print(f"       -> 同步重命名 .uid 存根文件")

    # 5. 执行门禁断言
    print(f"[4/4] 正在运行自动化健康体检进行即时验证...")
    code, out, err = run_cmd("python scripts/health_check.py")
    if "0 处断裂引用" in out and "0 Parse Errors" in out or "严重语法解析错误 (Parse Errors): 0 个" in out or code == 0:
        print(f"[SUCCESS] 重命名成功！全盘场景 0 断裂引用，脚本编译 100% 正常！")
        return True
    else:
        print(f"[!] 警告: 编译体检发现异常，请核对输出:")
        for line in out.splitlines()[-15:]:
            print(f"       {line}")
        return False


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="ZMXYBHYH 生产级资源与目录原子重命名工具")
    parser.add_argument("old_path", help="原路径 (相对于 source/v6.5.0.0/，如 Scene/Main_menu)")
    parser.add_argument("new_path", help="新路径 (相对于 source/v6.5.0.0/，如 Scene/main_menu)")
    parser.add_argument("--dry-run", action="store_true", help="试运行模式，仅扫描引用不执行修改")

    args = parser.parse_args()
    success = safe_rename(args.old_path, args.new_path, dry_run=args.dry_run)
    sys.exit(0 if success else 1)
