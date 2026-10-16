import os, sys, shutil, subprocess, time

ROOT = r"G:\source\repos\ZMXYBHYH"
EXT_DIR = os.path.join(ROOT, r"extracted\6.5.0.0")
SRC_DIR = os.path.join(ROOT, r"source\v6.5.0.0")
GDRE_EXE = os.path.join(ROOT, r"scripts\legacy\gdre\gdre_tools.exe")
TMP_OUT = os.path.join(ROOT, r"scripts\legacy\converted_scenes")

def restore_scenes_and_resources():
    print("==================================================")
    print("开始批量反编译并归位 6.5.0.0 场景 (.tscn) 与资源 (.tres)")
    print("==================================================")
    
    t0 = time.time()
    os.makedirs(TMP_OUT, exist_ok=True)
    
    # 1. 扫描所有 .tscn.remap 与 .tres.remap
    mappings = [] # (exported_full_path, target_full_path)
    exported_set = set()
    
    for r, ds, fs in os.walk(EXT_DIR):
        if os.sep + "godot" in r: continue
        for f in fs:
            if f.endswith((".tscn.remap", ".tres.remap")):
                remap_p = os.path.join(r, f)
                rel_p = os.path.relpath(remap_p, EXT_DIR)
                target_rel = rel_p[:-6] # 去掉 .remap
                target_full = os.path.join(SRC_DIR, target_rel)
                
                # 读取引用的 exported 路径
                exp_rel = None
                with open(remap_p, "r", encoding="utf-8", errors="ignore") as fh:
                    for line in fh:
                        if line.strip().startswith("path="):
                            exp_rel = line.strip().split("=", 1)[1].strip('"\' \r\n')
                            if exp_rel.startswith("res://"):
                                exp_rel = exp_rel[6:]
                            break
                            
                if exp_rel:
                    exp_full = os.path.join(EXT_DIR, exp_rel.replace("/", os.sep))
                    if os.path.exists(exp_full):
                        mappings.append((exp_full, target_full))
                        exported_set.add(exp_full)
                        
    print(f"找到有效场景/资源 remap 映射: {len(mappings):,} 个")
    print(f"涉及独立二进制导出文件: {len(exported_set):,} 个")
    
    # 2. 批量将二进制导出文件转为文本
    exported_list = sorted(list(exported_set))
    batch_size = 60
    total_batches = (len(exported_list) + batch_size - 1) // batch_size
    
    print(f"开始调用 GDRETools 进行批量格式反编译 (共 {total_batches} 批)...")
    for b_idx in range(total_batches):
        batch = exported_list[b_idx * batch_size : (b_idx + 1) * batch_size]
        args = [GDRE_EXE, "--headless", f"--output={TMP_OUT}"] + [f"--bin-to-txt={f}" for f in batch]
        subprocess.run(args, capture_output=True, text=True, cwd=ROOT)
        if (b_idx + 1) % 5 == 0 or (b_idx + 1) == total_batches:
            print(f"  进度: 批次 {b_idx + 1} / {total_batches} 完成")
            
    # 3. 将转换出来的文本文件精准复制到目标路径
    print("正在精准写入目标工程 source/v6.5.0.0/ ...")
    succ_cnt = 0
    fail_cnt = 0
    for exp_full, target_full in mappings:
        base_fn = os.path.basename(exp_full)
        conv_p = os.path.join(TMP_OUT, base_fn)
        if os.path.exists(conv_p):
            os.makedirs(os.path.dirname(target_full), exist_ok=True)
            # 复制并重命名
            shutil.copy2(conv_p, target_full)
            succ_cnt += 1
        else:
            fail_cnt += 1
            
    # 4. 清理临时转换目录
    shutil.rmtree(TMP_OUT, ignore_errors=True)
    
    t1 = time.time()
    print(f"\n场景与资源归位完成！耗时: {t1-t0:.2f} 秒")
    print(f"  成功归位: {succ_cnt:,} 个")
    print(f"  未转换成功: {fail_cnt} 个")
    
    # 核心标志性验证
    test_load_scene = os.path.join(SRC_DIR, r"Scene\OtherScene\load_scene.tscn")
    print(f"验证 load_scene.tscn: 存在={os.path.exists(test_load_scene)}, 大小={os.path.getsize(test_load_scene) if os.path.exists(test_load_scene) else 0:,} B")

if __name__ == "__main__":
    restore_scenes_and_resources()
