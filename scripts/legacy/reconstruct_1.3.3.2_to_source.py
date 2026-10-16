import os, sys, shutil, time, subprocess, io, struct, zstandard
from PIL import Image

ROOT = r"G:\source\repos\ZMXYBHYH"
EXE_13 = os.path.join(ROOT, r"binaries\1.3.3.2\八荒湮隳1.3.3.2.exe")
EXT_13 = os.path.join(ROOT, r"extracted\1.3.3.2")
SRC_13 = os.path.join(ROOT, r"source\v1.3.3.2")
GDRE_EXE = os.path.join(ROOT, r"scripts\legacy\gdre\gdre_tools.exe")

def step1_reset_extracted():
    print("==================================================")
    print("步骤 1: 还原纯净的解包原件区 (extracted/1.3.3.2/)")
    print("==================================================")
    if os.path.exists(EXT_13):
        shutil.rmtree(EXT_13)
    os.makedirs(EXT_13, exist_ok=True)
    
    pck_off = 68_119_040
    file_base = 1_083_056
    with open(EXE_13, "rb") as f:
        f.seek(pck_off)
        head = f.read(100)
        magic, fmt, vmaj, vmin, vpat, flags = struct.unpack_from("<IIIIII", head, 0)
        file_count = struct.unpack_from("<I", head, 96)[0]
        dir_buf = f.read(4 * 1024 * 1024)
        p = 0
        entries = []
        for _ in range(file_count):
            plen = struct.unpack_from("<I", dir_buf, p)[0]; p += 4
            name_raw = dir_buf[p:p+plen]; p += plen
            p += (-plen) % 4
            off, size = struct.unpack_from("<QQ", dir_buf, p); p += 16
            p += 16; p += 4
            name = name_raw.rstrip(b'\0').decode('utf-8', 'replace')
            entries.append((name, off, size))
            
    with open(EXE_13, "rb") as f:
        for name, off, size in entries:
            clean = name[6:] if name.startswith("res://") else name
            clean = clean.replace("/", os.sep)
            dest = os.path.join(EXT_13, clean)
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            f.seek(pck_off + file_base + off)
            with open(dest, "wb") as out_f:
                out_f.write(f.read(size))
    
    # 验证纯净度: 不应存在任何 .gd 或 .png (除了原生内置的极少数)
    gd_cnt = sum(1 for r, _, fs in os.walk(EXT_13) for f in fs if f.endswith(".gd"))
    gdc_cnt = sum(1 for r, _, fs in os.walk(EXT_13) for f in fs if f.endswith(".gdc"))
    print(f"解包区纯净度校验: .gdc 编译字节码 {gdc_cnt} 个 | 反编译 .gd 源码 {gd_cnt} 个\n")

