extends Node

func _ready() -> void :
	print("SCENE_PROBE_READY roleprop=" + str(get_node_or_null("/root/RoleProp")) + " class=" + str(ClassDB.class_exists("SpineSprite")))
	var script_resource: = load("res://Script/Hero/CangMuLongYunEffect.gd")
	print("SCENE_PROBE_SCRIPT=" + str(script_resource))
	get_tree().quit(0)
