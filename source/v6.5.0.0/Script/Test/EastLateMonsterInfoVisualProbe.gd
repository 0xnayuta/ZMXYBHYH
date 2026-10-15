extends SceneTree

const LEVEL_PATH: = "res://Scene/Level/Level_74.tscn"
const OUTPUT_PATH: = "res://.tmp/east_late_monster_info.png"
const EXPECTED_NAMES: = ["金甲护卫", "小狐狸", "琉璃鸟", "电之祖巫"]

func _init() -> void :
	call_deferred("_run")

func _run() -> void :
	var global_node: = root.get_node_or_null("Global")
	if global_node == null:
		_fail("Global autoload缺失")
		return
	var canvas: = Control.new()
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(canvas)
	var level_info: Variant = global_node.call(
		"AddLevelInfo", canvas, "浮天台", Vector2.ZERO, LEVEL_PATH
	)
	if not level_info is Control:
		_fail("关卡信息框创建失败")
		return
	for _frame in range(8):
		await physics_frame
	var monster_list: = (level_info as Node).get_node_or_null(
		"ColorRect/TextureRect/ScrollContainer2/MonsterList"
	)
	if monster_list == null or monster_list.get_child_count() != EXPECTED_NAMES.size():
		_fail("怪物头像数量错误")
		return
	for index in EXPECTED_NAMES.size():
		var head: = monster_list.get_child(index)
		var name_button: = head.get_node_or_null("MonsterName") as Button
		var picture: = head.get_node_or_null("pic") as Sprite2D
		if name_button == null or name_button.text != EXPECTED_NAMES[index]:
			_fail("第%d个怪物名错误：%s" % [index, name_button.text if name_button != null else ""])
			return
		if picture == null or picture.texture == null:
			_fail("第%d个怪物头像未渲染" % index)
			return
	await RenderingServer.frame_post_draw
	var output_dir: = ProjectSettings.globalize_path("res://.tmp")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var image: = root.get_viewport().get_texture().get_image()
	var output_path: = ProjectSettings.globalize_path(OUTPUT_PATH)
	if image == null or image.save_png(output_path) != OK:
		_fail("截图保存失败")
		return
	print("EAST_LATE_MONSTER_INFO_VISUAL_OK heads=%d output=%s" % [
		EXPECTED_NAMES.size(), output_path, 
	])
	quit(0)

func _fail(reason: String) -> void :
	push_error("EAST_LATE_MONSTER_INFO_VISUAL_FAIL " + reason)
	quit(1)
