extends Node

const BODY_TRAINING_DATA = preload("res://Script/Data/BodyTrainingData.gd")

var Directon: bool
var SourcePlayer
var roleprop = {}
var baseroleprop = {}
var equprop = {}
var Paslprop = {}
var WqBs_prop = {}
var FjBs_prop = {}
var SpBs_prop = {}
var CbBs_prop = {}
var SzBs_prop = {}
var TxBs_prop = {}
var role_pos_x
var role_pos
var role_pos_y
var _monster_attack_targets: Array[Node2D] = []
var slz_level: int
var hytj_level: int
var lys_level: int
var lyfb_level: int
var hmz_level: int
var ws_value: int
var max_ws_value = 100
var is_ws_state = false
var ws_up_power = 1
var wq_prop = {}
var fj_prop = {}
var sp_prop = {}
var sz_prop = {}
var tx_prop = {}
var cb_prop = {}
var fb_prop = {}
var Role1SXBJ: float
var Role1SXxx: float
var CurrentHp: int = 1
var CurrentMp: int = 1
var pet_life_bonus: int = 0
var pet_attack_bonus: int = 0
var pet_defense_bonus: int = 0
var pet_magic_defense_bonus: int = 0
var pet_mana_bonus: int = 0
var _equipment_signature := 0
var _static_prop_signature := 0
var _cached_pellet_props: Array = []
var _cached_zf_props: Dictionary = {}
var _cached_sword_props: Dictionary = {}
var _cached_body_props: Dictionary = {}
var _cached_wanling_props: Dictionary = {}
var _cached_mount_props: Dictionary = {}
var PelletProps = {
	"1品丹":
	{
		"生命": 100,
		"魔法": 10,
		"攻击": 10,
		"暴击": 1,
		"幸运": 1,
		"回魔": 0.4,
	},
	"2品丹":
	{
		"生命": 150,
		"魔法": 15,
		"攻击": 15,
		"暴击": 1,
		"幸运": 1,
		"回魔": 0.4,
	},
	"3品丹":
	{
		"生命": 200,
		"魔法": 40,
		"攻击": 20,
		"暴击": 1,
		"幸运": 1,
		"回魔": 0.4,
	},
	"4品丹":
	{
		"生命": 250,
		"魔法": 55,
		"攻击": 25,
		"暴击": 1,
		"幸运": 1,
		"回魔": 0.4,
	},
	"5品丹":
	{
		"生命": 300,
		"魔法": 70,
		"攻击": 30,
		"暴击": 2,
		"幸运": 2,
		"回魔": 0.4,
	},
}
var ZhenFaProps = {
	"森罗阵":
	{
		"1": {"Type": "物防", "Value": 1},
		"2": {"Type": "暴击", "Value": 1},
		"3": {"Type": "魔防", "Value": 1},
	},
	"落魄阵":
	{
		"1": {"Type": "魔法", "Value": 15},
		"2": {"Type": "攻击", "Value": 5},
		"3": {"Type": "幸运", "Value": 1},
	},
	"腾蛇阵":
	{
		"1": {"Type": "生命", "Value": 75},
		"2": {"Type": "攻击", "Value": 10},
		"3": {"Type": "破甲", "Value": 2},
		"4": {"Type": "破魔", "Value": 2},
	},
	"太清阵":
	{
		"1": {"Type": "生命", "Value": 75},
		"2": {"Type": "攻击", "Value": 10},
		"3": {"Type": "暴击", "Value": 1},
		"4": {"Type": "幸运", "Value": 1},
	},
}


func register_monster_attack_target(target: Node2D) -> void:
	if target != null and is_instance_valid(target) and not _monster_attack_targets.has(target):
		_monster_attack_targets.append(target)


func unregister_monster_attack_target(target: Node2D) -> void:
	_monster_attack_targets.erase(target)


func get_nearest_monster_target_position(origin: Vector2) -> Vector2:
	var nearest_position := Vector2.ZERO
	if SourcePlayer is Node2D and is_instance_valid(SourcePlayer):
		nearest_position = (SourcePlayer as Node2D).global_position
	elif role_pos is Vector2:
		nearest_position = role_pos
	elif role_pos_x != null and role_pos_y != null:
		nearest_position = Vector2(float(role_pos_x), float(role_pos_y))

	var nearest_distance := origin.distance_squared_to(nearest_position)
	for index in range(_monster_attack_targets.size() - 1, -1, -1):
		var target := _monster_attack_targets[index]
		if target == null or not is_instance_valid(target) or not target.is_inside_tree() or int(target.get("Hp")) <= 0:
			_monster_attack_targets.remove_at(index)
			continue
		var target_position := target.global_position
		var target_distance := origin.distance_squared_to(target_position)
		if target_distance < nearest_distance:
			nearest_position = target_position
			nearest_distance = target_distance
	return nearest_position


func get_zf_loc_prop(Name, loc):
	var Level = int(PlayerData.player_data[Name][str(loc)]["Level"])
	var Dic = ZhenFaProps[Name]
	var Prop = int(Dic[str(loc)]["Value"]) * Level
	return Prop


func get_next_level_prop(Name, loc):
	var Level = int(PlayerData.player_data[Name][str(loc)]["Level"]) + 1
	var Dic = ZhenFaProps[Name]
	var Prop = int(Dic[str(loc)]["Value"]) * Level
	return Prop


func get_zf_prop(Name):
	match Name:
		"生命":
			return GetZFLocProp("太清阵", 1) + GetZFLocProp("腾蛇阵", 1)
		"魔法":
			return GetZFLocProp("落魄阵", 1)
		"攻击":
			return GetZFLocProp("太清阵", 2) + GetZFLocProp("腾蛇阵", 2) + GetZFLocProp("落魄阵", 2)
		"物防":
			return GetZFLocProp("森罗阵", 1)
		"魔防":
			return GetZFLocProp("森罗阵", 3)
		"暴击":
			return GetZFLocProp("森罗阵", 2) + GetZFLocProp("太清阵", 3)
		"幸运":
			return GetZFLocProp("太清阵", 4) + GetZFLocProp("落魄阵", 3)
		"破甲":
			return GetZFLocProp("腾蛇阵", 3)
		"破魔":
			return GetZFLocProp("腾蛇阵", 4)
	return 0


