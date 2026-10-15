# 造梦青川版 · 造梦八荒 exe 单文件二进制解密方案

> 适用目标：`binaries/6.5.0.0/造梦八荒6.5.exe`，该构建的 PCK 内嵌于同一个 PE 文件。本文记录已验证的块格式、密钥派生算法、静态常量位置、完整解密脚本和逆向过程中的陷阱。  
> **验证结果：** 39,833 个目录条目全部解密，39,833/39,833 个文件 MD5 通过；全量 `--verify-only` 实测 9 秒完成。

## 1. 快速使用

在仓库根目录安装依赖并运行伴随脚本：

```powershell
py -m pip install pycryptodome
py .\tools\zmbh_decrypt.py --verify-only
py .\tools\zmbh_decrypt.py --limit 100 --out .\decrypt-test
py .\tools\zmbh_decrypt.py --out .\extracted\6.5.0.0
```

`--verify-only` 不写出文件，只解析目录、逐块解密并验证 MD5。省略 `--exe` 时，脚本按自身位置解析 `binaries/6.5.0.0/造梦八荒6.5.exe`；省略 `--out` 时，输出到当前工作目录下的 `extracted/`。

完整脚本位于 [`../tools/zmbh_decrypt.py`](../tools/zmbh_decrypt.py)。本文第 4 节提供相同的自包含实现，可单独保存运行。

## 2. 文件与 PCK 布局

### 2.1 PE 与内嵌 PCK

此版本 exe 的 PE 节区中有名为 `pck` 的节区。对该构建，PCK 的**文件偏移**为 `0x4238E00`（十进制 `69,438,976`）；不能把该偏移当作 RVA。

| 字段 | 值 | 含义 |
|---|---:|---|
| exe | `binaries/6.5.0.0/造梦八荒6.5.exe` | 输入的单文件 PE |
| PCK 原始文件偏移 `PCK_OFF` | `0x4238E00` | `pck` 节区的 `PointerToRawData` |
| PCK header `file_base` | `112` (`0x70`) | 文件数据区基点 |
| PCK header `dir_offset` | `2,606,803,736` (`0x9B60AB18`) | 目录 blob 相对 PCK 起点的偏移 |
| 解密目录条目数 | `39,833` | 目录块开头的 `u32` |
| 解密目录明文长度 | `4,046,468` 字节 | 目录块头中的 `u64` |

PCK 头以 `GDPC` 开始，长度为 `file_base=112` 字节。此构建中使用的头字段位于：`PCK_OFF+24`（小端 `u64 file_base`）和 `PCK_OFF+32`（小端 `u64 dir_offset`）。

**绝对偏移公式（经块头与 MD5 验证）：**

```text
目录 blob = PCK_OFF + dir_offset
文件块   = PCK_OFF + file_base + directory_entry.ofs
         = PCK_OFF + 112 + ofs
```

不要对这两个公式混用基点：目录偏移不再加 112；文件条目偏移必须加 `file_base`。

### 2.2 加密块格式

文件块头长 44 字节：

| 相对偏移 | 长度 | 字段 |
|---:|---:|---|
| `+0` | 4 | ASCII `HBXZ` |
| `+4` | 16 | 明文 MD5 |
| `+20` | 8 | 明文长度，小端 `u64` |
| `+28` | 16 | IV |
| `+44` | 向上补齐至 16 字节倍数 | AES-CFB128 密文 |

目录块头比文件块多一个 `u32` 条目数前缀，共 48 字节：

| 相对偏移 | 长度 | 字段 |
|---:|---:|---|
| `+0` | 4 | 条目数，小端 `u32` |
| `+4` | 4 | ASCII `HBXZ` |
| `+8` | 16 | 解密后目录 blob 的 MD5 |
| `+24` | 8 | 目录明文长度，小端 `u64` |
| `+32` | 16 | 目录 IV |
| `+48` | 向上补齐至 16 字节倍数 | AES-CFB128 密文 |

