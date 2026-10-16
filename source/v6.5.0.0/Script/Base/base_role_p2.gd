extends "res://Script/base/base_role.gd"

@onready var touch_screen_button = $role_menu/grey/TouchScreenButton


func _ready() -> void:
	super._ready()
	if not OS.has_feature("android"):
		touch_screen_button.queue_free()
	grey.position = menu.position + Vector2(85, 85)


func _load_skill_icons() -> void:
	magicCD = MagicTscn.instantiate()
	magicCD.name = "7"
	magicIcon.add_child(magicCD)

	var skill_names: Dictionary = {"L": "8", "O": "6", "I": "5", "U": "4", "Y": "3"}
	for key_name in skill_names.keys():
		var icon = SkillTscn.instantiate()
		icon.name = key_name
		SkillBox.add_child(icon)
