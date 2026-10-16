extends Node2D
class_name BasicTask
@onready var text: Label = $BG/ms/ScrollContainer/Text
@onready var task_list: VBoxContainer = $BG/ScrollContainer/TaskList
@onready var reward_list: GridContainer = $BG/jl/ScrollContainer/RewardList
@onready var lqjl: TextureButton = $BG/lqjl
@onready var title: Label = $BG/ColorRect/Title
@onready var num: Label = $BG/ColorRect/Title/Num
var ActivityFinishNum: int = 0
var DailyFinishNum: int = 0
var TaskIsFinish: bool
var CurrentTaskName: String
var CurrentTaskType: int = 1
var AllDailyList = {
	"关注造梦青川":
	{
		"TaskName": "关注造梦青川",
		"TaskType": "DailyTask",
		"TaskInfo": "关注造梦青川",
		"TaskReward": [{"Name": "zmcq", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0}],
		"UnlimitedClaim": true,
	},
	"至尊骨养成一":
	{
		"TaskName": "至尊骨养成一",
		"TaskType": "DailyTask",
		"TaskInfo": "玩家等级达到1级就可以领取\n（" + str(PlayerData.player_data["玩家等级"]) + "/1）",
		"TaskReward": [{"Name": "psdzzg", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0}],
		"UnlimitedClaim": true,
	},
}
var AllActivityList = {
	"新的旅途":
	{
		"TaskName": "新的旅途",
		"TaskType": "ActivityTask",
		"TaskInfo": "玩家等级达10级\n" + "（" + str(PlayerData.player_data["玩家等级"]) + "/1）",
		"TaskTarget": {"玩家等级": 1},
		"FinishType": 2,
		"TaskReward":
		[
			{
				"Name": "zcld",
				"Value": 1,
				"Prop": {},
				"WX":
				[
					"金",
					"木",
				],
				"StrengthValue": 0
			},
		],
	},
	"七魔尽伏":
	{
		"TaskName": "七魔尽伏",
		"TaskType": "ActivityTask",
		"TaskInfo": "通关所有图一副本（花果山、水帘洞、桃花源、蝙蝠窟、七星洞、迦楼罗之穴、浅岸、东海、鲨之涡流、牛魔谷）",
		"TaskTarget":
		{"花果山": 1, "水帘洞": 1, "桃花源": 1, "蝙蝠窟": 1, "七星洞": 1, "迦楼罗之穴": 1, "浅岸": 1, "东海": 1, "鲨之涡流": 1, "牛魔谷": 1},
		"FinishType": 6,
		"TaskReward":
		[
			{"Name": "fmxz", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "jsbx_1", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
		]
	},
	"十殿肃清":
	{
		"TaskName": "十殿肃清",
		"TaskType": "ActivityTask",
		"TaskInfo": "通关所有图二副本（鬼城、无常巷、鬼门关、接引院、判官府、阎罗殿、忘川河、奈何桥、望乡台、转轮殿）",
		"TaskTarget":
		{"鬼城": 1, "无常巷": 1, "鬼门关": 1, "接引院": 1, "判官府": 1, "阎罗殿": 1, "忘川河": 1, "奈何桥": 1, "望乡台": 1, "转轮殿": 1},
		"FinishType": 6,
		"TaskReward":
		[
			{"Name": "zmxz", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "jsbx_1", "Value": 3, "Prop": {}, "WX": [], "StrengthValue": 0},
		]
	},
	"成长礼包1":
	{
		"TaskName": "成长礼包1",
		"TaskType": "ActivityTask",
		"TaskInfo": "玩家等级达10级\n" + "（" + str(PlayerData.player_data["玩家等级"]) + "/10）",
		"TaskTarget": {"玩家等级": 10},
		"FinishType": 2,
		"TaskReward":
		[
			{"Name": "xydxq", "Value": 2, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "mpyj", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "qhsbx", "Value": 10, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "bsd_1", "Value": 3, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
	"成长礼包2":
	{
		"TaskName": "成长礼包2",
		"TaskType": "ActivityTask",
		"TaskInfo": "玩家等级达20级\n" + "（" + str(PlayerData.player_data["玩家等级"]) + "/20）",
		"TaskTarget": {"玩家等级": 20},
		"FinishType": 2,
		"TaskReward":
		[
			{"Name": "xydxq", "Value": 2, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "qhsbx", "Value": 18, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "szbx_1", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "bsd_2", "Value": 3, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "xlhys", "Value": 2, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "czlxls", "Value": 15, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "wxxls", "Value": 30, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
	"成长礼包3":
	{
		"TaskName": "成长礼包3",
		"TaskType": "ActivityTask",
		"TaskInfo": "玩家等级达30级\n" + "（" + str(PlayerData.player_data["玩家等级"]) + "/30）",
		"TaskTarget": {"玩家等级": 30},
		"FinishType": 2,
		"TaskReward":
		[
			{"Name": "xydxq", "Value": 2, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "qhsbx", "Value": 25, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "szbx_2", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "renshen", "Value": 15, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "liuhuang", "Value": 15, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "shougong", "Value": 15, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "lingli", "Value": 15, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "xianmao", "Value": 15, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "leizong", "Value": 15, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "smlp", "Value": 50, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "xlhys", "Value": 5, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "czlxls", "Value": 30, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "wxxls", "Value": 60, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "ziyanyujin", "Value": 200, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
	"成长礼包4":
	{
		"TaskName": "成长礼包4",
		"TaskType": "ActivityTask",
		"TaskInfo": "玩家等级达40级\n" + "（" + str(PlayerData.player_data["玩家等级"]) + "/40）",
		"TaskTarget": {"玩家等级": 40},
		"FinishType": 2,
		"TaskReward":
		[
			{"Name": "xydxq", "Value": 3, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "qhsbx", "Value": 28, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "bsd_3", "Value": 3, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "renshen", "Value": 15, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "liuhuang", "Value": 15, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "shougong", "Value": 15, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "lingli", "Value": 15, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "xianmao", "Value": 15, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "leizong", "Value": 15, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "dudan", "Value": 30, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "smlp", "Value": 100, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "dlhys", "Value": 3, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "czlxls", "Value": 60, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "wxxls", "Value": 90, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "ziyanyujin", "Value": 300, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
	"决战平天大圣":
	{
		"TaskName": "决战平天大圣",
		"TaskType": "ActivityTask",
		"TaskTarget": {"牛魔王·鬼": 5},
		"FinishType": 1,
		"TaskInfo": "击败牛魔王·鬼5次\n" + "（" + str(PlayerData.player_data["牛魔王·鬼"]) + "/5）",
		"TaskReward":
		[
			{"Name": "bsd_4", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
	"浩瀚星河":
	{
		"TaskName": "浩瀚星河",
		"TaskType": "ActivityTask",
		"TaskTarget": {"转轮·真法": 5},
		"FinishType": 1,
		"TaskInfo": "击败转轮·真法5次\n" + "（" + str(PlayerData.player_data["转轮·真法"]) + "/5）",
		"TaskReward":
		[
			{"Name": "bsd_5", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
	"无首神":
	{
		"TaskName": "无首神",
		"TaskType": "ActivityTask",
		"TaskTarget": {"战神刑天": 10, "玩家等级": 50},
		"FinishType": 6,
		"TaskInfo":
		(
			"击败战神刑天10次"
			+ "（"
			+ str(PlayerData.player_data["战神刑天"])
			+ "/10）玩家等级达50级"
			+ "（"
			+ str(PlayerData.player_data["玩家等级"])
			+ "/50）"
		),
		"TaskReward":
		[
			{"Name": "xmzy", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
	"小有所藏":
	{
		"TaskName": "小有所藏",
		"TaskType": "ActivityTask",
		"TaskInfo": "幻化功能中，收集进度达5" + "（" + str(PlayerData.player_data["幻化拥有列表"].size()) + "/5），若显示不准确，请先进去幻化界面再过来。",
		"TaskTarget": {"收集进度": 5},
		"FinishType": 4,
		"TaskReward":
		[
			{"Name": "xysc", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "qhsbx", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
	"业余收藏家":
	{
		"TaskName": "业余收藏家",
		"TaskType": "ActivityTask",
		"TaskInfo": "幻化功能中，收集进度达10" + "（" + str(PlayerData.player_data["幻化拥有列表"].size()) + "/10），若显示不准确，请先进去幻化界面再过来。",
		"TaskTarget": {"收集进度": 10},
		"FinishType": 4,
		"TaskReward":
		[
			{"Name": "yyscj", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "qhsbx", "Value": 2, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
	"专业收藏家":
	{
		"TaskName": "专业收藏家",
		"TaskType": "ActivityTask",
		"TaskInfo": "幻化功能中，收集进度达15" + "（" + str(PlayerData.player_data["幻化拥有列表"].size()) + "/15），若显示不准确，请先进去幻化界面再过来。",
		"TaskTarget": {"收集进度": 15},
		"FinishType": 4,
		"TaskReward":
		[
			{"Name": "zyscj", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "qhsbx", "Value": 3, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
	"痴迷收藏家":
	{
		"TaskName": "痴迷收藏家",
		"TaskType": "ActivityTask",
		"TaskInfo": "幻化功能中，收集进度达20" + "（" + str(PlayerData.player_data["幻化拥有列表"].size()) + "/20），若显示不准确，请先进去幻化界面再过来。",
		"TaskTarget": {"收集进度": 20},
		"FinishType": 4,
		"TaskReward":
		[
			{"Name": "cmscj", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "qhsbx", "Value": 5, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
	"强迫症收藏家":
	{
		"TaskName": "强迫症收藏家",
		"TaskType": "ActivityTask",
		"TaskInfo": "幻化功能中，收集进度达25" + "（" + str(PlayerData.player_data["幻化拥有列表"].size()) + "/25），若显示不准确，请先进去幻化界面再过来。",
		"TaskTarget": {"收集进度": 25},
		"FinishType": 4,
		"TaskReward":
		[
			{"Name": "qpzscj", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "qhsbx", "Value": 8, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
	"骨灰级收藏家":
	{
		"TaskName": "骨灰级收藏家",
		"TaskType": "ActivityTask",
		"TaskInfo": "幻化功能中，收集进度达30" + "（" + str(PlayerData.player_data["幻化拥有列表"].size()) + "/30），若显示不准确，请先进去幻化界面再过来。",
		"TaskTarget": {"收集进度": 30},
		"FinishType": 4,
		"TaskReward":
		[
			{"Name": "ghjscj", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "qhsbx", "Value": 10, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
	"行走博物馆":
	{
		"TaskName": "行走博物馆",
		"TaskType": "ActivityTask",
		"TaskInfo": "幻化功能中，收集进度达35" + "（" + str(PlayerData.player_data["幻化拥有列表"].size()) + "/35），若显示不准确，请先进去幻化界面再过来。",
		"TaskTarget": {"收集进度": 35},
		"FinishType": 4,
		"TaskReward":
		[
			{"Name": "xzbwg", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "qhsbx", "Value": 15, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
	"勇闯八荒":
	{
		"TaskName": "勇闯八荒",
		"TaskType": "ActivityTask",
		"TaskInfo": "未拥有过”修成正果头衔“，并且通过天庭",
		"TaskTarget": {"未持有": true, "天庭": true},
		"FinishType": 5,
		"TaskReward":
		[
			{"Name": "hhyx", "Value": 1, "Prop": {}, "WX": [], "StrengthValue": 0},
			{"Name": "jsbx_2", "Value": 2, "Prop": {}, "WX": [], "StrengthValue": 0},
		],
	},
}


func _remove_black_transparent_frames(root: Node = self) -> void:
	if root is ColorRect:
		(root as ColorRect).color = Color(0, 0, 0, 0)
	elif root is Label:
		var label := root as Label
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
		label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0))
		label.add_theme_constant_override("outline_size", 0)
		label.add_theme_constant_override("shadow_outline_size", 0)
		label.add_theme_constant_override("shadow_offset_x", 0)
		label.add_theme_constant_override("shadow_offset_y", 0)
	for child in root.get_children():
		_remove_black_transparent_frames(child)


func _ready() -> void:
	_remove_black_transparent_frames()
	_clear_current_task_selection()
	ADDTaskList()


func _physics_process(delta: float) -> void:
	match CurrentTaskType:
		1:
			title.text = "活动任务完成："
			num.text = "（" + str(ActivityFinishNum) + "/" + str(AllActivityList.size()) + "）"
			if CurrentTaskName == null or CurrentTaskName == "" or not AllActivityList.has(CurrentTaskName):
				_disable_claim_button()
				return

			if CurrentTaskName == "七魔尽伏":
				var target = AllActivityList["七魔尽伏"]["TaskTarget"]
				var completed = 0
				var total = target.size()
				for key in target.keys():
					if PlayerData.player_data.get(key, 0) >= target[key]:
						completed += 1
				text.text = "通关所有图一副本（已完成 {completed}/{total}）".format({"completed": completed, "total": total})

			elif CurrentTaskName == "十殿肃清":
				var target = AllActivityList["十殿肃清"]["TaskTarget"]
				var completed = 0
				var total = target.size()
				for key in target.keys():
					if PlayerData.player_data.get(key, 0) >= target[key]:
						completed += 1
				text.text = "通关所有图二副本（已完成 {completed}/{total}）".format({"completed": completed, "total": total})
			else:
				text.text = str(AllActivityList[CurrentTaskName]["TaskInfo"])

			if TaskIsFinish:
				if not PlayerData.player_data.get(CurrentTaskName, false):
					lqjl.disabled = false
				else:
					lqjl.disabled = true
			else:
				lqjl.disabled = true
		2:
			title.text = "日常任务完成："
			num.text = "（" + str(DailyFinishNum) + "/" + str(AllDailyList.size()) + "）"
			if CurrentTaskName == null or CurrentTaskName == "" or not AllDailyList.has(CurrentTaskName):
				_disable_claim_button()
				return
			text.text = str(AllDailyList[CurrentTaskName]["TaskInfo"])
			lqjl.disabled = not TaskIsFinish


func ADDTaskList():
	match CurrentTaskType:
		1:
			RemoveList()
			for i in AllActivityList:
				Global.AddTaskTitle(task_list, AllActivityList[i]["TaskType"], AllActivityList[i]["TaskName"], self)
		2:
			RemoveList()
			for i in AllDailyList:
				Global.AddTaskTitle(task_list, AllDailyList[i]["TaskType"], AllDailyList[i]["TaskName"], self)


func ADDReward():
	RemoveReward()
	var task_data = _get_current_task_data()
	if task_data.is_empty():
		_disable_claim_button()
		return
	for i in task_data["TaskReward"]:
		var ItemName = i["Name"]
		var TotalNum = i["Value"]
		Global.AddTaskReward(reward_list, ItemName, TotalNum)


func _clear_current_task_selection() -> void:
	CurrentTaskName = ""
	TaskIsFinish = false
	text.text = ""
	RemoveReward()
	_disable_claim_button()


func _disable_claim_button() -> void:
	if lqjl != null:
		lqjl.disabled = true


func RemoveReward():
	for i in reward_list.get_children():
		i.queue_free()


func RemoveList():
	ActivityFinishNum = 0
	DailyFinishNum = 0
	for i in task_list.get_children():
		i.queue_free()


func _on_lqjl_pressed() -> void:
	var task_data = _get_current_task_data()
	if task_data.is_empty():
		_disable_claim_button()
		return
	if not TaskIsFinish:
		_disable_claim_button()
		return
	if CurrentTaskType == 1 and PlayerData.player_data.get(CurrentTaskName, false):
		_disable_claim_button()
		return
	if not task_data.get("UnlimitedClaim", false):
		PlayerData.player_data[CurrentTaskName] = true
	var list = task_data["TaskReward"]
	Global.AddRewardInfo(Global.get_parent_(self, 1), Vector2(0, 0), list, null, null)
	MemoryClass.保存游戏(Global.cd_path)


func _get_current_task_data() -> Dictionary:
	match CurrentTaskType:
		1:
			if AllActivityList.has(CurrentTaskName):
				return AllActivityList[CurrentTaskName]
		2:
			if AllDailyList.has(CurrentTaskName):
				return AllDailyList[CurrentTaskName]
	return {}


func _on_close_pressed() -> void:
	queue_free()


func _on_hd_task_pressed() -> void:
	CurrentTaskType = 1
	_clear_current_task_selection()
	ADDTaskList()


func _on_rc_task_pressed() -> void:
	CurrentTaskType = 2
	_clear_current_task_selection()
	ADDTaskList()