块密文长度为 `ceil(plain_length / 16) * 16`。解密后必须截取到头部记录的明文长度，再计算 MD5。目录块的 `HBXZ` 位于 `+4`，文件块的 `HBXZ` 位于 `+0`。

### 2.3 目录条目格式

目录明文从条目数之后开始，连续包含下列记录：

```text
path_len : u32       # 4 字节对齐后的路径字段长度
path     : byte[]    # UTF-8；长度为 path_len，按第一个 NUL 截断
ofs      : u64
size     : u64
md5      : 16 bytes
flags    : u32
```

本构建实测 39,833 个条目的 `flags` 都是 `1`（`PACK_FILE_ENCRYPTED`）。常见位定义为：bit 0 加密、bit 1 删除标记、bit 2 delta。脚本跳过删除标记；本构建没有删除条目或 delta 条目。

## 3. 密钥派生与解密算法

每个块（包括目录块）都使用其**自身块头中的 IV**派生 AES 密钥。目录密钥与文件密钥不同，但不是随机生成的独立密钥：它们由同一全局 KEY 和不同 IV 确定性派生。

```mermaid
graph LR
  KEY[全局 KEY 32B] --> A[计算 A 32B]
  KEY --> B[计算 B 32B]
  T1T2[T1 / T2 静态表] --> A
  T1T2 --> B
  T1T2 --> C[计算 C 32B]
  IV[当前块 IV 16B] --> D2[D2 = TC XOR IV]
  TC[TC 常量 16B] --> D2
  A --> H[SHA-256 A || B || C || D2]
  B --> H
  C --> H
  D2 --> H
  H --> MIX[按 T1 / T2 重排异或]
  T1T2 --> MIX
  MIX --> AES[AES-256-CFB128 解密]
```

### 3.1 完整公式

对 `i=0..31`：

```text
A[i] = T1[(7*i) & 31] ^ KEY[i]
B[i] = T2[(11*i) & 31] ^ KEY[31-i]
C[i] = T1[i] ^ T2[31-i] ^ ((((i+7) & 0xFF) * 13) & 0xFF)
```

对 `j=0..15`：

```text
D2[j] = TC[j] ^ IV[j]
```

然后：

```text
H = SHA256(A || B || C || D2)   # 输入恰为 112 字节，输出 32 字节
key[k] = T1[(k+9) & 31] ^ T2[(5*k) & 31] ^ H[k]  # k=0..31
```

最终使用 `AES-256-CFB128(key, IV)` 解密密文。PyCryptodome 参数为 `AES.MODE_CFB, segment_size=128`。

### 3.2 此构建的静态常量及其来源

这些是从目标 exe 的原始文件字节读取的偏移（不是 RVA）：

| 常量 | exe 文件偏移 | 长度 | 值 / 用途 |
|---|---:|---:|---|
| `KEY` | `0x3EA5040` | 32 | 全局密钥；在 PCK 前的 PE 部分检出一次 |
| `T1` | `0x395CBA0` | 32 | RVA `0x395D9A0` |
| `T2` | `0x395CBC0` | 32 | RVA `0x395D9C0` |
| `TC` | `0x395CBE0` | 16 | RVA `0x395D9E0`，ASCII `Godot-4.7-zmbh-2` |

```text
KEY = c853751d0bfd824e5df1af202750b6c5389b67dea0873e7f4b39e95529ef863f
T1  = 21844cd70f39a26e7518c390ba4d02ed69f4378b13ae5cd19f4026b87a03e5cc
T2  = f30a925d41ca1788bc642fe1097dd43658af2091cb6a04fe3b8215dc774ea901
TC  = 476f646f742d342e372d7a6d62682d32
```

`T1`、`T2` 同时用于 A/B/C 与最终重混；没有额外的 T3/T4 表。`TC` 的 16 字节正好是 `Godot-4.7-zmbh-2`；derive 函数读取 TC 后续的字节不参与 D2。

### 3.3 已知答案校验向量