def step2_reconstruct_to_source():
    print("==================================================")
    print("步骤 2: 将反编译源码与素材正位输出至 source/v1.3.3.2/")
    print("==================================================")
    if os.path.exists(SRC_13):
        shutil.rmtree(SRC_13)
    os.makedirs(SRC_13, exist_ok=True)
    
    t0 = time.time()
    
    # 1. 反编译 project.binary -> source/v1.3.3.2/project.godot
    bin_proj = os.path.join(EXT_13, "project.binary")
    if os.path.exists(bin_proj):
        res = subprocess.run([GDRE_EXE, "--headless", f"--bin-to-txt={bin_proj}", f"--output={SRC_13}"], capture_output=True, text=True)
        print(f"project.godot 反编译完成: {os.path.exists(os.path.join(SRC_13, 'project.godot'))}")
        
    # 2. 反编译所有 .gdc -> .gd 写到 source/v1.3.3.2/ 对应目录
    folder_to_gdc = {}
    for r, ds, fs in os.walk(EXT_13):
        for f in fs:
            if f.endswith(".gdc"):
                folder_to_gdc.setdefault(r, []).append(f)
                
    gdc_total = sum(len(v) for v in folder_to_gdc.values())
    print(f"开始反编译 {gdc_total} 个 .gdc 字节码到 source/v1.3.3.2/ ...")
    succ_gdc = 0
    for folder, gdc_list in folder_to_gdc.items():
        rel_folder = os.path.relpath(folder, EXT_13)
        target_folder = os.path.join(SRC_13, rel_folder) if rel_folder != "." else SRC_13
        os.makedirs(target_folder, exist_ok=True)
        
        cmd = [GDRE_EXE, "--headless", "--bytecode=4.3.0-stable"]
        for gdc in gdc_list:
            cmd.append(f"--decompile={os.path.join(folder, gdc)}")
            cmd.append(f"--output={target_folder.replace(os.sep, '/')}")
            
        res = subprocess.run(cmd, cwd=target_folder, capture_output=True, text=True)
        for gdc in gdc_list:
            expected = os.path.join(target_folder, gdc[:-4] + ".gd")
            if os.path.exists(expected) and os.path.getsize(expected) > 0:
                succ_gdc += 1
                
    print(f"源码反编译完成: 成功 {succ_gdc} / {gdc_total} 个 .gd 脚本")
    
    # 3. 复制工程结构 (Shader, addons, Scene, .import 存根, 基础 json/cfg/ico 等)
    print("正在同步工程骨架与基础资源...")
    for r, ds, fs in os.walk(EXT_13):
        rel = os.path.relpath(r, EXT_13)
        # 忽略编译态临时件
        for f in fs:
            if f.endswith(".gdc") or f.endswith(".gd.remap") or f == "project.binary":
                continue
            ext = os.path.splitext(f)[1].lower()
            src_f = os.path.join(r, f)
            dst_f = os.path.join(SRC_13, rel, f) if rel != "." else os.path.join(SRC_13, f)
            os.makedirs(os.path.dirname(dst_f), exist_ok=True)
            # 基础文件与场景、存根、缓存文件直接同步
            if ext in (".gdshader", ".json", ".cfg", ".ico", ".import", ".scn", ".tscn", ".res", ".bin") or "godot" in rel:
                shutil.copy2(src_f, dst_f)
                
    # 4. 批量还原素材 (.ctex -> .png, .mp3str -> .mp3, .fontdata -> .ttf)
    print("开始全量无损还原素材源文件至 source/v1.3.3.2/ ...")
    succ_asset = 0
    import_files = []
    for r, ds, fs in os.walk(SRC_13):
        if os.sep + "godot" in r: continue
        for f in fs:
            if f.endswith(".import"):
                import_files.append(os.path.join(r, f))
                
    for idx, imp_path in enumerate(import_files, 1):
        target_path = imp_path[:-7]
        cached_rel = None
        try:
            with open(imp_path, "r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    if line.strip().startswith("path="):
                        val = line.strip().split("=", 1)[1].strip('"\' \r\n')
                        if val.startswith("res://"):
                            cached_rel = val[6:].replace("/", os.sep)
                        break
        except Exception:
            pass
        if not cached_rel: continue
        cached_full = os.path.join(SRC_13, cached_rel)
        if not os.path.exists(cached_full) or os.path.getsize(cached_full) == 0: continue
        
        ext = os.path.splitext(target_path)[1].lower()
        data = None
        if ext in (".png", ".jpg", ".webp"):
            with open(cached_full, "rb") as f: raw = f.read()
            if len(raw) > 64 and raw.startswith(b"GST2"):
                riff_pos = raw.find(b"RIFF", 32, 80)
                if riff_pos >= 0:
                    riff_sz = struct.unpack_from("<I", raw, riff_pos + 4)[0]
                    webp_b = raw[riff_pos : riff_pos + 8 + riff_sz]
                    try:
                        img = Image.open(io.BytesIO(webp_b))
                        buf = io.BytesIO()
                        img.save(buf, format="PNG")
                        data = buf.getvalue()
                    except Exception: pass
        elif ext in (".mp3", ".ogg", ".wav"):
            with open(cached_full, "rb") as f: raw = f.read()
            for p in range(256, 1024):
                if p + 8 > len(raw): break
                if raw[p] == 0x1F and raw[p+1:p+4] == b"\\x00\\x00\\x00":
                    d_len = struct.unpack_from("<I", raw, p + 4)[0]
                    if 100 < d_len <= len(raw) - (p + 8):
                        data = raw[p + 8 : p + 8 + d_len]
                        break
        if data:
            with open(target_path, "wb") as out_f:
                out_f.write(data)
            succ_asset += 1
            
        if idx % 1000 == 0 or idx == len(import_files):
            print(f"  素材还原进度: {idx:,} / {len(import_files):,} | 成功: {succ_asset:,}")
            
    t1 = time.time()
    print(f"\nsource/v1.3.3.2 重构正位完成！耗时: {t1-t0:.2f} 秒")
    print(f"  源码文件 (.gd): {succ_gdc} 个")
    print(f"  真实素材源文件: {succ_asset} 个\n")

if __name__ == "__main__":
    # 动态把 unpack 函数注入
    sys.path.append(os.path.join(ROOT, "scripts", "legacy"))
    step1_reset_extracted()
    step2_reconstruct_to_source()
