# ZMXYBHYH 全工程字面量契约诊断审计报告 (Phase 8-1)

> 生成时间: 2026-10-17 16:39:12  
> 审计对象: `G:\source\repos\ZMXYBHYH\source\v6.5.0.0`  
> 扫描耗时: `4.60 秒`（指标要求 ≤ 30 秒）  
> 覆盖资产: 脚本 `722 个` / 场景 `1132 个`  

---

## 一、五大字面量契约健康看板

| 契约类别 (Category) | 严重错误 (ERROR) | 告警/建议 (WARNING) | 待收敛 (INFO) | 合计条目 | 健康状态 |
|:---|:---:|:---:|:---:|:---:|:---:|
| **1. 资源路径契约 (Resource Path)** | **0** | 157 | 0 | **157** | 🟡 需关注 |
| **2. 节点路径契约 (Node Path)** | **0** | 0 | 0 | **0** | 🟢 契约完好 |
| **3. 动态反射契约 (Reflection)** | **0** | 0 | 13 | **13** | 🟢 契约完好 |
| **4. 动画轨道契约 (Anim Track)** | **0** | 0 | 0 | **0** | 🟢 契约完好 |
| **5. 中文字典键契约 (Dict Key)** | **0** | 872 | 925 | **1797** | 🟡 需关注 |

**总计缺陷与待收敛项**: `1967 个`（ERROR: `0` / WARNING: `1029` / INFO: `938`）

---

## 二、1. 资源路径契约 (Resource Path) 详细清单 (157 条)

