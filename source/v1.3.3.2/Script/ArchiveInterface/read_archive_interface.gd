extends Node2D
var Initialized_Data = {}
@onready var cd_number: LineEdit = $background / cd_number
@onready var cd_1_level: Label = $cd_jm / cd_1_2 / cd_1 / cd_1_level
@onready var cd_3_level: Label = $cd_jm / cd_3_4 / cd_3 / cd_3_level
@onready var cd_4_level: Label = $cd_jm / cd_3_4 / cd_4 / cd_4_level
@onready var cd_5_level: Label = $cd_jm / cd_5_6 / cd_5 / cd_5_level
@onready var cd_6_level: Label = $cd_jm / cd_5_6 / cd_6 / cd_6_level
@onready var cd_2_level: Label = $cd_jm / cd_1_2 / cd_2 / cd_2_level
@onready var time1: Label = $cd_jm / cd_1_2 / cd_1 / time1
@onready var time2: Label = $cd_jm / cd_1_2 / cd_2 / time2
@onready var time3: Label = $cd_jm / cd_3_4 / cd_3 / time3
@onready var time4: Label = $cd_jm / cd_3_4 / cd_4 / time4
@onready var time5: Label = $cd_jm / cd_5_6 / cd_5 / time5
@onready var time6: Label = $cd_jm / cd_5_6 / cd_6 / time6
@onready var name_1: Label = $cd_jm / cd_1_2 / cd_1 / name_1
@onready var name_2: Label = $cd_jm / cd_1_2 / cd_2 / name_2
@onready var name_3: Label = $cd_jm / cd_3_4 / cd_3 / name_3
@onready var name_4: Label = $cd_jm / cd_3_4 / cd_4 / name_4
@onready var name_5: Label = $cd_jm / cd_5_6 / cd_5 / name_5
@onready var name_6: Label = $cd_jm / cd_5_6 / cd_6 / name_6
var choose_jm
var time_1
var time_2
var time_3
var time_4
var time_5
var time_6
var is_set
func remove_data():
	Initialized_Data = {
	"FileValue": 1.0, 
	"FristJiejiao": true, 
	"玩家等级": int(1), 
	"玩家当前经验": 0, 
	"装备列表": {"页码1": [], "页码2": [], "页码3": [], "页码4": [], "页码5": [], "页码6": [], "页码7": [], "页码8": [], "页码9": [], "页码10": []}, 
	"道具列表": {"页码1": [], "页码2": [], "页码3": [], "页码4": [], "页码5": [], "页码6": [], "页码7": [], "页码8": [], "页码9": [], "页码10": []}, 
	"消耗品列表": {"页码1": [], "页码2": [], "页码3": [], "页码4": [], "页码5": [], "页码6": [], "页码7": [], "页码8": [], "页码9": [], "页码10": []}, 
	"幻化列表": {"武器": "", "防具": "", "时装": "", "翅膀": "", "头衔": ""}, 
	"幻化拥有列表": [], 
	"实战法宝": "", 
	"武器": [], 
	"防具": [], 
	"饰品": [], 
	"翅膀": [], 
	"头衔": [], 
	"时装": [], 
	"法宝": [], 
	"关卡评价": {"花果山": 0, "水帘洞": 0, "桃花源": 0, "蝙蝠窟": 0, "七星洞": 0, "迦楼罗之穴": 0, "浅岸": 0, "东海": 0, "鲨之涡流": 0, "牛魔谷": 0, "火焰山": 0, 
	"鬼城": 0, "无常巷": 0, "鬼门关": 0, "接引院": 0, "判官府": 0, "阎罗殿": 0, "忘川河": 0, "奈何桥": 0, "望乡台": 0, "转轮殿": 0, "螺旋地狱": 0, 
	"九重天": 0, "天宫道": 0, "南天门": 0, "南天王殿": 0, "西天王殿": 0, "北天王殿": 0, "彩虹楼": 0, "朝会殿": 0, "凌霄宝殿": 0, "玲珑宝塔": 0, "兜率宫": 0, 
	"流沙河": 0, "火龙岛": 0, "九龙岛": 0, "龙脊山": 0, "尾妖林": 0, "仙音岛": 0, "仙幻岛": 0, "仙树岛": 0, "蓬莱岛": 0, "蓬莱仙境": 0, 
	"绝仙门": 0, "戮仙门": 0, "陷仙门": 0, "紫晶门": 0, "紫仙门": 0, "指景宫": 0, "通天戮台": 0}, 
	"花果山": 1, 
	"水帘洞": 0, 
	"桃花源": 0, 
	"蝙蝠窟": 0, 
	"七星洞": 0, 
	"迦楼罗之穴": 0, 
	"浅岸": 0, 
	"东海": 0, 
	"鲨之涡流": 0, 
	"牛魔谷": 0, 
	"地府": false, 
	"天庭": false, 
	"截教天境": false, 
	"碧游宫": false, 
	"玲珑宝塔层数": 0, 
	"Map_num": 1, 
	"鬼城": 1, 
	"无常巷": 0, 
	"鬼门关": 0, 
	"接引院": 0, 
	"判官府": 0, 
	"阎罗殿": 0, 
	"忘川河": 0, 
	"奈何桥": 0, 
	"望乡台": 0, 
	"转轮殿": 0, 
	"九重天": 0, 
	"天宫道": 0, 
	"南天门": 0, 
	"南天王殿": 0, 
	"西天王殿": 0, 
	"北天王殿": 0, 
	"彩虹楼": 0, 
	"朝会殿": 0, 
	"凌霄宝殿": 0, 
	"玲珑宝塔": 0, 
	"兜率宫": 0, 
	"火龙岛": 0, 
	"九龙岛": 0, 
	"龙脊山": 0, 
	"尾妖林": 0, 
	"仙音岛": 0, 
	"仙幻岛": 0, 
	"仙树岛": 0, 
	"蓬莱岛": 0, 
	"蓬莱仙境": 0, 
	"绝仙门": 0, 
	"戮仙门": 0, 
	"陷仙门": 0, 
	"紫晶门": 0, 
	"紫仙门": 0, 
	"指景宫": 0, 
	"通天戮台": 0, 
	"八仙过海": 0, 
	"翅膀显示": true, 
	"头衔显示": true, 
	"时装显示": true, 
	"zubi": false, 
	"截教": false, 
	"成长礼包1": false, 
	"成长礼包2": false, 
	"成长礼包3": false, 
	"成长礼包4": false, 
	"天庭之证": false, 
	"小有所藏": false, 
	"业余收藏家": false, 
	"专业收藏家": false, 
	"痴迷收藏家": false, 
	"强迫症收藏家": false, 
	"骨灰级收藏家": false, 
	"行走博物馆": false, 
	"勇闯八荒": false, 
	"至尊宝": false, 
	"初始Buff": [], 
	"ieho": false, 
	"猕猴王": 0, "水帘洞天": false, 
	"禺狨王": 0, "桃花深谷": false, 
	"蝙蝠石像": 0, "身陷蝙蝠窟": false, 
	"狮驼王": 0, "密探七星洞": false, 
	"鹏魔王": 0, "金翅大鹏": false, 
	"龟丞相": 0, "东海浅岸": false, 
	"蛟魔王": 0, "东海龙宫": false, 
	"鲨魔王": 0, "嗜血鲨鱼涡流": false, 
	"牛魔王·鬼": 0, "决战平天大圣": false, 
	"魔·红孩儿": 0, "炽焰火焰山": false, 
	"守夜人": 0, "诡异城镇": false, 
	"黑无常": 0, "白无常": 0, "阴魂巷": false, 
	"傀儡王": 0, "诡异石像": false, 
	"秦广王": 0, "一殿阎罗": false, 
	"判官": 0, "末日审判": false, 
	"阎罗王": 0, "冥府阎罗殿": false, 
	"宋帝王": 0, "凶险冥河": false, 
	"夜叉": 0, "三生惘然": false, 
	"孟婆": 0, "永别思乡岭": false, 
	"转轮·真法": 0, "浩瀚星河": false, 
	"刑天": 0, "十八层地狱": false, 
	"楚江王": 0, "活大地狱": false, 
	"龙王·低": 0, "龙王·高": 0, "水晶宫1": false, "水晶宫2": false, 
	"白骨精·精": 0, "白骨精·妖": 0, "白骨精·魔": 0, "三打白骨精1": false, "三打白骨精2": false, 
	"沙华": 0, "曼珠": 0, "彼岸双生": false, 
	"青蛇": 0, "冥河蛇妖": false, 
	"河童": 0, "诡异河童": false, 
	"战神刑天": 0, "不灭战神": false, "无首神": false, 
	"牛魔王·魂": 0, "决战平天大圣2": false, 
	"生命丹1": 0, "生命丹2": 0, "生命丹3": 0, "生命丹4": 0, "生命丹5": 0, 
	"魔法丹1": 0, "魔法丹2": 0, "魔法丹3": 0, "魔法丹4": 0, "魔法丹5": 0, 
	"攻击丹1": 0, "攻击丹2": 0, "攻击丹3": 0, "攻击丹4": 0, "攻击丹5": 0, 
	"暴击丹1": 0, "暴击丹2": 0, "暴击丹3": 0, "暴击丹4": 0, "暴击丹5": 0, 
	"幸运丹1": 0, "幸运丹2": 0, "幸运丹3": 0, "幸运丹4": 0, "幸运丹5": 0, 
	"回魔丹1": 0, "回魔丹2": 0, "回魔丹3": 0, "回魔丹4": 0, "回魔丹5": 0, 
	"特殊Buff": [], 
	"宝珠列表": [], 
	"MyTime": {}, 
	"MyId": 0, 
	"已佩戴阵法": "", 
	"拥有阵法": {}, 
	"落魄阵": {"1": {"Name": "幽", "Level": 0, "InName": "lpzyou"}, "2": {"Name": "冥", "Level": 0, "InName": "lpzming"}
	, "3": {"Name": "鬼", "Level": 0, "InName": "lpzgui"}, "Level": 0}, 
	"森罗阵": {"1": {"Name": "天", "Level": 0, "InName": "lslztian"}, "2": {"Name": "地", "Level": 0, "InName": "lslzdi"}
	, "3": {"Name": "人", "Level": 0, "InName": "ren"}, "Level": 0}, 
	"腾蛇阵": {"1": {"Name": "天枢", "Level": 0, "InName": "tsztianshu"}
	, "2": {"Name": "天璇", "Level": 0, "InName": "tsztianxuan"}, "3": {"Name": "天玑", "Level": 0, "InName": "tsztianji"}
	, "4": {"Name": "天权", "Level": 0, "InName": "tsztianquan"}, "Level": 0}, 
	"太清阵": {"1": {"Name": "青龙", "Level": 0, "InName": "tqzqinglong"}, "2": {"Name": "白虎", "Level": 0, "InName": "tqzbaihu"}
	, "3": {"Name": "朱雀", "Level": 0, "InName": "tqzzhuque"}
	, "4": {"Name": "玄武", "Level": 0, "InName": "tqzxuanwu"}, "Level": 0}, 
	"coin_num": 0, 
	"放入列表": {"物品1": [], "物品2": [], "物品3": []}, 
	"镶嵌列表": [], 
	"分解列表": [], 
	"Myself": 0, 
	"购买次数": 0, 
	"技能学习":
	{"技能1": {"学习": 0, "等级": 0}, "技能2": {"学习": 0, "等级": 0}, "技能3": {"学习": 0, "等级": 0}, "技能4": {"学习": 0, "等级": 0}, 
		"技能5": {"学习": 0, "等级": 0}, "技能6": {"学习": 0, "等级": 0}, "技能7": {"学习": 0, "等级": 0}, "技能8": {"学习": 0, "等级": 0}, 
		"技能9": {"学习": 0, "等级": 0}, "技能10": {"学习": 0, "等级": 0}, "技能键位": {"Y": "", "U": "", "I": "", "O": "", "L": ""}}, 
	"被动技能": {"热血": 0, "魔泉": 0, "狂暴": 0, "永恒": 0, "辉煌": 0, "敏锐": 0}
	}
	MainSet.set_data["name" + str(cd_number.text)] = ""
	MainSet.set_data["time" + str(cd_number.text)] = ""
	MemoryClass.main_bc()
