extends "res://Script/Pet/PetInterface.gd"

var refresh_count: = 0
var save_count: = 0
var tip_messages: Array[String] = []


func _refresh_current_pet() -> void :
	refresh_count += 1


func _refresh_pet_skill_upgrade_popup() -> void :
	refresh_count += 1


func _refresh_live_pet_passives(_pet: Dictionary) -> void :
	pass


func _save_pet_changes() -> void :
	save_count += 1


func _add_tip(message: String) -> Control:
	tip_messages.append(message)
	return null
