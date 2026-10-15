extends "res://Script/Pet/PetInterface.gd"

var equipment_bonus_call_count: = 0


func _pet_equipment_bonuses(pet: Dictionary) -> Dictionary:
	equipment_bonus_call_count += 1
	return super._pet_equipment_bonuses(pet)


func reset_equipment_bonus_call_count() -> void :
	equipment_bonus_call_count = 0


func _show_tip(_message: String) -> void :
	pass
