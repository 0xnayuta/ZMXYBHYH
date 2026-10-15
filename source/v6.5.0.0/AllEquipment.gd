extends Node

const DATA_SCRIPT: = "res://Script/Data/AllEquipmentData.gd"

var PropListName = ["SHp", "SMp", "power", "Def", "Mdef", "Crit", "Miss", "R_hp", "R_mp", "vampirism", "Lucky", "Toughness", "Htarget", "CritReduce", "ar", "sp"]
var _data: Node

var AllEquipment_: Dictionary:
	get:
		return _get_data().AllEquipment_
	set(value):
		_get_data().AllEquipment_ = value

func _ready() -> void :
	randomize()

func ensure_loaded() -> void :
	_get_data().ensure_loaded()

func All_equ() -> void :
	_get_data().All_equ()

func get_last_equ_pro(name_, qh_level, data):
	return _get_data().get_last_equ_pro(name_, qh_level, data)

func get_fb_last_equ_pro(name_, qh_level, wxlist, data):
	return _get_data().get_fb_last_equ_pro(name_, qh_level, wxlist, data)

func get_divine_forge_stage(data: Dictionary) -> int:
	return _get_data().get_divine_forge_stage(data)

func can_divine_forge(name_: String, data: Dictionary = {}) -> bool:
	return _get_data().can_divine_forge(name_, data)

func get_divine_forge_multiplier(name_: String, data: Dictionary) -> float:
	return _get_data().get_divine_forge_multiplier(name_, data)

func scale_divine_forge_value(value, name_: String, data: Dictionary):
	return _get_data().scale_divine_forge_value(value, name_, data)

func get_divine_forge_display_name(name_: String, data: Dictionary) -> String:
	return _get_data().get_divine_forge_display_name(name_, data)

func get_divine_forge_gem_properties(name_: String, data: Dictionary) -> Dictionary:
	return _get_data().get_divine_forge_gem_properties(name_, data)

func get_gem_resonance_level(data: Dictionary) -> int:
	return _get_data().get_gem_resonance_level(data)

func scale_gem_resonance_value(value, data: Dictionary):
	return _get_data().scale_gem_resonance_value(value, data)

func get_divine_forge_properties(name_: String, qh_level: int, data: Dictionary, include_gems: = false) -> Dictionary:
	return _get_data().get_divine_forge_properties(name_, qh_level, data, include_gems)

func get_wx():
	return _get_data().get_wx()

func _get_data() -> Node:
	if _data == null:
		_data = load(DATA_SCRIPT).new()
	return _data
