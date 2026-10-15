extends SceneTree

func _init() -> void :
	call_deferred("_run")

func _run() -> void :
	var level_scene: = load("res://Scene/Level/Level_esbxx.tscn") as PackedScene
	if level_scene == null:
		push_error("MONSTER140_VISUAL_FAIL missing level scene")
		quit(1)
		return
	var level: = level_scene.instantiate()
	get_root().add_child(level)
	for _i in range(12):
		await process_frame
	var boss: Node = null
	for child in level.get_node("Monster").get_children():
		if child.get("source_id") == 140:
			boss = child
			break
	if boss == null:
		push_error("MONSTER140_VISUAL_FAIL boss")
		quit(1)
		return
	boss.set("_busy", true)
	var output_dir: = ProjectSettings.globalize_path("res://.tmp")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var captures: = [
		{"skill": 1, "stage": 1, "name": "bullet1"}, 
		{"skill": 2, "stage": 1, "name": "bullet2_1"}, 
		{"skill": 3, "stage": 1, "name": "bullet3"}, 
		{"skill": 4, "stage": 1, "name": "bullet4"}, 
	]
	for capture: Dictionary in captures:
		boss.call("_emit_monster140_skill", int(capture["skill"]), int(capture["stage"]))
		for _i in range(18):
			await process_frame
		var image: = get_root().get_viewport().get_texture().get_image()
		var output_path: = output_dir.path_join("monster140_%s.png" % capture["name"])
		var save_error: = image.save_png(output_path)
		if save_error != OK:
			push_error("MONSTER140_VISUAL_FAIL save=%s error=%s" % [output_path, save_error])
			quit(1)
			return
		print("MONSTER140_VISUAL_OK %s size=%sx%s" % [output_path, image.get_width(), image.get_height()])
	quit(0)
