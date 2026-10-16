import os, struct, time

def unpack_1332(exe_path, out_dir):
    pck_off = 68_119_040
    file_base = 1_083_056
    os.makedirs(out_dir, exist_ok=True)

    with open(exe_path, "rb") as f:
        f.seek(pck_off)
        head = f.read(100)
        magic, fmt, vmaj, vmin, vpat, flags = struct.unpack_from("<IIIIII", head, 0)
        assert magic == 0x43504447, "PCK 魔数错误"
        file_count = struct.unpack_from("<I", head, 96)[0]
        print(f"PCK 头解析成功: Godot {vmaj}.{vmin}.{vpat}, 文件总数: {file_count:,}")
        
        # 11466 个条目目录区约 1.2 MB，预读 4 MB 绝对足够
        dir_buf = f.read(4 * 1024 * 1024)
        p = 0
        entries = []
        for _ in range(file_count):
            plen = struct.unpack_from("<I", dir_buf, p)[0]; p += 4
            name_raw = dir_buf[p:p+plen]; p += plen
            p += (-plen) % 4
            off, size = struct.unpack_from("<QQ", dir_buf, p); p += 16
            md5 = dir_buf[p:p+16]; p += 16
            fl = struct.unpack_from("<I", dir_buf, p)[0]; p += 4
            name = name_raw.rstrip(b'\0').decode('utf-8', 'replace')
            entries.append((name, off, size))

    print(f"成功解析 {len(entries)} 个文件条目，开始解包到: {out_dir}")

    t0 = time.time()
    extracted_count = 0
    total_bytes = 0

    with open(exe_path, "rb") as f:
        for name, off, size in entries:
            clean_name = name
            if clean_name.startswith("res://"):
                clean_name = clean_name[6:]
            clean_name = clean_name.replace("/", os.sep)
            dest_path = os.path.join(out_dir, clean_name)
            os.makedirs(os.path.dirname(dest_path), exist_ok=True)
            
            f.seek(pck_off + file_base + off)
            data = f.read(size)
            with open(dest_path, "wb") as out_f:
                out_f.write(data)
            
            extracted_count += 1
            total_bytes += size
            if extracted_count % 2000 == 0:
                print(f"  已解包: {extracted_count:,} / {len(entries):,} ({total_bytes/1e6:.1f} MB)")

    t1 = time.time()
    print(f"解包完成！总耗时: {t1-t0:.2f} 秒，成功提取 {extracted_count:,} 个文件，共 {total_bytes/1e6:.1f} MB。")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="ZMXYBHYH 1.3.3.2 离线资源提取工具")
    parser.add_argument("--exe", default=os.environ.get("GAME_EXE_13", r"binaries/1.3.3.2/八荒湮隳1.3.3.2.exe"), help="输入可执行文件路径")
    parser.add_argument("--out", default=os.environ.get("EXTRACT_OUT_13", r"extracted/1.3.3.2"), help="输出目录路径")
    args = parser.parse_args()
    if not os.path.exists(args.exe):
        print(f"[!] 错误: 输入目标不存在 ({args.exe})，请使用 --exe 指定有效路径")
        exit(1)
    unpack_1332(args.exe, args.out)