func get_main_sword_array_prop(Name):
	var active := str(PlayerData.player_data.get("主线剑阵出战", ""))
	if active == "":
		return 0
	var total := 0
	if active == "sijianheyi":
		total += _get_single_main_sword_array_prop(Name, "zhuxianjian", _get_main_sword_array_level("zhuxianjian"))
		total += _get_single_main_sword_array_prop(Name, "xianxianjian", _get_main_sword_array_level("xianxianjian"))
		total += _get_single_main_sword_array_prop(Name, "luxianjian", _get_main_sword_array_level("luxianjian"))
		total += _get_single_main_sword_array_prop(Name, "juexianjian", _get_main_sword_array_level("juexianjian"))
		total += _get_sijianheyi_prop(Name, _get_main_sword_array_level("sijianheyi"))
		return total
	return _get_single_main_sword_array_prop(Name, active, _get_main_sword_array_level(active))


func _get_main_sword_array_level(sword_id: String) -> int:
	if PlayerData != null and PlayerData.has_method("get_main_sword_array_level"):
		return int(PlayerData.get_main_sword_array_level(sword_id))
	return 0


func _get_single_main_sword_array_prop(Name: String, sword_id: String, level: int) -> int:
	if level <= 0:
		return 0
	match sword_id:
		"zhuxianjian":
			if Name == "攻击":
				return level * 150
		"xianxianjian":
			if Name == "生命":
				return level * 500
		"luxianjian":
			if Name == "物防" or Name == "魔防":
				return level * 20
		"juexianjian":
			if Name == "魔法":
				return level * 400
	return 0


func _get_sijianheyi_prop(Name: String, level: int) -> int:
	if level <= 0:
		return 0
	match Name:
		"暴击":
			return level * 10
		"命中":
			return level * 10
		"闪避":
			return level * 5
		"幸运":
			return level * 5
	return 0


func _ready() -> void:
	baseroleprop = {
		"Level": 1,
		"SHp": 0,
		"Hp": 0,
		"SMp": 0,
		"Mp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"Toughness": 0,
		"Htarget": 0,
		"CritReduce": 0,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"ar": 0,
		"sp": 0,
		"exp": 0,
		"max_exp": 0,
		"gxp_value": 0,
		"coin_num": 0
	}
	roleprop = {
		"SHp": 0,
		"Hp": 0,
		"SMp": 0,
		"Mp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"Toughness": 0,
		"Htarget": 0,
		"CritReduce": 0,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"ar": 0,
		"sp": 0
	}
	equprop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"Toughness": 0,
		"Htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	wq_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"Toughness": 0,
		"Htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	fj_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"Toughness": 0,
		"Htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	sp_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"Toughness": 0,
		"Htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	fb_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"Toughness": 0,
		"Htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	cb_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"Toughness": 0,
		"Htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	tx_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"Toughness": 0,
		"Htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	sz_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"Toughness": 0,
		"Htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	Paslprop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"Toughness": 0,
		"Htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	WqBs_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0,
		"Lucky": 0,
		"Toughness": 0,
		"Htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	FjBs_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0,
		"Lucky": 0,
		"Toughness": 0,
		"Htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	SpBs_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0,
		"Lucky": 0,
		"Toughness": 0,
		"Htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}


func get_pellet_prop():
	var Hp: int = 0
	var Mp: int = 0
	var Att: int = 0
	var Crit: int = 0
	var Lucky: int = 0
	var Emp: float = 0
	for i in range(6):
		if i > 0:
			Hp += PlayerData.player_data["生命丹" + str(i)] * PelletProps[str(i) + "品丹"]["生命"]
			Mp += PlayerData.player_data["魔法丹" + str(i)] * PelletProps[str(i) + "品丹"]["魔法"]
			Att += PlayerData.player_data["攻击丹" + str(i)] * PelletProps[str(i) + "品丹"]["攻击"]
			Crit += PlayerData.player_data["暴击丹" + str(i)] * PelletProps[str(i) + "品丹"]["暴击"]
			Lucky += PlayerData.player_data["幸运丹" + str(i)] * PelletProps[str(i) + "品丹"]["幸运"]
			Emp += PlayerData.player_data["回魔丹" + str(i)] * PelletProps[str(i) + "品丹"]["回魔"]
	return [Hp, Mp, Att, Crit, Lucky, Emp]


func _get_static_prop_signature() -> int:
	var values: Array = []
	for i in range(1, 6):
		values.append(PlayerData.player_data.get("生命丹" + str(i), 0))
		values.append(PlayerData.player_data.get("魔法丹" + str(i), 0))
		values.append(PlayerData.player_data.get("攻击丹" + str(i), 0))
		values.append(PlayerData.player_data.get("暴击丹" + str(i), 0))
		values.append(PlayerData.player_data.get("幸运丹" + str(i), 0))
		values.append(PlayerData.player_data.get("回魔丹" + str(i), 0))
	for formation_name in ["森罗阵", "落魂阵", "腾蛇阵", "太清阵"]:
		values.append(PlayerData.player_data.get(formation_name, {}))
	values.append(PlayerData.player_data.get("主线剑阵出战", ""))
	for sword_id in ["zhuxianjian", "xianxianjian", "luxianjian", "juexianjian", "sijianheyi"]:
		values.append(_get_main_sword_array_level(sword_id))
	values.append(PlayerData.player_data.get("炼体", {}))
	values.append(PlayerData.player_data.get(PlayerData.WANLING_CATALOG_LEVELS_KEY, {}))
	values.append(PlayerData.player_data.get(PlayerData.ACTIVE_MOUNT_KEY, ""))
	var active_mount := PlayerData.get_active_mount()
	values.append(active_mount.get("等级", 0))
	return hash(values)