| 严重等级 | 文件位置 | 字面量内容 | 诊断原因与修复建议 |
|:---:|:---|:---|:---|
| `WARNING` | `Global.gd:190` | `res://Scene/base/SpecialAffectSlim` | 资源文件或目录不存在: 分段不存在: SpecialAffectSlim |
| `WARNING` | `Global.gd:202` | `res://Scene/hero/RoleBulletSlim` | 资源文件或目录不存在: 分段不存在: RoleBulletSlim |
| `WARNING` | `Global.gd:252` | `res://Art/Monster/QiongQi/Monster42FramesCenteredCropped` | 资源文件或目录不存在: 分段不存在: Monster42FramesCenteredCropped |
| `WARNING` | `Global.gd:256` | `res://Art/Monster/TaoWu/Monster47FramesCenteredCropped` | 资源文件或目录不存在: 分段不存在: Monster47FramesCenteredCropped |
| `WARNING` | `Global.gd:278` | `res://Art/Monster/PetTigerBoss/model/frames/stage1` | 资源文件或目录不存在: 分段不存在: frames |
| `WARNING` | `Global.gd:279` | `res://Art/Monster/PetTigerBoss/effects` | 资源文件或目录不存在: 分段不存在: effects |
| `WARNING` | `Global.gd:283` | `res://Art/Monster/PetTigerBoss/model/frames/stage2` | 资源文件或目录不存在: 分段不存在: frames |
| `WARNING` | `Global.gd:284` | `res://Art/Monster/PetTigerBoss/effects` | 资源文件或目录不存在: 分段不存在: effects |
| `WARNING` | `Global.gd:288` | `res://Art/Monster/PetTigerBoss/model/frames/stage3` | 资源文件或目录不存在: 分段不存在: frames |
| `WARNING` | `Global.gd:289` | `res://Art/Monster/PetTigerBoss/effects` | 资源文件或目录不存在: 分段不存在: effects |
| `WARNING` | `Global.gd:293` | `res://Art/Monster/PetTigerBoss/model/frames/stage4` | 资源文件或目录不存在: 分段不存在: frames |
| `WARNING` | `Global.gd:294` | `res://Art/Monster/PetTigerBoss/effects` | 资源文件或目录不存在: 分段不存在: effects |
| `WARNING` | `Global.gd:305` | `res://Art/Monster/QiongQi/Effects` | 资源文件或目录不存在: 分段不存在: Effects |
| `WARNING` | `Global.gd:306` | `res://Art/Monster/TaoWu/Effects` | 资源文件或目录不存在: 分段不存在: Effects |
| `WARNING` | `Global.gd:1271` | `res://Art/all_number/cure/cure_` | 资源文件或目录不存在: 分段不存在: cure_ |
| `WARNING` | `Global.gd:1272` | `res://Art/all_number/CureMp/CureMp_` | 资源文件或目录不存在: 分段不存在: CureMp_ |
| `WARNING` | `Global.gd:1273` | `res://Art/all_number/ReduceMp/ReduceMp_` | 资源文件或目录不存在: 分段不存在: ReduceMp_ |
| `WARNING` | `Global.gd:1274` | `res://Art/all_number/Physics/physics_` | 资源文件或目录不存在: 分段不存在: physics_ |
| `WARNING` | `Global.gd:1275` | `res://Art/all_number/physicscrit/physics_` | 资源文件或目录不存在: 分段不存在: physics_ |
| `WARNING` | `Global.gd:1276` | `res://Art/all_number/magic/magic_` | 资源文件或目录不存在: 分段不存在: magic_ |
| `WARNING` | `Global.gd:1277` | `res://Art/all_number/magic/physics_` | 资源文件或目录不存在: 分段不存在: physics_ |
| `WARNING` | `Global.gd:1278` | `res://Art/all_number/magiccrit/magic_` | 资源文件或目录不存在: 分段不存在: magic_ |
| `WARNING` | `Global.gd:1279` | `res://Art/all_number/real/real_` | 资源文件或目录不存在: 分段不存在: real_ |
| `WARNING` | `Global.gd:1280` | `res://Art/all_number/realcrit/real_` | 资源文件或目录不存在: 分段不存在: real_ |
| `WARNING` | `Global.gd:1281` | `res://Art/all_number/LJ/lj_` | 资源文件或目录不存在: 分段不存在: lj_ |
| `WARNING` | `Global.gd:1282` | `res://Art/all_number/monster/physics/physics_` | 资源文件或目录不存在: 分段不存在: physics_ |
| `WARNING` | `Global.gd:1283` | `res://Art/all_number/monster/magic/magic_` | 资源文件或目录不存在: 分段不存在: magic_ |
| `WARNING` | `Global.gd:1984` | `res://Scene/monster/monster_` | 资源文件或目录不存在: 分段不存在: monster_ |
| `WARNING` | `Global.gd:2085` | `res://Art/all_number/cure/cure_` | 资源文件或目录不存在: 分段不存在: cure_ |
| `WARNING` | `Global.gd:2086` | `res://Art/all_number/CureMp/CureMp_` | 资源文件或目录不存在: 分段不存在: CureMp_ |
| `WARNING` | `Global.gd:2087` | `res://Art/all_number/ReduceMp/ReduceMp_` | 资源文件或目录不存在: 分段不存在: ReduceMp_ |
| `WARNING` | `Global.gd:2088` | `res://Art/all_number/Physics/physics_` | 资源文件或目录不存在: 分段不存在: physics_ |
| `WARNING` | `Global.gd:2089` | `res://Art/all_number/physicscrit/physics_` | 资源文件或目录不存在: 分段不存在: physics_ |
| `WARNING` | `Global.gd:2090` | `res://Art/all_number/magic/magic_` | 资源文件或目录不存在: 分段不存在: magic_ |
| `WARNING` | `Global.gd:2091` | `res://Art/all_number/magic/physics_` | 资源文件或目录不存在: 分段不存在: physics_ |
| `WARNING` | `Global.gd:2092` | `res://Art/all_number/magiccrit/magic_` | 资源文件或目录不存在: 分段不存在: magic_ |
| `WARNING` | `Global.gd:2093` | `res://Art/all_number/real/real_` | 资源文件或目录不存在: 分段不存在: real_ |
| `WARNING` | `Global.gd:2094` | `res://Art/all_number/realcrit/real_` | 资源文件或目录不存在: 分段不存在: real_ |
| `WARNING` | `Global.gd:2095` | `res://Art/all_number/LJ/lj_` | 资源文件或目录不存在: 分段不存在: lj_ |
| `WARNING` | `Global.gd:2096` | `res://Art/all_number/monster/physics/physics_` | 资源文件或目录不存在: 分段不存在: physics_ |

> *(剩余 117 条已收入机读 JSON 报告 docs/contract_audit.json)*


## 二、2. 节点路径契约 (Node Path) 详细清单 (0 条)

`[√] 未检测到任何契约违规项，该类别 100% 达成合规！`

## 二、3. 动态反射契约 (Reflection) 详细清单 (13 条)

