import os, sys, subprocess, time, io, struct, zstandard
from PIL import Image

gdre_exe = r"G:\source\repos\ZMXYBHYH\tools\gdre\gdre_tools.exe"
target_dir = r"G:\source\repos\ZMXYBHYH\extracted\1.3.3.2"

def decompile_all_gdcs():
    print("==================================================")
    print("1. 批量反编译 1.3.3.2 的 GDScript 字节码 (.gdc -> .gd)")
    print("==================================================")
    
    # 按目录分组 .gdc
    folder_to_files = {}
    total_gdc = 0
    for r, ds, fs in os.walk(target_dir):
        for f in fs:
            if f.endswith(".gdc"):
                folder_to_files.setdefault(r, []).append(f)
                total_gdc += 1
                
    print(f"找到 {total_gdc} 个 .gdc 文件，分布在 {len(folder_to_files)} 个目录中。")
    t0 = time.time()
    success = 0
    fail = 0
    
    for folder, gdc_list in folder_to_files.items():
        cmd = [gdre_exe, "--headless", "--bytecode=4.3.0-stable"]
        for gdc in gdc_list:
            cmd.append(f"--decompile={gdc}")
            
        res = subprocess.run(cmd, cwd=folder, capture_output=True, text=True)
        for gdc in gdc_list:
            expected = os.path.join(folder, gdc[:-4] + ".gd")
            if os.path.exists(expected) and os.path.getsize(expected) > 0:
                success += 1
            else:
                fail += 1
                
    t1 = time.time()
    print(f"反编译完成！耗时: {t1-t0:.2f} 秒 | 成功: {success:,} 个 | 失败: {fail} 个\n")

def recover_assets_in_1332():
    print("==================================================")
    print("2. 批量还原 1.3.3.2 的贴图与音频资产 (.ctex -> .png)")
    print("==================================================")
    
    t0 = time.time()
    import_files = []
    for r, ds, fs in os.walk(target_dir):
        if os.sep + "godot" in r: continue
        for f in fs:
            if f.endswith(".import"):
                import_files.append(os.path.join(r, f))
                
    print(f"找到 .import 存根: {len(import_files):,} 个")
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
            
        cached_full = os.path.join(target_dir, cached_rel)
        if not os.path.exists(cached_full) or os.path.getsize(cached_full) == 0:
            fail += 1
            continue
            
        ext = os.path.splitext(target_path)[1].lower()
        data = None
        if ext in (".png", ".jpg", ".webp"):
            with open(cached_full, "rb") as f:
                raw = f.read()
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
            with open(cached_full, "rb") as f:
                raw = f.read()
            for p in range(256, 1024):
                if p + 8 > len(raw): break
                if raw[p] == 0x1F and raw[p+1:p+4] == b"\x00\x00\x00":
                    d_len = struct.unpack_from("<I", raw, p + 4)[0]
                    if 100 < d_len <= len(raw) - (p + 8):
                        data = raw[p + 8 : p + 8 + d_len]
                        break
                        
        if data:
            os.makedirs(os.path.dirname(target_path), exist_ok=True)
            with open(target_path, "wb") as out_f:
                out_f.write(data)
            succ += 1
        else:
            fail += 1
            
        if idx % 1000 == 0 or idx == len(import_files):
            print(f"  资产还原进度: {idx:,} / {len(import_files):,} | 成功: {succ:,} | 跳过: {fail}")
            
    t1 = time.time()
    print(f"资产还原完成！耗时: {t1-t0:.2f} 秒 | 成功: {succ:,} 个 | 跳过: {fail} 个\n")

if __name__ == "__main__":
    decompile_all_gdcs()
    recover_assets_in_1332()
