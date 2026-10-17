# ZMXYBHYH 全工程字面量契约诊断审计报告 (Phase 8-1)

> 生成时间: 2026-10-17 14:59:43  
> 审计对象: `G:\source\repos\ZMXYBHYH\source\v6.5.0.0`  
> 扫描耗时: `5.08 秒`（指标要求 ≤ 30 秒）  
> 覆盖资产: 脚本 `722 个` / 场景 `1132 个`  

---

## 一、五大字面量契约健康看板

| 契约类别 (Category) | 严重错误 (ERROR) | 告警/建议 (WARNING) | 待收敛 (INFO) | 合计条目 | 健康状态 |
|:---|:---:|:---:|:---:|:---:|:---:|
| **1. 资源路径契约 (Resource Path)** | **75** | 0 | 0 | **75** | 🔴 待修复 |
| **2. 节点路径契约 (Node Path)** | **1** | 1 | 0 | **2** | 🔴 待修复 |
| **3. 动态反射契约 (Reflection)** | **0** | 0 | 13 | **13** | 🟢 契约完好 |
| **4. 动画轨道契约 (Anim Track)** | **2** | 0 | 0 | **2** | 🔴 待修复 |
| **5. 中文字典键契约 (Dict Key)** | **0** | 872 | 925 | **1797** | 🟡 需关注 |

**总计缺陷与待收敛项**: `1889 个`（ERROR: `78` / WARNING: `873` / INFO: `938`）

---

## 二、1. 资源路径契约 (Resource Path) 详细清单 (75 条)

