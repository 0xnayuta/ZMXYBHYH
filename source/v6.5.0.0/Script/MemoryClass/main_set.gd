extends Node

const FRAME_RATE_OPTIONS := [30, 60, 90, 120, 150]
const DEFAULT_FRAME_RATE := 150
const DEFAULT_MOBILE_FRAME_RATE := 60


func get_default_frame_rate() -> int:
	return DEFAULT_MOBILE_FRAME_RATE if OS.has_feature("mobile") else DEFAULT_FRAME_RATE


var auto_battle_enabled_runtime: bool = false

var set_data: Dictionary = {
	"music": 1,
	"time1": "",
	"time2": "",
	"time3": "",
	"time4": "",
	"time5": "",
	"time6": "",
	"name1": "",
	"name2": "",
	"name3": "",
	"name4": "",
	"name5": "",
	"name6": "",
	"其他存档": {},
	"剧情跳过": false,
	"Map_num": 1,
	"MainMenuBG": 1,
	"BackGroundMusic": true,
	"RoleOrMonsterHit": true,
	"MonsterBloodSHow": true,
	"MonsterBloodTextSHow": false,
	"MonsterLittleBlood": true,
	"ShowDamageText": true,
	"MusicFB": 0,
	"MusicFB_2": 0,
	"NoShowMonsterBody": true,
	"HpBarDelay": false,
	"FristGame": true,
	"automatically_pick_up_items": false,
	"PickUpItemsMusic": false,
	"CurrentLevelPage": 0,
	"CreateMonsterSpeed": 1.2,
	"CreateMonsterCount": 1,
	"Difficult": 0,
	"镇妖塔自动下一层": false,
	"LevelInfo": true,
	"AutoBattleEnabled": false,
	"AutoBattleSkills": [],
	"AutoBattleSkillsByRole": {},
	"AutoBattleWushuang": false,
	"AutoBattleRetry": false,
	"AutoBattleSkillOnly": false,
	"AutoBattleMagicWeapon": false,
	"AutoBattleSwordArray": false,
	"xg": false,
	"Music4": false,
	"LevelHYS": true,
	"LevelLSH": false,
	"LevelTT": true,
	"MyTime": {},
	"FileValue": 1.0,
	"XiaoBaiLong": true,
	"NotShowRoleBody": false,
	"NotShowRoleEQ": false,
	"CdNum": 6,
	"FrameRate": get_default_frame_rate(),
}


func is_auto_battle_enabled() -> bool:
	return auto_battle_enabled_runtime


func set_auto_battle_enabled(enabled: bool) -> void:
	auto_battle_enabled_runtime = enabled


func get_frame_rate() -> int:
	var frame_rate := int(set_data.get("FrameRate", get_default_frame_rate()))
	if frame_rate not in FRAME_RATE_OPTIONS:
		frame_rate = get_default_frame_rate()
		set_data["FrameRate"] = frame_rate
	return frame_rate


func apply_frame_rate() -> void:
	Engine.max_fps = get_frame_rate()