func _ready() -> void :
	MemoryClass.main_dq()
func _physics_process(_delta: float) -> void :

	if choose_jm != null:
		if choose_jm.is_qd:
			remove_data_()
	if not is_set:
		if MainSet.set_data["name1"] != "":
			name_1.text = "名字：" + str(MainSet.set_data["name1"])
		else:
			cd_1_level.position.y = 30
			name_1.text = ""
		if MainSet.set_data["name2"] != "":
			name_2.text = "名字：" + str(MainSet.set_data["name2"])
		else:
			cd_2_level.position.y = 30
			name_2.text = ""
		if MainSet.set_data["name3"] != "":
			name_3.text = "名字：" + str(MainSet.set_data["name3"])
		else:
			cd_3_level.position.y = 30
			name_3.text = ""
		if MainSet.set_data["name4"] != "":
			name_4.text = "名字：" + str(MainSet.set_data["name4"])
		else:
			cd_4_level.position.y = 30
			name_4.text = ""
		if MainSet.set_data["name5"] != "":
			name_5.text = "名字：" + str(MainSet.set_data["name5"])
		else:
			cd_5_level.position.y = 30
			name_5.text = ""
		if MainSet.set_data["name6"] != "":
			name_6.text = "名字：" + str(MainSet.set_data["name6"])
		else:
			cd_6_level.position.y = 30
			name_6.text = ""
		time1.text = str(MainSet.set_data["time1"])
		time2.text = str(MainSet.set_data["time2"])
		time3.text = str(MainSet.set_data["time3"])
		time4.text = str(MainSet.set_data["time4"])
		time5.text = str(MainSet.set_data["time5"])
		time6.text = str(MainSet.set_data["time6"])
		if MainSet.set_data["time1"] != "":
			cd_1_level.text = "Lv：" + str(MemoryClass.得到数据("user://MyAr_1.json")) + "    " + str(GeTroleNmae(1))
		else:
			cd_1_level.text = "空存档"
		if MainSet.set_data["time2"] != "":
			cd_2_level.text = "Lv：" + str(MemoryClass.得到数据("user://MyAr_2.json")) + "    " + str(GeTroleNmae(2))
		else:
			cd_2_level.text = "空存档"
		if MainSet.set_data["time3"] != "":
			cd_3_level.text = "Lv：" + str(MemoryClass.得到数据("user://MyAr_3.json")) + "    " + str(GeTroleNmae(3))
		else:
			cd_3_level.text = "空存档"
		if MainSet.set_data["time4"] != "":
			cd_4_level.text = "Lv：" + str(MemoryClass.得到数据("user://MyAr_4.json")) + "    " + str(GeTroleNmae(4))
		else:
			cd_4_level.text = "空存档"
		if MainSet.set_data["time5"] != "":
			cd_5_level.text = "Lv：" + str(MemoryClass.得到数据("user://MyAr_5.json")) + "    " + str(GeTroleNmae(5))
		else:
			cd_5_level.text = "空存档"
		if MainSet.set_data["time6"] != "":
			cd_6_level.text = "Lv：" + str(MemoryClass.得到数据("user://MyAr_6.json")) + "    " + str(GeTroleNmae(6))
		else:
			cd_6_level.text = "空存档"
	is_set = true

