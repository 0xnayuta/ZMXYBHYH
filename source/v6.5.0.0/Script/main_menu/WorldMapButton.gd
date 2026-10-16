extends TextureButton

const WORLD_MAP_PATH := "res://Scene/main_menu/Map_0.tscn"


func _pressed() -> void:
	Global.cleanup_transient_ui()
	Global.change_scene(WORLD_MAP_PATH)
