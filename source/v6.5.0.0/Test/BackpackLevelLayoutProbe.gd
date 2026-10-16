extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene := load("res://Scene/BackPack/BackPack.tscn") as PackedScene
	var backpack := scene.instantiate()
	var background := backpack.get_node("background/infomation/leve_background") as Sprite2D
	var level_show := background.get_node("Level_Show") as Node2D
	print("BEFORE_ADD level_show=", level_show.position)
	root.add_child(backpack)
	print("AFTER_ADD level_show=", level_show.position)
	await process_frame
	print("AFTER_FRAME_1 level_show=", level_show.position)
	await process_frame
	print("AFTER_FRAME_2 level_show=", level_show.position)
	var digit := level_show.get_node("Number_1") as TextureRect
	print("BACKGROUND global=", background.global_position, " texture_size=", background.texture.get_size())
	print("LEVEL_SHOW local=", level_show.position, " global=", level_show.global_position)
	print("DIGIT local=", digit.position, " size=", digit.size, " min=", digit.get_combined_minimum_size())
	print("DIGIT global_rect=", digit.get_global_rect(), " texture_size=", digit.texture.get_size())
	quit()