| 严重等级 | 文件位置 | 字面量内容 | 诊断原因与修复建议 |
|:---:|:---|:---|:---|
| `ERROR` | `Global.gd:210` | `res://Scene/monster/MonsterBullet.tscn` | 资源文件或目录不存在: 分段不存在: MonsterBullet.tscn |
| `ERROR` | `Global.gd:253` | `res://Art/Monster/QiongQi/Effects/BuffGreen.png` | 资源文件或目录不存在: 分段不存在: Effects |
| `ERROR` | `Global.gd:254` | `res://Art/Monster/QiongQi/Effects/BuffBlue.png` | 资源文件或目录不存在: 分段不存在: Effects |
| `ERROR` | `Global.gd:2016` | `res://Art/AddEffect/Buff_icon/mp_poision.png` | 资源文件或目录不存在: 分段不存在: mp_poision.png |
| `ERROR` | `Global.gd:2048` | `res://Art/AddEffect/Buff_icon/mp_poision.png` | 资源文件或目录不存在: 分段不存在: mp_poision.png |
| `ERROR` | `Global.gd:2171` | `res://Music/Hero/Role4/Arrowdcj.mp3` | 资源文件或目录不存在: 分段不存在: Arrowdcj.mp3 |
| `ERROR` | `Global.gd:2172` | `res://Music/Hero/Role4/ArrowHit1.mp3` | 资源文件或目录不存在: 分段不存在: ArrowHit1.mp3 |
| `ERROR` | `Global.gd:2173` | `res://Music/Hero/Role4/ArrowHit2.mp3` | 资源文件或目录不存在: 分段不存在: ArrowHit2.mp3 |
| `ERROR` | `Global.gd:2174` | `res://Music/Hero/Role4/Arrowmmw.mp3` | 资源文件或目录不存在: 分段不存在: Arrowmmw.mp3 |
| `ERROR` | `Global.gd:2175` | `res://Music/Hero/Role4/Arrowqlj.mp3` | 资源文件或目录不存在: 分段不存在: Arrowqlj.mp3 |
| `ERROR` | `Global.gd:2176` | `res://Music/Hero/Role4/Arrowtkj.mp3` | 资源文件或目录不存在: 分段不存在: Arrowtkj.mp3 |
| `ERROR` | `Global.gd:2177` | `res://Music/Hero/Role4/Arrowzq.mp3` | 资源文件或目录不存在: 分段不存在: Arrowzq.mp3 |
| `ERROR` | `Global.gd:2201` | `res://Music/Hero/Role5/effect4.mp3` | 资源文件或目录不存在: 分段不存在: effect4.mp3 |
| `ERROR` | `Global.gd:2389` | `res://Music/Hero/Role4/ArrowHit1.mp3` | 资源文件或目录不存在: 分段不存在: ArrowHit1.mp3 |
| `ERROR` | `Global.gd:2390` | `res://Music/Hero/Role4/ArrowHit2.mp3` | 资源文件或目录不存在: 分段不存在: ArrowHit2.mp3 |
| `ERROR` | `Global.gd:2392` | `res://Music/Hero/Role4/Arrowqlj.mp3` | 资源文件或目录不存在: 分段不存在: Arrowqlj.mp3 |
| `ERROR` | `Global.gd:2394` | `res://Music/Hero/Role4/Arrowdcj.mp3` | 资源文件或目录不存在: 分段不存在: Arrowdcj.mp3 |
| `ERROR` | `Global.gd:2396` | `res://Music/Hero/Role4/Arrowmmw.mp3` | 资源文件或目录不存在: 分段不存在: Arrowmmw.mp3 |
| `ERROR` | `Global.gd:2398` | `res://Music/Hero/Role4/Arrowzq.mp3` | 资源文件或目录不存在: 分段不存在: Arrowzq.mp3 |
| `ERROR` | `Global.gd:2399` | `res://Music/Hero/Role4/Arrowtkj.mp3` | 资源文件或目录不存在: 分段不存在: Arrowtkj.mp3 |
| `ERROR` | `Global.gd:2414` | `res://Music/Hero/Role5/effect4.mp3` | 资源文件或目录不存在: 分段不存在: effect4.mp3 |
| `ERROR` | `Global.gd:2589` | `res://Music/Hero/Role4/ArrowHit1.mp3` | 资源文件或目录不存在: 分段不存在: ArrowHit1.mp3 |
| `ERROR` | `Global.gd:2590` | `res://Music/Hero/Role4/ArrowHit2.mp3` | 资源文件或目录不存在: 分段不存在: ArrowHit2.mp3 |
| `ERROR` | `Global.gd:2592` | `res://Music/Hero/Role4/Arrowqlj.mp3` | 资源文件或目录不存在: 分段不存在: Arrowqlj.mp3 |
| `ERROR` | `Global.gd:2594` | `res://Music/Hero/Role4/Arrowdcj.mp3` | 资源文件或目录不存在: 分段不存在: Arrowdcj.mp3 |
| `ERROR` | `Global.gd:2596` | `res://Music/Hero/Role4/Arrowmmw.mp3` | 资源文件或目录不存在: 分段不存在: Arrowmmw.mp3 |
| `ERROR` | `Global.gd:2598` | `res://Music/Hero/Role4/Arrowzq.mp3` | 资源文件或目录不存在: 分段不存在: Arrowzq.mp3 |
| `ERROR` | `Global.gd:2599` | `res://Music/Hero/Role4/Arrowtkj.mp3` | 资源文件或目录不存在: 分段不存在: Arrowtkj.mp3 |
| `ERROR` | `Global.gd:2614` | `res://Music/Hero/Role5/effect4.mp3` | 资源文件或目录不存在: 分段不存在: effect4.mp3 |
| `ERROR` | `Global.gd:4526` | `res://Art/Monster/GuanyinSpine/skeleton.atlas` | 资源文件或目录不存在: 分段不存在: skeleton.atlas |
| `ERROR` | `Global.gd:4527` | `res://Art/Monster/GuanyinSpine/guanyin.spine-json` | 资源文件或目录不存在: 分段不存在: guanyin.spine-json |
| `ERROR` | `Scene/other_scene/load_scene.gd:43` | `res://Art/Pet/PetTiger/model/actions/stage1/wait/icon.png` | 资源文件或目录不存在: 分段不存在: wait |
| `ERROR` | `Scene/other_scene/load_scene.gd:44` | `res://Art/Pet/PetTiger/model/actions/stage2/wait/icon.png` | 资源文件或目录不存在: 分段不存在: wait |
| `ERROR` | `Scene/other_scene/load_scene.gd:45` | `res://Art/Pet/PetTiger/model/actions/stage3/wait/icon.png` | 资源文件或目录不存在: 分段不存在: wait |
| `ERROR` | `Scene/other_scene/load_scene.gd:46` | `res://Art/Pet/PetTiger/model/actions/stage4/wait/icon.png` | 资源文件或目录不存在: 分段不存在: wait |
| `ERROR` | `Scene/other_scene/monster_head_info.gd:6` | `res://Art/Monster/Game3Monster/ThreePrince/nezha/idle/1.png` | 资源文件或目录不存在: 分段不存在: idle |
| `ERROR` | `Script/back_pack/equipment_fall.gd:81` | `res://Music/level/86_pickup.mp3` | 资源文件或目录不存在: 分段不存在: 86_pickup.mp3 |
| `ERROR` | `Script/back_pack/skill_select.gd:50` | `res://Art/MagicWeapon/skill_icon/wdsf.png` | 资源文件或目录不存在: 分段不存在: wdsf.png |
| `ERROR` | `Script/back_pack/skill_select.gd:52` | `res://Art/MagicWeapon/skill_icon/wdsh.png` | 资源文件或目录不存在: 分段不存在: wdsh.png |
| `ERROR` | `Script/back_pack/skill_select.gd:54` | `res://Art/MagicWeapon/skill_icon/wdst.png` | 资源文件或目录不存在: 分段不存在: wdst.png |

> *(剩余 35 条已收入机读 JSON 报告 docs/contract_audit.json)*


## 二、2. 节点路径契约 (Node Path) 详细清单 (2 条)

