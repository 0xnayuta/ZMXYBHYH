extends BaseLevel
class_name Lhhj

const GAME4_LEVEL_CONFIG_SCRIPT_PATH_BY_MONSTER := {
	3001: "res://Script/Level/Level_47.gd",
	3003: "res://Script/Level/Level_47.gd",
	3004: "res://Script/Level/Level_47.gd",
	3005: "res://Script/Level/Level_47.gd",
	3002: "res://Script/Level/Level_48.gd",
	3006: "res://Script/Level/Level_48.gd",
	3007: "res://Script/Level/Level_49.gd",
	3008: "res://Script/Level/Level_50.gd",
	3009: "res://Script/Level/Level_50.gd",
	3019: "res://Script/Level/Level_50.gd",
	3010: "res://Script/Level/Level_51.gd",
	3011: "res://Script/Level/Level_51.gd",
	3020: "res://Script/Level/Level_51.gd",
	3021: "res://Script/Level/Level_52.gd",
	3031: "res://Script/Level/Level_53.gd",
	3033: "res://Script/Level/Level_53.gd",
	3049: "res://Script/Level/Level_53.gd",
	3028: "res://Script/Level/Level_54.gd",
	3032: "res://Script/Level/Level_54.gd",
	3034: "res://Script/Level/Level_54.gd",
	3030: "res://Script/Level/Level_55.gd",
	3035: "res://Script/Level/Level_55.gd",
	3038: "res://Script/Level/Level_56.gd",
	3040: "res://Script/Level/Level_56.gd",
	3047: "res://Script/Level/Level_56.gd",
	3036: "res://Script/Level/Level_57.gd",
	3037: "res://Script/Level/Level_57.gd",
	3039: "res://Script/Level/Level_57.gd",
	3041: "res://Script/Level/Level_57.gd",
	3042: "res://Script/Level/Level_58.gd",
	3056: "res://Script/Level/Level_58.gd",
	3065: "res://Script/Level/Level_59.gd",
	3066: "res://Script/Level/Level_59.gd",
	3068: "res://Script/Level/Level_59.gd",
	3069: "res://Script/Level/Level_59.gd",
	3067: "res://Script/Level/Level_60.gd",
	3070: "res://Script/Level/Level_60.gd",
	3071: "res://Script/Level/Level_61.gd",
	3076: "res://Script/Level/Level_61.gd",
	3077: "res://Script/Level/Level_61.gd",
	3078: "res://Script/Level/Level_61.gd",
	3080: "res://Script/Level/Level_61.gd",
	3081: "res://Script/Level/Level_61.gd",
	3082: "res://Script/Level/Level_61.gd",
	3117: "res://Script/Level/Level_62.gd",
}

var is_cc = false
var IsSet: bool
var _game4_level_config_providers: Dictionary = {}


func _ready() -> void:
	Global.CurrentLevel = ""
	Global.addBGM_(self, "res://Music/level/szzw.mp3")

	self.level_stage = 1
	super._ready()
	Monster_group = {
		"stage_1": [],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	Monster_position_x = {
		"stage_1": [500],
		"stage_2": [500],
		"stage_3": [],
		"stage_4": [],
	}
	Monster_position_y = {
		"stage_1": [500],
		"stage_2": [500],
		"stage_3": [],
		"stage_4": [],
	}


func get_level_monster_config(monster_id: int) -> Dictionary:
	var script_path := str(GAME4_LEVEL_CONFIG_SCRIPT_PATH_BY_MONSTER.get(monster_id, ""))
	if script_path == "":
		return {}
	var provider: Node = _game4_level_config_providers.get(script_path) as Node
	if provider == null:
		var source := ResourceLoader.load(script_path, "GDScript", ResourceLoader.CACHE_MODE_REUSE) as Script
		var instance: Variant = source.new() if source != null else null
		if not instance is Node:
			return {}
		provider = instance as Node
		_game4_level_config_providers[script_path] = provider
	if provider.has_method("get_level_monster_config"):
		var value: Variant = provider.call("get_level_monster_config", monster_id)
		if value is Dictionary and not (value as Dictionary).is_empty():
			return (value as Dictionary).duplicate(true)
	return {}


func _exit_tree() -> void:
	for provider_value in _game4_level_config_providers.values():
		var provider := provider_value as Node
		if provider != null and is_instance_valid(provider):
			provider.free()
	_game4_level_config_providers.clear()


func _physics_process(delta: float) -> void:
	role_information.gogo.visible = false
	if not IsSet:
		for u in Global.LHHJBossList:
			var i = Global.LHHJBossList[u]
			var Monster
			var Id = i["Num"]
			var Local = Vector2(1100, 400)
			if Id == 33 or Id == 24 or Id == 56:
				Local = Vector2(700, 390)
			Monster = Global.Create_Monster(i["Num"], monster, Local)
			if Monster == null:
				continue
			if i["Name"] != null and str(i["Name"]) != "":
				Monster.my_mr_name = str(i["Name"])
			if int(i["Level"]) > 0:
				Monster.level = i["Level"]
			if int(i["SHp"]) > 0:
				Monster.SHp = i["SHp"]
				Monster.Hp = Monster.SHp
			if int(i["def"]) > 0:
				Monster.def = i["def"]
			if int(i["mdef"]) > 0:
				Monster.mdef = i["mdef"]
			if int(i["crit"]) > 0:
				Monster.crit = i["crit"]
			if int(i["miss"]) > 0:
				Monster.miss = i["miss"]
			if int(i["lucky"]) > 0:
				Monster.lucky = i["lucky"]
			if int(i["Htarget"]) > 0:
				Monster.Htarget = i["Htarget"]
			if int(i["Toughness"]) > 0:
				Monster.Toughness = i["Toughness"]
			if int(i["Critreduce"]) > 0:
				Monster.Critreduce = i["Critreduce"]
			if int(i["ar"]) > 0:
				Monster.ar = i["ar"]
			if int(i["sp"]) > 0:
				Monster.sp = i["sp"]
			if int(i["speed"]) > 0:
				Monster.speed = i["speed"]
			if int(i["self_rhp"]) > 0:
				Monster.self_rhp = i["self_rhp"]
			if float(i["ebol"]) > 0:
				Monster.ebol = i["ebol"]
			Monster.fall_list = []
			Monster.add_exp = 0
			Monster.fall_coin = 0
			Monster.fall_pro = 0
			Monster.fall_stone_pro = 0
			Monster.fall_stone = []
			if int(i["power"]) > 0:
				for z in Monster.objattackDic:
					if Monster.objattackDic[z].has("power"):
						Monster.objattackDic[z]["power"] = i["power"]
		IsSet = true
	if not is_cc:
		if Role_.position.x >= 600:
			create_control.wait_time = 3
			create_control.start()
			is_cc = true
			role_information.gogo.visible = false
		else:
			create_control.wait_time = 3
			create_control.start()
	super._physics_process(delta)
	my_camera.max_right = 1400

	if current_stage >= 1:
		if check_can_pass() and current_stage < 1:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false