func _refresh_static_prop_cache() -> void:
	var signature := _get_static_prop_signature()
	if signature == _static_prop_signature and not _cached_pellet_props.is_empty():
		return
	_static_prop_signature = signature
	_cached_pellet_props = GetPelletProp()
	_cached_zf_props = {
		"生命": GetZFProp("生命"),
		"魔法": GetZFProp("魔法"),
		"攻击": GetZFProp("攻击"),
		"暴击": GetZFProp("暴击"),
		"幸运": GetZFProp("幸运"),
		"物防": GetZFProp("物防"),
		"魔防": GetZFProp("魔防"),
		"破甲": GetZFProp("破甲"),
		"破魔": GetZFProp("破魔")
	}
	_cached_sword_props = {
		"生命": GetMainSwordArrayProp("生命"),
		"魔法": GetMainSwordArrayProp("魔法"),
		"攻击": GetMainSwordArrayProp("攻击"),
		"暴击": GetMainSwordArrayProp("暴击"),
		"幸运": GetMainSwordArrayProp("幸运"),
		"物防": GetMainSwordArrayProp("物防"),
		"魔防": GetMainSwordArrayProp("魔防"),
		"闪避": GetMainSwordArrayProp("闪避"),
		"命中": GetMainSwordArrayProp("命中")
	}
	_cached_body_props = BODY_TRAINING_DATA.get_attribute_totals(PlayerData.player_data.get("炼体", {}))
	_cached_wanling_props = PlayerData.get_wanling_attribute_totals()
	_cached_mount_props = PlayerData.get_active_mount_attribute_bonuses()


