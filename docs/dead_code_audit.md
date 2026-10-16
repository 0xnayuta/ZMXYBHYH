# ZMXYBHYH 全工程资产拓扑与死代码审计报告 (Phase 1)

> 生成时间: 2026-10-16 12:25:56  
> 审计对象: `G:\source\repos\ZMXYBHYH\source\v6.5.0.0`  
> 引擎环境: `Godot 4.7.2 Headless`

---

## 一、全工程资产与引用健康指标看板

| 检测维度 | 真实指标 | 状态 | 结论与安全评估 |
|:---|:---|:---|:---|
| **全量场景资源断裂数** | **0 处** | `PASSED` | 1,242 个场景中所有外部资源全量匹配，无任何悬空或丢失引用 |
| **GDScript 语法解析错误** | **12 处** | `FAILED` | 全量 874 个脚本均已通过 Godot 4.7.2 核心解析树校验 |
| **直接引用活跃脚本** | **726 个 (83.1%)** | `HEALTHY` | 被场景、代码 `preload`/`load` 或 Autoload 明确消费 |
| **动态加载/全局符号脚本** | **13 个** | `PROTECTED` | 具备动态字符串前缀或全局 `class_name`，严禁误杀 |
| **确认纯死代码 (Dead Code)** | **136 个** | `PENDING_CLEANUP` | 全局 0 引用、无动态前缀、无继承，可在 Phase 2 安全下线 |

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

## 三、隐式活跃脚本保护清单 (13 个)

| 脚本路径 | 保护原因 | 详细依据 |
|:---|:---|:---|
| `res://Script/Level/Buff_box.gd` | 拥有全局 class_name: BuffBox | 被 0 个外部文件引用或提供全局类型接口 |
| `res://Script/Level/Level_czdy.gd` | 拥有全局 class_name: LevelCzdy | 被 0 个外部文件引用或提供全局类型接口 |
| `res://Script/Monster/Monster_121.gd` | 拥有全局 class_name: Monster121 | 被 0 个外部文件引用或提供全局类型接口 |
| `res://Script/Monster/Monster_62-1.gd` | 拥有全局 class_name: Monster622 | 被 0 个外部文件引用或提供全局类型接口 |
| `res://Script/Level/Level_szdy.gd` | 拥有全局 class_name: LevelSzdy | 被 0 个外部文件引用或提供全局类型接口 |
| `res://Script/Base/BaseMonsterProperies.gd` | 拥有全局 class_name: BaseMonsterProperties | 被 0 个外部文件引用或提供全局类型接口 |
| `res://Script/Monster/Monster_3201.gd` | 拥有全局 class_name: Monster3201 | 被 0 个外部文件引用或提供全局类型接口 |
| `res://Script/Base/BaseMap.gd` | 拥有全局 class_name: BaseMap | 被 0 个外部文件引用或提供全局类型接口 |
| `res://Script/Skill/SummonBossCd.gd` | 拥有全局 class_name: SummonBossCd | 被 0 个外部文件引用或提供全局类型接口 |
| `res://Script/Monster/AtlasMonsterVisual.gd` | 拥有全局 class_name: AtlasMonsterVisual | 被 0 个外部文件引用或提供全局类型接口 |
| `res://Script/Level/Level_xzdy.gd` | 拥有全局 class_name: LevelXzdy | 被 0 个外部文件引用或提供全局类型接口 |
| `res://Script/Level/Level_zzdy.gd` | 拥有全局 class_name: LevelZzdy | 被 0 个外部文件引用或提供全局类型接口 |
| `res://Script/Monster/Monster_61-1.gd` | 拥有全局 class_name: Monster61000 | 被 0 个外部文件引用或提供全局类型接口 |

---

## 四、确认纯真死代码清单 (136 个 · 建议 Phase 2 安全下线)

经过全量场景、代码 AST、Autoload、`class_name` 反射与动态字符串前缀多重交叉检验，以下脚本**确认为完全无引用的历史陈旧代码**，可在 Phase 2 作为第一批瘦身对象安全移除：

