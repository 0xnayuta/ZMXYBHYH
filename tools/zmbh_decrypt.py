#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
造梦青川版 · 造梦八荒 exe 单文件解密器（最终版）

适用目标 : 6.5.0.0\\造梦八荒6.5.exe  (引擎标识 Godot-4.7-zmbh-2)
依赖     : pycryptodome (pip install pycryptodome)

用法:
    python zmbh_decrypt.py --out <输出目录>              # 全量解密
    python zmbh_decrypt.py --limit 100 --out <目录>      # 只解前 100 个
    python zmbh_decrypt.py --verify-only                 # 只做校验，不写盘
"""
import argparse
import hashlib
import mmap
import os
import struct
import sys
import time

from Crypto.Cipher import AES

# ==================== 版本相关常量 ====================
# 换版本时必须重新捕获，见配套文档《逆向方法与复用指南》一节
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EXE_PATH = os.path.join(REPO_ROOT, "binaries", "6.5.0.0", "造梦八荒6.5.exe")
PCK_OFF = 0x4238E00  # 69,438,976  pck 数据起点（PE 节区 "pck" 的 Raw 偏移）

GLOBAL_KEY_OFF = 0x3EA5040  # 全局密钥在 exe 中的原始文件偏移
T1_OFF = 0x395CBA0          # RVA 0x395D9A0
T2_OFF = 0x395CBC0          # RVA 0x395D9C0
TC_OFF = 0x395CBE0          # RVA 0x395D9E0，仅使用前 16 字节
GLOBAL_KEY = T1 = T2 = TC = b""

PACK_FILE_ENCRYPTED = 1 << 0
PACK_FILE_REMOVAL = 1 << 1

_sha256 = hashlib.sha256
_md5 = hashlib.md5




# ==================== 核心算法 ====================
def derive_key(iv: bytes) -> bytes:
    """由块头 IV 派生该块（目录或文件）的 32 字节 AES-256 密钥（完整公式版）。"""
    a = bytes(T1[(7 * i) & 31] ^ GLOBAL_KEY[i] for i in range(32))
    b = bytes(T2[(11 * i) & 31] ^ GLOBAL_KEY[31 - i] for i in range(32))
    c = bytes(T1[i] ^ T2[31 - i] ^ (((i + 7) & 0xFF) * 13 & 0xFF) for i in range(32))
    d2 = bytes(TC[j] ^ iv[j] for j in range(16))
    h = _sha256(a + b + c + d2).digest()
    return bytes(T1[(k + 9) & 31] ^ T2[(5 * k) & 31] ^ h[k] for k in range(32))


def aes_cfb128_decrypt(key: bytes, iv: bytes, ct: bytes, length: int) -> bytes:
    return AES.new(key, AES.MODE_CFB, iv=iv, segment_size=128).decrypt(ct)[:length]


def decrypt_block(mm, abs_off: int, is_dir: bool):
    """解密一个块，返回 (明文, md5是否通过)。

    文件块头 44B: [HBXZ][md5:16][len:8][iv:16]
    目录块头 48B: [count:4][HBXZ][md5:16][len:8][iv:16]
    """
    if is_dir:
        count = struct.unpack_from("<I", mm, abs_off)[0]
        hdr = 4
    else:
        count = None
        hdr = 0
    magic = bytes(mm[abs_off + hdr: abs_off + hdr + 4])
    if magic != b"HBXZ":
        raise ValueError(f"非 HBXZ 块 @ {abs_off:#x}: {magic!r}")
    md5_expect = bytes(mm[abs_off + hdr + 4: abs_off + hdr + 20])
    plain_len = struct.unpack_from("<Q", mm, abs_off + hdr + 20)[0]
    iv = bytes(mm[abs_off + hdr + 28: abs_off + hdr + 44])
    ct_len = (plain_len + 15) // 16 * 16
    ct = bytes(mm[abs_off + hdr + 44: abs_off + hdr + 44 + ct_len])
    key = derive_key(iv)
    plain = aes_cfb128_decrypt(key, iv, ct, plain_len)
    return count, plain, plain_len, iv, (_md5(plain).digest() == md5_expect)


def parse_dir(plain: bytes, count: int):
    """解析目录明文 → [(path, ofs, size, md5, flags)]"""
    entries = []
    p = 0
    for _ in range(count):
        sl = struct.unpack_from("<I", plain, p)[0]; p += 4
        path = plain[p:p + sl].split(b"\x00", 1)[0].decode("utf-8", "replace"); p += sl
        ofs, size = struct.unpack_from("<QQ", plain, p); p += 16
        fmd5 = bytes(plain[p:p + 16]); p += 16
        flags = struct.unpack_from("<I", plain, p)[0]; p += 4
        entries.append((path, ofs, size, fmd5, flags))
    return entries


# ==================== 主流程 ====================
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--exe", default=EXE_PATH)
    ap.add_argument("--out", default="extracted")
    ap.add_argument("--limit", type=int, default=0)
    ap.add_argument("--verify-only", action="store_true")
    args = ap.parse_args()

    fh = open(args.exe, "rb")
    mm = mmap.mmap(fh.fileno(), 0, access=mmap.ACCESS_READ)
    global GLOBAL_KEY, T1, T2, TC
    GLOBAL_KEY = bytes(mm[GLOBAL_KEY_OFF:GLOBAL_KEY_OFF + 32])
    T1 = bytes(mm[T1_OFF:T1_OFF + 32])
    T2 = bytes(mm[T2_OFF:T2_OFF + 32])
    TC = bytes(mm[TC_OFF:TC_OFF + 16])
    if not all((len(GLOBAL_KEY) == 32, len(T1) == 32, len(T2) == 32, len(TC) == 16)):
        raise ValueError("exe 中的密钥或派生表读取不完整")
    t0 = time.time()

    # ---- 1) pck 头 ----
    if bytes(mm[PCK_OFF:PCK_OFF + 4]) != b"GDPC":
        print("未找到 GDPC pck 头 —— 检查 PCK_OFF"); return 2
    file_base = struct.unpack_from("<Q", mm, PCK_OFF + 24)[0]
    dir_offset = struct.unpack_from("<Q", mm, PCK_OFF + 32)[0]
    print(f"[1] pck: file_base={file_base}  dir_offset={dir_offset:,}")

    # ---- 2) 目录 ----
    count, dplain, dlen, div, ok = decrypt_block(mm, PCK_OFF + dir_offset, True)
    print(f"[2] 目录: {count:,} 条目 / {dlen:,} 字节  MD5={'OK' if ok else 'FAIL'}")
    if not ok:
        return 1
    entries = parse_dir(dplain, count)

    # ---- 3) 文件 ----
    todo = entries[:args.limit] if args.limit else entries
    ok_n = fail_n = skip_n = 0
    for idx, (path, ofs, size, fmd5, flags) in enumerate(todo):
        if flags & PACK_FILE_REMOVAL:
            skip_n += 1
            continue
        abs_off = PCK_OFF + file_base + ofs
        if flags & PACK_FILE_ENCRYPTED:
            _, plain, plen, _, fok = decrypt_block(mm, abs_off, False)
            if not fok:
                fail_n += 1
                if fail_n <= 5:
                    print(f"    [MD5失败] {path}")
                continue
            ok_n += 1
            if not args.verify_only:
                outp = os.path.join(args.out, *path.split("/"))
                os.makedirs(os.path.dirname(outp) or args.out, exist_ok=True)
                with open(outp, "wb") as w:
                    w.write(plain)
        else:
            # 未加密文件：直接复制（理论上本版本不存在）
            ok_n += 1
            if not args.verify_only:
                outp = os.path.join(args.out, *path.split("/"))
                os.makedirs(os.path.dirname(outp) or args.out, exist_ok=True)
                with open(outp, "wb") as w:
                    w.write(bytes(mm[abs_off:abs_off + size]))
    mm.close(); fh.close()
    mode = "校验" if args.verify_only else "解密"
    print(f"[3] {mode}完成: 成功 {ok_n:,} / 失败 {fail_n:,} / 跳过 {skip_n:,}  用时 {time.time()-t0:.0f}s")
    return 0 if fail_n == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