func get_last_prop():
	if PlayerData.ChekEqzb("头衔", "xczg"):
		if SourcePlayer != null:
			for i in SourcePlayer.buff.get_children():
				if i.BuffInfo.has("DeBuff") and i.BuffInfo["DeBuff"]:
					i.queue_free()
	var is_sxyr: bool = bool(PlayerData.ChekEqzb("头衔", "sxyr"))
	if is_sxyr and SourcePlayer != null and not SourcePlayer.SXYRCannotCure:
		roleprop.SHp = 1
		roleprop.Hp = 1
		SourcePlayer.SXYRCannotCure = true
		for i in SourcePlayer.buff.get_children():
			if i.BuffInfo.has("DeBuff") and i.BuffInfo["DeBuff"]:
				i.queue_free()

	_refresh_static_prop_cache()
	var pellet: Array = _cached_pellet_props
	var zf_hp = _cached_zf_props["生命"]
	var zf_mp = _cached_zf_props["魔法"]
	var zf_power = _cached_zf_props["攻击"]
	var zf_crit = _cached_zf_props["暴击"]
	var zf_lucky = _cached_zf_props["幸运"]
	var zf_def = _cached_zf_props["物防"]
	var zf_mdef = _cached_zf_props["魔防"]
	var zf_ar = _cached_zf_props["破甲"]
	var zf_sp = _cached_zf_props["破魔"]
	var sword_hp = _cached_sword_props["生命"]
	var sword_mp = _cached_sword_props["魔法"]
	var sword_power = _cached_sword_props["攻击"]
	var sword_crit = _cached_sword_props["暴击"]
	var sword_lucky = _cached_sword_props["幸运"]
	var sword_def = _cached_sword_props["物防"]
	var sword_mdef = _cached_sword_props["魔防"]
	var sword_miss = _cached_sword_props["闪避"]
	var sword_hit = _cached_sword_props["命中"]
	var body_hp = int(_cached_body_props.get("hpMax", 0))
	var body_mp = int(_cached_body_props.get("mpMax", 0))
	var body_power = int(_cached_body_props.get("atk", 0))
	var body_def = int(_cached_body_props.get("phyDef", 0))
	var body_mdef = int(_cached_body_props.get("magicDef", 0))
	var wanling_hp = float(_cached_wanling_props.get("SHp", 0.0))
	var wanling_mp = float(_cached_wanling_props.get("SMp", 0.0))
	var wanling_power = float(_cached_wanling_props.get("power", 0.0))
	var wanling_def = float(_cached_wanling_props.get("Def", 0.0))
	var wanling_mdef = float(_cached_wanling_props.get("Mdef", 0.0))
	var wanling_crit = float(_cached_wanling_props.get("Crit", 0.0))
	var mount_hp = float(_cached_mount_props.get("SHp", 0.0))
	var mount_power = float(_cached_mount_props.get("power", 0.0))
	var mount_def = float(_cached_mount_props.get("Def", 0.0))
	var mount_mdef = float(_cached_mount_props.get("Mdef", 0.0))
	var mount_crit = float(_cached_mount_props.get("Crit", 0.0))
	if not is_sxyr:
		roleprop.SHp = maxi(
			1,
			int(
				(
					baseroleprop.SHp
					+ equprop.SHp
					+ Paslprop.SHp
					+ pellet[0]
					+ zf_hp
					+ sword_hp
					+ body_hp
					+ pet_life_bonus
					+ wanling_hp
					+ mount_hp
				)
			)
		)
		if SourcePlayer != null:
			roleprop.SHp = maxi(
				1, int(round(float(roleprop.SHp) * (1.0 + maxf(0.0, SourcePlayer.temp_max_hp_bonus_rate))))
			)
	roleprop.SMp = (
		baseroleprop.SMp
		+ equprop.SMp
		+ Paslprop.SMp
		+ pellet[1]
		+ zf_mp
		+ sword_mp
		+ body_mp
		+ pet_mana_bonus
		+ wanling_mp
	)
	var base_power = (
		baseroleprop.power
		+ equprop.power
		+ Paslprop.power
		+ pellet[2]
		+ zf_power
		+ sword_power
		+ body_power
		+ pet_attack_bonus
		+ wanling_power
		+ mount_power
	)
	var base_crit = (
		baseroleprop.Crit
		+ equprop.Crit
		+ Paslprop.Crit
		+ Role1SXBJ
		+ pellet[3]
		+ zf_crit
		+ sword_crit
		+ wanling_crit
		+ float(_cached_mount_props.get("Crit", 0.0))
	)
	var base_lucky = (
		baseroleprop.Lucky
		+ equprop.Lucky
		+ Paslprop.Lucky
		+ pellet[4]
		+ zf_lucky
		+ sword_lucky
		+ float(_cached_mount_props.get("Lucky", 0.0))
	)
	if SourcePlayer != null and SourcePlayer.IsYxBuff:
		roleprop.power = int(base_power * (1 + SourcePlayer.YxBuffPowerRate))
		roleprop.Crit = base_crit * (1 + SourcePlayer.YxBuffCritRate)
		roleprop.Lucky = int(base_lucky * (1 + SourcePlayer.YxBuffLuckyRate))
	else:
		roleprop.power = base_power
		roleprop.Crit = base_crit
		roleprop.Lucky = base_lucky
	if SourcePlayer != null:
		roleprop.power = int(round(float(roleprop.power) * (1.0 + maxf(0.0, SourcePlayer.temp_power_bonus_rate))))
	roleprop.Def = (
		baseroleprop.Def
		+ equprop.Def
		+ Paslprop.Def
		+ zf_def
		+ sword_def
		+ body_def
		+ pet_defense_bonus
		+ wanling_def
		+ mount_def
	)
	roleprop.Mdef = (
		baseroleprop.Mdef
		+ equprop.Mdef
		+ Paslprop.Mdef
		+ zf_mdef
		+ sword_mdef
		+ body_mdef
		+ pet_magic_defense_bonus
		+ wanling_mdef
		+ mount_mdef
	)
	if SourcePlayer != null:
		roleprop.Def += SourcePlayer.temp_def_bonus
		roleprop.Mdef += SourcePlayer.temp_mdef_bonus
		if SourcePlayer.IsTMc:
			roleprop.Def = int(round(float(roleprop.Def) * 1.5))
			roleprop.Mdef = int(round(float(roleprop.Mdef) * 1.5))
	roleprop.Miss = (
		baseroleprop.Miss + equprop.Miss + Paslprop.Miss + sword_miss + float(_cached_mount_props.get("Miss", 0.0))
	)
	roleprop.R_hp = (
		baseroleprop.R_hp
		+ equprop.R_hp
		+ Paslprop.R_hp
		+ float(_cached_wanling_props.get("R_hp", 0.0))
		+ float(_cached_mount_props.get("R_hp", 0.0))
	)
	roleprop.R_mp = (
		baseroleprop.R_mp + equprop.R_mp + Paslprop.R_mp + pellet[5] + float(_cached_wanling_props.get("R_mp", 0.0))
	)
	roleprop.vampirism = (
		baseroleprop.vampirism
		+ equprop.vampirism
		+ Paslprop.vampirism
		+ Role1SXxx
		+ float(_cached_wanling_props.get("vampirism", 0.0))
	)
	roleprop.Toughness = baseroleprop.Toughness + equprop.Toughness + Paslprop.Toughness
	roleprop.Htarget = (
		baseroleprop.Htarget
		+ equprop.Htarget
		+ Paslprop.Htarget
		+ sword_hit
		+ float(_cached_mount_props.get("Htarget", 0.0))
	)
	roleprop.CritReduce = baseroleprop.CritReduce + equprop.CritReduce + Paslprop.CritReduce
	roleprop.damage_bonus = (
		float(baseroleprop.get("damage_bonus", 0.0)) + float(_cached_wanling_props.get("damage_bonus", 0.0))
	)
	roleprop.damage_reduction = (
		float(baseroleprop.get("damage_reduction", 0.0)) + float(_cached_wanling_props.get("damage_reduction", 0.0))
	)
	roleprop.ar = baseroleprop.ar + equprop.ar + Paslprop.ar + zf_ar + float(_cached_wanling_props.get("ar", 0.0))
	roleprop.sp = (
		baseroleprop.sp
		+ equprop.sp
		+ Paslprop.sp
		+ zf_sp
		+ float(_cached_wanling_props.get("sp", 0.0))
		+ float(_cached_mount_props.get("sp", 0.0))
	)


