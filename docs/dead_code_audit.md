# ZMXYBHYH 全工程资产拓扑与死代码审计报告 (Phase 1)

> 生成时间: 2026-10-17 19:40:50  
> 审计对象: `G:\source\repos\ZMXYBHYH\source\v6.5.0.0`  
> 引擎环境: `Godot 4.7.2 Headless`

---

## 一、全工程资产与引用健康指标看板

| 检测维度 | 真实指标 | 状态 | 结论与安全评估 |
|:---|:---|:---|:---|
| **全量场景资源断裂数** | **0 处** | `PASSED` | 1,242 个场景中所有外部资源全量匹配，无任何悬空或丢失引用 |
| **GDScript 语法解析错误** | **0 处** | `PASSED` | 全量 874 个脚本均已通过 Godot 4.7.2 核心解析树校验 |
| **直接引用活跃脚本** | **686 个 (100.0%)** | `HEALTHY` | 被场景、代码 `preload`/`load` 或 Autoload 明确消费 |
| **动态加载/全局符号脚本** | **1 个** | `PROTECTED` | 具备动态字符串前缀或全局 `class_name`，严禁误杀 |
| **确认纯死代码 (Dead Code)** | **0 个** | `PENDING_CLEANUP` | 全局 0 引用、无动态前缀、无继承，可在 Phase 2 安全下线 |

---

## 二、受保护的动态加载模式 (Dynamic Load Guard)

以下前缀在代码中通过变量拼接动态 `load(...)`，其目录下的所有子脚本**严禁作为孤岛删除**：

- `load("res://Art/BackPack/AllItems/" + ...)`
- `load("res://Art/Level/Challenge/ui_beizhan_pj_" + ...)`
- `load("res://Art/LevelInfoBg/" + ...)`
- `load("res://Art/MainGame/choose_player/" + ...)`
- `load("res://Art/MainGame/choose_player/xx_" + ...)`
- `load("res://Art/Monster/monster_head/" + ...)`
- `load("res://Art/Skill/SkillIcon/" + ...)`
- `load("res://Art/all_number/Level/Level_" + ...)`

---

## 三、隐式活跃脚本保护清单 (1 个)

| 脚本路径 | 保护原因 | 详细依据 |
|:---|:---|:---|
| `res://Script/monster/pet_tiger_boss_base.gd` | 拥有全局 class_name: PetTigerBossBase | 被 0 个外部文件引用或提供全局类型接口 |

---

## 四、确认纯真死代码清单 (0 个 · 建议 Phase 2 安全下线)

经过全量场景、代码 AST、Autoload、`class_name` 反射与动态字符串前缀多重交叉检验，以下脚本**确认为完全无引用的历史陈旧代码**，可在 Phase 2 作为第一批瘦身对象安全移除：

| 序号 | 脚本相对路径 | 源码大小 (字节) | 归属类别建议 |
|:---|:---|:---|:---|

---

## 五、对 Phase 2 重构行动的指导约束

1. **下线限制**：Phase 2 仅允许下线本报告第四节列出的纯真死代码，严禁触碰第三节受保护的隐式活跃脚本；
2. **原子化验证**：每次删除或重构后，必须重新运行 `python scripts/health_check.py`，确认 `broken_scene_refs` 维持为 0。