| 严重等级 | 文件位置 | 字面量内容 | 诊断原因与修复建议 |
|:---:|:---|:---|:---|
| `ERROR` | `Script/base/base_monster.gd:2327` | `buff` | 场景 'base_monster.tscn' 中节点路径大小写失配: 实际节点全名为 'Buff' → **建议**: `Buff` |
| `WARNING` | `Global.gd:4691` | `ChaseAni` | 全局节点引用段 'ChaseAni' 疑似大小写失配，工程中存在对应节点 'Chaseani' → **建议**: `Chaseani` |

## 二、3. 动态反射契约 (Reflection) 详细清单 (13 条)

| 严重等级 | 文件位置 | 字面量内容 | 诊断原因与修复建议 |
|:---:|:---|:---|:---|
| `INFO` | `Global.gd:3427` | `get_rect` | 动态反射调用的方法 'get_rect' 在工程中无对应显式声明 |
| `INFO` | `joy.gd:88` | `get_size` | 动态反射调用的方法 'get_size' 在工程中无对应显式声明 |
| `INFO` | `Script/base/base_monster.gd:2331` | `get_buff_node` | 动态反射调用的方法 'get_buff_node' 在工程中无对应显式声明 |
| `INFO` | `Script/base/summon_base_monster.gd:553` | `get_hit_damage` | 动态反射调用的方法 'get_hit_damage' 在工程中无对应显式声明 |
| `INFO` | `Script/magic_weapon/qlsword.gd:112` | `set_physics_process` | 动态反射调用的方法 'set_physics_process' 在工程中无对应显式声明 |
| `INFO` | `Script/main_menu/game_announcement.gd:846` | `grab_focus` | 动态反射调用的方法 'grab_focus' 在工程中无对应显式声明 |
| `INFO` | `Script/monster/boss_blood.gd:169` | `start_timer` | 动态反射调用的方法 'start_timer' 在工程中无对应显式声明 |
| `INFO` | `Script/monster/boss_blood.gd:192` | `start_timer` | 动态反射调用的方法 'start_timer' 在工程中无对应显式声明 |
| `INFO` | `Script/monster/monster_148.gd:299` | `set_scale` | 动态反射调用的方法 'set_scale' 在工程中无对应显式声明 |
| `INFO` | `Script/monster/monster_zhw/guanyin_summon.gd:107` | `get_skeleton_data_res` | 动态反射调用的方法 'get_skeleton_data_res' 在工程中无对应显式声明 |
| `INFO` | `Script/monster/monster_zhw/monster_141_zhw.gd:33` | `get_power` | 动态反射调用的方法 'get_power' 在工程中无对应显式声明 |
| `INFO` | `Script/monster/monster_zhw/monster_zhw.gd:22` | `get_power` | 动态反射调用的方法 'get_power' 在工程中无对应显式声明 |
| `INFO` | `Script/monster/monster_zhw/monster_zhw_sq.gd:22` | `get_power` | 动态反射调用的方法 'get_power' 在工程中无对应显式声明 |

## 二、4. 动画轨道契约 (Anim Track) 详细清单 (2 条)

| 严重等级 | 文件位置 | 字面量内容 | 诊断原因与修复建议 |
|:---:|:---|:---|:---|
| `ERROR` | `Scene/level/bsz.tscn` | `Bsz:self_modulate` | 动画轨道绑定节点大小写失配: 实际节点路径为 'BSz' → **建议**: `BSz:self_modulate` |
| `ERROR` | `Scene/level/level_5.tscn` | `Wall:position` | 动画轨道绑定节点大小写失配: 实际节点路径为 'wall' → **建议**: `wall:position` |

## 二、5. 中文字典键契约 (Dict Key) 详细清单 (1797 条)

| 严重等级 | 文件位置 | 字面量内容 | 诊断原因与修复建议 |
|:---:|:---|:---|:---|
| `WARNING` | `Global.gd:2218` | `技能键位` | 硬编码中文字典键 '技能键位' 已在契约表收录，建议使用 'DataKeys.Skill.KEYMAP' → **建议**: `DataKeys.Skill.KEYMAP` |
| `WARNING` | `Global.gd:4313` | `阶段` | 硬编码中文字典键 '阶段' 已在契约表收录，建议使用 'DataKeys.Pet.STAGE' → **建议**: `DataKeys.Pet.STAGE` |
| `WARNING` | `Global.gd:4939` | `所属` | 硬编码中文字典键 '所属' 已在契约表收录，建议使用 'DataKeys.Item.BELONG' → **建议**: `DataKeys.Item.BELONG` |
| `WARNING` | `Global.gd:4942` | `所属` | 硬编码中文字典键 '所属' 已在契约表收录，建议使用 'DataKeys.Item.BELONG' → **建议**: `DataKeys.Item.BELONG` |
| `WARNING` | `Global.gd:4942` | `所属` | 硬编码中文字典键 '所属' 已在契约表收录，建议使用 'DataKeys.Item.BELONG' → **建议**: `DataKeys.Item.BELONG` |
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