func set_basic_prop():
	baseroleprop.Level = clampi(int(baseroleprop.Level), 1, int(PlayerData.PLAYER_MAX_LEVEL))
	var max_exp_list = [
		140, 160, 180, 200, 220, 300, 400, 500, 600, 700, 800, 900, 1200, 1400, 1600, 2000, 2400, 3000, 4000, 5000
	]
	match int(PlayerData.player_data["Myself"]):
		1:
			baseroleprop.SHp = 80 + 50 * (baseroleprop.Level - 1)
			baseroleprop.SMp = 50 + 15 * (baseroleprop.Level - 1)
			baseroleprop.power = 8 + 4 * (baseroleprop.Level - 1)
			baseroleprop.Def = 10 + 1 * (baseroleprop.Level - 1)
			baseroleprop.Mdef = 10 + 1 * (baseroleprop.Level - 1)
		2:
			baseroleprop.SHp = 50 + 30 * (baseroleprop.Level - 1)
			baseroleprop.SMp = 100 + 30 * (baseroleprop.Level - 1)
			baseroleprop.power = 15 + 6 * (baseroleprop.Level - 1)
			baseroleprop.Def = 10 + 1 * (baseroleprop.Level - 1)
			baseroleprop.Mdef = 10 + 1 * (baseroleprop.Level - 1)
		3:
			baseroleprop.SHp = 120 + 60 * (baseroleprop.Level - 1)
			baseroleprop.SMp = 25 + 10 * (baseroleprop.Level - 1)
			baseroleprop.power = 15 + 4 * (baseroleprop.Level - 1)
			baseroleprop.Def = 15 + 1 * (baseroleprop.Level - 1)
			baseroleprop.Mdef = 15 + 1 * (baseroleprop.Level - 1)
		4:
			baseroleprop.SHp = 70 + 40 * (baseroleprop.Level - 1)
			baseroleprop.SMp = 70 + 20 * (baseroleprop.Level - 1)
			baseroleprop.power = 15 + 4 * (baseroleprop.Level - 1)
			baseroleprop.Def = 5 + 1 * (baseroleprop.Level - 1)
			baseroleprop.Mdef = 5 + 1 * (baseroleprop.Level - 1)
		5:
			baseroleprop.SHp = 80 + 40 * (baseroleprop.Level - 1)
			baseroleprop.SMp = 50 + 20 * (baseroleprop.Level - 1)
			baseroleprop.power = 10 + 4 * (baseroleprop.Level - 1)
			baseroleprop.Def = 8 + 1 * (baseroleprop.Level - 1)
			baseroleprop.Mdef = 8 + 1 * (baseroleprop.Level - 1)
		6:
			baseroleprop.SHp = 80 + 50 * (baseroleprop.Level - 1)
			baseroleprop.SMp = 50 + 15 * (baseroleprop.Level - 1)
			baseroleprop.power = 8 + 4 * (baseroleprop.Level - 1)
			baseroleprop.Def = 10 + 1 * (baseroleprop.Level - 1)
			baseroleprop.Mdef = 10 + 1 * (baseroleprop.Level - 1)
	if baseroleprop.Level < 20:
		baseroleprop.max_exp = max_exp_list[baseroleprop.Level - 1]
	else:
		baseroleprop.max_exp = 5000 + 5000 * (baseroleprop.Level - 19)
	get_last_prop()
	set_full_Hp()
	set_full_Mp()


func set_full_hp():
	roleprop.Hp = roleprop.SHp


func set_full_mp():
	roleprop.Mp = roleprop.SMp


func _physics_process(_delta: float) -> void:
	if ws_value >= max_ws_value:
		ws_value = max_ws_value

	if ws_value <= 0:
		is_ws_state = false
		ws_value = 0
	if is_ws_state == true:
		ws_up_power = 1.5
	else:
		ws_up_power = 1
	check_Hp()
	check_Mp()
	var equipment_signature := hash(
		[
			PlayerData.player_data.get("武器", []),
			PlayerData.player_data.get("防具", []),
			PlayerData.player_data.get("饰品", []),
			PlayerData.player_data.get("时装", []),
			PlayerData.player_data.get("神骨", []),
			PlayerData.player_data.get("头衔", []),
			PlayerData.player_data.get("翅膀", []),
			PlayerData.player_data.get("法宝", [])
		]
	)
	if equipment_signature != _equipment_signature:
		_equipment_signature = equipment_signature
		get_equ_last_pro()
	get_last_prop()


func check_hp():
	roleprop.SHp = maxi(1, int(roleprop.SHp))
	if roleprop.Hp >= roleprop.SHp:
		roleprop.Hp = roleprop.SHp
	if roleprop.Hp <= 0:
		roleprop.Hp = 0


func check_mp():
	if roleprop.Mp >= roleprop.SMp:
		roleprop.Mp = roleprop.SMp
	if roleprop.Mp <= 0:
		roleprop.Mp = 0


func up_level():
	if baseroleprop.Level >= int(PlayerData.PLAYER_MAX_LEVEL):
		baseroleprop.Level = int(PlayerData.PLAYER_MAX_LEVEL)
		baseroleprop.exp = 0
		PlayerData.player_data.玩家等级 = baseroleprop.Level
		PlayerData.player_data.玩家当前经验 = 0
		return
	if baseroleprop.exp >= baseroleprop.max_exp:
		if baseroleprop.Level < int(PlayerData.PLAYER_MAX_LEVEL):
			CureLevel()


