extends Node

func _ready() -> void :

	ProjectSettings.set_setting("editor/script_encryption_key", "C853751D0BFD824E5DF1AF202750B6C5389B67DEA0873E7F4B39E95529EF863F")
	ProjectSettings.set_setting("application/config/use_hidden_project_data_dir", true)
	var dir = DirAccess.open("res://")

	if dir:
		var files = dir.get_files()
		for file in files:
			if file.get_extension() == "pck":
				ProjectSettings.load_resource_pack(file)
	get_tree().change_scene_to_file("res://Scene/Main_menu/Main_Menu.tscn")
