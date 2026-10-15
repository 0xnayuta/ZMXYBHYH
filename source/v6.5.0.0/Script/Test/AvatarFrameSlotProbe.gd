extends SceneTree

const BACKPACK_SCENE_PATH: = "res://Scene/BackPack/BackPack.tscn"
const EQUIPMENT_SLOT_SCENE_PATH: = "res://Scene/BackPack/zb.tscn"
const OUTPUT_PATH: = "res://.tmp/avatar_frame_slot.png"


func _init() -> void :
	call_deferred("_run")


func _run() -> void :
	var player_data_node: = root.get_node_or_null("PlayerData")
	var equipment_node: = root.get_node_or_null("AE")
	if player_data_node == null or equipment_node == null:
		return _fail("required autoloads")
	var original_player_data: Dictionary = (player_data_node.get("player_data") as Dictionary).duplicate(true)
	var test_player_data: = original_player_data.duplicate(true)
	test_player_data.erase("头像框")
	player_data_node.set("player_data", test_player_data)
	var ensured_slot: Variant = player_data_node.call("ensure_avatar_frame_slot")
	if not (ensured_slot is Array) or not (ensured_slot as Array).is_empty():
		player_data_node.set("player_data", original_player_data)
		return _fail("old save migration")

	var scene_text: = FileAccess.get_file_as_string(BACKPACK_SCENE_PATH)
	if not scene_text.contains("[node name=\"txk\" parent=\"background/infomation\" instance=ExtResource(\"19\")]"):
		player_data_node.set("player_data", original_player_data)
		return _fail("backpack scene slot declaration")
	var slot_scene: = load(EQUIPMENT_SLOT_SCENE_PATH) as PackedScene
	if slot_scene == null:
		player_data_node.set("player_data", original_player_data)
		return _fail("equipment slot scene load")

	var preview: = Node2D.new()
	preview.position = Vector2(481, 297)
	root.add_child(preview)
	var background: = Sprite2D.new()
	background.texture = load("res://Art/BackPack/207.png")
	preview.add_child(background)
	var information: = Node2D.new()
	information.position = Vector2(17, 55)
	preview.add_child(information)

	var title_slot: = slot_scene.instantiate() as Button
	title_slot.name = "tx"
	title_slot.position = Vector2(-337, -189)
	title_slot.size = Vector2(50, 50)
	title_slot.scale = Vector2(0.6, 0.6)
	title_slot.icon = load("res://Art/BackPack/AllItems/tx.png")
	information.add_child(title_slot)
	var avatar_frame_slot: = slot_scene.instantiate() as Button
	avatar_frame_slot.name = "txk"
	avatar_frame_slot.position = Vector2(-302, -189)
	avatar_frame_slot.size = Vector2(50, 50)
	avatar_frame_slot.scale = Vector2(0.6, 0.6)
	information.add_child(avatar_frame_slot)
	await process_frame
	await process_frame

	if not avatar_frame_slot.size.is_equal_approx(title_slot.size) or not avatar_frame_slot.scale.is_equal_approx(title_slot.scale):
		player_data_node.set("player_data", original_player_data)
		return _fail("slot size")
	var title_rect: = title_slot.get_global_rect()
	var avatar_rect: = avatar_frame_slot.get_global_rect()
	if avatar_rect.position.x <= title_rect.position.x or avatar_rect.intersects(title_rect):
		player_data_node.set("player_data", original_player_data)
		return _fail("slot placement")

	equipment_node.call("ensure_loaded")
	var all_equipment: Dictionary = equipment_node.get("AllEquipment_")
	var sample_data: Dictionary = (all_equipment["qtds"] as Dictionary).duplicate(true)
	test_player_data["头像框"] = [{"名字": "qtds", "强化等级": 0, "Data": sample_data}]
	avatar_frame_slot.call("_sync_avatar_frame_equipment", true)
	if str(avatar_frame_slot.get("get_item_name")) != "qtds":
		player_data_node.set("player_data", original_player_data)
		return _fail("equipped frame display")

	test_player_data["头像框"] = []
	avatar_frame_slot.call("_sync_avatar_frame_equipment", true)
	player_data_node.set("player_data", original_player_data)

	await process_frame
	await process_frame
	var image: = root.get_viewport().get_texture().get_image()
	if image == null:
		return _fail("viewport image")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.tmp"))
	if image.save_png(ProjectSettings.globalize_path(OUTPUT_PATH)) != OK:
		return _fail("screenshot")
	print("AVATAR_FRAME_SLOT_OK same_size right_of_title old_save_compatible output=%s" % OUTPUT_PATH)
	quit(0)


func _fail(reason: String) -> bool:
	push_error("AVATAR_FRAME_SLOT_FAIL %s" % reason)
	quit(1)
	return false