func get_equ_properies():
	if PlayerData.player_data["武器"].size() != 0:
		var name_ = PlayerData.player_data["武器"][0]["名字"]
		var qh_level = PlayerData.player_data["武器"][0]["强化等级"]
		var Data = PlayerData.player_data["武器"][0]["Data"]
		var wq_list: Dictionary = AE.get_divine_forge_properties(name_, qh_level, Data)
		for i in wq_list.size():
			var loc_1 = wq_list.keys()[i]
			if wq_prop.has(loc_1):
				wq_prop[loc_1] = wq_list[loc_1]
	else:
		remove_wq_pro()

	if PlayerData.player_data["防具"].size() != 0:
		var name_ = PlayerData.player_data["防具"][0]["名字"]
		var qh_level = PlayerData.player_data["防具"][0]["强化等级"]
		var Data = PlayerData.player_data["防具"][0]["Data"]
		var fj_list: Dictionary = AE.get_divine_forge_properties(name_, qh_level, Data)
		for i in fj_list.size():
			var loc_1 = fj_list.keys()[i]
			if fj_prop.has(loc_1):
				fj_prop[loc_1] = fj_list[loc_1]
	else:
		remove_fj_pro()

	if PlayerData.player_data["饰品"].size() != 0:
		var name_ = PlayerData.player_data["饰品"][0]["名字"]
		var qh_level = PlayerData.player_data["饰品"][0]["强化等级"]
		var Data = PlayerData.player_data["饰品"][0]["Data"]
		var sp_list: Dictionary = AE.get_divine_forge_properties(name_, qh_level, Data)
		for i in sp_list.size():
			var loc_1 = sp_list.keys()[i]
			if sp_prop.has(loc_1):
				sp_prop[loc_1] = sp_list[loc_1]
	else:
		remove_sp_pro()

	if PlayerData.player_data["时装"].size() != 0:
		var name_ = PlayerData.player_data["时装"][0]["名字"]
		var qh_level = PlayerData.player_data["时装"][0]["强化等级"]
		var Data = PlayerData.player_data["时装"][0]["Data"]
		var sz_list = AE.get_last_equ_pro(name_, qh_level, Data)
		for i in sz_list.size():
			var loc_1 = sz_list.keys()[i]
			if sz_prop.has(loc_1):
				sz_prop[loc_1] = sz_list[loc_1]
	else:
		remove_sz_pro()

	if PlayerData.player_data["头衔"].size() != 0:
		var name_ = PlayerData.player_data["头衔"][0]["名字"]
		var qh_level = PlayerData.player_data["头衔"][0]["强化等级"]
		var Data = PlayerData.player_data["头衔"][0]["Data"]
		var tx_list = AE.get_last_equ_pro(name_, qh_level, Data)
		for i in tx_list.size():
			var loc_1 = tx_list.keys()[i]
			if tx_prop.has(loc_1):
				tx_prop[loc_1] = tx_list[loc_1]
	else:
		remove_tx_pro()

	if PlayerData.player_data["翅膀"].size() != 0:
		var name_ = PlayerData.player_data["翅膀"][0]["名字"]
		var qh_level = PlayerData.player_data["翅膀"][0]["强化等级"]
		var Data = PlayerData.player_data["翅膀"][0]["Data"]
		var cb_list = AE.get_last_equ_pro(name_, qh_level, Data)
		for i in cb_list.size():
			var loc_1 = cb_list.keys()[i]
			if cb_prop.has(loc_1):
				cb_prop[loc_1] = cb_list[loc_1]
	else:
		remove_cb_pro()

	if PlayerData.player_data["法宝"].size() != 0:
		var name_ = PlayerData.player_data["法宝"][0]["名字"]
		var qh_level = PlayerData.player_data["法宝"][0]["强化等级"]
		var wxlist = PlayerData.player_data["法宝"][0]["五行"]
		var Data = PlayerData.player_data["法宝"][0]["Data"]
		var fb_list = AE.get_fb_last_equ_pro(name_, qh_level, wxlist, Data)
		for i in fb_list.size():
			var loc_1 = fb_list.keys()[i]
			if fb_prop.has(loc_1):
				fb_prop[loc_1] = fb_list[loc_1]
	else:
		remove_fb_pro()

	get_BsWqProperies()
	get_BsFjProperies()
	get_BsSpProperies()
	get_BsCbProperies()
	get_BsSzProperies()
	get_BsTxProperies()


func get_bs_wq_properties():
	for property_name in WqBs_prop:
		WqBs_prop[property_name] = 0
	if PlayerData.player_data["武器"].size() != 0:
		var equipment: Dictionary = PlayerData.player_data["武器"][0]
		var gem_properties: Dictionary = AE.get_divine_forge_gem_properties(str(equipment["名字"]), equipment["Data"])
		for property_name in WqBs_prop:
			WqBs_prop[property_name] = gem_properties.get(property_name, 0)


func get_bs_fj_properties():
	for property_name in FjBs_prop:
		FjBs_prop[property_name] = 0
	if PlayerData.player_data["防具"].size() != 0:
		var equipment: Dictionary = PlayerData.player_data["防具"][0]
		var gem_properties: Dictionary = AE.get_divine_forge_gem_properties(str(equipment["名字"]), equipment["Data"])
		for property_name in FjBs_prop:
			FjBs_prop[property_name] = gem_properties.get(property_name, 0)


func get_bs_sp_properties():
	for property_name in SpBs_prop:
		SpBs_prop[property_name] = 0
	if PlayerData.player_data["饰品"].size() != 0:
		var equipment: Dictionary = PlayerData.player_data["饰品"][0]
		var gem_properties: Dictionary = AE.get_divine_forge_gem_properties(str(equipment["名字"]), equipment["Data"])
		for property_name in SpBs_prop:
			SpBs_prop[property_name] = gem_properties.get(property_name, 0)


func get_bs_cb_properties():
	_set_slot_gem_properties("翅膀", CbBs_prop)


func get_bs_sz_properties():
	_set_slot_gem_properties("时装", SzBs_prop)


func get_bs_tx_properties():
	_set_slot_gem_properties("头衔", TxBs_prop)


func _set_slot_gem_properties(slot_name: String, properties: Dictionary) -> void:
	for property_name in AE.PropListName:
		properties[property_name] = 0
	var equipped: Array = PlayerData.player_data.get(slot_name, [])
	if equipped.is_empty():
		return
	var equipment: Dictionary = equipped[0]
	var gem_properties := AE.get_divine_forge_gem_properties(str(equipment.get("名字", "")), equipment.get("Data", {}))
	for property_name in properties:
		properties[property_name] = gem_properties.get(property_name, 0)


func get_equ_last_pro():
	get_equ_properies()
	var shengu_properties: Dictionary = {}
	var equipped_shengu: Array = PlayerData.ensure_shengu_slot()
	if not equipped_shengu.is_empty() and equipped_shengu[0] is Dictionary:
		var item: Dictionary = equipped_shengu[0]
		shengu_properties = AE.get_divine_forge_properties(
			str(item.get("名字", "")), int(item.get("强化等级", 0)), item.get("Data", {}), true
		)
	for i in equprop.keys():
		equprop[i] = (
			wq_prop[i]
			+ fj_prop[i]
			+ sp_prop[i]
			+ fb_prop[i]
			+ WqBs_prop[i]
			+ FjBs_prop[i]
			+ SpBs_prop[i]
			+ CbBs_prop[i]
			+ SzBs_prop[i]
			+ TxBs_prop[i]
			+ tx_prop[i]
			+ sz_prop[i]
			+ cb_prop[i]
			+ shengu_properties.get(i, 0)
		)