func _on_close_pressed() -> void :
	queue_free()


func _on_delete_pressed() -> void :
	if int(cd_number.text) > 6 or int(cd_number.text) <= 0:
		Global.AddMessageShow(self, "找不到存档" + str(cd_number.text) + "的信息，请确保正确输入了存档号！！", 1.5, Vector2(470, 300))
		return
	if cd_number.text == "":
		Global.AddMessageShow(self, "找不到存档信息，请确保正确输入了存档号！！", 1.5, Vector2(470, 300))
		return
	else:
		choose_jm = Global.add_choose_text(self, Vector2(0, 0), "确定要删除存档" + str(cd_number.text) + "吗？\n（删除后无法恢复！）", 4)
func remove_data_():
	is_set = false
	remove_data()
	var 写入 = FileAccess.open_encrypted_with_pass("user://MyAr_" + cd_number.text + ".json", FileAccess.WRITE, MemoryClass.Keys)
	写入.store_line(JSON.stringify(Initialized_Data))
	Global.AddMessageShow(self, "存档" + cd_number.text + "已重置为初始状态！！", 1.5, Vector2(470, 300))

func _on_cd_1_pressed() -> void :
	Global.cd_path = "user://MyAr_1.json"
	MemoryClass.读取游戏(Global.cd_path)
	if cd_1_level.text == "空存档":
		get_tree().change_scene_to_file("res://Scene/Main_menu/ChoosePlayer.tscn")
	else:
		change_to_map()