| 严重等级 | 文件位置 | 字面量内容 | 诊断原因与修复建议 |
|:---:|:---|:---|:---|
| `INFO` | `Global.gd:3427` | `get_rect` | 动态反射调用的方法 'get_rect' 在工程中无对应显式声明 |
| `INFO` | `joy.gd:88` | `get_size` | 动态反射调用的方法 'get_size' 在工程中无对应显式声明 |
| `INFO` | `Script/base/base_monster.gd:2336` | `get_buff_node` | 动态反射调用的方法 'get_buff_node' 在工程中无对应显式声明 |
| `INFO` | `Script/base/summon_base_monster.gd:555` | `get_hit_damage` | 动态反射调用的方法 'get_hit_damage' 在工程中无对应显式声明 |
| `INFO` | `Script/magic_weapon/qlsword.gd:112` | `set_physics_process` | 动态反射调用的方法 'set_physics_process' 在工程中无对应显式声明 |
| `INFO` | `Script/main_menu/game_announcement.gd:846` | `grab_focus` | 动态反射调用的方法 'grab_focus' 在工程中无对应显式声明 |
| `INFO` | `Script/monster/boss_blood.gd:169` | `start_timer` | 动态反射调用的方法 'start_timer' 在工程中无对应显式声明 |
| `INFO` | `Script/monster/boss_blood.gd:192` | `start_timer` | 动态反射调用的方法 'start_timer' 在工程中无对应显式声明 |
| `INFO` | `Script/monster/monster_148.gd:299` | `set_scale` | 动态反射调用的方法 'set_scale' 在工程中无对应显式声明 |
| `INFO` | `Script/monster/monster_zhw/guanyin_summon.gd:107` | `get_skeleton_data_res` | 动态反射调用的方法 'get_skeleton_data_res' 在工程中无对应显式声明 |
| `INFO` | `Script/monster/monster_zhw/monster_141_zhw.gd:33` | `get_power` | 动态反射调用的方法 'get_power' 在工程中无对应显式声明 |
| `INFO` | `Script/monster/monster_zhw/monster_zhw.gd:22` | `get_power` | 动态反射调用的方法 'get_power' 在工程中无对应显式声明 |
| `INFO` | `Script/monster/monster_zhw/monster_zhw_sq.gd:22` | `get_power` | 动态反射调用的方法 'get_power' 在工程中无对应显式声明 |

## 二、4. 动画轨道契约 (Anim Track) 详细清单 (0 条)

`[√] 未检测到任何契约违规项，该类别 100% 达成合规！`

## 二、5. 中文字典键契约 (Dict Key) 详细清单 (1797 条)