func remove_wq_pro():
	wq_prop.SHp = 0
	wq_prop.SMp = 0
	wq_prop.power = 0
	wq_prop.Def = 0
	wq_prop.Mdef = 0
	wq_prop.Crit = 0
	wq_prop.Miss = 0
	wq_prop.R_hp = 0
	wq_prop.R_mp = 0
	wq_prop.vampirism = 0
	wq_prop.Lucky = 0
	wq_prop.Toughness = 0
	wq_prop.Htarget = 0
	wq_prop.CritReduce = 0
	wq_prop.ar = 0
	wq_prop.sp = 0
	pass


func remove_fj_pro():
	fj_prop.SHp = 0
	fj_prop.SMp = 0
	fj_prop.power = 0
	fj_prop.Def = 0
	fj_prop.Mdef = 0
	fj_prop.Crit = 0
	fj_prop.Miss = 0
	fj_prop.R_hp = 0
	fj_prop.R_mp = 0
	fj_prop.vampirism = 0
	fj_prop.Lucky = 0
	fj_prop.Toughness = 0
	fj_prop.Htarget = 0
	fj_prop.CritReduce = 0
	fj_prop.ar = 0
	fj_prop.sp = 0
	pass


func remove_sp_pro():
	sp_prop.SHp = 0
	sp_prop.SMp = 0
	sp_prop.power = 0
	sp_prop.Def = 0
	sp_prop.Mdef = 0
	sp_prop.Crit = 0
	sp_prop.Miss = 0
	sp_prop.R_hp = 0
	sp_prop.R_mp = 0
	sp_prop.vampirism = 0
	sp_prop.Lucky = 0
	sp_prop.Toughness = 0
	sp_prop.Htarget = 0
	sp_prop.CritReduce = 0
	sp_prop.ar = 0
	sp_prop.sp = 0
	pass


func remove_fb_pro():
	fb_prop.SHp = 0
	fb_prop.SMp = 0
	fb_prop.power = 0
	fb_prop.Def = 0
	fb_prop.Mdef = 0
	fb_prop.Crit = 0
	fb_prop.Miss = 0
	fb_prop.R_hp = 0
	fb_prop.R_mp = 0
	fb_prop.vampirism = 0
	fb_prop.Lucky = 0
	fb_prop.Toughness = 0
	fb_prop.Htarget = 0
	fb_prop.CritReduce = 0
	fb_prop.ar = 0
	fb_prop.sp = 0


func remove_cb_pro():
	cb_prop.SHp = 0
	cb_prop.SMp = 0
	cb_prop.power = 0
	cb_prop.Def = 0
	cb_prop.Mdef = 0
	cb_prop.Crit = 0
	cb_prop.Miss = 0
	cb_prop.R_hp = 0
	cb_prop.R_mp = 0
	cb_prop.vampirism = 0
	cb_prop.Lucky = 0
	cb_prop.Toughness = 0
	cb_prop.Htarget = 0
	cb_prop.CritReduce = 0
	cb_prop.ar = 0
	cb_prop.sp = 0


func remove_sz_pro():
	sz_prop.SHp = 0
	sz_prop.SMp = 0
	sz_prop.power = 0
	sz_prop.Def = 0
	sz_prop.Mdef = 0
	sz_prop.Crit = 0
	sz_prop.Miss = 0
	sz_prop.R_hp = 0
	sz_prop.R_mp = 0
	sz_prop.vampirism = 0
	sz_prop.Lucky = 0
	sz_prop.Toughness = 0
	sz_prop.Htarget = 0
	sz_prop.CritReduce = 0
	sz_prop.ar = 0
	sz_prop.sp = 0


func remove_tx_pro():
	tx_prop.SHp = 0
	tx_prop.SMp = 0
	tx_prop.power = 0
	tx_prop.Def = 0
	tx_prop.Mdef = 0
	tx_prop.Crit = 0
	tx_prop.Miss = 0
	tx_prop.R_hp = 0
	tx_prop.R_mp = 0
	tx_prop.vampirism = 0
	tx_prop.Lucky = 0
	tx_prop.Toughness = 0
	tx_prop.Htarget = 0
	tx_prop.CritReduce = 0
	tx_prop.ar = 0
	tx_prop.sp = 0


func remove_wq_bs():
	WqBs_prop.SHp = 0
	WqBs_prop.SMp = 0
	WqBs_prop.power = 0
	WqBs_prop.Def = 0
	WqBs_prop.Mdef = 0
	WqBs_prop.Crit = 0
	WqBs_prop.Miss = 0
	WqBs_prop.R_hp = 0
	WqBs_prop.R_mp = 0
	WqBs_prop.vampirism = 0
	WqBs_prop.Lucky = 0
	WqBs_prop.Toughness = 0
	WqBs_prop.Htarget = 0
	WqBs_prop.CritReduce = 0
	WqBs_prop.ar = 0
	WqBs_prop.sp = 0


func remove_fj_bs():
	FjBs_prop.SHp = 0
	FjBs_prop.SMp = 0
	FjBs_prop.power = 0
	FjBs_prop.Def = 0
	FjBs_prop.Mdef = 0
	FjBs_prop.Crit = 0
	FjBs_prop.Miss = 0
	FjBs_prop.R_hp = 0
	FjBs_prop.R_mp = 0
	FjBs_prop.vampirism = 0
	FjBs_prop.Lucky = 0
	FjBs_prop.Toughness = 0
	FjBs_prop.Htarget = 0
	FjBs_prop.CritReduce = 0
	FjBs_prop.ar = 0
	FjBs_prop.sp = 0


func remove_sp_bs():
	SpBs_prop.SHp = 0
	SpBs_prop.SMp = 0
	SpBs_prop.power = 0
	SpBs_prop.Def = 0
	SpBs_prop.Mdef = 0
	SpBs_prop.Crit = 0
	SpBs_prop.Miss = 0
	SpBs_prop.R_hp = 0
	SpBs_prop.R_mp = 0
	SpBs_prop.vampirism = 0
	SpBs_prop.Lucky = 0
	SpBs_prop.Toughness = 0
	SpBs_prop.Htarget = 0
	SpBs_prop.CritReduce = 0
	SpBs_prop.ar = 0
	SpBs_prop.sp = 0