func _on_cd_2_pressed() -> void :
	Global.cd_path = "user://MyAr_2.json"
	MemoryClass.读取游戏(Global.cd_path)
	if cd_2_level.text == "空存档":
		get_tree().change_scene_to_file("res://Scene/Main_menu/ChoosePlayer.tscn")
	else:
		change_to_map()

func _on_cd_3_pressed() -> void :
	Global.cd_path = "user://MyAr_3.json"
	MemoryClass.读取游戏(Global.cd_path)
	if cd_3_level.text == "空存档":
		get_tree().change_scene_to_file("res://Scene/Main_menu/ChoosePlayer.tscn")
	else:
		change_to_map()

func _on_cd_4_pressed() -> void :
	Global.cd_path = "user://MyAr_4.json"
	MemoryClass.读取游戏(Global.cd_path)
	if cd_4_level.text == "空存档":
		get_tree().change_scene_to_file("res://Scene/Main_menu/ChoosePlayer.tscn")
	else:
		change_to_map()

func _on_cd_5_pressed() -> void :
	Global.cd_path = "user://MyAr_5.json"
	MemoryClass.读取游戏(Global.cd_path)
	if cd_5_level.text == "空存档":
		get_tree().change_scene_to_file("res://Scene/Main_menu/ChoosePlayer.tscn")
	else:
		change_to_map()

