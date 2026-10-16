extends "res://Script/base/base_role.gd"

@onready var touch_screen_button = $role_menu/grey/TouchScreenButton


func _ready() -> void:
	super._ready()
	if not OS.has_feature("android"):
		touch_screen_button.queue_free()
	grey.position = menu.position + Vector2(85, 85)


func _load_skill_icons() -> void:
	magic_cd = magic_tscn.instantiate()
	magic_cd.name = "7"
	magic_icon.add_child(magic_cd)

	var skill_names: Dictionary = {"L": "8", "O": "6", "I": "5", "U": "4", "Y": "3"}
	for key_name in skill_names.keys():
		var icon = skill_tscn.instantiate()
		icon.name = key_name
		SkillBox.add_child(icon)
