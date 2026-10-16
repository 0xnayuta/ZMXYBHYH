# 造梦西游八荒 / 八荒湮隳 现代化重构与工程资产仓库

本工程致力于《八荒湮隳》（《造梦西游八荒》）的现代 Godot 4 游戏引擎架构正位提纯、跨版本资产比对、GDScript 现代语法演进与运行时架构重构。

---

## 一、三大源码工程定位与当前状态

| 版本 / 标识 | 存放位置 | 当前状态 | 核心产物形态 | 说明 |
| :--- | :--- | :--- | :--- | :--- |
| **《八荒湮隳》1.2.0.1** | `source/v1.2.0.1/` | **全资产已落盘恢复** | `.gd` (411个), `.tscn`, `project.godot`, `.png`, `.mp3` | 早期原生明文源码工程镜像（3,428 贴图、108 音频、14 字体），用于对照早期原始逻辑与原生数值定义（只读基线） |
| **《八荒湮隳》1.3.3.2** | `source/v1.3.3.2/` | **纯净反编译源码工程** | `.gd` 源码 (433个), `.png` (4,540个), `project.godot` | 原作者 1.3.3.2 独立正位工程镜像（4,540 PNG, 433 脚本），包含早春樱花新增的邪四师徒 Boss、五毒兽法宝、关卡结构与组件化架构（只读基线） |
| **造梦青川版 6.5.0.0** | `source/v6.5.0.0/` | **活跃重构开发工程** | `.gd` 源码 (734个规范化脚本), `.png` (1.6万+), `project.godot` | **当前唯一的活跃开发工程**。已完成全量 GDScript 2.0 规范化、Unix LF 行尾归一化、背包三层守卫重构与花果山 Stage 1~4 全链路闭环 |

---

## 二、项目目录架构

```text
G:\source\repos\ZMXYBHYH\
├── .gitattributes               # Git 全局文本归一化 (强制 LF) 与二进制保护
├── .editorconfig                # 跨编辑器排版规范 (UTF-8, Tab 缩进, LF)
├── .gdlintrc                    # 静态代码审查规范配置 (对标 clang-tidy)
├── .git-blame-ignore-revs       # Git Blame 历史责任穿透列表
├── .gitignore                   # 严格排除本地环境私有缓存与外部临时资产
├── README.md                    # 项目全景索引与工程开发指南
├── AGENTS.md                    # AI 协作者架构规范与门禁指引
│
├── docs/                        # 架构设计、重构审计与演进路线图
│   ├── roadmap.md               # 现代化重构与工程演进路线图 (Phase 1~4 已收官)
│   └── dead_code_audit.md       # 全工程死代码依赖拓扑与安全瘦身审计报告
│
├── source/                      # [核心源码控制区 · 三大工程并列 · 可直接用 Godot 打开编辑]
│   ├── v1.2.0.1/                # 1.2.0.1 历史参考工程（3,428 PNG, 108 MP3, 411 脚本 · 只读）
│   ├── v1.3.3.2/                # 1.3.3.2 独立正位工程（4,540 PNG, 433 脚本 · 只读）
│   └── v6.5.0.0/                # [唯一活跃开发主工程] 满足 0 ERROR / 0 WARNING 门禁
│       ├── Scene/               # 场景树结构与节点 (.tscn)
│       ├── Script/              # 现代 GDScript 业务逻辑脚本 (.gd)
│       ├── Art/                 # 真实 PNG 图像素材与精灵帧
│       ├── Music/               # MP3 音频原件与音效
│       ├── Font/                # 字体资源
│       ├── Shader/              # 着色器源码 (.gdshader)
│       ├── addons/              # 插件系统 (anti_cheat, godot-mcp 等)
│       └── project.godot        # Godot 4.7.2 核心项目配置
│
└── scripts/                     # 生产级自动化测试、CI 门禁与工程运维工具链
    ├── check_all.py             # 一键式全维度质量总指挥门禁 (行尾 + 格式 + Lint + 编译)
    ├── format_all.py            # GDScript 代码风格规范格式化流水线 (gdformat 4.5.0)
    ├── health_check.py          # 全盘场景引用拓扑与 874 脚本 Headless 编译扫描
    ├── level_test_runner.py     # 关卡全自动极速冒烟战斗测试夹具
    ├── normalize_eol.py         # 跨平台文本行尾 LF 归一化工具
    │
    └── legacy/                  # [历史资产正位与跨版本构建流水线]
        ├── recover_v1.2_assets.py           # 1.2.0.1 历史资产正位转码脚本
        ├── reconstruct_1.3.3.2_to_source.py # 1.3.3.2 历史工程构建流水线
        ├── reconstruct_6.5.0.0_to_source.py # 6.5.0.0 历史骨架重组流水线
        └── restore_6.5.0.0_scenes.py        # 历史场景与依赖修复工具
```

---

## 三、工程质量流水线与日常开发指南

本仓库严格对标现代大型工程的质量守护标准，在日常开发或提交前，请运行以下自动化命令：

### 1. 一键全维度工程质量总指挥门禁 (Comprehensive Quality Gate)
```bash
python scripts/check_all.py
```
> 一键串联四大防御维度：
> 1. **跨平台行尾 LF 检查**：确保 0 CRLF 残留；
> 2. **GDScript 格式校验**：确保全盘脚本 100% 符合官方排版规范；
> 3. **静态 Lint 审查**：拦截缩进混用、未赋值死表达式与自身比较等逻辑异味；
> 4. **引擎静态编译体检**：脱离 GUI 极速校验 1,242 场景依赖与 874 个脚本编译语法。

### 2. 代码自动格式化
```bash
# 校验格式（不写入文件，CI 模式）
python scripts/format_all.py source/v6.5.0.0 --check

# 执行格式化（自动覆写并强制 LF 归一化）
python scripts/format_all.py source/v6.5.0.0
```

### 3. 全工程依赖拓扑与编译体检
```bash
python scripts/health_check.py
```

### 4. 极速战斗实机自动化冒烟测试
```bash
# 启动花果山 Stage 1~4 全流程自动化测试，断言胜利结算与日志纯净度 (0 ERROR, 0 WARNING)
python scripts/level_test_runner.py
```
