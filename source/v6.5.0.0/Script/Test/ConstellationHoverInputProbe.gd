extends SceneTree

const HEAD_SCENE_PATH: = "res://Scene/OtherScene/MonsterHeadInfo.tscn"
const OUTPUT_PATH: = "res://.tmp/constellation_hover_input.png"


func _init() -> void :
	call_deferred("_run")


func _run() -> void :
	var scene: = load(HEAD_SCENE_PATH) as PackedScene
	if scene == null:
		return _fail("head scene load")

	var canvas: = Control.new()
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(canvas)

	var head: = scene.instantiate()
	head.set("MonsterName", "轸宿")
	head.set("IsBoss", true)
	head.set("LevelMonsterConfig", {
		"name": "一阶 轸宿", 
		"level": 91, 
		"hp": 1500000, 
		"attack": 10000, 
		"def": 400, 
		"mdef": 5, 
		"speed": 4.0, 
		"sight": 2500, 
		"range": 200, 
		"attacks": {
			"hit1": {
				"power": 500, 
				"kind": "physics", 
			}, 
		}, 
	})
	head.position = Vector2(100, 100)
	canvas.add_child(head)
	await process_frame
	await process_frame

	_move_mouse(Vector2(10, 10))
	await process_frame
	_move_mouse(Vector2(130, 130))
	head.call("_on_monster_hover_entered")
	for _frame in range(3):
		await process_frame

	var panel: Variant = head.get("HoverAttrPanel")
	if not panel is Control or not is_instance_valid(panel):
		return _fail("panel cleared while pointer is inside")
	var text: = _collect_label_text(panel)
	if "生命：1500000" not in text or "攻击伤害：" not in text:
		return _fail("panel text: %s" % text)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var output_dir: = ProjectSettings.globalize_path("res://.tmp")
		DirAccess.make_dir_recursive_absolute(output_dir)
		var image: = root.get_viewport().get_texture().get_image()
		if image.save_png(ProjectSettings.globalize_path(OUTPUT_PATH)) != OK:
			return _fail("screenshot")

	_move_mouse(Vector2(10, 10))
	head.call("_on_monster_hover_exited")
	for _frame in range(6):
		await process_frame
	panel = head.get("HoverAttrPanel")
	if panel != null and is_instance_valid(panel):
		return _fail(
			"panel remains after pointer exits mouse=%s rect=%s hovered=%s" % [
				str(root.get_viewport().get_mouse_position()), 
				str(head.get_global_rect()), 
				str(root.get_viewport().gui_get_hovered_control()), 
			]
		)

	print("CONSTELLATION_HOVER_INPUT_OK output=%s" % OUTPUT_PATH)
	quit(0)


func _move_mouse(position: Vector2) -> void :
	if DisplayServer.get_name() != "headless":
		Input.warp_mouse(position)
	var event: = InputEventMouseMotion.new()
	event.position = position
	event.global_position = position
	Input.parse_input_event(event)


func _collect_label_text(node: Node) -> String:
	var result: = ""
	if node is Label:
		result = (node as Label).text + "\n"
	for child in node.get_children():
		result += _collect_label_text(child)
	return result


func _fail(reason: String) -> void :
	push_error("CONSTELLATION_HOVER_INPUT_FAIL %s" % reason)
	quit(1)
