extends Node
var Player = PlayerData.player_data
var Initialized_Data = {}
var Get_sj = {}
var Keys = "qwertyuio" + OS.get_unique_id() + "plmqsc128"

var level



func 读取游戏(路径: String) -> int:
	if not FileAccess.file_exists(路径):
		print("文件不存在:", 路径)
		return 1
	var 读取 = FileAccess.open_encrypted_with_pass(路径, FileAccess.READ, Keys)

	var 文件内容 = 读取.get_as_text()
	读取.close()

	var json_parser = JSON.new()
	var json_data = json_parser.parse_string(文件内容)
	if json_data == null:
		print("JSON 解析失败:", json_parser.get_error_message())
		remove_data()
		return 1

	for key in Initialized_Data:
		if json_data.has(key):
			Initialized_Data[key] = json_data[key]
		else:
			json_data[key] = Initialized_Data[key]

	for key in Player:
		if json_data.has(key):
			Player[key] = json_data[key]
		else:
			json_data[key] = Player[key]

	return json_data.get("玩家等级", 1)
func 提前数据(路径: String) -> Dictionary:
	var List = {}

	if not FileAccess.file_exists(路径):
		return List
	var 读取 = FileAccess.open_encrypted_with_pass(路径, FileAccess.READ, Keys)

	var 文件内容 = 读取.get_as_text()
	读取.close()

	var json_parser = JSON.new()
	var json_data = json_parser.parse_string(文件内容)
	if json_data == null:
		print("JSON 解析失败:", json_parser.get_error_message())
		return List

	for key in json_data:
		List[key] = json_data[key]

	return List

func 得到数据(路径: String) -> int:
	if not FileAccess.file_exists(路径):
		return 1
	var 读取 = FileAccess.open_encrypted_with_pass(路径, FileAccess.READ, Keys)

	var 文件内容 = 读取.get_as_text()
	读取.close()

	var json_parser = JSON.new()
	var json_data = json_parser.parse_string(文件内容)
	if json_data == null:
		print("JSON 解析失败:", json_parser.get_error_message())
		return 1

	return json_data.get("玩家等级", 1)

func 保存游戏(path: String):
	var get_cdh = path.split("Ar_")[1].split(".")[0]
	MainSet.set_data["time" + str(get_cdh)] = get_time()
	MemoryClass.main_bc()
	var 写入 = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, Keys)

	if 写入 != null:

		写入.store_line(JSON.stringify(Player, "\t"))




func main_dq():

	if not FileAccess.file_exists("user://MainGame.json"):
		print("MainGame.json 文件不存在！")
		return


	var 读取 = FileAccess.open("user://MainGame.json", FileAccess.READ)
	var 文件内容 = 读取.get_as_text()
	读取.close()


	var json_parser = JSON.new()
	var json_data = json_parser.parse_string(文件内容)
	if json_data == null:
		print("JSON 解析失败:", json_parser.get_error_message())
		return


	var Main_set = MainSet.set_data
	for key in Main_set:
		if json_data.has(key):
			Main_set[key] = json_data[key]
		else:

			print("警告：JSON 数据缺少键 '%s'，使用默认值" % key)



func main_bc():
	var 写入 = FileAccess.open("user://MainGame.json", FileAccess.WRITE)
	if FileAccess.file_exists("user://MainGame.json"):
		if 写入 != null:
			写入.store_line(JSON.stringify(MainSet.set_data))
func get_time():
	var date = Time.get_date_string_from_system()
	var time_ = Time.get_time_string_from_system()
	var last_time = date + " " + time_
	return last_time
func get_cd_number():
	var number = Global.cd_path.split("Ar_")[1].split(".")[0]

	return number
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
	"兜率宫1": 0, 
	"兜率宫2": 0, 
	"兜率宫3": 0, 
	"兜率宫4": 0, 
	"兜率宫5": 0, 
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
	MainSet.set_data["name" + str(get_cd_number())] = ""
	MainSet.set_data["time" + str(get_cd_number())] = ""
	MemoryClass.main_bc()
func remove_play_data():
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
	"兜率宫1": 0, 
	"兜率宫2": 0, 
	"兜率宫3": 0, 
	"兜率宫4": 0, 
	"兜率宫5": 0, 
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
	for i in Initialized_Data:
		if Initialized_Data != null:
			if Player.has(i):
				Player[i] = Initialized_Data[i]
	pass
func Remove():
	Global.AddMessageShow(Global.Windows_, "该存档有作弊嫌疑，存档数据已经全部清除！！不会有人玩个单机游戏还要开挂吧？？真是又菜又爱玩呢~", 4, Vector2(485, 295))
	remove_data()
	var 写入 = FileAccess.open_encrypted_with_pass(Global.cd_path, FileAccess.WRITE, MemoryClass.Keys)

	写入.store_line(JSON.stringify(Initialized_Data))
