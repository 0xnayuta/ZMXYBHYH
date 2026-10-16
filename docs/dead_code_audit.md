# ZMXYBHYH 全工程资产拓扑与死代码审计报告 (Phase 1)

> 生成时间: 2026-10-16 19:06:23  
> 审计对象: `G:\source\repos\ZMXYBHYH\source\v6.5.0.0`  
> 引擎环境: `Godot 4.7.2 Headless`

---

## 一、全工程资产与引用健康指标看板

| 检测维度 | 真实指标 | 状态 | 结论与安全评估 |
|:---|:---|:---|:---|
| **全量场景资源断裂数** | **0 处** | `PASSED` | 1,242 个场景中所有外部资源全量匹配，无任何悬空或丢失引用 |
| **GDScript 语法解析错误** | **0 处** | `PASSED` | 全量 874 个脚本均已通过 Godot 4.7.2 核心解析树校验 |
| **直接引用活跃脚本** | **687 个 (94.9%)** | `HEALTHY` | 被场景、代码 `preload`/`load` 或 Autoload 明确消费 |
| **动态加载/全局符号脚本** | **0 个** | `PROTECTED` | 具备动态字符串前缀或全局 `class_name`，严禁误杀 |
| **确认纯死代码 (Dead Code)** | **38 个** | `PENDING_CLEANUP` | 全局 0 引用、无动态前缀、无继承，可在 Phase 2 安全下线 |

---

## 二、受保护的动态加载模式 (Dynamic Load Guard)

以下前缀在代码中通过变量拼接动态 `load(...)`，其目录下的所有子脚本**严禁作为孤岛删除**：

- `load("res://Art/AllNumber/Level/Level_" + ...)`
- `load("res://Art/BackPack/AllItems/" + ...)`
- `load("res://Art/Level/Challenge/ui_beizhan_pj_" + ...)`
- `load("res://Art/LevelInfoBg/" + ...)`
- `load("res://Art/MainGame/ChoosePlayer/" + ...)`
- `load("res://Art/MainGame/ChoosePlayer/xx_" + ...)`
- `load("res://Art/Monster/MonsterHead/" + ...)`
- `load("res://Art/Skill/SkillIcon/" + ...)`

---

## 三、隐式活跃脚本保护清单 (0 个)

| 脚本路径 | 保护原因 | 详细依据 |
|:---|:---|:---|

---

## 四、确认纯真死代码清单 (38 个 · 建议 Phase 2 安全下线)

经过全量场景、代码 AST、Autoload、`class_name` 反射与动态字符串前缀多重交叉检验，以下脚本**确认为完全无引用的历史陈旧代码**，可在 Phase 2 作为第一批瘦身对象安全移除：

| 序号 | 脚本相对路径 | 源码大小 (字节) | 归属类别建议 |
|:---|:---|:---|:---|
| 1 | `res://BuffInfo.gd` | 491 | 历史遗留孤立脚本 |
| 2 | `res://MagicWeapon.gd` | 33 | 历史遗留孤立脚本 |
| 3 | `res://Scene/other_scene/load_scene.gd` | 27,954 | 历史遗留孤立脚本 |
| 4 | `res://Script/Base/BaseMap.gd` | 1,285 | 历史遗留孤立脚本 |
| 5 | `res://Script/Base/BaseMonsterProperies.gd` | 152 | 历史遗留孤立脚本 |
| 6 | `res://Script/Data/AllEquipmentData.gd` | 401,957 | 历史遗留孤立脚本 |
| 7 | `res://Script/Level/Buff_box.gd` | 22 | 历史遗留孤立脚本 |
| 8 | `res://Script/Level/Level_czdy.gd` | 18 | 历史遗留孤立脚本 |
| 9 | `res://Script/Level/Level_gzdy.gd` | 70 | 历史遗留孤立脚本 |
| 10 | `res://Script/Level/Level_lxdy.gd` | 4,309 | 历史遗留孤立脚本 |
| 11 | `res://Script/Level/Level_szdy.gd` | 18 | 历史遗留孤立脚本 |
| 12 | `res://Script/Level/Level_xzdy.gd` | 18 | 历史遗留孤立脚本 |
| 13 | `res://Script/Level/Level_zzdy.gd` | 18 | 历史遗留孤立脚本 |
| 14 | `res://Script/Monster/AtlasMonsterVisual.gd` | 1,208 | 历史遗留孤立脚本 |
| 15 | `res://Script/Monster/Fly_bullet.gd` | 538 | 历史遗留孤立脚本 |
| 16 | `res://Script/Monster/Monster_121.gd` | 3,142 | 历史遗留孤立脚本 |
| 17 | `res://Script/Monster/Monster_3201.gd` | 3,007 | 历史遗留孤立脚本 |
| 18 | `res://Script/Monster/Monster_61-1.gd` | 20 | 历史遗留孤立脚本 |
| 19 | `res://Script/Monster/Monster_62-1.gd` | 20 | 历史遗留孤立脚本 |
| 20 | `res://Script/Monster/Monster_63-1.gd` | 7,602 | 历史遗留孤立脚本 |
| 21 | `res://Script/Monster/Monster_70.gd` | 20 | 历史遗留孤立脚本 |
| 22 | `res://Script/Monster/Monster_71.gd` | 20 | 历史遗留孤立脚本 |
| 23 | `res://Script/Monster/SandKingSkills.gd` | 3,547 | 历史遗留孤立脚本 |
| 24 | `res://Script/Pet/PetTigerSummon_4.gd` | 49 | 历史遗留孤立脚本 |
| 25 | `res://Script/Skill/SummonBossCd.gd` | 13 | 历史遗留孤立脚本 |
| 26 | `res://Script/Tools/skill_1.gd` | 330 | 历史遗留孤立脚本 |
| 27 | `res://Script/main_menu/WorldMapButton.gd` | 177 | 历史遗留孤立脚本 |
| 28 | `res://Test/ActiveSkillUpgradeProbe.gd` | 108 | 历史遗留孤立脚本 |
| 29 | `res://Test/BackpackLevelLayoutProbe.gd` | 1,112 | 历史遗留孤立脚本 |
| 30 | `res://Test/PetInterfaceEquipmentProbe.gd` | 350 | 历史遗留孤立脚本 |
| 31 | `res://Test/verify_active_skill_upgrade.gd` | 5,977 | 历史遗留孤立脚本 |
| 32 | `res://Test/verify_esbxx_popup.gd` | 3,068 | 历史遗留孤立脚本 |
| 33 | `res://Test/verify_level49_skill_book_drop.gd` | 5,662 | 历史遗留孤立脚本 |
| 34 | `res://Test/verify_mount_unlock_material_drop_preview.gd` | 3,499 | 历史遗留孤立脚本 |
| 35 | `res://Test/verify_mount_unlock_material_drops.gd` | 6,061 | 历史遗留孤立脚本 |
| 36 | `res://Test/verify_passive_income.gd` | 4,087 | 历史遗留孤立脚本 |
| 37 | `res://Test/verify_pet_mosaic.gd` | 26,768 | 历史遗留孤立脚本 |
| 38 | `res://Test/verify_pet_mouse.gd` | 23,861 | 历史遗留孤立脚本 |

---

## 五、对 Phase 2 重构行动的指导约束

1. **下线限制**：Phase 2 仅允许下线本报告第四节列出的纯真死代码，严禁触碰第三节受保护的隐式活跃脚本；
2. **原子化验证**：每次删除或重构后，必须重新运行 `python scripts/health_check.py`，确认 `broken_scene_refs` 维持为 0。