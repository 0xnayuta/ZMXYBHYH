extends Node

const HEAVENLY_WAR_GOD_LEVEL: = "res://Scene/Level/Level_hdzm.tscn"


func _on_challenge_pressed() -> void :
	Global.change_scene(HEAVENLY_WAR_GOD_LEVEL)