func _on_cd_6_pressed() -> void :
	Global.cd_path = "user://MyAr_6.json"
	MemoryClass.读取游戏(Global.cd_path)
	if cd_6_level.text == "空存档":
		get_tree().change_scene_to_file("res://Scene/Main_menu/ChoosePlayer.tscn")
	else:
		change_to_map()

func get_time():
	var date = Time.get_date_string_from_system()
	var time_ = Time.get_time_string_from_system()
	var last_time = date + " " + time_
	return last_time
func change_to_map():
	match int(PlayerData.player_data["Map_num"]):
		1:
			get_tree().change_scene_to_file("res://Scene/Main_menu/Map_1.tscn")
		2:
			if PlayerData.player_data["地府"]:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_2.tscn")
			else:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_1.tscn")
		3:
			if PlayerData.player_data["天庭"]:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_3.tscn")
			else:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_1.tscn")

		4:
			if PlayerData.player_data["截教天境"]:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_4.tscn")
			else:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_1.tscn")

func GeTroleNmae(cd_num):
	var num: int
	match cd_num:
		1:
			num = MemoryClass.提前数据("user://MyAr_1.json")["Myself"]
		2:
			num = MemoryClass.提前数据("user://MyAr_2.json")["Myself"]
		3:
			num = MemoryClass.提前数据("user://MyAr_3.json")["Myself"]
		4:
			num = MemoryClass.提前数据("user://MyAr_4.json")["Myself"]
		5:
			num = MemoryClass.提前数据("user://MyAr_5.json")["Myself"]
		6:
			num = MemoryClass.提前数据("user://MyAr_6.json")["Myself"]
	match num:
		1:
			return "悟空"
		2:
			return "唐僧"
		3:
			return "八戒"
		4:
			return "沙僧"
		5:
			return "小白龙"
		6:
			return "玉兔"
