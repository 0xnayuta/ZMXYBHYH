# Flash 动画导出与 Sprite 表切片参考指南插图库

本目录归档了早期造梦西游 Flash (Adobe Animate) 动画逆向移植与 Sprite 表图集（TexturePacker / Spritesheet）导出的图文操作指南插图。

---

## 1. 来源与背景

- **原始来源**：早期开发者在将 Flash 历史底座素材正位移植至 Godot 4 引擎时参考的内部技术指导 Word 文档（`.docx`）的解包媒体库；
- **历史归档**：原存放于活跃游戏工程 `source/v6.5.0.0/docx_extract/`，现已整体剥离出游戏源码工程，归纳至项目参考文档体系中。

## 2. 核心图解指引

目录中的主要截图展示了以下关键技术流程：
- `image10.png`：Adobe Animate 中角色矢量元件库的图层规划与骨架结构（如悟空大圣服各部件图层）；
- `image18.png`：Adobe Animate “生成 Sprite 表 (Sprite Sheet)” 导出参数规范（自定义尺寸、PNG 32 位、裁切、边框与形状填充归零等规范）。
