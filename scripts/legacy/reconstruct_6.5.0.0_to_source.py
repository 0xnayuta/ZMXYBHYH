import os, sys, shutil, time, subprocess, io, struct
from PIL import Image

ROOT = r"G:\source\repos\ZMXYBHYH"
EXT_65 = os.path.join(ROOT, r"extracted\6.5.0.0")
SRC_65 = os.path.join(ROOT, r"source\v6.5.0.0")
GDRE_EXE = os.path.join(ROOT, r"scripts\legacy\gdre\gdre_tools.exe")

def step1_reconstruct_scripts_and_skeleton():
    print("==================================================")
    print("阶段 1: 反编译 6.5.0.0 脚本与工程骨架至 source/v6.5.0.0/")
    print("==================================================")
    os.makedirs(SRC_65, exist_ok=True)
    t0 = time.time()
    
    # 1. 转换 project.binary -> project.godot
    bin_proj = os.path.join(EXT_65, "project.binary")
    if os.path.exists(bin_proj):
        res = subprocess.run([GDRE_EXE, "--headless", f"--bin-to-txt={bin_proj}", f"--output={SRC_65}"], 
                             capture_output=True, text=True)
        print(f"project.godot 转换完成: {os.path.exists(os.path.join(SRC_65, 'project.godot'))}")

    # 2. 批量反编译所有 .gdc (带批次拆分避免 WinError 206 命令行超长)
    folder_to_gdc = {}
    for r, ds, fs in os.walk(EXT_65):
        for f in fs:
            if f.endswith(".gdc"):
                folder_to_gdc.setdefault(r, []).append(f)

    gdc_total = sum(len(v) for v in folder_to_gdc.values())
    print(f"找到 {gdc_total} 个 .gdc 字节码文件，分布于 {len(folder_to_gdc)} 个目录中，开始反编译...")
    
    succ_gdc = 0
    fail_gdc = 0
    for folder, gdc_list in folder_to_gdc.items():
        rel_folder = os.path.relpath(folder, EXT_65)
        target_folder = os.path.join(SRC_65, rel_folder) if rel_folder != "." else SRC_65
        os.makedirs(target_folder, exist_ok=True)
        
        batch_size = 20
        for b_idx in range(0, len(gdc_list), batch_size):
            batch = gdc_list[b_idx : b_idx + batch_size]
            cmd = [GDRE_EXE, "--headless", "--bytecode=4.5.0-stable"]
            for gdc in batch:
                cmd.append(f"--decompile={os.path.join(folder, gdc)}")
                cmd.append(f"--output={target_folder.replace(os.sep, '/')}")
            res = subprocess.run(cmd, cwd=target_folder, capture_output=True, text=True)
            
        for gdc in gdc_list:
            expected = os.path.join(target_folder, gdc[:-4] + ".gd")
            if os.path.exists(expected) and os.path.getsize(expected) > 0:
                succ_gdc += 1
            else:
                fail_gdc += 1
                
    print(f"脚本反编译完成！成功: {succ_gdc:,} 个 | 失败: {fail_gdc} 个\n")
    
    # 3. 同步基础工程骨架
    print("正在同步基础工程文件与场景结构...")
    copied_files = 0
    for r, ds, fs in os.walk(EXT_65):
        rel = os.path.relpath(r, EXT_65)
        for f in fs:
            if f.endswith(".gdc") or f.endswith(".gd.remap") or f == "project.binary":
                continue
            ext = os.path.splitext(f)[1].lower()
            src_f = os.path.join(r, f)
            dst_f = os.path.join(SRC_65, rel, f) if rel != "." else os.path.join(SRC_65, f)
            os.makedirs(os.path.dirname(dst_f), exist_ok=True)
            if ext in (".gdshader", ".json", ".cfg", ".ico", ".import", ".scn", ".tscn", ".res", ".bin", ".ogv", ".translation") or "godot" in rel:
                shutil.copy2(src_f, dst_f)
                copied_files += 1
                
    t1 = time.time()
    print(f"工程骨架同步完成: 复制 {copied_files:,} 个文件 | 阶段耗时: {t1-t0:.2f} 秒\n")

def step2_recover_all_assets():
    print("==================================================")
    print("阶段 2: 批量还原 6.5.0.0 的全量素材 (.ctex -> .png, .mp3)")
    print("==================================================")
    t0 = time.time()
    
    import_files = []
    for r, ds, fs in os.walk(SRC_65):
        if os.sep + "godot" in r: continue
        for f in fs:
            if f.endswith(".import"):
                import_files.append(os.path.join(r, f))
                
    print(f"待还原 .import 素材存根数: {len(import_files):,} 个")
    succ = 0
    fail = 0
    
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
            
        if not cached_rel:
            fail += 1
            continue
            
        cached_full = os.path.join(SRC_65, cached_rel)
        if not os.path.exists(cached_full) or os.path.getsize(cached_full) == 0:
            fail += 1
            continue
            
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
                    except Exception:
                        pass
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
            succ += 1
        else:
            fail += 1
            
        if idx % 2000 == 0 or idx == len(import_files):
            print(f"  素材还原进度: {idx:,} / {len(import_files):,} | 成功: {succ:,} | 跳过: {fail}")
            
    t1 = time.time()
    print(f"\n素材还原完成！耗时: {t1-t0:.2f} 秒 | 成功: {succ:,} 个 | 跳过: {fail} 个\n")

if __name__ == "__main__":
    step1_reconstruct_scripts_and_skeleton()
    step2_recover_all_assets()
