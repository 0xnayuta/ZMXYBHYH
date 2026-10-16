extends Node2D
@onready var text_1: Label = $VBoxContainer/text_1
@onready var text_2: Label = $VBoxContainer/text_2
@onready var text_3: Label = $VBoxContainer/text_3
@onready var text_4: Label = $VBoxContainer/text_4
@onready var zhen_fa_level: Label = $BG/ZhenFaLevel
@onready var add_prop: Label = $VBoxContainer2/AddProp
@onready var skill_info: Label = $VBoxContainer2/SkillInfo
var Father
var ZhenFaType: String
var RealName: String


func _physics_process(delta: float) -> void:
	if Father != null:
		ZhenFaType = Father.CurrentZhenFaName
		match ZhenFaType:
			"slz":
				RealName = "森罗阵"
			"lpz":
				RealName = "落魄阵"
			"tsz":
				RealName = "腾蛇阵"
			"tqz":
				RealName = "太清阵"
		zhen_fa_level.text = "阵法等级：Lv." + str(PlayerData.player_data[RealName]["Level"])
		set_prop_text()
		set_add_prop_text()
		set_skill_info()
		set_physics_process(false)


func set_add_prop_text():
	var cur_level = PlayerData.player_data[RealName]["Level"]
	match RealName:
		"森罗阵":
			add_prop.text = "附加属性：最终伤害减少" + str(cur_level) + "%"
		"落魄阵":
			add_prop.text = "附加属性：最终伤害增加" + str(cur_level) + "%"
		"腾蛇阵":
			add_prop.text = "附加属性：受到爆伤伤害减少" + str(cur_level) + "%"
		"太清阵":
			add_prop.text = "附加属性：造成爆伤增加" + str(cur_level) + "%"


func set_skill_info():
	var cur_level = PlayerData.player_data[RealName]["Level"]
	match RealName:
		"森罗阵":
			skill_info.text = "森罗阵Lv." + str(cur_level) + "：使用后立刻获得森罗加护（自身受伤减少" + str(cur_level * 2) + "%，效果持续10秒）。"
		"落魄阵":
			skill_info.text = (
				"落魄阵Lv."
				+ str(cur_level)
				+ "：对进入法阵的敌人有"
				+ str(cur_level * 10)
				+ "%概率对其施加虚弱效果（造成伤害降低"
				+ str(cur_level * 2)
				+ "%），阵法存在8秒，持续10秒。"
			)
		"腾蛇阵":
			skill_info.text = "腾蛇阵Lv." + str(cur_level) + "：自身伤害增加" + str(cur_level * 1.5) + "%，持续10秒。"
		"太清阵":
			skill_info.text = "太清阵Lv." + str(cur_level) + "：每过1秒，清除处于法阵内玩家的低级负面，并恢复一定量的生命，令其1秒内不会被击退，法阵持续10秒。"


func set_prop_text():
	var List = PlayerData.player_data[RealName]
	for i in List:
		if typeof(List[i]) == TYPE_DICTIONARY:
			var Prop = int(List[i]["Level"] * RoleProp.ZhenFaProps[RealName][i]["Value"])
			var PropType = RoleProp.ZhenFaProps[RealName][i]["Type"]
			var TargetText = get_node("PropText/text_" + str(i))
			if Prop > 0:
				TargetText.visible = true
				TargetText.text = i + "号位Lv." + str(List[i]["Level"]) + "：" + str(PropType) + "+" + str(Prop)
			else:
				TargetText.visible = false
