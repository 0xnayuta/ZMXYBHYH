extends SceneTree

const MOUNT_VISUAL: = preload("res://Script/Mount/MountVisual.gd")
const ROOT: = "res://Scene/Mount/RiderAdjustments"
const MOUNT_IDS: = ["1002200", "1002700", "1002800", "1003100", "1003500", "1003600", "1003900", "1004700"]
const EXPECTED_FRAMES: = {1: 49, 2: 44, 3: 69, 4: 44, 5: 116, 6: 0}
const ROLE_NAMES: = {1: "孙悟空", 2: "唐僧", 3: "八戒", 4: "沙僧", 5: "白龙", 6: "哪吒"}
const CELL_SIZE: = Vector2(165.0, 135.0)

var failures: Array[String] = []

func _initialize() -> void :
	call_deferred("_run")

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)

func _run() -> void :
	root.size = Vector2i(int(CELL_SIZE.x * MOUNT_IDS.size()), int(CELL_SIZE.y * EXPECTED_FRAMES.size()))
	var background: = ColorRect.new()
	background.color = Color("20242c")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(background)
	for role_id in EXPECTED_FRAMES:
		for mount_column in range(MOUNT_IDS.size()):
			var mount_id: String = MOUNT_IDS[mount_column]
			var path: = "%s/Role%d/%s.tscn" % [ROOT, role_id, mount_id]
			var scene: = load(path) as PackedScene
			_check(scene != null, "调整场景无法加载: %s" % path)
			if scene == null:
				continue
			var adjustment: = scene.instantiate() as Node2D
			_check(adjustment != null, "调整场景无法实例化: %s" % path)
			if adjustment == null:
				continue
			_check(int(adjustment.get_meta("role_id", 0)) == role_id, "%s 人物元数据错误" % path)
			_check(str(adjustment.get_meta("mount_id", "")) == mount_id, "%s 坐骑元数据错误" % path)
			var guide: = adjustment.get_node_or_null("MountGuide") as Node2D
			var pose: = adjustment.get_node_or_null("Pose") as Node2D
			var body: = adjustment.get_node_or_null("Pose/Body") as Sprite2D
			var front: = adjustment.get_node_or_null("Pose/BodyFront") as Sprite2D
			_check(guide != null, "%s 缺少 2D 坐骑参考" % path)
			_check(pose != null and body != null, "%s 缺少可编辑 Pose/Body" % path)
			if pose != null:
				if role_id == 1:
					_check(pose.scale.x > 0.0, "%s 孙悟空姿态被错误翻转" % path)
				elif role_id <= 5:
					_check(pose.scale.x < 0.0, "%s 非孙悟空姿态没有纠正朝向" % path)
				else:
					_check(pose.scale.x > 0.0, "%s 哪吒原版动作被错误翻转" % path)
			_check(adjustment.get_node_or_null("Pose/Equipment") == null, "%s 错误包含武器层" % path)
			if body != null:
				_check(body.frame == int(EXPECTED_FRAMES[role_id]), "%s 动作帧错误" % path)
				_check(body.texture != null, "%s 人物身体纹理为空" % path)
			if role_id == 6:
				_check(front != null and front.texture != null and front.visible, "%s 哪吒身体前层缺失" % path)
			else:
				_check(front != null and not front.visible, "%s 普通人物意外包含前层" % path)

			adjustment.position = Vector2(
				CELL_SIZE.x * (float(mount_column) + 0.5), 
				CELL_SIZE.y * (float(role_id - 1) + 0.78)
			)
			adjustment.scale = Vector2(0.31, 0.31)
			root.add_child(adjustment)
			var label: = Label.new()
			label.text = "%s × %s" % [ROLE_NAMES[role_id], mount_id]
			label.position = Vector2(CELL_SIZE.x * mount_column + 5.0, CELL_SIZE.y * (role_id - 1) + 4.0)
			label.add_theme_font_size_override("font_size", 9)
			label.z_index = 20
			root.add_child(label)

			var runtime_visual: MountVisual = MOUNT_VISUAL.new()
			root.add_child(runtime_visual)
			_check(runtime_visual.setup("1003100", "idle"), "运行时坐骑视觉初始化失败")
			runtime_visual.set_process(false)
			runtime_visual.set_rider_pose(
				scene, path, 
				null, null, 
				maxi(1, body.hframes if body != null else 1), 
				maxi(1, body.vframes if body != null else 1), 
				int(EXPECTED_FRAMES[role_id])
			)
			var runtime_rider: = runtime_visual.get_node_or_null("Rider") as Node2D
			var runtime_pose: = runtime_visual.get_node_or_null("Rider/Pose") as Node2D
			_check(runtime_rider != null and runtime_pose != null, "%s 运行时姿态未加载" % path)
			_check(runtime_visual.get_node_or_null("Rider/MountGuide") == null, "%s 运行时带入编辑器参考图" % path)
			_check(runtime_pose != null and runtime_pose.transform.is_equal_approx(pose.transform), "%s 运行时没有保留 Pose 调整" % path)
			_check(runtime_visual.get_node_or_null("Rider/Pose/Equipment") == null, "%s 运行时错误包含武器层" % path)
			runtime_visual.queue_free()

	await process_frame
	await process_frame
	RenderingServer.force_draw()
	await process_frame
	var output: = OS.get_environment("TEMP").path_join("mount_rider_adjustments_6x8.png")
	var image: = root.get_texture().get_image()
	_check(image != null and not image.is_empty(), "6×8 骑乘组合截图为空")
	if image != null and not image.is_empty():
		_check(image.save_png(output) == OK, "6×8 骑乘组合截图保存失败")
		print("MOUNT_RIDER_ADJUSTMENT_SHEET:%s" % output)
	if failures.is_empty():
		print("MOUNT_RIDER_ADJUSTMENT_PROBE_OK")
		quit(0)
		return
	for failure in failures:
		push_error("MOUNT_RIDER_ADJUSTMENT_PROBE_FAIL: %s" % failure)
	quit(1)