func remove_cb_bs():
	CbBs_prop.SHp = 0
	CbBs_prop.SMp = 0
	CbBs_prop.power = 0
	CbBs_prop.Def = 0
	CbBs_prop.Mdef = 0
	CbBs_prop.Crit = 0
	CbBs_prop.Miss = 0
	CbBs_prop.R_hp = 0
	CbBs_prop.R_mp = 0
	CbBs_prop.vampirism = 0
	CbBs_prop.Lucky = 0
	CbBs_prop.Toughness = 0
	CbBs_prop.Htarget = 0
	CbBs_prop.CritReduce = 0
	CbBs_prop.ar = 0
	CbBs_prop.sp = 0


func remove_sz_bs():
	SzBs_prop.SHp = 0
	SzBs_prop.SMp = 0
	SzBs_prop.power = 0
	SzBs_prop.Def = 0
	SzBs_prop.Mdef = 0
	SzBs_prop.Crit = 0
	SzBs_prop.Miss = 0
	SzBs_prop.R_hp = 0
	SzBs_prop.R_mp = 0
	SzBs_prop.vampirism = 0
	SzBs_prop.Lucky = 0
	SzBs_prop.Toughness = 0
	SzBs_prop.Htarget = 0
	SzBs_prop.CritReduce = 0
	SzBs_prop.ar = 0
	SzBs_prop.sp = 0


func remove_tx_bs():
	TxBs_prop.SHp = 0
	TxBs_prop.SMp = 0
	TxBs_prop.power = 0
	TxBs_prop.Def = 0
	TxBs_prop.Mdef = 0
	TxBs_prop.Crit = 0
	TxBs_prop.Miss = 0
	TxBs_prop.R_hp = 0
	TxBs_prop.R_mp = 0
	TxBs_prop.vampirism = 0
	TxBs_prop.Lucky = 0
	TxBs_prop.Toughness = 0
	TxBs_prop.Htarget = 0
	TxBs_prop.CritReduce = 0
	TxBs_prop.ar = 0
	TxBs_prop.sp = 0


func cure_exp(Exp: int):
	if baseroleprop.Level >= int(PlayerData.PLAYER_MAX_LEVEL):
		baseroleprop.Level = int(PlayerData.PLAYER_MAX_LEVEL)
		baseroleprop.exp = 0
		PlayerData.player_data.玩家等级 = baseroleprop.Level
		PlayerData.player_data.玩家当前经验 = 0
		return
	RoleProp.baseroleprop.exp += Exp
	PlayerData.player_data.玩家当前经验 = RoleProp.baseroleprop.exp


func cure_level():
	if baseroleprop.Level >= int(PlayerData.PLAYER_MAX_LEVEL):
		baseroleprop.Level = int(PlayerData.PLAYER_MAX_LEVEL)
		baseroleprop.exp = 0
		PlayerData.player_data.玩家等级 = baseroleprop.Level
		PlayerData.player_data.玩家当前经验 = 0
		return
	baseroleprop.Level = mini(baseroleprop.Level + 1, int(PlayerData.PLAYER_MAX_LEVEL))
	PlayerData.player_data.玩家等级 = baseroleprop.Level
	baseroleprop.exp = 0
	PlayerData.player_data.玩家当前经验 = 0
	MemoryClass.保存游戏(Global.cd_path)
	set_basic_prop()


## [兼容代理] 保持旧接口兼容
func GetZFLocProp(Name, loc):
	return get_zf_loc_prop(Name, loc)


## [兼容代理] 保持旧接口兼容
func GetNextLevelProp(Name, loc):
	return get_next_level_prop(Name, loc)


## [兼容代理] 保持旧接口兼容
func GetZFProp(Name):
	return get_zf_prop(Name)


## [兼容代理] 保持旧接口兼容
func GetMainSwordArrayProp(Name):
	return get_main_sword_array_prop(Name)


## [兼容代理] 保持旧接口兼容
func GetPelletProp():
	return get_pellet_prop()


## [兼容代理] 保持旧接口兼容
func set_full_Hp():
	return set_full_hp()


## [兼容代理] 保持旧接口兼容
func set_full_Mp():
	return set_full_mp()


## [兼容代理] 保持旧接口兼容
func check_Hp():
	return check_hp()


## [兼容代理] 保持旧接口兼容
func check_Mp():
	return check_mp()


## [兼容代理] 保持旧接口兼容
func get_BsWqProperies():
	return get_bs_wq_properties()


## [兼容代理] 保持旧接口兼容
func get_BsFjProperies():
	return get_bs_fj_properties()


## [兼容代理] 保持旧接口兼容
func get_BsSpProperies():
	return get_bs_sp_properties()


## [兼容代理] 保持旧接口兼容
func get_BsCbProperies():
	return get_bs_cb_properties()


## [兼容代理] 保持旧接口兼容
func get_BsSzProperies():
	return get_bs_sz_properties()


## [兼容代理] 保持旧接口兼容
func get_BsTxProperies():
	return get_bs_tx_properties()


## [兼容代理] 保持旧接口兼容
func removeWqBs():
	return remove_wq_bs()


## [兼容代理] 保持旧接口兼容
func removeFjBs():
	return remove_fj_bs()


## [兼容代理] 保持旧接口兼容
func removeSpBs():
	return remove_sp_bs()


## [兼容代理] 保持旧接口兼容
func removeCbBs():
	return remove_cb_bs()


## [兼容代理] 保持旧接口兼容
func removeSzBs():
	return remove_sz_bs()


## [兼容代理] 保持旧接口兼容
func removeTxBs():
	return remove_tx_bs()


## [兼容代理] 保持旧接口兼容
func CureExp(Exp: int):
	return cure_exp(Exp)


## [兼容代理] 保持旧接口兼容
func CureLevel():
	return cure_level()
