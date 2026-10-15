extends SceneTree

const LEVEL_PATH: = "res://Scene/Level/Level_esbxx.tscn"
const OUTPUT_PATH: = "res://.tmp/constellation_hover.png"

func _init() -> void :
	call_deferred("_run")

func _run() -> void :
	var global_node: = root.get_node_or_null("Global")
	if global_node == null:
		_fail("Global autoload")
		return
	var canvas: = Control.new()
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(canvas)
	var level_info: Variant = global_node.call(
		"AddLevelInfo", canvas, "挑战28星宿", Vector2.ZERO, LEVEL_PATH
	)
	if not level_info is Control:
		_fail("LevelInfo popup")
		return
	for _frame in range(8):
		await physics_frame
	var monster_list: = (level_info as Node).get_node_or_null(
		"ColorRect/TextureRect/ScrollContainer2/MonsterList"
	)
	if monster_list == null or monster_list.get_child_count() != 14:
		_fail("portrait count")
		return
	var first_head: = monster_list.get_child(0)
	var click: = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	first_head.call("_on_selection_gui_input", click)
	await process_frame
	var fall_list: = (level_info as Node).get_node_or_null(
		"ColorRect/TextureRect/ScrollContainer/FallList"
	)
	if fall_list == null or fall_list.get_child_count() != 3:
		_fail("first boss drop count")
		return
	var first_drop_ids: Array[String] = []
	for box in fall_list.get_children():
		first_drop_ids.append(str(box.get_meta("fall_item_name", "")))
	if first_drop_ids != ["zqjs", "zqjh", "smjc_skill_book"]:
		_fail("first boss drops: %s" % first_drop_ids)
		return
	var fall_text: = _collect_label_text(fall_list)
	if "20%" not in fall_text or "10%" not in fall_text or "5%" not in fall_text:
		_fail("first boss drop probabilities: %s" % fall_text)
		return
	if not first_head.mouse_entered.is_connected(
		Callable(first_head, "_on_monster_hover_entered")
	):
		_fail("portrait hover signal")
		return
	var panel: = first_head.call("_create_monster_attr_panel") as Control
	var panel_text: = _collect_label_text(panel)
	if "暂无属性数据" in panel_text or "生命：" not in panel_text\
	or "攻击：" not in panel_text or "攻击伤害：" not in panel_text:
		_fail("hover text: %s" % panel_text)
		return
	panel.free()
	await RenderingServer.frame_post_draw
	var output_dir: = ProjectSettings.globalize_path("res://.tmp")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var image: = root.get_viewport().get_texture().get_image()
	var output_path: = ProjectSettings.globalize_path(OUTPUT_PATH)
	var save_error: = image.save_png(output_path)
	if save_error != OK:
		_fail("screenshot %s" % save_error)
		return
	var eleventh_head: = monster_list.get_child(10)
	eleventh_head.call("_on_selection_gui_input", click)
	await process_frame
	if fall_list.get_child_count() != 2\
	or str(fall_list.get_child(0).get_meta("fall_item_name", "")) != "xwjs"\
	or str(fall_list.get_child(1).get_meta("fall_item_name", "")) != "xwjh":
		_fail("eleventh boss drops")
		return
	print("CONSTELLATION_HOVER_OK heads=14 output=%s" % output_path)
	quit(0)

func _collect_label_text(node: Node) -> String:
	var result: = ""
	if node is Label:
		result = (node as Label).text + "\n"
	for child in node.get_children():
		result += _collect_label_text(child)
	return result

func _fail(reason: String) -> void :
	push_error("CONSTELLATION_HOVER_FAIL %s" % reason)
	quit(1)
