extends Control
const THREE_PRINCE_DROP_ITEMS: = {
	0: ["rls", "llst", "llzx", "llkj", "lltk"], 
	4401: ["rls", "llst"], 
	4402: ["rls", "llzx"], 
	4403: ["rls", "llkj", "lltk"], 
}
const EIGHT_IMMORTAL_IDS: Array[int] = [163, 175, 165, 166, 168, 169, 174, 164]
const HUMAN_NIGHTMARE_LEVEL_PATHS: = [
	"res://Scene/Level/Level_1.tscn", "res://Scene/Level/Level_2.tscn", 
	"res://Scene/Level/Level_3.tscn", "res://Scene/Level/Level_4.tscn", 
	"res://Scene/Level/Level_5.tscn", "res://Scene/Level/Level_6.tscn", 
	"res://Scene/Level/Level_7.tscn", "res://Scene/Level/Level_8.tscn", 
	"res://Scene/Level/Level_9.tscn", "res://Scene/Level/Level_10.tscn", 
]
const UNDERWORLD_NIGHTMARE_LEVEL_PATHS: = [
	"res://Scene/Level/Level_nmg.tscn", 
	"res://Scene/Level/Level_bgmj.tscn", 
	"res://Scene/Level/Level_11.tscn", "res://Scene/Level/Level_12.tscn", 
	"res://Scene/Level/Level_13.tscn", "res://Scene/Level/Level_14.tscn", 
	"res://Scene/Level/Level_15.tscn", "res://Scene/Level/Level_16.tscn", 
	"res://Scene/Level/Level_17.tscn", "res://Scene/Level/Level_18.tscn", 
	"res://Scene/Level/Level_19.tscn", "res://Scene/Level/Level_21.tscn", 
]
const HEAVEN_NIGHTMARE_LEVEL_PATHS: = [
	"res://Scene/Level/Level_23.tscn", "res://Scene/Level/Level_24.tscn", 
	"res://Scene/Level/Level_25.tscn", "res://Scene/Level/Level_26.tscn", 
	"res://Scene/Level/Level_27.tscn", "res://Scene/Level/Level_28.tscn", 
	"res://Scene/Level/Level_29.tscn", "res://Scene/Level/Level_30.tscn", 
	"res://Scene/Level/Level_pty.tscn", "res://Scene/Level/Level_ymj.tscn", 
	"res://Scene/Level/Level_llbt.tscn", "兜率宫", 
	"res://Scene/Level/Level_dtwd.tscn", 
]
const EAST_LATE_LEVEL_NAMES: = {
	69: "蝙蝠窟", 70: "七星洞", 71: "万妖穴", 72: "琉璃宫", 
	73: "金玉宫", 74: "浮天台", 75: "云川", 
}
const EAST_LATE_LEVEL_MONSTERS: = {
	69: [
		{"Name": "3198", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3198.tscn", "ConfigId": 3198}, 
		{"Name": "3199", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3199.tscn", "ConfigId": 3199}, 
		{"Name": "3201", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3201.tscn", "ConfigId": 3201}, 
		{"Name": "3200", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3200.tscn", "ConfigId": 3200}, 
	], 
	70: [
		{"Name": "3221", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3199.tscn", "ConfigId": 3221}, 
		{"Name": "3222", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3222.tscn", "ConfigId": 3222}, 
		{"Name": "3226", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3198.tscn", "ConfigId": 3226}, 
		{"Name": "3223", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3223.tscn", "ConfigId": 3223}, 
	], 
	71: [
		{"Name": "3274", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3222.tscn", "ConfigId": 3274}, 
		{"Name": "3275", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3198.tscn", "ConfigId": 3275}, 
		{"Name": "3276", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3276.tscn", "ConfigId": 3276}, 
		{"Name": "3277", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3277.tscn", "ConfigId": 3277}, 
	], 
	72: [
		{"Name": "3308", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3308.tscn", "ConfigId": 3308}, 
		{"Name": "3309", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3309.tscn", "ConfigId": 3309}, 
		{"Name": "3310", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3310.tscn", "ConfigId": 3310}, 
	], 
	73: [
		{"Name": "3320", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3320.tscn", "ConfigId": 3320}, 
		{"Name": "3321", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3308.tscn", "ConfigId": 3321}, 
		{"Name": "3322", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3309.tscn", "ConfigId": 3322}, 
		{"Name": "3323", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3323.tscn", "ConfigId": 3323}, 
	], 
	74: [
		{"Name": "3340", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3320.tscn", "ConfigId": 3340}, 
		{"Name": "3341", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3308.tscn", "ConfigId": 3341}, 
		{"Name": "3342", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3309.tscn", "ConfigId": 3342}, 
		{"Name": "3343", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3343.tscn", "ConfigId": 3343}, 
	], 
	75: [
		{"Name": "3352", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3352.tscn", "ConfigId": 3352}, 
	], 
}
const HUMAN_SOUL_CRYSTAL_MONSTER_IDS: = {
	"xh": 1, "yh": 2, "dxx": 3, "mhw": 4, "yrw": 5, "lw": 6, 
	"bf": 7, "bfsx": 8, "dsj": 9, "ys": 10, "stw": 11, "pmw": 12, 
	"jjy": 13, "xb": 14, "xj": 15, "yjj": 16, "gcx": 17, "jmw": 18, 
	"smw": 20, "nmds": 21, "nmw1": 22, "nmw2": 23, "nmw3": 24, 
}
const UNDERWORLD_SOUL_CRYSTAL_MONSTER_IDS: = {
	"gd": 26, "js": 27, "syr": 28, "bgj": 32, "hwc": 30, "bwc": 31, 
	"klw": 33, "qgw": 37, "nt": 40, "mm": 39, "pg": 41, "ylw": 43, 
	"yc": 48, "mp": 49, "mz": 53, "sh": 51, "qs": 54, "ht": 52, 
	"zlsz": 58, "zlw1": 57, "zlw2": 55, "zlw3": 56, "hhe": 29, 
}
const HEAVEN_SOUL_CRYSTAL_MONSTER_IDS: = {
	"hg": 74, "hh": 75, "wy": 76, "qly": 77, "sfe": 78, 
	"jls": 79, "tbq": 80, "tbd": 81, "tbg": 82, 
	"zztw": 83, "gmtw": 84, "dwtw": 85, 
	"goy": 86, "yy": 87, "ny": 88, "zzz": 89, 
	"sey": 90, "yuh": 91, "wgj": 92, "els": 93, "mhwtf": 96, 
	"jdhw": 97, "cdhw": 98, "hdhw": 99, "txs": 100, 
	"lzz": 101, "nz": 102, "tttw": 103, 
	"lhtz": 104, "wdtz": 105, "ghtz": 106, "yjdw": 107, 
	"jjdw": 108, "yntz": 109, "qnj": 110, "rstz": 111, 
	"tbjx": 112, "dhtz": 113, "tslj": 114, 
	"mtj": 134, "twsz": 135, "cgkl": 136, "cgtw": 137, 
}

@onready var panel_layer: ColorRect = $ColorRect
@onready var level_info_panel: TextureRect = $ColorRect / TextureRect
@onready var Title: Label = $ColorRect / TextureRect / Title
@onready var my_pj: Label = $ColorRect / TextureRect / pj / MyPj
@onready var fall_list: HBoxContainer = $ColorRect / TextureRect / ScrollContainer / FallList
@onready var monster_scroll: ScrollContainer = $ColorRect / TextureRect / ScrollContainer2
@onready var monster_list: HBoxContainer = $ColorRect / TextureRect / ScrollContainer2 / MonsterList
@onready var mybg: TextureRect = $ColorRect / TextureRect / Mybg
@onready var fall: Label = $ColorRect / TextureRect / Fall
@onready var pj: Label = $ColorRect / TextureRect / pj
@onready var speedtext: Label = $ColorRect / TextureRect / Speed / speedtext
@onready var counttext: Label = $ColorRect / TextureRect / Count / counttext
@onready var diffbutton: TextureButton = $ColorRect / TextureRect / diffbutton
@onready var difftext: Label = $ColorRect / TextureRect / diffbutton / difftext
@onready var diffvalue: Label = $ColorRect / TextureRect / diffbutton / diffvalue
@onready var four_swords_mode_dialog: Control = $FourSwordsModeDialog

@onready var color_rect_2: ColorRect = $ColorRect2
@onready var level_down: Label = $ColorRect / TextureRect / Level / LevelDown



var FontColorList = {
	"font_colorList": ["4c4c4c", "818181", "00ff00", "0095ff", "ba2cff", "ff9d2e"], 
}
var PjList = {
	"PjList": ["暂无", "丙", "乙", "甲", "超凡", "至尊"], 
}
var LevelInfo = {
	"广寒宫": {
		"LevelName": "广寒宫", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "ce", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_130.tscn", "HideIndependentDrops": true}, 
		], 
		"LevelFall": [], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 5000}, 
			"2": {"角色": "唐僧", "战斗力": 5000}, 
			"3": {"角色": "八戒", "战斗力": 5000}, 
			"4": {"角色": "沙僧", "战斗力": 5000}, 
		}, 
		"SelfBg": "hgs", 
		"Level": 50, 
	}, 
	"挑战三太子": {
		"LevelName": "挑战三太子", 
		"fall_pro": 50, 
		"MonsterList": [
			{"Name": "stz_nz", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_4401.tscn", "SelectId": 4401}, 
			{"Name": "stz_mz", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_4402.tscn", "SelectId": 4402}, 
			{"Name": "stz_jz", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_4403.tscn", "SelectId": 4403}, 
		], 
		"LevelFall": ["rls", "llst", "llzx", "llkj", "lltk"], 
		"LevelFallProbability": {"rls": 50, "llst": 20, "llzx": 20, "llkj": 20, "lltk": 20}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 5000}, 
			"2": {"角色": "唐僧", "战斗力": 5000}, 
			"3": {"角色": "八戒", "战斗力": 5000}, 
			"4": {"角色": "沙僧", "战斗力": 5000}, 
		}, 
		"SelfBg": "jxm", 
		"Level": 50
	}, 
	"八仙过海": {
		"LevelName": "八仙过海", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "bxgh_163", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_163.tscn", "SelectId": 163}, 
			{"Name": "bxgh_175", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_175.tscn", "SelectId": 175}, 
			{"Name": "bxgh_165", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_165.tscn", "SelectId": 165}, 
			{"Name": "bxgh_166", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_166.tscn", "SelectId": 166}, 
			{"Name": "bxgh_168", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_168.tscn", "SelectId": 168}, 
			{"Name": "bxgh_169", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_169.tscn", "SelectId": 169}, 
			{"Name": "bxgh_174", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_174.tscn", "SelectId": 174}, 
			{"Name": "bxgh_164", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_164.tscn", "SelectId": 164}, 
		], 
		"LevelFall": [], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 5000}, 
			"2": {"角色": "唐僧", "战斗力": 5000}, 
			"3": {"角色": "八戒", "战斗力": 5000}, 
			"4": {"角色": "沙僧", "战斗力": 5000}, 
		}, 
		"SelfBg": "hgs", 
		"Level": 50
	}, 
	"挑战28星宿": {
		"LevelName": "挑战28星宿", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "轸宿", "IsBoss": true, "SelectConstellationLevel": 1, "ConfigId": 47101}, 
			{"Name": "翼火蛇", "IsBoss": true, "SelectConstellationLevel": 2, "ConfigId": 47102}, 
			{"Name": "张月鹿", "IsBoss": true, "SelectConstellationLevel": 3, "ConfigId": 47103}, 
			{"Name": "星日马", "IsBoss": true, "SelectConstellationLevel": 4, "ConfigId": 47104}, 
			{"Name": "柳宿", "IsBoss": true, "SelectConstellationLevel": 5, "ConfigId": 47105}, 
			{"Name": "鬼宿", "IsBoss": true, "SelectConstellationLevel": 6, "ConfigId": 47106}, 
			{"Name": "井宿", "IsBoss": true, "SelectConstellationLevel": 7, "ConfigId": 47107}, 
			{"Name": "壁宿", "IsBoss": true, "SelectConstellationLevel": 8, "ConfigId": 47108}, 
			{"Name": "室宿", "IsBoss": true, "SelectConstellationLevel": 9, "ConfigId": 47109}, 
			{"Name": "危宿", "IsBoss": true, "SelectConstellationLevel": 10, "ConfigId": 47110}, 
			{"Name": "虚宿", "IsBoss": true, "SelectConstellationLevel": 11, "ConfigId": 47111}, 
			{"Name": "女宿", "IsBoss": true, "SelectConstellationLevel": 12, "ConfigId": 47112}, 
			{"Name": "牛宿", "IsBoss": true, "SelectConstellationLevel": 13, "ConfigId": 47113}, 
			{"Name": "斗宿", "IsBoss": true, "SelectConstellationLevel": 14, "ConfigId": 47114}, 
		], 
		"LevelFall": [], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "jxm", 
		"Level": 90, 
	}, 
	"挑战四剑": {
		"LevelName": "挑战四剑", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "zxjboss", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_951.tscn"}, 
			{"Name": "xxjboss", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_952.tscn"}, 
			{"Name": "lxjboss", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_953.tscn"}, 
			{"Name": "jxjboss", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_954.tscn"}, 
		], 
		"LevelFall": ["zxjp", "xxjp", "lxjp", "jxjp", "zxjh"], 
		"LevelFallProbability": {
			"zxjp": 15, 
			"xxjp": 15, 
			"lxjp": 15, 
			"jxjp": 15, 
			"zxjh": 20, 
		}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 12000}, 
			"2": {"角色": "唐僧", "战斗力": 12000}, 
			"3": {"角色": "八戒", "战斗力": 12000}, 
			"4": {"角色": "沙僧", "战斗力": 12000}, 
		}, 
		"SelfBg": "jxm", 
		"Level": 65
	}, 
	"花果山": {
		"LevelName": "花果山", 
		"fall_pro": 25, 
		"MonsterList": [{"Name": "xh", "IsBoss": false}, {"Name": "yh", "IsBoss": false}, {"Name": "dxx", "IsBoss": true}], 
		"LevelFall": ["ptxzg", "ptxzf", "ptsmz", "ptjs", "ptdp", "ptcs", "ptyyc", "ptcp", "pttq", "ptcf", "nzhjq", "nzly"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 100}, 
			"2": {"角色": "唐僧", "战斗力": 100}, 
			"3": {"角色": "八戒", "战斗力": 100}, 
			"4": {"角色": "沙僧", "战斗力": 100}, 
		}, 
		"SelfBg": "hgs", 
		"Level": 5
	}, 
	"水帘洞": {
		"LevelName": "水帘洞", 
		"fall_pro": 25, 
		"MonsterList": [{"Name": "xh", "IsBoss": false}, {"Name": "yh", "IsBoss": false}, {"Name": "dxx", "IsBoss": false}, {"Name": "mhw", "IsBoss": true}, {"Name": "lw", "IsBoss": true}], 
		"LevelFall": ["ptxzg", "ptxzf", "ptsmz", "ptjs", "ptdp", "ptcs", "ptyyc", "ptcp", "pttq", "ptcf", "dslj", "dshp", "dszy", "dslq", "qld", "hdc", "bhz", "zhp", "twq", "ryjgb", "jhcz", "jcdp", "jlxmc", "qthbq", "qxsh", "nzhjq", "nzly", "210007001"], 
		"LevelFallProbability": {"210007001": 25}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 150}, 
			"2": {"角色": "唐僧", "战斗力": 150}, 
			"3": {"角色": "八戒", "战斗力": 150}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "hgs", 
		"Level": 10
	}, 
	"桃花源": {
		"LevelName": "桃花源", 
		"fall_pro": 25, 
		"MonsterList": [{"Name": "yh", "IsBoss": false}, {"Name": "dxx", "IsBoss": false}, {"Name": "yrw", "IsBoss": true}], 
		"LevelFall": ["ptxzg", "ptxzf", "ptsmz", "ptjs", "ptdp", "ptcs", "ptyyc", "ptcp", "pttq", "ptcf", "dsyj", "jmc", "dsqz", "zhj", "nzhjq", "nzly"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 250}, 
			"2": {"角色": "唐僧", "战斗力": 300}, 
			"3": {"角色": "八戒", "战斗力": 300}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "thy", 
		"Level": 13
	}, 
	"蝙蝠窟": {
		"LevelName": "蝙蝠窟", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "bf", "IsBoss": false}, {"Name": "bfsx", "IsBoss": true}], 
		"LevelFall": ["ptxzg", "ptxzf", "ptsmz", "ptjs", "ptdp", "ptcs", "ptyyc", "ptcp", "pttq", "ptcf", "whg", "wtp", "bsp", "nzhjq", "nzly", "211007001"], 
		"LevelFallProbability": {"211007001": 25}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 350}, 
			"2": {"角色": "唐僧", "战斗力": 400}, 
			"3": {"角色": "八戒", "战斗力": 350}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "bfk", 
		"Level": 17
	}, 
	"七星洞": {
		"LevelName": "七星洞", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "bf", "IsBoss": false}, {"Name": "ys", "IsBoss": false}, {"Name": "dsj", "IsBoss": false}, {"Name": "stw", "IsBoss": true}], 
		"LevelFall": ["ptxzg", "ptxzf", "ptsmz", "ptjs", "ptdp", "ptcs", "ptyyc", "ptcp", "pttq", "ptcf", "jcbj", "jcmc", "jcjp", "nzhjq", "nzly"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 450}, 
			"2": {"角色": "唐僧", "战斗力": 450}, 
			"3": {"角色": "八戒", "战斗力": 450}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "bfk", 
		"Level": 18
	}, 
	"迦楼罗之穴": {
		"LevelName": "迦楼罗之穴", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "jjy", "IsBoss": false}, {"Name": "ys", "IsBoss": false}, {"Name": "dsj", "IsBoss": false}, {"Name": "pmw", "IsBoss": true}], 
		"LevelFall": ["ptxzg", "ptxzf", "ptsmz", "ptjs", "ptdp", "ptcs", "ptyyc", "ptcp", "pttq", "ptcf", "jcjs", "jcsz", "jclj", "nzhjq", "nzly", "210007002"], 
		"LevelFallProbability": {"210007002": 25}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 650}, 
			"2": {"角色": "唐僧", "战斗力": 700}, 
			"3": {"角色": "八戒", "战斗力": 600}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "bfk", 
		"Level": 20
	}, 
	"浅岸": {
		"LevelName": "浅岸", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "xb", "IsBoss": false}, {"Name": "xj", "IsBoss": false}, {"Name": "gcx", "IsBoss": true}], 
		"LevelFall": ["xqzy"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 700}, 
			"2": {"角色": "唐僧", "战斗力": 700}, 
			"3": {"角色": "八戒", "战斗力": 700}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "qa", 
		"Level": 20
	}, 
	"东海": {
		"LevelName": "东海", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "xb", "IsBoss": false}, {"Name": "xj", "IsBoss": false}, {"Name": "gcx", "IsBoss": false}, {"Name": "yjj", "IsBoss": false}, {"Name": "jmw", "IsBoss": true}], 
		"LevelFall": ["xwj", "pxk", "bxp", "211007002"], 
		"LevelFallProbability": {"211007002": 25}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 1000}, 
			"2": {"角色": "唐僧", "战斗力": 1000}, 
			"3": {"角色": "八戒", "战斗力": 900}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "qa", 
		"Level": 23
	}, 
	"鲨之涡流": {
		"LevelName": "鲨之涡流", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "xb", "IsBoss": false}, {"Name": "xj", "IsBoss": false}, {"Name": "gcx", "IsBoss": false}, {"Name": "yjj", "IsBoss": false}, {"Name": "sy", "IsBoss": true}, {"Name": "smw", "IsBoss": true}], 
		"LevelFall": ["qlp", "zqj", "ttj"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 1200}, 
			"2": {"角色": "唐僧", "战斗力": 1100}, 
			"3": {"角色": "八戒", "战斗力": 1000}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "qa", 
		"Level": 25
	}, 
	"牛魔谷": {
		"LevelName": "牛魔谷", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "nmds", "IsBoss": false}, {"Name": "nmw1", "IsBoss": true}, {"Name": "nmw2", "IsBoss": true}, {"Name": "nmw3", "IsBoss": true}], 
		"LevelFall": ["ttlp1"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 1700}, 
			"2": {"角色": "唐僧", "战斗力": 1600}, 
			"3": {"角色": "八戒", "战斗力": 1400}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "nmg", 
		"Level": 25
	}, 
	"火焰山": {
		"LevelName": "火焰山", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "hhe", "IsBoss": true}], 
		"LevelFall": ["jgj", "ssj"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 1700}, 
			"2": {"角色": "唐僧", "战斗力": 1600}, 
			"3": {"角色": "八戒", "战斗力": 1400}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "nmg", 
		"Level": 25
	}, 
	"鬼城": {
		"LevelName": "鬼城", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "gd", "IsBoss": false}, {"Name": "js", "IsBoss": false}, {"Name": "syr", "IsBoss": true}], 
		"LevelFall": ["lzp", "jmy", "221007001"], 
		"LevelFallProbability": {"221007001": 33}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 1700}, 
			"2": {"角色": "唐僧", "战斗力": 1600}, 
			"3": {"角色": "八戒", "战斗力": 1400}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "df", 
		"Level": 25
	}, 
	"无常巷": {
		"LevelName": "无常巷", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "gd", "IsBoss": false}, {"Name": "js", "IsBoss": false}, {"Name": "syr", "IsBoss": false}, {"Name": "hwc", "IsBoss": true}, {"Name": "bwc", "IsBoss": true}, {"Name": "bgj", "IsBoss": true}], 
		"LevelFall": ["yhj", "tsgl", "bsyz", "bsxj", "bszj", "bsbc", "bshq", "csgs", "bszy"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 1800}, 
			"2": {"角色": "唐僧", "战斗力": 1700}, 
			"3": {"角色": "八戒", "战斗力": 1500}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "df", 
		"Level": 27
	}, 
	"白骨秘境": {
		"LevelName": "白骨精", 
		"fall_pro": 30, 
		"MonsterList": [{"Name": "bgj", "IsBoss": true}], 
		"LevelFall": ["bsxj", "bszj", "bsyz", "bsbc", "bshq", "csgs", "bszy"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 1800}, 
			"2": {"角色": "唐僧", "战斗力": 1700}, 
			"3": {"角色": "八戒", "战斗力": 1500}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "df", 
		"Level": 27
	}, 


	"鬼门关": {
		"LevelName": "鬼门关", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "gd", "IsBoss": false}, {"Name": "js", "IsBoss": false}, {"Name": "syr", "IsBoss": false}, {"Name": "klw", "IsBoss": true}], 
		"LevelFall": ["lcgy", "tsgp"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 2000}, 
			"2": {"角色": "唐僧", "战斗力": 2000}, 
			"3": {"角色": "八戒", "战斗力": 1800}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "df", 
		"Level": 27
	}, 
	"接引院": {
		"LevelName": "接引院", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "nt", "IsBoss": false}, {"Name": "mm", "IsBoss": false}, {"Name": "qgw", "IsBoss": true}], 
		"LevelFall": ["gtq", "gtb", "gtc", "tsyj", "220007001"], 
		"LevelFallProbability": {"220007001": 33}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 2000}, 
			"2": {"角色": "唐僧", "战斗力": 2000}, 
			"3": {"角色": "八戒", "战斗力": 2500}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "jyy", 
		"Level": 27
	}, 
	"判官府": {
		"LevelName": "判官府", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "nt", "IsBoss": false}, {"Name": "mm", "IsBoss": false}, {"Name": "hwc", "IsBoss": false}, {"Name": "bwc", "IsBoss": false}, {"Name": "pg", "IsBoss": true}], 
		"LevelFall": ["gtq", "gtb", "lcld", "tsyp"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 2200}, 
			"2": {"角色": "唐僧", "战斗力": 2500}, 
			"3": {"角色": "八戒", "战斗力": 2700}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "pgf", 
		"Level": 27
	}, 
	"阎罗殿": {
		"LevelName": "阎罗殿", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "nt", "IsBoss": false}, {"Name": "mm", "IsBoss": false}, {"Name": "hwc", "IsBoss": false}, {"Name": "bwc", "IsBoss": false}, {"Name": "sdgm", "IsBoss": true}, {"Name": "ylw", "IsBoss": true}], 
		"LevelFall": ["gtq", "gtb", "yll", "fygwj", "lchp", "221007002"], 
		"LevelFallProbability": {"221007002": 33}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 2400}, 
			"2": {"角色": "唐僧", "战斗力": 2700}, 
			"3": {"角色": "八戒", "战斗力": 2700}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "yld", 
		"Level": 27
	}, 
	"忘川河": {
		"LevelName": "忘川河", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "gy", "IsBoss": false}, {"Name": "sdw", "IsBoss": true}], 
		"LevelFall": [], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 2200}, 
			"2": {"角色": "唐僧", "战斗力": 2700}, 
			"3": {"角色": "八戒", "战斗力": 2800}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "wch", 
		"Level": 30
	}, 
	"奈何桥": {
		"LevelName": "奈何桥", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "mz", "IsBoss": false}, {"Name": "sh", "IsBoss": false}, {"Name": "ht", "IsBoss": false}, {"Name": "yc", "IsBoss": true}], 
		"LevelFall": ["yazfw", "yizfw", "hshb", "zshb", "lssp", "qssp", "lczh", "xhmj", "xhxc", "220007002"], 
		"LevelFallProbability": {"220007002": 33}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 3000}, 
			"2": {"角色": "唐僧", "战斗力": 3000}, 
			"3": {"角色": "八戒", "战斗力": 3000}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "nhq", 
		"Level": 30
	}, 
	"望乡台": {
		"LevelName": "望乡台", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "mz", "IsBoss": false}, {"Name": "sh", "IsBoss": false}, {"Name": "ht", "IsBoss": false}, {"Name": "qs", "IsBoss": false}, {"Name": "mp", "IsBoss": true}], 
		"LevelFall": ["yazfw", "yizfw", "hshb", "zshb", "lshb", "lssp", "qssp", "jssp", "xhgp", "xhxh", "xhyk", "xhymk"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 3500}, 
			"2": {"角色": "唐僧", "战斗力": 3400}, 
			"3": {"角色": "八戒", "战斗力": 3600}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "wxt", 
		"Level": 30
	}, 

	"十八地狱": {
		"LevelName": "十八地狱", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "xt", "IsBoss": true}, {"Name": "zsxt", "IsBoss": true}], 
		"LevelFall": ["qtz", "dszk", "jljs", "tpzy", "lhz", "tpltp", "jlfyc", "jlfyj", "ylhq", "yljj"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 3500}, 
			"2": {"角色": "唐僧", "战斗力": 3400}, 
			"3": {"角色": "八戒", "战斗力": 3600}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "sbcdy", 
		"Level": 35
	}, 
	"转轮殿": {
		"LevelName": "转轮殿", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "zlsz", "IsBoss": false}, {"Name": "zlw1", "IsBoss": true}, {"Name": "zlw2", "IsBoss": true}, {"Name": "zlw3", "IsBoss": true}], 
		"LevelFall": ["ttlp2", "myz", "nyd", "syc", "shyc", "xyq"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 4500}, 
			"2": {"角色": "唐僧", "战斗力": 4500}, 
			"3": {"角色": "八戒", "战斗力": 4500}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "zld", 
		"Level": 30
	}, 
	"螺旋地狱": {
		"LevelName": "螺旋地狱", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "wgw", "IsBoss": true}, {"Name": "bcw", "IsBoss": true}, {"Name": "tsw", "IsBoss": true}, {"Name": "dsw", "IsBoss": true}, {"Name": "pdw", "IsBoss": true}], 
		"LevelFall": ["szyj", "xzyj", "czyj", "zzyj", "gzyj"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "lxdy"
	}, 
	"九重天": {
		"LevelName": "九重天", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "ey", "IsBoss": false}, {"Name": "xtq", "IsBoss": true}], 
		"LevelFall": [], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 5600}, 
			"2": {"角色": "唐僧", "战斗力": 5600}, 
			"3": {"角色": "八戒", "战斗力": 5600}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "jct", 
		"Level": 35
	}, 
	"天宫道": {
		"LevelName": "天宫道", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "hg", "IsBoss": false}, {"Name": "hh", "IsBoss": false}, {"Name": "wy", "IsBoss": false}, {"Name": "qly", "IsBoss": true}, {"Name": "sfe", "IsBoss": true}, {"Name": "mhwtf", "IsBoss": true}], 
		"LevelFall": ["kys", "xhz", "kyz", "kyc", "tfljzzs", "231007001"], 
		"LevelFallProbability": {"231007001": 33}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 5800}, 
			"2": {"角色": "唐僧", "战斗力": 5800}, 
			"3": {"角色": "八戒", "战斗力": 5800}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "jct", 
		"Level": 35
	}, 
	"南天门": {
		"LevelName": "南天门", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "hg", "IsBoss": false}, {"Name": "hh", "IsBoss": false}, {"Name": "wy", "IsBoss": false}, {"Name": "jls", "IsBoss": true}], 
		"LevelFall": ["xhp", "xhc", "xhj", "230007001"], 
		"LevelFallProbability": {"230007001": 33}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 6000}, 
			"2": {"角色": "唐僧", "战斗力": 6000}, 
			"3": {"角色": "八戒", "战斗力": 6000}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "jct", 
		"Level": 35
	}, 
	"南天王殿": {
		"LevelName": "南天王殿", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "tbd", "IsBoss": false}, {"Name": "tbq", "IsBoss": false}, {"Name": "tbg", "IsBoss": false}, {"Name": "zztw", "IsBoss": true}], 
		"LevelFall": ["qyfp", "qybd", "qysq"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 6500}, 
			"2": {"角色": "唐僧", "战斗力": 6500}, 
			"3": {"角色": "八戒", "战斗力": 6500}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "zztw", 
		"Level": 35
	}, 
	"西天王殿": {
		"LevelName": "西天王殿", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "tbd", "IsBoss": false}, {"Name": "tbq", "IsBoss": false}, {"Name": "tbg", "IsBoss": false}, {"Name": "gmtw", "IsBoss": true}], 
		"LevelFall": ["hylk", "qysz"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 6700}, 
			"2": {"角色": "唐僧", "战斗力": 6700}, 
			"3": {"角色": "八戒", "战斗力": 6700}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "gmtw", 
		"Level": 35
	}, 
	"北天王殿": {
		"LevelName": "北天王殿", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "tbd", "IsBoss": false}, {"Name": "tbq", "IsBoss": false}, {"Name": "tbg", "IsBoss": false}, {"Name": "dwtw", "IsBoss": true}, {"Name": "mtj", "IsBoss": true}], 
		"LevelFall": ["hylc", "hylz", "mgzhzzs", "231007002"], 
		"LevelFallProbability": {"231007002": 33}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 7000}, 
			"2": {"角色": "唐僧", "战斗力": 7000}, 
			"3": {"角色": "八戒", "战斗力": 7000}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "dwtw", 
		"Level": 35
	}, 
	"彩虹楼": {
		"LevelName": "彩虹楼", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "goy", "IsBoss": false}, {"Name": "yy", "IsBoss": false}, {"Name": "ny", "IsBoss": false}, {"Name": "zzz", "IsBoss": true}, {"Name": "cgtw", "IsBoss": true}], 
		"LevelFall": ["zjqj", "zjksf", "zjgp", "zjxmczzs", "hljhzzs", "tdlzjzzs", "230007002"], 
		"LevelFallProbability": {"230007002": 33}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 7000}, 
			"2": {"角色": "唐僧", "战斗力": 7000}, 
			"3": {"角色": "八戒", "战斗力": 7000}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "chl", 
		"Level": 35
	}, 
	"朝会殿": {
		"LevelName": "朝会殿", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "goy", "IsBoss": false}, {"Name": "yy", "IsBoss": false}, {"Name": "ny", "IsBoss": false}, {"Name": "sey", "IsBoss": false}, {"Name": "yuh", "IsBoss": true}], 
		"LevelFall": ["zjbtgzzs", "wsjgzzs", "blmqzzs", "jllm", "smz"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 7000}, 
			"2": {"角色": "唐僧", "战斗力": 7000}, 
			"3": {"角色": "八戒", "战斗力": 7000}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "zhd", 
		"Level": 35
	}, 
	"凌霄宝殿": {
		"LevelName": "凌霄宝殿", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "yy", "IsBoss": false}, {"Name": "ny", "IsBoss": false}, {"Name": "wgj", "IsBoss": false}, {"Name": "xtq", "IsBoss": true}, {"Name": "els", "IsBoss": true}], 
		"LevelFall": ["shsjt"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 7000}, 
			"2": {"角色": "唐僧", "战斗力": 7000}, 
			"3": {"角色": "八戒", "战斗力": 7000}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "lxbd", 
		"Level": 35
	}, 
	"玲珑宝塔": {
		"LevelName": "玲珑宝塔", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "jdhw", "IsBoss": false}, {"Name": "cdhw", "IsBoss": false}, {"Name": "hdhw", "IsBoss": false}, {"Name": "txs", "IsBoss": true}, {"Name": "lzz", "IsBoss": true}, {"Name": "nz", "IsBoss": true}, {"Name": "tttw", "IsBoss": true}], 
		"LevelFall": ["230007003zzs", "231007003zzs", "xuantie", "sichou", "tanmu", "eyzzs", "tzzzs", "zezzs", "yjzzs", "czzzs", "tczzs", "tqzzs", "thzzs", "ryzzs", "tszzs", "rls", "llyzzs"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 7000}, 
			"2": {"角色": "唐僧", "战斗力": 7000}, 
			"3": {"角色": "八戒", "战斗力": 7000}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "llbt", 
		"Level": 40
	}, 
	"兜率宫": {
		"LevelName": "兜率宫", 
		"fall_pro": 30, 
		"MonsterList": [{"Name": "lhtz", "IsBoss": false}, {"Name": "wdtz", "IsBoss": false}, {"Name": "ghtz", "IsBoss": false}, 
		{"Name": "yntz", "IsBoss": false}, {"Name": "rstz", "IsBoss": false}, {"Name": "dhtz", "IsBoss": false}, {"Name": "yjdw", "IsBoss": true}, 
		{"Name": "jjdw", "IsBoss": true}, {"Name": "qnj", "IsBoss": true}, {"Name": "tbjx", "IsBoss": true}, {"Name": "tslj", "IsBoss": true}], 
		"LevelFall": ["230007004zzs", "231007004zzs", "ziyanyujin", "liuhuang", "xianmao", "lingli", "shougong", "renshen", "dudan", "yjpysp", "yjpyasp", "leizong", "qljzzs", "plpzzs", "ylkzzs", "jljzzs", "tljzzs", "qlgzzs", "plzzzs", "ylfzzs", "jlczzs", "tlqzzs", "doushuaiziyanzzs"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 7000}, 
			"2": {"角色": "唐僧", "战斗力": 7000}, 
			"3": {"角色": "八戒", "战斗力": 7000}, 
			"4": {"角色": "沙僧", "战斗力": 80}, 
		}, 
		"SelfBg": "dsg", 
		"Level": 50
	}, 
	"神兽森林": {
		"LevelName": "神兽森林", 
		"fall_pro": 0, 
		"MonsterList": [{"Name": "qiongqi", "IsBoss": true}, {"Name": "taowu", "IsBoss": true}, {"Name": "hundun", "IsBoss": true}, {"Name": "taotie", "IsBoss": true}], 
		"LevelFall": ["wuxingguo", "genguguo", "lingliguo", "zizhiguo"], 
		"LevelFallProbability": {"wuxingguo": 10, "genguguo": 10, "lingliguo": 10, "zizhiguo": 25}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "sssl", 
		"Level": 55
	}, 

	"火龙岛": {
		"LevelName": "火龙岛", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "hlhw", "IsBoss": false}, {"Name": "fyj", "IsBoss": true}, {"Name": "wll", "IsBoss": true}, {"Name": "yzx", "IsBoss": true}], 
		"LevelFall": ["240007001zzs", "qszzs", "rczzs", "ytzzs", "llzzs", "ldzzs"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "hld", 
		"Level": 55
	}, 

	"九龙岛": {
		"LevelName": "九龙岛", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "emlqs", "IsBoss": false}, {"Name": "hylqs", "IsBoss": false}, {"Name": "hbsz", "IsBoss": true}], 
		"LevelFall": ["241007001zzs", "dzzzs", "ztzzs", "jtzzs", "jszzs", "tlzzs"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "jls", 
		"Level": 55
	}, 

	"龙脊山": {
		"LevelName": "龙脊山", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "hylqs", "IsBoss": false}, {"Name": "yflqs", "IsBoss": false}, {"Name": "jnsz", "IsBoss": true}], 
		"LevelFall": ["241007005zzs", "slyszzs", "slfkzzs", ], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "ljs", 
		"Level": 56
	}, 

	"尾妖林": {
		"LevelName": "尾妖林", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "dylqs", "IsBoss": false}, {"Name": "yflqs", "IsBoss": false}, {"Name": "basz", "IsBoss": true}, {"Name": "ly", "IsBoss": true}], 
		"LevelFall": ["240007005zzs", "slshjzzs", "sljszzs", "slcpzzs", "slshgzzs", "slfmzzzs", "slhlqzzs", "slxjczzs", "sllypzzs", ], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "wyl", 
		"Level": 56
	}, 

	"仙音岛": {
		"LevelName": "仙音岛", 
		"fall_pro": 40, 
		"MonsterList": [{"Name": "fl", "IsBoss": false}, {"Name": "bx", "IsBoss": true}], 
		"LevelFall": ["ygs", "zhhzzzs"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "xyd", 
		"Level": 57
	}, 

	"仙幻岛": {
		"LevelName": "仙幻岛", 
		"fall_pro": 40, 
		"MonsterList": [{"Name": "lzg", "IsBoss": false}, {"Name": "qx", "IsBoss": true}], 
		"LevelFall": ["ygs", "phhlzzs"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "xhd", 
		"Level": 57
	}, 

	"仙树岛": {
		"LevelName": "仙树岛", 
		"fall_pro": 28, 
		"MonsterList": [{"Name": "lzg", "IsBoss": false}, {"Name": "fl", "IsBoss": false}, {"Name": "yx", "IsBoss": true}], 
		"LevelFall": ["ygs", "bxhyzzs"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "xsd", 
		"Level": 58
	}, 

	"蓬莱岛": {
		"LevelName": "蓬莱岛", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "dylqs", "IsBoss": false}, {"Name": "hylqs", "IsBoss": false}, {"Name": "emlqs", "IsBoss": false}, {"Name": "yflqs", "IsBoss": false}, {"Name": "qnyw", "IsBoss": true}, {"Name": "qnwg", "IsBoss": true}], 
		"LevelFall": ["ttsl1", "shenhuo_1", "ttsl2", "shenhuo_2"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "pld", 
		"Level": 58
	}, 
	"蓬莱仙境": {
		"LevelName": "蓬莱仙境", 
		"fall_pro": 33, 
		"MonsterList": [{"Name": "dylqs", "IsBoss": false}, {"Name": "hylqs", "IsBoss": false}, {"Name": "emlqs", "IsBoss": false}, {"Name": "yflqs", "IsBoss": false}, {"Name": "qnyc", "IsBoss": true}], 
		"LevelFall": ["ttsl3", "shenhuo_3"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "plxj", 
		"Level": 59
	}, 


	"绝仙门": {
		"LevelName": "绝仙门", 
		"fall_pro": 10, 
		"MonsterList": [{"Name": "dylqs", "IsBoss": false}, {"Name": "cysj", "IsBoss": true}], 
		"LevelFall": ["sqzlwzzs"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "jxm", 
		"Level": 60
	}, 

	"陷仙门": {
		"LevelName": "陷仙门", 
		"fall_pro": 10, 
		"MonsterList": [{"Name": "qysj", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_212.tscn", "HideIndependentDrops": true}], 
		"LevelFall": ["xyfjwkzzs", "xyfjbjzzs", "xyfjtszzs", "xyfjsszzs", "xyfjblzzs", "341071301zzs"], 
		"LevelFallProbability": {
			"xyfjwkzzs": 10, 
			"xyfjbjzzs": 10, 
			"xyfjtszzs": 10, 
			"xyfjsszzs": 10, 
			"xyfjblzzs": 10, 
			"341071301zzs": 10, 
		}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "jxm", 
		"Level": 61
	}, 

	"绝境宫": {
		"LevelName": "绝境宫", 
		"fall_pro": 10, 
		"MonsterList": [
			{"Name": "dylqs", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_118.tscn"}, 
			{"Name": "hyr", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_215.tscn", "HideIndependentDrops": true}, 
		], 
		"LevelFall": ["cswkxyhbzzs", "cstsxyhbzzs", "csbjxyhbzzs", "csssxyhbzzs", "csblxyhbzzs", "342071301zzs"], 
		"LevelFallProbability": {
			"cswkxyhbzzs": 10, 
			"cstsxyhbzzs": 10, 
			"csbjxyhbzzs": 10, 
			"csssxyhbzzs": 10, 
			"csblxyhbzzs": 10, 
			"342071301zzs": 10, 
		}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "jjg", 
		"Level": 65
	}, 

	"通天教主": {
		"LevelName": "通天教主", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "ttjz", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_1460.tscn", "HideIndependentDrops": true}
		], 
		"LevelFall": ["139300016", "xyzyzzs"], 
		"LevelFallProbability": {
			"139300016": 10, 
			"xyzyzzs": 10, 
		}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "jjg", 
		"Level": 66
	}, 

	"玄武门": {
		"LevelName": "玄武门", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "xwm3001", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3001.tscn"}, 
			{"Name": "xwm3003", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3003.tscn"}, 
			{"Name": "xwm3004", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3004.tscn"}, 
			{"Name": "xwm3005", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3005.tscn", "HideIndependentDrops": true}, 
		], 
		"LevelFall": ["pgs"], 
		"LevelFallProbability": {"pgs": 15}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"朱雀街": {
		"LevelName": "朱雀街", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "xwm3001", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3001.tscn"}, 
			{"Name": "zqj3002", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3002.tscn"}, 
			{"Name": "xwm3004", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3004.tscn"}, 
			{"Name": "zqj3006", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3006.tscn"}, 
		], 
		"LevelFall": ["tjs"], 
		"LevelFallProbability": {"tjs": 10}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"未央宫": {
		"LevelName": "未央宫", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "xwm3001", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3001.tscn"}, 
			{"Name": "zqj3002", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3002.tscn"}, 
			{"Name": "xwm3004", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3004.tscn"}, 
			{"Name": "weiyang3007", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3007.tscn"}, 
		], 
		"LevelFall": ["139300014V1", "1_jns"], 
		"LevelFallProbability": {"139300014V1": 10, "1_jns": 20}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"九华山麓": {
		"LevelName": "九华山麓", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "蘑菇精", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3008.tscn"}, 
			{"Name": "金钱松", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3009.tscn"}, 
			{"Name": "闵老护法", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3019.tscn", "HideIndependentDrops": true}
		], 
		"LevelFall": ["7_bsjh"], 
		"LevelFallProbability": {"7_bsjh": 25}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"双溪寺": {
		"LevelName": "双溪寺", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "蘑菇精", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3008.tscn"}, 
			{"Name": "人形藤蔓", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3010.tscn"}, 
			{"Name": "苍耳妖", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3011.tscn"}, 
			{"Name": "道明妖僧", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3020.tscn", "HideIndependentDrops": true}
		], 
		"LevelFall": ["dzyl"], 
		"LevelFallProbability": {"dzyl": 10}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"神光金岭": {
		"LevelName": "神光金岭", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "金钱松", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3009.tscn"}, 
			{"Name": "人形藤蔓", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3010.tscn"}, 
			{"Name": "苍耳妖", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3011.tscn"}, 
			{"Name": "木之祖巫", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3021.tscn"}
		], 
		"LevelFall": ["139300012", "105400003"], 
		"LevelFallProbability": {"139300012": 10, "105400003": 10}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"普陀山脚": {
		"LevelName": "普陀山脚", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "虾兵", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3031.tscn"}, 
			{"Name": "虎鲨", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3029.tscn"}, 
			{"Name": "灵感大王", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3033.tscn"}
		], 
		"LevelFall": ["105400005V1"], 
		"LevelFallProbability": {"105400005V1": 10}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"九龙宝殿": {
		"LevelName": "九龙宝殿", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "贝壳", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3028.tscn"}, 
			{"Name": "夜叉", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3032.tscn"}, 
			{"Name": "虾兵", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3031.tscn", "ConfigId": 3031}, 
			{"Name": "四头虫", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3034.tscn"}
		], 
		"LevelFall": ["ymqzq"], 
		"LevelFallProbability": {"ymqzq": 10}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"法华灵洞": {
		"LevelName": "法华灵洞", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "蚌女", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3030.tscn", "ConfigId": 3030}, 
			{"Name": "夜叉", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3032.tscn", "ConfigId": 3032}, 
			{"Name": "贝壳", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3028.tscn", "ConfigId": 3028}, 
			{"Name": "水之祖巫", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3035.tscn"}
		], 
		"LevelFall": ["139300018", "hhyq"], 
		"LevelFallProbability": {"139300018": 10, "hhyq": 10}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"峨眉山道": {
		"LevelName": "峨眉山道", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "岩石怪", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3047.tscn"}, 
			{"Name": "忍猴", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3038.tscn"}, 
			{"Name": "赤炎金刚", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3040.tscn"}
		], 
		"LevelFall": ["zqfjwkzzs", "zqfjtszzs", "zqfjbjzzs"], 
		"LevelFallProbability": {"zqfjwkzzs": 10, "zqfjtszzs": 10, "zqfjbjzzs": 10}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"清音阁": {
		"LevelName": "清音阁", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "百足蜈蚣", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3039.tscn"}, 
			{"Name": "蝎子精", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3037.tscn"}, 
			{"Name": "火焰鸟", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3036.tscn"}, 
			{"Name": "噬火毒蝎", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3041.tscn"}
		], 
		"LevelFall": ["zqfjsszzs", "zqfjblzzs", "zqfjnzzzs"], 
		"LevelFallProbability": {"zqfjsszzs": 10, "zqfjblzzs": 10, "zqfjnzzzs": 10}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"金顶云海": {
		"LevelName": "金顶云海", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "岩石怪", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3047.tscn", "ConfigId": 3047}, 
			{"Name": "忍猴", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3038.tscn", "ConfigId": 3038}, 
			{"Name": "火焰鸟", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3036.tscn", "ConfigId": 3036}, 
			{"Name": "百足蜈蚣", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3039.tscn", "ConfigId": 3039}, 
			{"Name": "火之祖巫", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3042.tscn"}
		], 
		"LevelFall": ["139300021", "zqwqwkzzs", "zqwqtszzs", "zqwqbjzzs"], 
		"LevelFallProbability": {"139300021": 10, "zqwqwkzzs": 10, "zqwqtszzs": 10, "zqwqbjzzs": 10}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"五台山口": {
		"LevelName": "五台山口", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "鸟身女妖", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3065.tscn"}, 
			{"Name": "泥偶精", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3066.tscn"}, 
			{"Name": "核桃精", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3068.tscn"}, 
			{"Name": "金光孔雀", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3069.tscn"}
		], 
		"LevelFall": ["zqwqsszzs", "zqwqblzzs", "zqwqnzzzs"], 
		"LevelFallProbability": {"zqwqsszzs": 10, "zqwqblzzs": 10, "zqwqnzzzs": 10}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"锦绣峰": {
		"LevelName": "锦绣峰", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "鸟身女妖", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3065.tscn"}, 
			{"Name": "花妖", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3067.tscn"}, 
			{"Name": "芙蓉仙子", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3070.tscn"}
		], 
		"LevelFall": ["469000004"], 
		"LevelFallProbability": {"469000004": 10}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"万佛朝阁": {
		"LevelName": "万佛朝阁", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "花妖", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3067.tscn", "ConfigId": 3067}, 
			{"Name": "核桃精", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3068.tscn", "ConfigId": 3068}, 
			{"Name": "泥偶精", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3066.tscn", "ConfigId": 3066}, 
			{"Name": "守卫", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3076.tscn", "ConfigId": 3076}, 
			{"Name": "土之祖巫", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3071.tscn", "ConfigId": 3071, "HideIndependentDrops": true}
		], 
		"LevelFall": ["139300017"], 
		"LevelFallProbability": {"139300017": 10}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"冥海": {
		"LevelName": "冥海", 
		"fall_pro": 0, 
		"MonsterList": [
			{"Name": "通天教主(穷奇版)", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3117.tscn", "HideIndependentDrops": true}
		], 
		"LevelFall": [], 
		"LevelFallProbability": {}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}
		}, 
		"SelfBg": "hgs", 
		"Level": 90
	}, 

	"紫晶门": {
		"LevelName": "紫晶门", 
		"fall_pro": 10, 
		"MonsterList": [{"Name": "dylqs", "IsBoss": false}, 
		{"Name": "zmjw", "IsBoss": true}], 
		"LevelFall": ["sqnmwdnhzzs"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "zjm", 
		"Level": 62
	}, 


		"戮仙门": {
		"LevelName": "戮仙门", 
		"fall_pro": 10, 
		"MonsterList": [{"Name": "bssj", "IsBoss": true}], 
		"LevelFall": ["cjshenjzzs", "cdshenjzzs", "zhshenjzzs"], 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "lxm", 
		"Level": 64
	}, 
		"指景宫": {
		"LevelName": "指景宫", 
		"fall_pro": 0, 
		"MonsterList": [{"Name": "fyg", "IsBoss": false}, {"Name": "zqpw", "IsBoss": true}], 
		"LevelFall": ["xianyjp"], 
		"LevelFallProbability": {"xianyjp": 5}, 
		"NeedZDL": {
			"1": {"角色": "悟空", "战斗力": 0}, 
			"2": {"角色": "唐僧", "战斗力": 0}, 
			"3": {"角色": "八戒", "战斗力": 0}, 
			"4": {"角色": "沙僧", "战斗力": 0}, 
		}, 
		"SelfBg": "zjg", 
		"Level": 64
	}, 


}

var LevelName: String
var Num: int
var TargetStagePath: String
var _fall_refresh_pending: = false
var _monster_touch_active: = false
var _monster_touch_last_x: float = 0.0
var Time_: float
var Is_set: bool

func _popup_parent() -> Node:
	var parent_node: = get_parent()
	if parent_node != null and is_instance_valid(parent_node) and not parent_node.is_queued_for_deletion():
		return parent_node
	if Global.Windows_ != null and is_instance_valid(Global.Windows_) and not Global.Windows_.is_queued_for_deletion():
		return Global.Windows_
	var current_scene: = get_tree().current_scene
	if current_scene != null and is_instance_valid(current_scene):
		return current_scene
	return get_tree().root

func _open_special_level_popup(target_path: String) -> void :
	var parent_node: = _popup_parent()
	var popup = null
	if target_path == "res://Scene/Level/Level_llbt.tscn":
		popup = Global.AddllbtChallenge(parent_node, Vector2(0, 0))
	elif target_path == "兜率宫":
		popup = Global.AddDsgChoose(parent_node)
	if popup != null:
		popup.SourcePopup = self
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	queue_free()

func _ready() -> void :
	four_swords_mode_dialog.visible = false
	monster_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	monster_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_layout_for_viewport()
	get_viewport().size_changed.connect(_layout_for_viewport)

func _input(event: InputEvent) -> void :
	if TargetStagePath not in ["res://Scene/Level/Level_bxgh.tscn", "res://Scene/Level/Level_esbxx.tscn"]:
		return
	if monster_scroll == null or not is_instance_valid(monster_scroll) or not monster_scroll.is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_monster_touch_active = monster_scroll.get_global_rect().has_point(event.position)
			_monster_touch_last_x = event.position.x
		else:
			_monster_touch_active = false
	elif event is InputEventScreenDrag and _monster_touch_active:
		var delta_x: float = event.position.x - _monster_touch_last_x
		monster_scroll.scroll_horizontal = maxi(0, monster_scroll.scroll_horizontal - roundi(delta_x))
		_monster_touch_last_x = event.position.x
		get_viewport().set_input_as_handled()

func _layout_for_viewport() -> void :
	var viewport_size: = get_viewport_rect().size
	position = Vector2.ZERO
	scale = Vector2.ONE
	size = viewport_size
	if panel_layer != null:
		panel_layer.position = Vector2.ZERO
		panel_layer.size = viewport_size
		panel_layer.color = Color(0, 0, 0, 0)
	if color_rect_2 != null:
		color_rect_2.position = Vector2.ZERO
		color_rect_2.size = viewport_size
		color_rect_2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if level_info_panel != null:
		var panel_size: = level_info_panel.size * level_info_panel.scale
		level_info_panel.position = (viewport_size - panel_size) * 0.5

func _get_level_info() -> Dictionary:
	var info: = _get_base_level_info()
	var stages: = {50: 2, 53: 3, 56: 4, 59: 5, 63: 6, 66: 7, 69: 8, 72: 9}
	var stage: = int(TargetStagePath.get_file().get_basename().trim_prefix("Level_"))
	var tier: = int(stages.get(stage, 0))
	if tier == 0:
		tier = int({"九华山麓": 2, "普陀山脚": 3, "峨眉山道": 4, "五台山口": 5}.get(str(info.get("LevelName", "")), 0))
	if tier > 0:
		info = info.duplicate(true)
		var stone_id: = "pgs_%d" % tier
		var drops: Array = info.get("LevelFall", []).duplicate()
		if not drops.has(stone_id):
			drops.append(stone_id)
		info["LevelFall"] = drops
		var probabilities: Dictionary = info.get("LevelFallProbability", {}).duplicate()
		probabilities[stone_id] = 15
		info["LevelFallProbability"] = probabilities
	var moon_books: = {
		67: ["ygfjwkzzs", "ygfjtszzs", "ygfjbjzzs"], 
		68: ["ygfjsszzs", "ygfjblzzs", "ygfjnzzzs"], 
		70: ["ygwqwkzzs", "ygwqtszzs", "ygwqbjzzs"], 
		71: ["ygwqsszzs", "ygwqblzzs", "ygwqnzzzs"], 
	}
	if moon_books.has(stage):
		info = info.duplicate(true)
		var drops: Array = info.get("LevelFall", []).duplicate()
		var probabilities: Dictionary = info.get("LevelFallProbability", {}).duplicate()
		for book_id in moon_books[stage]:
			if not drops.has(book_id):
				drops.append(book_id)
			probabilities[book_id] = 10
		info["LevelFall"] = drops
		info["LevelFallProbability"] = probabilities
	return info

func _get_base_level_info() -> Dictionary:


	if TargetStagePath == "res://Scene/Level/Level_63.tscn":
		var east_jinshacun: = (LevelInfo["金沙村"] as Dictionary).duplicate(true) if LevelInfo.has("金沙村") else {}
		east_jinshacun["LevelName"] = "金沙村"
		east_jinshacun["MonsterList"] = [
			{"Name": "金沙村小怪", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3118.tscn"}, 
			{"Name": "金沙村飞行怪", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3119.tscn"}, 
			{"Name": "金沙村首领", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3120.tscn"}, 
		]
		east_jinshacun = _clear_east_continent_drop_preview(east_jinshacun)
		east_jinshacun["LevelFall"] = ["469000011"]
		east_jinshacun["LevelFallProbability"] = {"469000011": 10}
		return east_jinshacun
	if TargetStagePath == "res://Scene/Level/Level_64.tscn":
		var east_baixianyuan: = (LevelInfo["百仙园"] as Dictionary).duplicate(true) if LevelInfo.has("百仙园") else {}
		east_baixianyuan["LevelName"] = "百仙园"
		east_baixianyuan["MonsterList"] = [
			{"Name": "百仙园弓手", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3121.tscn"}, 
			{"Name": "百仙园妖灵", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3122.tscn"}, 
			{"Name": "煞人蜂", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3126.tscn"}, 
			{"Name": "百仙园首领", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3123.tscn"}, 
			{"Name": "百仙碟", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3125.tscn", "HideIndependentDrops": true}, 
		]
		east_baixianyuan = _clear_east_continent_drop_preview(east_baixianyuan)
		east_baixianyuan["LevelFall"] = ["2_jns"]
		east_baixianyuan["LevelFallProbability"] = {"2_jns": 20}
		return east_baixianyuan
	if TargetStagePath == "res://Scene/Level/Level_65.tscn":
		var east_aolaiguo: = (LevelInfo["傲来国"] as Dictionary).duplicate(true) if LevelInfo.has("傲来国") else {}
		east_aolaiguo["LevelName"] = "傲来国"
		east_aolaiguo["MonsterList"] = [
			{"Name": "3144", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3144.tscn", "ConfigId": 3144}, 
			{"Name": "3145", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3121.tscn", "ConfigId": 3145}, 
			{"Name": "3146", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3122.tscn", "ConfigId": 3146}, 
			{"Name": "3136", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3136.tscn", "ConfigId": 3136}, 
		]
		east_aolaiguo = _clear_east_continent_drop_preview(east_aolaiguo)
		if not east_aolaiguo.has("NeedZDL"):
			east_aolaiguo["NeedZDL"] = {}
		if not east_aolaiguo.has("SelfBg"):
			east_aolaiguo["SelfBg"] = "hgs"
		if not east_aolaiguo.has("Level"):
			east_aolaiguo["Level"] = 90
		return east_aolaiguo
	if TargetStagePath == "res://Scene/Level/Level_66.tscn":
		var east_huaguoshan: = (LevelInfo["花果山"] as Dictionary).duplicate(true)
		east_huaguoshan["MonsterList"] = [
			{"Name": "猴妖", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3159.tscn"}, 
			{"Name": "银杏精", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3160.tscn"}, 
			{"Name": "通臂白猿", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3161.tscn"}, 
		]
		return _clear_east_continent_drop_preview(east_huaguoshan)
	if TargetStagePath == "res://Scene/Level/Level_67.tscn":
		var east_shuiliandong: = (LevelInfo["水帘洞"] as Dictionary).duplicate(true)
		east_shuiliandong["MonsterList"] = [
			{"Name": "猴妖", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3159.tscn"}, 
			{"Name": "蘑菇长老", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3177.tscn"}, 
			{"Name": "六耳猕猴", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3179.tscn"}, 
		]
		return _clear_east_continent_drop_preview(east_shuiliandong)
	if TargetStagePath == "res://Scene/Level/Level_68.tscn":
		var east_taohuagu: = (LevelInfo["桃花源"] as Dictionary).duplicate(true)
		east_taohuagu["LevelName"] = "桃花谷"
		east_taohuagu["MonsterList"] = [
			{"Name": "骨刺兽", "IsBoss": false, "ScenePath": "res://Scene/Monster/Monster_3181.tscn"}, 
			{"Name": "雨之祖巫", "IsBoss": true, "ScenePath": "res://Scene/Monster/Monster_3182.tscn"}, 
		]
		return _clear_east_continent_drop_preview(east_taohuagu)
	var target_stage_text: = TargetStagePath.get_file().get_basename().trim_prefix("Level_")
	if target_stage_text.is_valid_int():
		var target_stage: = int(target_stage_text)
		if target_stage >= 76 and target_stage <= 85:
			return NorthOriginalData.preview(target_stage)
		if EAST_LATE_LEVEL_MONSTERS.has(target_stage):
			var east_late: = (LevelInfo[LevelName] as Dictionary).duplicate(true) if LevelInfo.has(LevelName) else {}
			east_late["LevelName"] = str(EAST_LATE_LEVEL_NAMES[target_stage])
			east_late["MonsterList"] = (EAST_LATE_LEVEL_MONSTERS[target_stage] as Array).duplicate(true)
			if not east_late.has("fall_pro"):
				east_late["fall_pro"] = 0
			if not east_late.has("LevelFall"):
				east_late["LevelFall"] = []
			if not east_late.has("NeedZDL"):
				east_late["NeedZDL"] = {}
			if not east_late.has("SelfBg"):
				east_late["SelfBg"] = "hgs"
			if not east_late.has("Level"):
				east_late["Level"] = 90
			return _clear_east_continent_drop_preview(east_late)
	if LevelInfo.has(LevelName):
		return LevelInfo[LevelName]
	push_warning("LevelInfo missing: " + str(LevelName))
	return {
		"LevelName": LevelName, 
		"fall_pro": 0, 
		"MonsterList": [], 
		"LevelFall": [], 
		"NeedZDL": {}, 
		"SelfBg": "hgs", 
		"Level": 0
	}

func _clear_east_continent_drop_preview(level_info: Dictionary) -> Dictionary:
	level_info["fall_pro"] = 0
	level_info["LevelFall"] = []
	level_info["LevelFallProbability"] = {}
	return level_info
func _physics_process(delta: float) -> void :
	match MainSet.set_data["CreateMonsterSpeed"]:
		1.2:
			speedtext.text = "×1"
		0.6:
			speedtext.text = "×2"
		0.3:
			speedtext.text = "×4"
		0.15:
			speedtext.text = "×8"
		0.075:
			speedtext.text = "×16"
	counttext.text = "×" + str(int(MainSet.set_data.get("CreateMonsterCount", 1)))
	if not Is_set:
		var info: = _get_level_info()
		level_down.text = str(info.get("Level", 0))
		pj.text = str(info.get("LevelName", LevelName)) + "历史最高评价："
		Title.text = str(info.get("LevelName", LevelName))
		fall.text = str(info.get("LevelName", LevelName)) + "概率掉落："
		Num = PlayerData.player_data["关卡评价"].get(LevelName, 0)
		mybg.texture = load_2(str(info.get("SelfBg", "hgs")))
		SetPJFontColor()
		AddLevelFallItem()
		_refresh_fall_pro_display()
		AddMonsterHead()


		var saved_diff = int(MainSet.set_data.get("Difficult", 0))
		diffvalue.text = ["普通", "困难", "地狱", "噩梦"][clampi(saved_diff, 0, 3)]
		difftext.text = "挑战难度:"

		Is_set = true


func SetPJFontColor():


	my_pj.text = PjList["PjList"][Num]
	my_pj.add_theme_color_override("font_color", FontColorList["font_colorList"][Num])

func AddLevelFallItem() -> void :
	if _fall_refresh_pending:
		return
	_fall_refresh_pending = true
	call_deferred("_rebuild_level_fall_items")

func _rebuild_level_fall_items() -> void :
	_fall_refresh_pending = false
	for child in fall_list.get_children():
		fall_list.remove_child(child)
		child.queue_free()
	var level_info: = _get_level_info()
	var InfoDic: Array = _get_level_fall_items(level_info)
	var fall_pro = level_info.get("fall_pro", 0)
	var item_probability: Dictionary = _get_level_fall_probabilities(level_info)
	var fixed_probability: = bool(level_info.get("LevelFallProbabilityFixed", false))\
	or _is_human_nightmare_level() or _is_underworld_nightmare_level()\
	or _is_heaven_nightmare_level()
	var default_pro_txt = ""
	if fall_pro > 0:
		default_pro_txt = _get_fall_pro_text(fall_pro)
	for i in InfoDic:
		var pro_txt = default_pro_txt
		if item_probability.has(i):
			pro_txt = _get_plain_fall_pro_text(int(item_probability[i])) if fixed_probability else _get_fall_pro_text(int(item_probability[i]))
		var box = Global.AddLevelFallBox(fall_list, true, true, i, 0, [], AE.AllEquipment_[i])
		box.set_button_icon(load_(i))
		box.set_meta("fall_item_name", i)
		if pro_txt != "":
			var pl = Label.new()
			pl.text = pro_txt
			pl.position = Vector2(1, -1)
			pl.add_theme_color_override("font_color", Color(1, 1, 1))
			pl.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
			pl.add_theme_constant_override("shadow_offset_x", 1)
			pl.add_theme_constant_override("shadow_offset_y", 1)
			pl.add_theme_font_size_override("font_size", 10)
			pl.mouse_filter = 2
			pl.set_meta("prob_label", true)
			box.add_child(pl)

	_sync_hell_extra_fall_display()

func _get_level_fall_items(level_info: Dictionary) -> Array:
	if _is_heaven_nightmare_level():
		return _get_heaven_nightmare_soul_items(level_info)
	if _is_underworld_nightmare_level():
		return _get_underworld_nightmare_soul_items(level_info)
	if _is_human_nightmare_level():
		return _get_human_nightmare_soul_items(level_info)
	if TargetStagePath == "res://Scene/Level/Level_stz.tscn":
		var selected_id: = int(Global.SelectedThreePrinceId)
		var items: = (THREE_PRINCE_DROP_ITEMS.get(selected_id, THREE_PRINCE_DROP_ITEMS[0]) as Array).duplicate()
		if int(MainSet.set_data.get("Difficult", 0)) == BaseMonster.NIGHTMARE_DIFFICULTY:
			for index in range(items.size()):
				items[index] = ThreePrinceBoss.NIGHTMARE_EQUIPMENT_REPLACEMENTS.get(items[index], items[index])
		return items
	if TargetStagePath == "res://Scene/Level/Level_bxgh.tscn":
		return (_get_eight_immortal_fall_preview().get("items", []) as Array).duplicate()
	if TargetStagePath == "res://Scene/Level/Level_esbxx.tscn":
		return (_get_constellation_fall_preview().get("items", []) as Array).duplicate()
	return (level_info.get("LevelFall", []) as Array).duplicate()

func _get_level_fall_probabilities(level_info: Dictionary) -> Dictionary:
	if TargetStagePath == "res://Scene/Level/Level_stz.tscn" and int(MainSet.set_data.get("Difficult", 0)) == BaseMonster.NIGHTMARE_DIFFICULTY:
		var probabilities: = {}
		for item_id in level_info.get("LevelFallProbability", {}):
			var replacement: String = ThreePrinceBoss.NIGHTMARE_EQUIPMENT_REPLACEMENTS.get(item_id, item_id)
			probabilities[replacement] = level_info["LevelFallProbability"][item_id]
		return probabilities
	if _is_heaven_nightmare_level():
		var heaven_probabilities: = {}
		for item_id in _get_heaven_nightmare_soul_items(level_info):
			heaven_probabilities[item_id] = 25
		return heaven_probabilities
	if _is_underworld_nightmare_level():
		var underworld_probabilities: = {}
		for item_id in _get_underworld_nightmare_soul_items(level_info):
			underworld_probabilities[item_id] = 25
		return underworld_probabilities
	if _is_human_nightmare_level():
		var probabilities: = {}
		for item_id in _get_human_nightmare_soul_items(level_info):
			probabilities[item_id] = 25
		return probabilities
	if TargetStagePath == "res://Scene/Level/Level_bxgh.tscn":
		return (_get_eight_immortal_fall_preview().get("probabilities", {}) as Dictionary).duplicate()
	if TargetStagePath == "res://Scene/Level/Level_esbxx.tscn":
		return (_get_constellation_fall_preview().get("probabilities", {}) as Dictionary).duplicate()
	return (level_info.get("LevelFallProbability", {}) as Dictionary).duplicate()

func _is_human_nightmare_level() -> bool:
	return int(MainSet.set_data.get("Difficult", 0)) == BaseMonster.NIGHTMARE_DIFFICULTY\
	and TargetStagePath in HUMAN_NIGHTMARE_LEVEL_PATHS

func _is_underworld_nightmare_level() -> bool:
	return int(MainSet.set_data.get("Difficult", 0)) == BaseMonster.NIGHTMARE_DIFFICULTY\
	and TargetStagePath in UNDERWORLD_NIGHTMARE_LEVEL_PATHS

func _is_heaven_nightmare_level() -> bool:
	return int(MainSet.set_data.get("Difficult", 0)) == BaseMonster.NIGHTMARE_DIFFICULTY\
	and TargetStagePath in HEAVEN_NIGHTMARE_LEVEL_PATHS

func _get_heaven_nightmare_soul_items(level_info: Dictionary) -> Array:
	var items: Array = []
	for monster_info: Variant in level_info.get("MonsterList", []):
		if not monster_info is Dictionary:
			continue
		var monster_key: = str(monster_info.get("Name", ""))
		var monster_id: = int(HEAVEN_SOUL_CRYSTAL_MONSTER_IDS.get(monster_key, 0))
		if monster_id <= 0:
			continue
		var item_id: = BaseMonster.HEAVEN_SOUL_CRYSTAL_ITEM_PREFIX + str(monster_id)
		if AE.AllEquipment_.has(item_id) and item_id not in items:
			items.append(item_id)
	return items

func _get_underworld_nightmare_soul_items(level_info: Dictionary) -> Array:
	var items: Array = []
	for monster_info: Variant in level_info.get("MonsterList", []):
		if not monster_info is Dictionary:
			continue
		var monster_key: = str(monster_info.get("Name", ""))
		var monster_id: = int(UNDERWORLD_SOUL_CRYSTAL_MONSTER_IDS.get(monster_key, 0))
		if monster_id <= 0:
			continue
		var item_id: = BaseMonster.UNDERWORLD_SOUL_CRYSTAL_ITEM_PREFIX + str(monster_id)
		if AE.AllEquipment_.has(item_id) and item_id not in items:
			items.append(item_id)
	return items

func _get_human_nightmare_soul_items(level_info: Dictionary) -> Array:
	var items: Array = []
	for monster_info: Variant in level_info.get("MonsterList", []):
		if not monster_info is Dictionary:
			continue
		var monster_key: = str(monster_info.get("Name", ""))
		var monster_id: = int(HUMAN_SOUL_CRYSTAL_MONSTER_IDS.get(monster_key, 0))
		if monster_id <= 0:
			continue
		var item_id: = BaseMonster.HUMAN_SOUL_CRYSTAL_ITEM_PREFIX + str(monster_id)
		if AE.AllEquipment_.has(item_id) and item_id not in items:
			items.append(item_id)
	return items

func _get_eight_immortal_fall_preview() -> Dictionary:
	var result: = {"items": [], "probabilities": {}}
	var selected_id: = int(Global.SelectedEightImmortalId)
	if selected_id not in EIGHT_IMMORTAL_IDS:
		return result
	var config: = _get_level_monster_config("", selected_id, 1)
	for drop_group in [config.get("drop_list", []), config.get("independent_drop_list", [])]:
		if not drop_group is Array:
			continue
		for drop: Variant in drop_group:
			if not drop is Dictionary:
				continue
			var item_id: = str(drop.get("name", ""))
			if item_id == "" or not AE.AllEquipment_.has(item_id):
				continue
			if item_id not in result["items"]:
				result["items"].append(item_id)
			var chance: = float(drop.get("chance", float(config.get("drop_rate", 0.0)) / 100.0))
			result["probabilities"][item_id] = roundi(chance * 100.0)
	return result

func _get_constellation_fall_preview() -> Dictionary:
	var result: = {"items": [], "probabilities": {}}
	var selected_level: = int(Global.SelectedConstellationLevel)
	if selected_level not in range(1, 15):
		return result
	var config: = _get_level_monster_config("", 47100 + selected_level, 1)
	for drop_group in [config.get("drop_list", []), config.get("independent_drop_list", [])]:
		if not drop_group is Array:
			continue
		for drop: Variant in drop_group:
			if not drop is Dictionary:
				continue
			var item_id: = str(drop.get("name", ""))
			if item_id == "" or not AE.AllEquipment_.has(item_id):
				continue
			if item_id not in result["items"]:
				result["items"].append(item_id)
			var chance: = float(drop.get("chance", float(config.get("drop_rate", 0.0)) / 100.0))
			result["probabilities"][item_id] = roundi(chance * 100.0)
	return result

func _get_fall_pro_text(base_pro: int) -> String:
	var diff = int(MainSet.set_data.get("Difficult", 0))
	var multipliers = [1.0, 2.0, 3.0, 3.0]
	diff = clampi(diff, 0, multipliers.size() - 1)
	var mult = multipliers[diff]
	var adjusted = min(base_pro * mult, 100.0)
	if diff == 0:
		if base_pro == 33:
			return "33.3%"
		return str(int(adjusted)) + "%"
	elif diff == 1:
		if base_pro == 33:
			return "66.6% (×2)"
		return str(int(adjusted)) + "% (×2)"
	elif diff == 2:
		if base_pro == 33:
			return "99.9% (×3)"
		return str(int(adjusted)) + "% (×3)"
	else:
		if base_pro == 33:
			return "99.9% (×3)"
		return str(int(adjusted)) + "% (×3)"

func _get_plain_fall_pro_text(base_pro: int) -> String:
	return str(base_pro) + "%"

func _sync_hell_extra_fall_display():
	var existing_qhsbx = null
	var duplicate_qhsbx = []
	for box in fall_list.get_children():
		var is_qhsbx = box.has_meta("hell_qhsbx") or (box.has_meta("fall_item_name") and str(box.get_meta("fall_item_name")) == "qhsbx") or (box.get("get_item_name") != null and str(box.get("get_item_name")) == "qhsbx")
		if is_qhsbx:
			if existing_qhsbx == null:
				existing_qhsbx = box
			else:
				duplicate_qhsbx.append(box)

	for box in duplicate_qhsbx:

		fall_list.remove_child(box)

		box.queue_free()

	if int(MainSet.set_data.get("Difficult", 0)) == 2:
		if existing_qhsbx == null and AE.AllEquipment_.has("qhsbx"):
			var qhsbx_box = Global.AddLevelFallBox(fall_list, true, true, "qhsbx", 0, [], AE.AllEquipment_["qhsbx"])
			qhsbx_box.set_button_icon(load_("qhsbx"))
			qhsbx_box.set_meta("fall_item_name", "qhsbx")
			qhsbx_box.set_meta("hell_qhsbx", true)
			var qhsbx_pro = Label.new()
			qhsbx_pro.text = "20%"
			qhsbx_pro.position = Vector2(1, -1)
			qhsbx_pro.add_theme_color_override("font_color", Color(1, 1, 1))
			qhsbx_pro.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
			qhsbx_pro.add_theme_constant_override("shadow_offset_x", 1)
			qhsbx_pro.add_theme_constant_override("shadow_offset_y", 1)
			qhsbx_pro.add_theme_font_size_override("font_size", 10)
			qhsbx_pro.mouse_filter = 2
			qhsbx_box.add_child(qhsbx_pro)
	elif existing_qhsbx != null and existing_qhsbx.has_meta("hell_qhsbx"):
		fall_list.remove_child(existing_qhsbx)
		existing_qhsbx.queue_free()

func _refresh_fall_pro_display():
	var level_info: = _get_level_info()
	var InfoDic = level_info.get("LevelFall", [])
	var base_pro = level_info.get("fall_pro", 0)
	var item_probability: Dictionary = _get_level_fall_probabilities(level_info)
	var fixed_probability: = bool(level_info.get("LevelFallProbabilityFixed", false))\
	or _is_human_nightmare_level() or _is_underworld_nightmare_level()\
	or _is_heaven_nightmare_level()
	var default_pro_txt = _get_fall_pro_text(base_pro) if base_pro > 0 else ""
	for box in fall_list.get_children():
		if box is Button:
			var item_name = str(box.get_meta("fall_item_name", ""))
			var pro_txt = default_pro_txt
			if item_probability.has(item_name):
				pro_txt = _get_plain_fall_pro_text(int(item_probability[item_name])) if fixed_probability else _get_fall_pro_text(int(item_probability[item_name]))
			for child in box.get_children():
				if child is Label and child.has_meta("prob_label"):
					child.text = pro_txt

func AddMonsterHead():
	var level_info: = _get_level_info()
	var InfoDic = level_info.get("MonsterList", [])
	for i in InfoDic:
		var head = Global.AddMonsterHead(monster_list, i["Name"], i["IsBoss"], str(i.get("ScenePath", "")))
		if head != null:
			head.LevelPath = TargetStagePath
			var constellation_level: = int(i.get("SelectConstellationLevel", 0))
			var preview_tier: = 0
			if constellation_level in range(1, 15):
				var stored_best: = PlayerData.get_constellation_highest_defeated_tier(constellation_level)
				var legacy_best: = clampi(
					int(Global.ConstellationBestTier.get(str(constellation_level), 0)), 0, 10
				)
				preview_tier = clampi(maxi(stored_best, legacy_best) + 1, 1, 10)
			head.LevelMonsterConfig = _get_level_monster_config(
				str(i.get("ScenePath", "")), int(i.get("ConfigId", 0)), preview_tier
			)
			head.set_meta("hide_independent_drops", bool(i.get("HideIndependentDrops", false)))
			var select_id: = int(i.get("SelectId", 0))
			if LevelName == "挑战三太子" and select_id > 0:
				head.set_meta("three_prince_id", select_id)
				head.set_selectable(true)
				head.selection_requested.connect(_on_three_prince_head_selected)
			if LevelName == "八仙过海" and select_id in EIGHT_IMMORTAL_IDS:
				head.set_meta("eight_immortal_id", select_id)
				head.set_selectable(true)
				head.selection_requested.connect(_on_eight_immortal_head_selected)
			if LevelName == "挑战28星宿" and constellation_level in range(1, 15):
				head.set_meta("constellation_level", constellation_level)
				head.set_selectable(true)
				head.selection_requested.connect(_on_constellation_head_selected)

func _get_level_monster_config(
	monster_scene_path: String, explicit_monster_id: int = 0, constellation_tier: int = 0
) -> Dictionary:
	if not TargetStagePath.begins_with("res://Scene/Level/Level_"):
		return {}
	var monster_id: = explicit_monster_id
	if monster_id <= 0:
		var monster_file: = monster_scene_path.get_file().get_basename()
		if not monster_file.begins_with("Monster_"):
			return {}
		var monster_id_text: = monster_file.trim_prefix("Monster_")
		if not monster_id_text.is_valid_int():
			return {}
		monster_id = int(monster_id_text)
	var level_script_path: = TargetStagePath.replace("res://Scene/Level/", "res://Script/Level/").get_basename() + ".gd"
	if not ResourceLoader.exists(level_script_path):
		return {}
	var level_script = load(level_script_path)
	if level_script == null:
		return {}
	var level_provider = level_script.new()
	if level_provider == null or not level_provider.has_method("get_level_monster_config"):
		if level_provider != null:
			level_provider.free()
		return {}
	var target_stage_text: = TargetStagePath.get_file().get_basename().trim_prefix("Level_")
	if target_stage_text.is_valid_int() and int(target_stage_text) in range(69, 76):
		level_provider.set("stage_number", int(target_stage_text))
	if constellation_tier > 0:
		level_provider.set("current_tier", clampi(constellation_tier, 1, 10))
	var config: Variant = level_provider.call("get_level_monster_config", monster_id)
	level_provider.free()
	return (config as Dictionary).duplicate(true) if config is Dictionary else {}

func _on_three_prince_head_selected(head: Node) -> void :
	var select_id: = int(head.get_meta("three_prince_id", 0))
	if select_id not in [4401, 4402, 4403]:
		return
	Global.SelectedThreePrinceId = select_id
	for child in monster_list.get_children():
		if child.has_method("set_selected"):
			child.set_selected(child == head)
	var prince_name: = str(head.get("MonsterName"))
	if head.has_method("get_display_name"):
		prince_name = str(head.call("get_display_name"))
	Title.text = "挑战三太子 · " + prince_name
	AddLevelFallItem()
	_refresh_fall_pro_display()

func _on_eight_immortal_head_selected(head: Node) -> void :
	var select_id: = int(head.get_meta("eight_immortal_id", 0))
	if select_id not in EIGHT_IMMORTAL_IDS:
		return
	Global.SelectedEightImmortalId = select_id
	for child in monster_list.get_children():
		if child.has_method("set_selected"):
			child.set_selected(child == head)
	var immortal_name: = str(head.get("MonsterName"))
	if head.has_method("get_display_name"):
		immortal_name = str(head.call("get_display_name"))
	Title.text = "八仙过海 · " + immortal_name
	AddLevelFallItem()
	_refresh_fall_pro_display()

func _on_constellation_head_selected(head: Node) -> void :
	var selected_level: = int(head.get_meta("constellation_level", 0))
	if selected_level not in range(1, 15):
		return
	Global.SelectedConstellationLevel = selected_level
	for child in monster_list.get_children():
		if child.has_method("set_selected"):
			child.set_selected(child == head)
	var constellation_name: = str(head.get("MonsterName"))
	if head.has_method("get_display_name"):
		constellation_name = str(head.call("get_display_name"))
	Title.text = "挑战28星宿 · " + constellation_name
	AddLevelFallItem()
	_refresh_fall_pro_display()
func load_(name_):
	var item_id: = str(name_)
	if AE.AllEquipment_.has(item_id):
		var data_icon_path: = str(AE.AllEquipment_[item_id].get("图标", ""))
		if data_icon_path != "" and ResourceLoader.exists(data_icon_path):
			return load(data_icon_path)
	var icon_path: = "res://Art/BackPack/AllItems/" + item_id + ".png"
	if ResourceLoader.exists(icon_path):
		return load(icon_path)
	return load("res://Art/BackPack/AllItems/empty.png")
func load_2(name_):
	var abc = load("res://Art/LevelInfoBg/" + str(name_) + ".png")
	return abc

func _get_nightmare_entry_block_message() -> String:
	if int(MainSet.set_data.get("Difficult", 0)) != BaseMonster.NIGHTMARE_DIFFICULTY:
		return ""
	if TargetStagePath == "res://Scene/Level/Level_stz.tscn":
		return ""
	if TargetStagePath in HUMAN_NIGHTMARE_LEVEL_PATHS:
		var cleared_biyou_palace: = int(PlayerData.player_data.get("通天教主", 0)) == 1
		return "" if cleared_biyou_palace else "通关碧游宫开放此难度"
	if TargetStagePath in UNDERWORLD_NIGHTMARE_LEVEL_PATHS:
		var cleared_south_continent: = int(PlayerData.player_data.get("冥海", 0)) == 1
		return "" if cleared_south_continent else "通关南瞻部洲开放此难度"
	if TargetStagePath in HEAVEN_NIGHTMARE_LEVEL_PATHS:
		var cleared_underworld_nightmare: = bool(PlayerData.player_data.get("地府噩梦", false))
		return "" if cleared_underworld_nightmare else "通关地府噩梦开放此难度"
	return "当前副本暂未开放此难度"

func _on_challenge_pressed() -> void :
	if TargetStagePath != "":
		var nightmare_block_message: = _get_nightmare_entry_block_message()
		if nightmare_block_message != "":
			Global.AddMessageShow(_popup_parent(), nightmare_block_message, 1.5, Vector2(470, 300))
			return
		if TargetStagePath == "res://Scene/Level/Level_stz.tscn" and Global.SelectedThreePrinceId not in [4401, 4402, 4403]:
			Global.AddMessageShow(_popup_parent(), "请选择要挑战的太子！", 1.5, Vector2(470, 300))
			return
		if TargetStagePath == "res://Scene/Level/Level_esbxx.tscn" and Global.SelectedConstellationLevel not in range(1, 15):
			Global.AddMessageShow(_popup_parent(), "请选择要挑战的星宿！", 1.5, Vector2(470, 300))
			return
		if TargetStagePath == "res://Scene/Level/Level_bxgh.tscn" and Global.SelectedEightImmortalId not in EIGHT_IMMORTAL_IDS:
			Global.AddMessageShow(_popup_parent(), "请选择要挑战的八仙 Boss！", 1.5, Vector2(470, 300))
			return
		if TargetStagePath == "res://Scene/Level/Level_llbt.tscn":
			_open_special_level_popup(TargetStagePath)
			return
		elif TargetStagePath == "兜率宫":
			_open_special_level_popup(TargetStagePath)
			return
		if TargetStagePath in ["res://Scene/Level/Level_stz.tscn", "res://Scene/Level/Level_tzsijian.tscn", "res://Scene/Level/Level_sssl.tscn", "res://Scene/Level/Level_esbxx.tscn"]:
			if TargetStagePath == "res://Scene/Level/Level_esbxx.tscn":
				four_swords_mode_dialog.get_node("BG/Title").text = "28星宿模式"
			else:
				four_swords_mode_dialog.get_node("BG/Title").text = "副本模式"
			four_swords_mode_dialog.visible = true
			return
		Global.ThreePrinceEndlessMode = false
		Global.FourSwordsEndlessMode = false
		Global.SSSLendlessMode = false
		Global.ConstellationEndlessMode = false
		Global.cleanup_transient_ui()
		Global.change_scene(TargetStagePath)
	else:
		Global.AddMessageShow(Global.Windows_, "获取关卡信息时出现错误，请手动更换关卡！！", 1.5, Vector2(470, 300))



func _on_boss_self_select_check_box_toggled(_toggled_on: bool) -> void :
	pass


func _on_close_pressed() -> void :
	if TargetStagePath in ["res://Scene/Level/Level_stz.tscn", "res://Scene/Level/Level_tzsijian.tscn", "res://Scene/Level/Level_sssl.tscn", "res://Scene/Level/Level_esbxx.tscn"]:
		Global.ThreePrinceEndlessMode = false
		Global.FourSwordsEndlessMode = false
		Global.SSSLendlessMode = false
		Global.ConstellationEndlessMode = false
	self.queue_free()

func _enter_four_swords_mode(endless_mode: bool) -> void :
	if TargetStagePath not in ["res://Scene/Level/Level_stz.tscn", "res://Scene/Level/Level_tzsijian.tscn", "res://Scene/Level/Level_sssl.tscn", "res://Scene/Level/Level_esbxx.tscn"]:
		return
	Global.ThreePrinceEndlessMode = TargetStagePath == "res://Scene/Level/Level_stz.tscn" and endless_mode
	Global.FourSwordsEndlessMode = TargetStagePath == "res://Scene/Level/Level_tzsijian.tscn" and endless_mode
	Global.SSSLendlessMode = TargetStagePath == "res://Scene/Level/Level_sssl.tscn" and endless_mode
	Global.ConstellationEndlessMode = TargetStagePath == "res://Scene/Level/Level_esbxx.tscn" and endless_mode
	four_swords_mode_dialog.visible = false
	Global.cleanup_transient_ui()
	Global.change_scene(TargetStagePath)

func _on_four_swords_mode_close_pressed() -> void :
	four_swords_mode_dialog.visible = false

func _on_four_swords_normal_mode_pressed() -> void :
	_enter_four_swords_mode(false)

func _on_four_swords_endless_mode_pressed() -> void :
	_enter_four_swords_mode(true)


func _on_speed_pressed() -> void :
	if MainSet.set_data["CreateMonsterSpeed"] > 0.075:
		MainSet.set_data["CreateMonsterSpeed"] = MainSet.set_data["CreateMonsterSpeed"] / 2
	else:
		MainSet.set_data["CreateMonsterSpeed"] = 1.2
	MemoryClass.main_bc()

func _on_diff_pressed() -> void :
	if diffvalue == null or difftext == null:
		return
	var diff = int(MainSet.set_data.get("Difficult", 0))
	diff = (diff + 1) % 4
	MainSet.set_data["Difficult"] = diff
	diffvalue.text = ["普通", "困难", "地狱", "噩梦"][diff]
	difftext.text = "挑战难度:"
	AddLevelFallItem()
	_refresh_fall_pro_display()
	MemoryClass.main_bc()

func _on_count_pressed() -> void :
	var count = int(MainSet.set_data.get("CreateMonsterCount", 1))
	count += 1
	if count > 5:
		count = 1
	MainSet.set_data["CreateMonsterCount"] = count
	counttext.text = "×" + str(count)
	MemoryClass.main_bc()