| 严重等级 | 文件位置 | 字面量内容 | 诊断原因与修复建议 |
|:---:|:---|:---|:---|
| `WARNING` | `Global.gd:2218` | `技能键位` | 硬编码中文字典键 '技能键位' 已在契约表收录，建议使用 'DataKeys.Skill.KEYMAP' → **建议**: `DataKeys.Skill.KEYMAP` |
| `WARNING` | `Global.gd:4313` | `阶段` | 硬编码中文字典键 '阶段' 已在契约表收录，建议使用 'DataKeys.Pet.STAGE' → **建议**: `DataKeys.Pet.STAGE` |
| `WARNING` | `Global.gd:4937` | `所属` | 硬编码中文字典键 '所属' 已在契约表收录，建议使用 'DataKeys.Item.BELONG' → **建议**: `DataKeys.Item.BELONG` |
| `WARNING` | `Global.gd:4940` | `所属` | 硬编码中文字典键 '所属' 已在契约表收录，建议使用 'DataKeys.Item.BELONG' → **建议**: `DataKeys.Item.BELONG` |
| `WARNING` | `Global.gd:4940` | `所属` | 硬编码中文字典键 '所属' 已在契约表收录，建议使用 'DataKeys.Item.BELONG' → **建议**: `DataKeys.Item.BELONG` |
| `WARNING` | `Passive_Skills.gd:75` | `被动技能` | 硬编码中文字典键 '被动技能' 已在契约表收录，建议使用 'DataKeys.Skill.PASSIVE' → **建议**: `DataKeys.Skill.PASSIVE` |
| `WARNING` | `Passive_Skills.gd:89` | `被动技能` | 硬编码中文字典键 '被动技能' 已在契约表收录，建议使用 'DataKeys.Skill.PASSIVE' → **建议**: `DataKeys.Skill.PASSIVE` |
| `WARNING` | `Passive_Skills.gd:99` | `被动技能` | 硬编码中文字典键 '被动技能' 已在契约表收录，建议使用 'DataKeys.Skill.PASSIVE' → **建议**: `DataKeys.Skill.PASSIVE` |
| `WARNING` | `Scene/other_scene/load_scene.gd:405` | `技能键位` | 硬编码中文字典键 '技能键位' 已在契约表收录，建议使用 'DataKeys.Skill.KEYMAP' → **建议**: `DataKeys.Skill.KEYMAP` |
| `WARNING` | `Script/back_pack/back_pack.gd:123` | `被动技能` | 硬编码中文字典键 '被动技能' 已在契约表收录，建议使用 'DataKeys.Skill.PASSIVE' → **建议**: `DataKeys.Skill.PASSIVE` |
| `WARNING` | `Script/back_pack/back_pack.gd:322` | `饰品` | 硬编码中文字典键 '饰品' 已在契约表收录，建议使用 'DataKeys.Skill.ACCESSORY' → **建议**: `DataKeys.Skill.ACCESSORY` |
| `WARNING` | `Script/back_pack/back_pack.gd:345` | `饰品` | 硬编码中文字典键 '饰品' 已在契约表收录，建议使用 'DataKeys.Skill.ACCESSORY' → **建议**: `DataKeys.Skill.ACCESSORY` |
| `WARNING` | `Script/back_pack/back_pack.gd:346` | `饰品` | 硬编码中文字典键 '饰品' 已在契约表收录，建议使用 'DataKeys.Skill.ACCESSORY' → **建议**: `DataKeys.Skill.ACCESSORY` |
| `WARNING` | `Script/back_pack/back_pack.gd:347` | `饰品` | 硬编码中文字典键 '饰品' 已在契约表收录，建议使用 'DataKeys.Skill.ACCESSORY' → **建议**: `DataKeys.Skill.ACCESSORY` |
| `WARNING` | `Script/back_pack/back_pack.gd:348` | `饰品` | 硬编码中文字典键 '饰品' 已在契约表收录，建议使用 'DataKeys.Skill.ACCESSORY' → **建议**: `DataKeys.Skill.ACCESSORY` |
| `WARNING` | `Script/back_pack/back_pack.gd:349` | `饰品` | 硬编码中文字典键 '饰品' 已在契约表收录，建议使用 'DataKeys.Skill.ACCESSORY' → **建议**: `DataKeys.Skill.ACCESSORY` |
| `WARNING` | `Script/back_pack/box_1.gd:179` | `来源` | 硬编码中文字典键 '来源' 已在契约表收录，建议使用 'DataKeys.Item.SOURCE' → **建议**: `DataKeys.Item.SOURCE` |
| `WARNING` | `Script/back_pack/box_1.gd:180` | `穿戴栏` | 硬编码中文字典键 '穿戴栏' 已在契约表收录，建议使用 'DataKeys.Storage.WEAR_BAR' → **建议**: `DataKeys.Storage.WEAR_BAR` |
| `WARNING` | `Script/back_pack/box_1.gd:201` | `来源` | 硬编码中文字典键 '来源' 已在契约表收录，建议使用 'DataKeys.Item.SOURCE' → **建议**: `DataKeys.Item.SOURCE` |
| `WARNING` | `Script/back_pack/box_1.gd:202` | `穿戴栏` | 硬编码中文字典键 '穿戴栏' 已在契约表收录，建议使用 'DataKeys.Storage.WEAR_BAR' → **建议**: `DataKeys.Storage.WEAR_BAR` |
| `WARNING` | `Script/back_pack/box_1.gd:218` | `来源` | 硬编码中文字典键 '来源' 已在契约表收录，建议使用 'DataKeys.Item.SOURCE' → **建议**: `DataKeys.Item.SOURCE` |
| `WARNING` | `Script/back_pack/box_1.gd:219` | `穿戴栏` | 硬编码中文字典键 '穿戴栏' 已在契约表收录，建议使用 'DataKeys.Storage.WEAR_BAR' → **建议**: `DataKeys.Storage.WEAR_BAR` |
| `WARNING` | `Script/back_pack/box_1.gd:247` | `放入列表` | 硬编码中文字典键 '放入列表' 已在契约表收录，建议使用 'DataKeys.Storage.PUT_IN_LIST' → **建议**: `DataKeys.Storage.PUT_IN_LIST` |
| `WARNING` | `Script/back_pack/box_1.gd:248` | `放入列表` | 硬编码中文字典键 '放入列表' 已在契约表收录，建议使用 'DataKeys.Storage.PUT_IN_LIST' → **建议**: `DataKeys.Storage.PUT_IN_LIST` |
| `WARNING` | `Script/back_pack/box_1.gd:257` | `放入列表` | 硬编码中文字典键 '放入列表' 已在契约表收录，建议使用 'DataKeys.Storage.PUT_IN_LIST' → **建议**: `DataKeys.Storage.PUT_IN_LIST` |
| `WARNING` | `Script/back_pack/box_1.gd:258` | `放入列表` | 硬编码中文字典键 '放入列表' 已在契约表收录，建议使用 'DataKeys.Storage.PUT_IN_LIST' → **建议**: `DataKeys.Storage.PUT_IN_LIST` |
| `WARNING` | `Script/back_pack/box_1.gd:259` | `放入列表` | 硬编码中文字典键 '放入列表' 已在契约表收录，建议使用 'DataKeys.Storage.PUT_IN_LIST' → **建议**: `DataKeys.Storage.PUT_IN_LIST` |
| `WARNING` | `Script/back_pack/box_1.gd:260` | `放入列表` | 硬编码中文字典键 '放入列表' 已在契约表收录，建议使用 'DataKeys.Storage.PUT_IN_LIST' → **建议**: `DataKeys.Storage.PUT_IN_LIST` |
| `WARNING` | `Script/back_pack/box_1.gd:261` | `放入列表` | 硬编码中文字典键 '放入列表' 已在契约表收录，建议使用 'DataKeys.Storage.PUT_IN_LIST' → **建议**: `DataKeys.Storage.PUT_IN_LIST` |
| `WARNING` | `Script/back_pack/box_1.gd:271` | `放入列表` | 硬编码中文字典键 '放入列表' 已在契约表收录，建议使用 'DataKeys.Storage.PUT_IN_LIST' → **建议**: `DataKeys.Storage.PUT_IN_LIST` |
| `WARNING` | `Script/back_pack/box_1.gd:287` | `放入列表` | 硬编码中文字典键 '放入列表' 已在契约表收录，建议使用 'DataKeys.Storage.PUT_IN_LIST' → **建议**: `DataKeys.Storage.PUT_IN_LIST` |
| `WARNING` | `Script/back_pack/box_1.gd:298` | `放入列表` | 硬编码中文字典键 '放入列表' 已在契约表收录，建议使用 'DataKeys.Storage.PUT_IN_LIST' → **建议**: `DataKeys.Storage.PUT_IN_LIST` |
| `WARNING` | `Script/back_pack/box_1.gd:310` | `所属` | 硬编码中文字典键 '所属' 已在契约表收录，建议使用 'DataKeys.Item.BELONG' → **建议**: `DataKeys.Item.BELONG` |
| `WARNING` | `Script/back_pack/box_1.gd:342` | `所属` | 硬编码中文字典键 '所属' 已在契约表收录，建议使用 'DataKeys.Item.BELONG' → **建议**: `DataKeys.Item.BELONG` |
| `WARNING` | `Script/back_pack/box_1.gd:391` | `所属` | 硬编码中文字典键 '所属' 已在契约表收录，建议使用 'DataKeys.Item.BELONG' → **建议**: `DataKeys.Item.BELONG` |
| `WARNING` | `Script/back_pack/box_1.gd:465` | `所属` | 硬编码中文字典键 '所属' 已在契约表收录，建议使用 'DataKeys.Item.BELONG' → **建议**: `DataKeys.Item.BELONG` |
| `WARNING` | `Script/back_pack/dj_information.gd:49` | `描述` | 硬编码中文字典键 '描述' 已在契约表收录，建议使用 'DataKeys.Item.DESC' → **建议**: `DataKeys.Item.DESC` |
| `WARNING` | `Script/back_pack/dj_sell.gd:78` | `锁定` | 硬编码中文字典键 '锁定' 已在契约表收录，建议使用 'DataKeys.Item.LOCK' → **建议**: `DataKeys.Item.LOCK` |
| `WARNING` | `Script/back_pack/dj_sell.gd:95` | `锁定` | 硬编码中文字典键 '锁定' 已在契约表收录，建议使用 'DataKeys.Item.LOCK' → **建议**: `DataKeys.Item.LOCK` |
| `WARNING` | `Script/back_pack/dj_sell.gd:95` | `锁定` | 硬编码中文字典键 '锁定' 已在契约表收录，建议使用 'DataKeys.Item.LOCK' → **建议**: `DataKeys.Item.LOCK` |

> *(剩余 1757 条已收入机读 JSON 报告 docs/contract_audit.json)*


---

## 三、Phase 8-2 推荐修复执行优先级

1. **高危阻断项 (ERROR)**：优先清零 `resource_path` 大小写失配与 `node_path` 大小写失配，防止运行时抛出 `Node not found` 与 `Resource not found` 崩溃；
2. **动画方法轨道 (anim_track)**：对齐动画帧 method 轨道大小写，消除方法静默不调用；
3. **字典键收敛 (dict_key)**：分批将已收录于 `DataKeys` 的中文硬编码键迁移为强类型常量引用。
