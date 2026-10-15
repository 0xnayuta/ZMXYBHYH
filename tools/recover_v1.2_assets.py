import os, io, struct, time, zstandard
from PIL import Image

def recover_ctex(ctex_path):
    with open(ctex_path, "rb") as f:
        data = f.read()
    if len(data) < 64: return None
    if not data.startswith(b"GST2"): return None
    riff_pos = data.find(b"RIFF", 32, 80)
    if riff_pos < 0: return None
    riff_size = struct.unpack_from("<I", data, riff_pos + 4)[0]
    webp_bytes = data[riff_pos : riff_pos + 8 + riff_size]
    try:
        img = Image.open(io.BytesIO(webp_bytes))
        buf = io.BytesIO()
        img.save(buf, format="PNG")
        return buf.getvalue()
    except Exception:
        return None

def recover_mp3(mp3str_path):
    with open(mp3str_path, "rb") as f:
        data = f.read()
    if len(data) < 350: return None
    for p in range(256, 1024):
        if p + 8 > len(data): break
        if data[p] == 0x1F and data[p+1:p+4] == b"\x00\x00\x00":
            data_len = struct.unpack_from("<I", data, p + 4)[0]
            if 100 < data_len <= len(data) - (p + 8):
                return data[p + 8 : p + 8 + data_len]
    return None

def recover_font(fontdata_path):
    with open(fontdata_path, "rb") as f:
        data = f.read()
    if len(data) < 1024: return None
    pos = 0
    dctx = zstandard.ZstdDecompressor()
    frames = []
    while True:
        idx = data.find(b"\x28\xb5\x2f\xfd", pos)
        if idx < 0: break
        try:
            decomp = dctx.decompress(data[idx:])
            frames.append(decomp)
        except Exception:
            pass
        pos = idx + 4
    if not frames: return None
    full = b"".join(frames)
    for sig in (b"\x00\x01\x00\x00", b"OTTO", b"ttcf", b"true"):
        p = full.find(sig)
        if p >= 0:
            return full[p:]
    return None

def run_recovery(proj_dir):
    print("==================================================")
    print(f"开始全量恢复工程资产: {proj_dir}")
    print("==================================================")
    
    t0 = time.time()
    import_files = []
    for r, ds, fs in os.walk(proj_dir):
        if os.sep + "godot" in r or os.sep + ".godot" in r:
            continue
        for f in fs:
            if f.endswith(".import"):
                import_files.append(os.path.join(r, f))
    
    print(f"扫描到 .import 存根总数: {len(import_files):,} 个")
    
    success_cnt = 0
    fail_cnt = 0
    
    for idx, imp_path in enumerate(import_files, 1):
        target_path = imp_path[:-7] # 去掉 .import
        
        cached_rel_path = None
        try:
            with open(imp_path, "r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("path="):
                        val = line.split("=", 1)[1].strip('"').strip("'").strip()
                        if val.startswith("res://"):
                            cached_rel_path = val[6:].replace("/", os.sep)
                        break
        except Exception:
            pass
        
        if not cached_rel_path:
            fail_cnt += 1
            continue
            
        cached_full_path = os.path.join(proj_dir, cached_rel_path)
        if not os.path.exists(cached_full_path) or os.path.getsize(cached_full_path) == 0:
            fail_cnt += 1
            continue
            
        ext = os.path.splitext(target_path)[1].lower()
        recovered_data = None
        
        if ext in (".png", ".jpg", ".jpeg", ".webp"):
            recovered_data = recover_ctex(cached_full_path)
        elif ext in (".mp3", ".ogg", ".wav"):
            recovered_data = recover_mp3(cached_full_path)
        elif ext in (".ttf", ".otf", ".ttc"):
            recovered_data = recover_font(cached_full_path)
        
        if recovered_data:
            os.makedirs(os.path.dirname(target_path), exist_ok=True)
            with open(target_path, "wb") as out_f:
                out_f.write(recovered_data)
            success_cnt += 1
        else:
            fail_cnt += 1
            
        if idx % 500 == 0 or idx == len(import_files):
            print(f"  处理进度: {idx:,} / {len(import_files):,} | 成功: {success_cnt:,} | 失败/跳过: {fail_cnt}")

    t1 = time.time()
    print(f"\n资产恢复完成！耗时: {t1-t0:.2f} 秒")
    print(f"  成功恢复真实源文件: {success_cnt:,} 个")
    print(f"  失败/跳过/无对应: {fail_cnt} 个")

if __name__ == "__main__":
    p_dir = r"G:\source\repos\ZMXYBHYH\source\v1.2.0.1"
    run_recovery(p_dir)