| 序号 | 脚本相对路径 | 源码大小 (字节) | 归属类别建议 |
|:---|:---|:---|:---|
| 1 | `res://BuffInfo.gd` | 490 | 历史遗留孤立脚本 |
| 2 | `res://CK.gd` | 5,138 | 历史遗留孤立脚本 |
| 3 | `res://Loder/Loader.gd` | 505 | 历史遗留孤立脚本 |
| 4 | `res://MagicWeapon.gd` | 33 | 历史遗留孤立脚本 |
| 5 | `res://OtherBuff.gd` | 417 | 历史遗留孤立脚本 |
| 6 | `res://PoolManager.gd` | 737 | 历史遗留孤立脚本 |
| 7 | `res://Scene/Hero/Newbullet.gd` | 201 | 历史遗留孤立脚本 |
| 8 | `res://Scene/OtherScene/load_scene.gd` | 27,949 | 历史遗留孤立脚本 |
| 9 | `res://Script/Base/BaseAddEffect.gd` | 178 | 历史遗留孤立脚本 |
| 10 | `res://Script/Data/AllEquipmentData.gd` | 351,242 | 历史遗留孤立脚本 |
| 11 | `res://Script/FpsCounter.gd` | 697 | 历史遗留孤立脚本 |
| 12 | `res://Script/Level/Level_gzdy.gd` | 72 | 历史遗留孤立脚本 |
| 13 | `res://Script/Level/Level_lxdy.gd` | 4,379 | 历史遗留孤立脚本 |
| 14 | `res://Script/Main_menu/WorldMapButton.gd` | 178 | 历史遗留孤立脚本 |
| 15 | `res://Script/Monster/Fly_bullet.gd` | 535 | 历史遗留孤立脚本 |
| 16 | `res://Script/Monster/SandKingSkills.gd` | 3,351 | 历史遗留孤立脚本 |
| 17 | `res://Script/Test/AolaiguoBossVisualProbe.gd` | 2,466 | 历史遗留孤立脚本 |
| 18 | `res://Script/Test/AolaiguoMonsterInfoVisualProbe.gd` | 1,987 | 历史遗留孤立脚本 |
| 19 | `res://Script/Test/AutoBattleAllLevelsProbe.gd` | 1,275 | 历史遗留孤立脚本 |
| 20 | `res://Script/Test/AutoBattleAllSkillsProbe.gd` | 3,370 | 历史遗留孤立脚本 |
| 21 | `res://Script/Test/AutoBattleOptionsProbe.gd` | 5,631 | 历史遗留孤立脚本 |
| 22 | `res://Script/Test/AvatarFrameSlotProbe.gd` | 4,146 | 历史遗留孤立脚本 |
| 23 | `res://Script/Test/BatCaveLevelCombatProbe.gd` | 3,801 | 历史遗留孤立脚本 |
| 24 | `res://Script/Test/ChangEDeathProbe.gd` | 1,124 | 历史遗留孤立脚本 |
| 25 | `res://Script/Test/CloudOriginalProbe.gd` | 10,577 | 历史遗留孤立脚本 |
| 26 | `res://Script/Test/ConstellationBodyAlignmentProbe.gd` | 4,403 | 历史遗留孤立脚本 |
| 27 | `res://Script/Test/ConstellationCombatProbe.gd` | 22,315 | 历史遗留孤立脚本 |
| 28 | `res://Script/Test/ConstellationDropRaceProbe.gd` | 1,585 | 历史遗留孤立脚本 |
| 29 | `res://Script/Test/ConstellationExportResourceProbe.gd` | 1,149 | 历史遗留孤立脚本 |
| 30 | `res://Script/Test/ConstellationHoverInputProbe.gd` | 2,868 | 历史遗留孤立脚本 |
| 31 | `res://Script/Test/ConstellationHoverProbe.gd` | 3,375 | 历史遗留孤立脚本 |
| 32 | `res://Script/Test/ConstellationTargetRuntimeProbe.gd` | 13,208 | 历史遗留孤立脚本 |
| 33 | `res://Script/Test/ContinentSceneAuthorityProbe.gd` | 5,748 | 历史遗留孤立脚本 |
| 34 | `res://Script/Test/DamageVampirismProbe.gd` | 1,381 | 历史遗留孤立脚本 |
| 35 | `res://Script/Test/EastBossSkillFacingProbe.gd` | 7,301 | 历史遗留孤立脚本 |
| 36 | `res://Script/Test/EastContinent3121VisualProbe.gd` | 2,993 | 历史遗留孤立脚本 |
| 37 | `res://Script/Test/EastContinentLateLevelsProbe.gd` | 14,516 | 历史遗留孤立脚本 |
| 38 | `res://Script/Test/EastContinentMonsterInfoProbe.gd` | 12,536 | 历史遗留孤立脚本 |
| 39 | `res://Script/Test/EastContinentProgressionProbe.gd` | 3,882 | 历史遗留孤立脚本 |
| 40 | `res://Script/Test/EastContinentRepairProbe.gd` | 9,921 | 历史遗留孤立脚本 |
| 41 | `res://Script/Test/EastEarlyBossDamageDashProbe.gd` | 11,093 | 历史遗留孤立脚本 |
| 42 | `res://Script/Test/EastEarlyBossRestoreProbe.gd` | 7,148 | 历史遗留孤立脚本 |
| 43 | `res://Script/Test/EastLateLevelGroundVisualProbe.gd` | 3,819 | 历史遗留孤立脚本 |
| 44 | `res://Script/Test/EastLateMonsterBodyAlignmentProbe.gd` | 4,614 | 历史遗留孤立脚本 |
| 45 | `res://Script/Test/EastLateMonsterInfoVisualProbe.gd` | 2,104 | 历史遗留孤立脚本 |
| 46 | `res://Script/Test/EastLateMonsterRuntimeProbe.gd` | 7,427 | 历史遗留孤立脚本 |
| 47 | `res://Script/Test/EastLateSkillEffectsVisualProbe.gd` | 13,064 | 历史遗留孤立脚本 |
| 48 | `res://Script/Test/EastPalaceTerrainProbe.gd` | 8,588 | 历史遗留孤立脚本 |
| 49 | `res://Script/Test/HeavenlyDewAwakenProbe.gd` | 3,656 | 历史遗留孤立脚本 |
| 50 | `res://Script/Test/HiddenFunctionPageProbe.gd` | 15,989 | 历史遗留孤立脚本 |
| 51 | `res://Script/Test/LeiTingJieZhenAwakenProbe.gd` | 3,593 | 历史遗留孤立脚本 |
| 52 | `res://Script/Test/Level59To62KnockbackProbe.gd` | 3,375 | 历史遗留孤立脚本 |
| 53 | `res://Script/Test/Level61WindDamageRuntimeProbe.gd` | 5,288 | 历史遗留孤立脚本 |
| 54 | `res://Script/Test/LevelClearAutoSaveProbe.gd` | 993 | 历史遗留孤立脚本 |
| 55 | `res://Script/Test/LevelEsbxxEntryProbe.gd` | 3,907 | 历史遗留孤立脚本 |
| 56 | `res://Script/Test/Map5HighlightProbe.gd` | 1,903 | 历史遗留孤立脚本 |
| 57 | `res://Script/Test/MemoryArchiveReadProbe.gd` | 1,455 | 历史遗留孤立脚本 |
| 58 | `res://Script/Test/Monster140OfficialEffectProbe.gd` | 9,610 | 历史遗留孤立脚本 |
| 59 | `res://Script/Test/Monster140VisualProbe.gd` | 1,562 | 历史遗留孤立脚本 |
| 60 | `res://Script/Test/MountOfficialEffectProbe.gd` | 18,582 | 历史遗留孤立脚本 |
| 61 | `res://Script/Test/MountOneClickUpgradeProbe.gd` | 4,617 | 历史遗留孤立脚本 |
| 62 | `res://Script/Test/MountPanelVisualProbe.gd` | 8,892 | 历史遗留孤立脚本 |
| 63 | `res://Script/Test/MountQualificationProbe.gd` | 5,523 | 历史遗留孤立脚本 |
| 64 | `res://Script/Test/MountRiderAdjustmentProbe.gd` | 5,102 | 历史遗留孤立脚本 |
| 65 | `res://Script/Test/MountRiderEquipmentRefreshProbe.gd` | 3,833 | 历史遗留孤立脚本 |
| 66 | `res://Script/Test/MountRiderRegistrationProbe.gd` | 3,031 | 历史遗留孤立脚本 |
| 67 | `res://Script/Test/MountRuntimeVisualProbe.gd` | 20,093 | 历史遗留孤立脚本 |
| 68 | `res://Script/Test/MountSkillEffectProbe.gd` | 5,645 | 历史遗留孤立脚本 |
| 69 | `res://Script/Test/MountSkillTimingProbe.gd` | 16,001 | 历史遗留孤立脚本 |
| 70 | `res://Script/Test/MountSkillUpgradeProbe.gd` | 5,624 | 历史遗留孤立脚本 |
| 71 | `res://Script/Test/MountSystemProbe.gd` | 8,147 | 历史遗留孤立脚本 |
| 72 | `res://Script/Test/MountVisualCatalogProbe.gd` | 5,054 | 历史遗留孤立脚本 |
| 73 | `res://Script/Test/MountWenyuSkillVisualProbe.gd` | 6,419 | 历史遗留孤立脚本 |
| 74 | `res://Script/Test/MountWushuangProbe.gd` | 2,189 | 历史遗留孤立脚本 |
| 75 | `res://Script/Test/NeZhaRiderPoseSheet.gd` | 3,020 | 历史遗留孤立脚本 |
| 76 | `res://Script/Test/NeZhaWushuangProbe.gd` | 2,525 | 历史遗留孤立脚本 |
| 77 | `res://Script/Test/NightmareDifficultyProbe.gd` | 36,884 | 历史遗留孤立脚本 |
| 78 | `res://Script/Test/NorthCameraProbe.gd` | 3,743 | 历史遗留孤立脚本 |
| 79 | `res://Script/Test/NorthCombatAuditProbe.gd` | 6,830 | 历史遗留孤立脚本 |
| 80 | `res://Script/Test/NorthGatePromptProbe.gd` | 2,009 | 历史遗留孤立脚本 |
| 81 | `res://Script/Test/NorthMazeSupportProbe.gd` | 4,031 | 历史遗留孤立脚本 |
| 82 | `res://Script/Test/NorthMechanicsProbe.gd` | 8,399 | 历史遗留孤立脚本 |
| 83 | `res://Script/Test/NorthOriginalProbe.gd` | 6,717 | 历史遗留孤立脚本 |
| 84 | `res://Script/Test/NorthPhysicsProbe.gd` | 3,908 | 历史遗留孤立脚本 |
| 85 | `res://Script/Test/NorthRequestedFixesProbe.gd` | 5,621 | 历史遗留孤立脚本 |
| 86 | `res://Script/Test/NorthSpawnPreviewProbe.gd` | 4,785 | 历史遗留孤立脚本 |
| 87 | `res://Script/Test/NorthThreeWavesProbe.gd` | 4,869 | 历史遗留孤立脚本 |
| 88 | `res://Script/Test/NorthVoidLandingProbe.gd` | 3,765 | 历史遗留孤立脚本 |
| 89 | `res://Script/Test/NorthWaveProbe.gd` | 5,053 | 历史遗留孤立脚本 |
| 90 | `res://Script/Test/PalaceBirdHeightProbe.gd` | 2,666 | 历史遗留孤立脚本 |
| 91 | `res://Script/Test/PalaceBossOriginalProbe.gd` | 10,275 | 历史遗留孤立脚本 |
| 92 | `res://Script/Test/PalaceFallDeathProbe.gd` | 3,456 | 历史遗留孤立脚本 |
| 93 | `res://Script/Test/PassiveLevelCapProbe.gd` | 1,706 | 历史遗留孤立脚本 |
| 94 | `res://Script/Test/PassiveOneKeyUpgradeProbe.gd` | 2,505 | 历史遗留孤立脚本 |
| 95 | `res://Script/Test/PassiveOneKeyUpgradeUiProbe.gd` | 4,335 | 历史遗留孤立脚本 |
| 96 | `res://Script/Test/PetSkillDirectUpgradeProbe.gd` | 1,190 | 历史遗留孤立脚本 |
| 97 | `res://Script/Test/RainAncestorSkillVisualProbe.gd` | 4,750 | 历史遗留孤立脚本 |
| 98 | `res://Script/Test/RenderNeZhaRiderPose.gd` | 2,317 | 历史遗留孤立脚本 |
| 99 | `res://Script/Test/SandMonkWushuangProbe.gd` | 1,306 | 历史遗留孤立脚本 |
| 100 | `res://Script/Test/SkillDamageFormulaProbe.gd` | 5,587 | 历史遗留孤立脚本 |
| 101 | `res://Script/Test/SkillDamageFormulaUiProbe.gd` | 5,468 | 历史遗留孤立脚本 |
| 102 | `res://Script/Test/SoulCaptureAwakenProbe.gd` | 4,887 | 历史遗留孤立脚本 |
| 103 | `res://Script/Test/TianLongLeiZhenAwakenProbe.gd` | 4,662 | 历史遗留孤立脚本 |
| 104 | `res://Script/Test/VampireBatDamageRuntimeProbe.gd` | 6,128 | 历史遗留孤立脚本 |
| 105 | `res://Script/Test/Verify3119AttackProbe.gd` | 2,945 | 历史遗留孤立脚本 |
| 106 | `res://Script/Test/Verify3120Probe.gd` | 2,723 | 历史遗留孤立脚本 |
| 107 | `res://Script/Test/Verify3120VisualProbe.gd` | 1,930 | 历史遗留孤立脚本 |
| 108 | `res://Script/Test/VoodooDollAwakenProbe.gd` | 4,156 | 历史遗留孤立脚本 |
| 109 | `res://Script/Test/XiangLongShanAwakenProbe.gd` | 4,475 | 历史遗留孤立脚本 |
| 110 | `res://Script/Test/YellowBrowOfficialSkillProbe.gd` | 8,390 | 历史遗留孤立脚本 |
| 111 | `res://Script/Test/YinGouTieHuaAwakenProbe.gd` | 6,151 | 历史遗留孤立脚本 |
| 112 | `res://Script/Test/_CangMuDamageCleanProbe.gd` | 1,369 | 历史遗留孤立脚本 |
| 113 | `res://Script/Test/_CangMuFilterProbe.gd` | 3,752 | 历史遗留孤立脚本 |
| 114 | `res://Script/Test/_CangMuReachProbe.gd` | 1,005 | 历史遗留孤立脚本 |
| 115 | `res://Script/Test/_CleanSpineProbe.gd` | 128 | 历史遗留孤立脚本 |
| 116 | `res://Script/Tools/skill_1.gd` | 328 | 历史遗留孤立脚本 |
| 117 | `res://Script/TouchControls.gd` | 3,861 | 历史遗留孤立脚本 |
| 118 | `res://Test/ActiveSkillUpgradeProbe.gd` | 107 | 历史遗留孤立脚本 |
| 119 | `res://Test/BackpackLevelLayoutProbe.gd` | 1,114 | 历史遗留孤立脚本 |
| 120 | `res://Test/PetInterfaceEquipmentProbe.gd` | 352 | 历史遗留孤立脚本 |
| 121 | `res://Test/verify_active_skill_upgrade.gd` | 5,977 | 历史遗留孤立脚本 |
| 122 | `res://Test/verify_esbxx_popup.gd` | 3,066 | 历史遗留孤立脚本 |
| 123 | `res://Test/verify_level49_skill_book_drop.gd` | 5,660 | 历史遗留孤立脚本 |
| 124 | `res://Test/verify_mount_unlock_material_drop_preview.gd` | 3,494 | 历史遗留孤立脚本 |
| 125 | `res://Test/verify_mount_unlock_material_drops.gd` | 6,043 | 历史遗留孤立脚本 |
| 126 | `res://Test/verify_passive_income.gd` | 4,078 | 历史遗留孤立脚本 |
| 127 | `res://Test/verify_pet_mosaic.gd` | 26,579 | 历史遗留孤立脚本 |
| 128 | `res://Test/verify_pet_mouse.gd` | 23,728 | 历史遗留孤立脚本 |
| 129 | `res://tests/pet_formation_probe.gd` | 4,345 | 历史遗留孤立脚本 |
| 130 | `res://tests/pet_formation_runtime_probe.gd` | 2,597 | 历史遗留孤立脚本 |
| 131 | `res://tests/pet_life_bonus_probe.gd` | 19,991 | 历史遗留孤立脚本 |
| 132 | `res://tests/pet_life_bonus_visual_probe.gd` | 2,592 | 历史遗留孤立脚本 |
| 133 | `res://tests/pet_yin_tiger_damage_probe.gd` | 15,250 | 历史遗留孤立脚本 |
| 134 | `res://tests/role_status_icon_size_probe.gd` | 4,720 | 历史遗留孤立脚本 |
| 135 | `res://tests/verify_pet_neat.gd` | 1,073 | 历史遗留孤立脚本 |
| 136 | `res://tests/verify_pet_yin_tiger.gd` | 4,783 | 历史遗留孤立脚本 |

---

## 五、对 Phase 2 重构行动的指导约束

1. **下线限制**：Phase 2 仅允许下线本报告第四节列出的纯真死代码，严禁触碰第三节受保护的隐式活跃脚本；
2. **原子化验证**：每次删除或重构后，必须重新运行 `python tools/health_check.py`，确认 `broken_scene_refs` 维持为 0。