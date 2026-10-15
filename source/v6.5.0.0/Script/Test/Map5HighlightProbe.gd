extends SceneTree

const MAP_SCENE_PATH: = "res://Scene/Main_menu/Map_5.tscn"


func _init() -> void :
	call_deferred("_run")


func _run() -> void :
	var map_scene: = load(MAP_SCENE_PATH) as PackedScene
	if map_scene == null:
		return _fail("map scene load")
	var map_5: = map_scene.instantiate()
	root.add_child(map_5)
	await process_frame

	var player_data_node: = root.get_node_or_null("PlayerData")
	if player_data_node == null:
		return _fail("PlayerData autoload")
	var live_player_data: Variant = player_data_node.get("player_data")
	if not (live_player_data is Dictionary):
		return _fail("PlayerData dictionary")
	var original_player_data: Dictionary = (live_player_data as Dictionary).duplicate(true)
	for level_name in ["绝仙门", "紫晶门", "戮仙门"]:
		(live_player_data as Dictionary)[level_name] = 1
	for level_name in ["指景宫", "陷仙门", "绝境宫", "通天教主"]:
		(live_player_data as Dictionary)[level_name] = 0

	map_5.call("check_pass_level")
	var animation_player: = map_5.get_node("Level") as AnimationPlayer
	animation_player.advance(0.0)
	var target_button: = map_5.get_node("Level_43") as TextureButton
	var failure_reason: = ""
	if target_button.disabled:
		failure_reason = "Level_43 disabled after 戮仙门"
	elif target_button.use_parent_material:
		failure_reason = "Level_43 still inherits parent material"
	elif animation_player.current_animation != "Level_43":
		failure_reason = "current animation %s" % animation_player.current_animation
	elif target_button.material == null:
		failure_reason = "Level_43 highlight material missing"

	player_data_node.set("player_data", original_player_data)
	map_5.queue_free()
	if not failure_reason.is_empty():
		return _fail(failure_reason)
	print("MAP5_HIGHLIGHT_OK target=指景宫 animation=Level_43")
	quit(0)


func _fail(reason: String) -> void :
	push_error("MAP5_HIGHLIGHT_FAIL %s" % reason)
	quit(1)
