extends Node2D
@onready var Skill_Icon: Sprite2D = $BG / SkillIcon
@onready var WX_mu: Sprite2D = $BG / SkillIcon / MU
@onready var Wp_name: Label = $BG / SkillIcon / Name_
@onready var Skill_name: Label = $BG / SkillName
@onready var Skill_level: Label = $BG / SkillName / Level
@onready var Skill_Infor: Label = $BG / Skill_Infor
@onready var ChooseIcon: Sprite2D = $BG / isChoose
@onready var ChooseButton = $BG / choose
@onready var no_have: Label = $BG / NoHave

var wp_name: String


func _physics_process(_delta: float) -> void :
	checkISchoose()
	set_infor()
func set_infor():
	match wp_name:
		"dshl":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon/dshl.png")
			Wp_name.text = "地煞葫芦"
			Skill_name.text = "烈焰火柱"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("dshl"))
			if PlayerData.CheckHaveWX("dshl", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "释放三道火柱，对范围内的敌人造成多段物理伤害（并令其灼烧）。"
		"tsgj":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon/wjgz.png")
			Wp_name.text = "天煞古剑"
			Skill_name.text = "万剑归宗"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("tsgj"))
			if PlayerData.CheckHaveWX("tsgj", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "召唤数把巨剑从天而降，造成多段魔法伤害(30%概率冰冻命中的目标)。"
		"bsyj":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon/bsyj.png")
			Wp_name.text = "白霜妖镜"
			Skill_name.text = "邪灵寄生"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("bsyj"))
			if PlayerData.CheckHaveWX("bsyj", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "附身到怪物身上偷取生命并令其减速，一段时间后将偷取到的生命给予玩家。"
		"lsys":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon/lsys.png")
			Wp_name.text = "罗刹妖伞"
			Skill_name.text = "暴雨梨花"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("lsys"))
			if PlayerData.CheckHaveWX("lsys", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "散出漫天毒针，命中敌人后会造成少量伤害并令其中毒。"
		"xhmt":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon/xhmt.png")
			Wp_name.text = "血海魔童"
			Skill_name.text = "魔童连击"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("xhmt"))
			if PlayerData.CheckHaveWX("xhmt", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "清除低级负面效果，之后对目标进行多次打击，造成魔法伤害。"
		"kyl":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon/kyl.png")
			Wp_name.text = "枯叶灵"
			Skill_name.text = "沐浴回春"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("kyl"))
			if PlayerData.CheckHaveWX("kyl", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "每秒为玩家恢复生命,期间免疫击退，持续10秒。"
		"xhhl":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon/xhhl.png")
			Wp_name.text = "萱花葫芦"
			Skill_name.text = "万象天引"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("xhhl"))
			if PlayerData.CheckHaveWX("xhhl", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "将怪物吸引至玩家身边."
		"qyj":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon/qyj.png")
			Wp_name.text = "青云剑"
			Skill_name.text = "戮天斩击"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("qyj"))
			if PlayerData.CheckHaveWX("qyj", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "释放剑阵，飞向当前生命最高的敌人，对受到伤害所有目标施加破甲"
		"zjfyd":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon/zjfyd.png")
			Wp_name.text = "混元伏妖盾"
			Skill_name.text = "不灭神盾"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("zjfyd"))
			if PlayerData.CheckHaveWX("zjfyd", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "拥有【不灭神盾】技能，使用后获得【不灭】Buff，一段时间内免疫高于当前生命的伤害。"
		"zjhl":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon/zjhl.png")
			Wp_name.text = "紫金葫芦"
			Skill_name.text = "伏妖神火"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("zjhl"))
			if PlayerData.CheckHaveWX("zjhl", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "拥有【伏妖神火】技能，朝前方喷出火焰，造成物理伤害,并有10%概率施加一层（灼烧）。"


		"yx":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon/yx.png")
			Wp_name.text = "渊邪"
			Skill_name.text = "入魔"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("yx"))
			if PlayerData.CheckHaveWX("yx", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "扣除失去一半生命值，攻击力和暴击率提高50%，持续一段时间"


		"wds_f":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon/五毒兽/wds_f.png")
			Wp_name.text = "五毒兽·风"
			Skill_name.text = "奥义·龙卷"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("wds_f"))
			if PlayerData.CheckHaveWX("wds_f", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "召唤龙卷风！"

		"wds_h":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon/五毒兽/wds_h.png")
			Wp_name.text = "五毒兽·火"
			Skill_name.text = "炎戒火柱"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("wds_h"))
			if PlayerData.CheckHaveWX("wds_h", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "召唤炎戒火柱，烧伤敌人！"

		"wds_y":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon/五毒兽/wds_y.png")
			Wp_name.text = "五毒兽·雨"
			Skill_name.text = "暴风雨"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("wds_y"))
			if PlayerData.CheckHaveWX("wds_y", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "召唤暴风雨！"

		"wds_l":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon//五毒兽/wds_l.png")
			Wp_name.text = "五毒兽·雷"
			Skill_name.text = "雷霆万钧"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("wds_l"))
			if PlayerData.CheckHaveWX("wds_l", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "释放雷霆万钧！"

		"wds_d":
			Skill_Icon.texture = load("res://Art/MagicWeapon/Skill_Icon//五毒兽/wds_d.png")
			Wp_name.text = "五毒兽·电"
			Skill_name.text = "电磁炮"
			Skill_level.text = "Lv: " + str(PlayerData.get_mostLevel("wds_d"))
			if PlayerData.CheckHaveWX("wds_d", "木"):
				WX_mu.visible = true
			else:
				WX_mu.visible = false
			Skill_Infor.text = "释放超电磁炮！"

func checkISchoose():
	if PlayerData.check_zb(wp_name) != []:
		no_have.text = "已拥有"
		if PlayerData.player_data["实战法宝"] == wp_name:
			ChooseButton.visible = false
			ChooseButton.disabled = true
			ChooseIcon.visible = true
		else:
			ChooseButton.visible = true
			ChooseButton.disabled = false
			ChooseIcon.visible = false
	else:
		no_have.text = "未拥有"
		ChooseButton.visible = true
		ChooseButton.disabled = true
		ChooseIcon.visible = false
func _on_choose_pressed() -> void :
	if Global.FB_CD <= 0:
		PlayerData.player_data["实战法宝"] = wp_name
		Global.should_change = true
		MemoryClass.保存游戏(Global.cd_path)
	else:
		Global.AddMessageShow(get_parent().get_parent(), "当前法宝正在使用，无法更换！！", 1.5, Vector2(0, 0))
