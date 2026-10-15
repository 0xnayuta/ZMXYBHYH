extends Node2D
func _ready() -> void :
	Global.addBGM_(self, "res://Music/level/12_over.mp3")
func _on_return_map_pressed() -> void :
	RoleProp.ws_value = 0
	Global.is_DeadLink = false
	if not Global.GameFrame.level_mgr_component.curr_Level_Info == null:
		Global.GameFrame.level_mgr_component.curr_Level_Info.queue_free()
	match int(PlayerData.player_data["Map_num"]):
		1:
			get_tree().change_scene_to_file("res://Scene/Main_menu/Map_1.tscn")
		2:
			if PlayerData.player_data["地府"]:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_2.tscn")
			else:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_1.tscn")
		3:
			if PlayerData.player_data["天庭"]:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_3.tscn")
			else:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_1.tscn")

		4:
			if PlayerData.player_data["截教天境"]:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_4.tscn")
			else:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_1.tscn")
	MemoryClass.保存游戏(Global.cd_path)


func _on_re_challenge_pressed() -> void :
	if Global.LastLevelPath == "":
		Global.AddMessageShow(Global.Windows_, "获取关卡信息时出现错误，请手动更换关卡！！", 1.5, Vector2(470, 300))
	else:
		Global.change_secen(Global.LastLevelPath)