下列向量可先用于验证脚本，再处理全量目录：

| 块 | IV | 派生出的 AES key |
|---|---|---|
| 目录块 | `7c7fbb1825d956305ab09e216eddf4be` | `fb5ccf3f875fa41b2a27be0d538f59bec3a5c266656c28c3c877138f42a02359` |
| `project.binary` | `cb39c919af75ae43871ca81cce47e81c` | `d6dbebbc6961ee31b2aab9efbc49c14fc48eb374b7f00f2794092c175bd9f8a5` |

`project.binary` 解密后的前 4 字节为 `ECFG`；目录解密后的 39,833 个条目以及每个文件块的明文 MD5 均通过校验。

## 4. 完整可复用脚本

脚本从目标 exe 的已知文件偏移读取 KEY/T1/T2/TC，不需要手工传密钥或运行调试器。它先解密目录，再按目录条目定位各文件块；`--verify-only` 可做全量校验而不写文件。

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""造梦青川版 · 造梦八荒 exe 单文件解密器。"""
import argparse
import hashlib
import mmap
import os
import struct
import sys
import time
from pathlib import Path
from Crypto.Cipher import AES

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_EXE = REPO_ROOT / "binaries" / "6.5.0.0" / "造梦八荒6.5.exe"
PCK_OFF = 0x4238E00
GLOBAL_KEY_OFF = 0x3EA5040
T1_OFF = 0x395CBA0
T2_OFF = 0x395CBC0
TC_OFF = 0x395CBE0
PACK_FILE_ENCRYPTED = 1 << 0
PACK_FILE_REMOVAL = 1 << 1


def derive_key(iv: bytes, key: bytes, t1: bytes, t2: bytes, tc: bytes) -> bytes:
    a = bytes(t1[(7 * i) & 31] ^ key[i] for i in range(32))
    b = bytes(t2[(11 * i) & 31] ^ key[31 - i] for i in range(32))
    c = bytes(t1[i] ^ t2[31 - i] ^ (((i + 7) & 0xFF) * 13 & 0xFF) for i in range(32))
    d2 = bytes(tc[j] ^ iv[j] for j in range(16))
    h = hashlib.sha256(a + b + c + d2).digest()
    return bytes(t1[(k + 9) & 31] ^ t2[(5 * k) & 31] ^ h[k] for k in range(32))


def decrypt_block(mm, abs_off: int, is_directory: bool, key: bytes, t1: bytes, t2: bytes, tc: bytes):
    prefix = 4 if is_directory else 0
    count = struct.unpack_from("<I", mm, abs_off)[0] if is_directory else None
    if bytes(mm[abs_off + prefix:abs_off + prefix + 4]) != b"HBXZ":
        raise ValueError(f"HBXZ magic 不匹配，偏移 {abs_off:#x}")
    md5_expected = bytes(mm[abs_off + prefix + 4:abs_off + prefix + 20])
    plain_len = struct.unpack_from("<Q", mm, abs_off + prefix + 20)[0]
    iv = bytes(mm[abs_off + prefix + 28:abs_off + prefix + 44])
    ct_len = (plain_len + 15) // 16 * 16
    ct = bytes(mm[abs_off + prefix + 44:abs_off + prefix + 44 + ct_len])
    aes_key = derive_key(iv, key, t1, t2, tc)
    plain = AES.new(aes_key, AES.MODE_CFB, iv=iv, segment_size=128).decrypt(ct)[:plain_len]
    return count, plain, plain_len, iv, hashlib.md5(plain).digest() == md5_expected


def parse_directory(plain: bytes, count: int):
    entries = []
    p = 0
    for _ in range(count):
        path_len = struct.unpack_from("<I", plain, p)[0]
        p += 4
        path = plain[p:p + path_len].split(b"\x00", 1)[0].decode("utf-8", "replace")
        p += path_len
        ofs, size = struct.unpack_from("<QQ", plain, p)
        p += 16
        md5 = bytes(plain[p:p + 16])
        p += 16
        flags = struct.unpack_from("<I", plain, p)[0]
        p += 4
        entries.append((path, ofs, size, md5, flags))
    return entries


def main():
    parser = argparse.ArgumentParser(description="解密造梦八荒 6.5 单文件 exe 中的 PCK")
    parser.add_argument("--exe", type=Path, default=DEFAULT_EXE)
    parser.add_argument("--out", type=Path, default=Path("extracted"))
    parser.add_argument("--limit", type=int, default=0, help="仅处理前 N 个目录条目")
    parser.add_argument("--verify-only", action="store_true", help="全量校验但不写出文件")
    args = parser.parse_args()

    started = time.time()
    with args.exe.open("rb") as fh:
        with mmap.mmap(fh.fileno(), 0, access=mmap.ACCESS_READ) as mm:
            if bytes(mm[PCK_OFF:PCK_OFF + 4]) != b"GDPC":
                raise ValueError("PCK_OFF 未指向 GDPC；exe 版本或 PE 布局不匹配")
            key = bytes(mm[GLOBAL_KEY_OFF:GLOBAL_KEY_OFF + 32])
            t1 = bytes(mm[T1_OFF:T1_OFF + 32])
            t2 = bytes(mm[T2_OFF:T2_OFF + 32])
            tc = bytes(mm[TC_OFF:TC_OFF + 16])
            if len(key) != 32 or len(t1) != 32 or len(t2) != 32 or tc != b"Godot-4.7-zmbh-2":
                raise ValueError("密钥/表/引擎标记不匹配；请确认输入 exe 是目标版本")

            file_base = struct.unpack_from("<Q", mm, PCK_OFF + 24)[0]
            dir_offset = struct.unpack_from("<Q", mm, PCK_OFF + 32)[0]
            dir_abs = PCK_OFF + dir_offset
            count, directory, dir_len, _, dir_ok = decrypt_block(mm, dir_abs, True, key, t1, t2, tc)
            if not dir_ok:
                raise ValueError("目录 MD5 校验失败：输入 exe 或算法常量不匹配")
            entries = parse_directory(directory, count)
            selected = entries[:args.limit] if args.limit else entries
            ok_count = fail_count = removed_count = 0

            for path, ofs, size, entry_md5, flags in selected:
                if flags & PACK_FILE_REMOVAL:
                    removed_count += 1
                    continue
                if flags & (1 << 2):
                    raise NotImplementedError(f"此脚本未实现 delta 条目: {path}")
                abs_off = PCK_OFF + file_base + ofs
                if flags & PACK_FILE_ENCRYPTED:
                    _, plain, plain_len, _, block_ok = decrypt_block(mm, abs_off, False, key, t1, t2, tc)
                    if plain_len != size or not block_ok or hashlib.md5(plain).digest() != entry_md5:
                        fail_count += 1
                        if fail_count <= 5:
                            print(f"MD5/长度校验失败: {path}")
                        continue
                else:
                    plain = bytes(mm[abs_off:abs_off + size])
                    if len(plain) != size or hashlib.md5(plain).digest() != entry_md5:
                        fail_count += 1
                        if fail_count <= 5:
                            print(f"明文条目校验失败: {path}")
                        continue

                ok_count += 1
                if not args.verify_only:
                    # PCK 路径为资源相对路径；拒绝绝对路径和向上跳转。
                    parts = path.replace("\\", "/").split("/")
                    if not parts or any(part in ("", ".", "..") for part in parts):
                        raise ValueError(f"不安全或无效的资源路径: {path!r}")
                    out_path = args.out.joinpath(*parts)
                    out_path.parent.mkdir(parents=True, exist_ok=True)
                    out_path.write_bytes(plain)

    action = "校验" if args.verify_only else "解密"
    print(f"{action}完成: 成功 {ok_count:,}, 失败 {fail_count:,}, 删除条目 {removed_count:,}, "
          f"目录条目 {count:,}, 用时 {time.time() - started:.0f}s")
    return 0 if fail_count == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
```

首次先校验再写盘：

```powershell
py .\docs\zmbh_decrypt.py --exe .\binaries\6.5.0.0\造梦八荒6.5.exe --verify-only
py .\docs\zmbh_decrypt.py --exe .\binaries\6.5.0.0\造梦八荒6.5.exe --limit 100 --out .\decrypt-test
py .\docs\zmbh_decrypt.py --exe .\binaries\6.5.0.0\造梦八荒6.5.exe --out .\extracted\6.5.0.0
```

预期全量校验输出：`目录条目 39,833`、`成功 39,833`、`失败 0`。已验证的伴随实现为 `tools/zmbh_decrypt.py`；用上面动态读取的 KEY/表偏移实现再次全量校验同样得到 39,833/39,833 MD5 通过。

## 5. 逆向复用步骤（其他构建）

上述脚本和偏移是**针对此 exe 构建**的。更新补丁、exe 重打包、引擎变更后，先重新确认 PE/PCK 布局；不能只沿用旧偏移。

### 5.1 先定位 PE 与 PCK

1. 解析 PE 节区表，找 `pck` 节区；取其 `PointerToRawData` 作为 `PCK_OFF`。本构建为 `0x4238E00`。
2. 按小端读取 PCK 头 `PCK_OFF+24` 的 `file_base` 和 `PCK_OFF+32` 的 `dir_offset`。本构建分别为 `112` 和 `2,606,803,736`。
3. 用 `PCK_OFF + dir_offset` 读取目录块，并检查 `[count][HBXZ]`；解密后验证目录 MD5。
4. 文件块用 `PCK_OFF + file_base + ofs` 定位。不要用目录 blob 的偏移公式定位文件块。

### 5.2 从同一次运行捕获派生中间值

本构建 derive 函数文件偏移为 `0x2CDEFB0`、RVA 为 `0x2CDFBB0`。在确认新版本函数地址后：

1. 在 derive 入口附近（本构建 RVA `0x2CDFBD9`）检查参数：`rdx+8` 指向 32 字节全局 KEY 数据；`r8+8` 指向 16 字节 IV 数据。
2. 在 SHA-256 调用前（本构建 RVA `0x2CDFE3F`）读取 `[rsp+0x70 : rsp+0xE0]`，恰为 112 字节 `A || B || C || D2`。
3. 在同一轮采样中记录 IV 与 112 字节输入。由此直接得到 `A=input[0:32]`、`B=input[32:64]`、`C=input[64:96]`、`D2=input[96:112]`；验证 `D2 ^ IV == TC`。
4. 用目录 IV 与已知目录 MD5、文件 IV 与对应文件 MD5 做交叉验证，再跑完整目录。
5. 本构建的全局 KEY 在 PE 原始文件偏移 `0x3EA5040`，RVA `0x3EA6040`；静态表 T1/T2/TC 的原始文件偏移分别为 `0x395CBA0`、`0x395CBC0`、`0x395CBE0`。新构建先在运行时确认内容，再更新脚本偏移。

如需设置软件断点，Windows x64 上 `int3` 触发时 RIP 已指向断点后一字节。读取原始指令、恢复断点和计算模块基址时，必须按 `RIP = breakpoint_address + 1` 处理。

## 6. 踩坑记录与注意事项

1. **不要把目录密钥当作所有文件的密钥。** 目录 IV 和各文件 IV 不同；每个块都要调用 KDF。初期尝试用同一个 key 解文件，100 个样本 MD5 全失败。
2. **最终并非“每文件任意随机密钥”。** 所有块共用同一个全局 KEY 和 T1/T2/TC，按各自 IV 确定性派生。找到 KDF 后可以离线处理全部 39,833 个条目。
3. **文件头和目录头不是同一布局。** 目录多 4 字节计数前缀；目录 `HBXZ` 在 `+4`，文件 `HBXZ` 在 `+0`。把文件头的 44 字节布局直接套到目录会造成所有字段错位。
4. **区分文件偏移、RVA、运行时 VA。** `.text` 本构建 `VirtualAddress=0x1000`、`PointerToRawData=0x400`，所以该节内 `RVA = file_offset + 0xC00`。`.rdata`、`.data` 的换算不同，必须按各自节区映射计算，不能把整个 exe 当作 RVA=文件偏移。
5. **表地址曾多次算错。** derive 内部实际 `r8` 在 Phase 1 实测等于模块基址；T1/T2 位于 RVA `0x395D9A0/0x395D9C0`，TC 位于 RVA `0x395D9E0`。不要把 `0x395D9A0 + 0x1000` 错算成 `0x396D9A0`；实际算术结果是 `0x395E9A0`，而那是另一段字符串，不是 T1。
6. **`r12` 的更新顺序影响 B 索引。** `mov rax,r12` 先于 `add r12,0xB`，因此第 `i` 次迭代读 `T2[(11*i)&31]`，不是 `T2[(11*(i+1))&31]`。后一种只会在部分索引上造成迷惑性的局部匹配。
7. **CFB 参数必须显式为 128 位 segment。** 使用 `AES.MODE_CFB` 默认 segment size 会解出错误数据；必须写 `segment_size=128`。
8. **密文读取长度按块补齐，明文按头部长度截断。** 读取 `(length+15)//16*16` 字节，解密后只保留 `length` 字节，再做 MD5。
9. **MD5 是完成条件，不是 magic 命中。** `GDSC`、`ECFG`、`[remap]` 等 magic 适合内存候选筛选；正式解密必须验证块头 MD5。最终全量结果为 39,833/39,833 通过。
10. **运行时表 dump 受 int3 RIP 偏移影响。** 命中后 RIP=断点地址+1；若用 RIP 反推模块基址，必须减去 1，否则 dump 起点偏一字节，字符串会从 `Godot...` 变成 `odot...`。
11. **不要在被 `head` 截断的管道里跑长任务。** 输出端关闭会导致脚本提前收到 broken pipe，可能来不及写结果文件。将完整 stdout/stderr 重定向到日志文件。
12. **一个函数中存在多个条件分支/调用点。** 在某个调用点之后设断点可能因分支未执行而零命中。更稳妥的采样方式是在 derive 入口与哈希调用前分别下断点，并在同一轮运行中配对。
13. **调试器字段名避免复用。** Windows `EXCEPTION_RECORD` 变量与自建字典都叫 `rec` 曾引发 `object does not support item assignment`；分别命名为 `exception_record`、`sample`。
14. **脚本运行路径与 PCK 文件路径分开。** exe 默认相对脚本目录定位；输出目录相对当前工作目录定位。先用 `--verify-only`，再选择输出目录。
15. **当前 PCK 目录中的 flags 全为 1。** 脚本仍处理删除标记，并对未实现的 delta 标记显式报错；不要在未验证格式的其它构建上默默跳过未知 flags。

## 7. 最终验证记录

- PCK magic：`GDPC`；内嵌 PCK 节区 raw offset：`0x4238E00`。
- 目录：39,833 条目，4,046,468 字节；目录 MD5 通过。
- 解密器动态从 exe 原始偏移读取全局 KEY 和三张表，全量 `--verify-only`：**39,833 成功、0 失败、0 删除条目，9 秒**。
- 解密输出抽查：`.gdc` 以 `GDSC` 开始；`project.binary` 以 `ECFG` 开始；`.remap` 为 `[remap]` 文本；Spine GDExtension 配置可读。
- 全量输出目录 `extracted/6.5.0.0/`：39,833 个文件，约 2.5 GB。

以上偏移与常量严格对应 `binaries/6.5.0.0/造梦八荒6.5.exe`。其它版本必须重新解析 PE/PCK 头并重新验证密钥派生，不能只复制偏移或校验样例。
