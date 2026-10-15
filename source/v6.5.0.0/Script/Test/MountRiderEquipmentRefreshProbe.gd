extends SceneTree

const OUTPUT_FILE: = "mount_rider_equipment_refresh.png"

var failures: Array[String] = []

func _initialize() -> void :
	call_deferred("_run")

func _run() -> void :
	var player_data: = root.get_node_or_null("PlayerData")
	_check(player_data != null, "PlayerData Autoload 未加载")
	if player_data == null:
		_finish()
		return
	var original: Dictionary = player_data.player_data.duplicate(true)
	player_data.player_data["Myself"] = 1
	var transmog_value: Variant = player_data.player_data.get("幻化列表", {})
	if not (transmog_value is Dictionary):
		player_data.player_data["幻化列表"] = {}
	var transmog: Dictionary = player_data.player_data["幻化列表"]
	transmog["防具"] = "Empty"
	root.size = Vector2i(940, 590)
	var background: = ColorRect.new()
	background.color = Color(0.08, 0.1, 0.14, 1.0)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(background)
	var hero_scene: = load("res://Scene/Hero/Role_1/Role1.tscn") as PackedScene
	_check(hero_scene != null, "孙悟空角色场景无法加载")
	if hero_scene == null:
		player_data.player_data = original
		_finish()
		return
	var hero = hero_scene.instantiate()
	hero.position = Vector2(470.0, 430.0)
	root.add_child(hero)
	await process_frame
	await process_frame
	hero.set_process(false)
	hero.set_physics_process(false)
	var runtime_script: = load("res://Script/Mount/MountRuntime.gd")
	var visual_script: = load("res://Script/Mount/MountVisual.gd")
	_check(runtime_script != null and visual_script != null, "坐骑运行时脚本无法加载")
	if runtime_script == null or visual_script == null:
		hero.queue_free()
		player_data.player_data = original
		_finish()
		return
	var runtime: Node = runtime_script.new()
	runtime.name = "MountRuntime"
	runtime.set("hero", hero)
	hero.add_child(runtime)
	var visual: Node2D = visual_script.new()
	visual.name = "MountVisual"
	visual.position = Vector2(0.0, 70.0)
	hero.add_child(visual)
	_check(visual.setup("1003900", "idle"), "年兽骑乘模型无法加载")
	runtime.set("mount_visual", visual)
	runtime.set("_current_mount_id", "1003900")
	runtime.call("refresh_rider_appearance")
	await process_frame
	var rider_pose: = visual.get_node_or_null("Rider/Pose") as Node2D
	var rider_body: = visual.get_node_or_null("Rider/Pose/Body") as Sprite2D
	_check(rider_pose != null and rider_body != null, "骑乘人物姿态未创建")
	var original_pose_transform: = rider_pose.transform if rider_pose != null else Transform2D.IDENTITY
	transmog["防具"] = "bsxj"
	hero.onEqchange()
	await process_frame
	_check(hero.RoleBody.texture != null, "人物切换防具后身体贴图为空")
	_check(rider_body != null and rider_body.texture == hero.RoleBody.texture, "人物切换装备后坐骑人物模型没有同步")
	_check(rider_pose != null and rider_pose.transform.is_equal_approx(original_pose_transform), "刷新装备时破坏了坐骑2D调整位置")
	if DisplayServer.get_name() != "headless":
		hero.action.visible = false
		visual.visible = true
		RenderingServer.force_draw()
		await process_frame
		var image: = root.get_texture().get_image()
		_check(image != null and not image.is_empty(), "骑乘换装截图为空")
		if image != null and not image.is_empty():
			var output: = OS.get_environment("TEMP").path_join(OUTPUT_FILE)
			_check(image.save_png(output) == OK, "骑乘换装截图保存失败")
			print("MOUNT_RIDER_EQUIPMENT_SCREENSHOT=" + output)
	hero.queue_free()
	player_data.player_data = original
	_finish()

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)

func _finish() -> void :
	if failures.is_empty():
		print("MOUNT_RIDER_EQUIPMENT_REFRESH_OK")
		quit(0)
		return
	for failure in failures:
		push_error("MOUNT_RIDER_EQUIPMENT_REFRESH_FAIL: " + failure)
	quit(1)
