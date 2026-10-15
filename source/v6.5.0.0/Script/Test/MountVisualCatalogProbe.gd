extends SceneTree

const MOUNT_VISUAL: = preload("res://Script/Mount/MountVisual.gd")
const MOUNT_IDS: = ["1002200", "1003100", "1002700", "1002800", "1003500", "1003600", "1003900", "1004700"]
const REQUIRED_ACTIONS: = ["idle", "walk", "attack1", "effect1", "effect2", "effect3", "effect4"]
const OUTPUT_PREFIX: = "mount_visual_"

var failures: Array[String] = []

func _initialize() -> void :
	call_deferred("_run")

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)

func _run() -> void :
	root.size = Vector2i(900, 650)
	var background: = ColorRect.new()
	background.color = Color(0.035, 0.045, 0.065, 1.0)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(background)

	var ground_line: = Line2D.new()
	ground_line.width = 2.0
	ground_line.default_color = Color(1.0, 0.2, 0.15, 1.0)
	ground_line.points = PackedVector2Array([Vector2(45.0, 570.0), Vector2(855.0, 570.0)])
	ground_line.z_index = 20
	root.add_child(ground_line)

	var origin_line: = Line2D.new()
	origin_line.width = 2.0
	origin_line.default_color = Color(0.1, 1.0, 0.35, 1.0)
	origin_line.points = PackedVector2Array([Vector2(450.0, 550.0), Vector2(450.0, 590.0)])
	origin_line.z_index = 20
	root.add_child(origin_line)

	var title: = Label.new()
	title.position = Vector2(30.0, 32.0)
	title.add_theme_font_size_override("font_size", 26)
	title.z_index = 20
	root.add_child(title)
	await process_frame
	await process_frame

	for mount_id in MOUNT_IDS:
		title.text = "%s  red=ground  green=armature origin" % mount_id
		var visual: MountVisual = MOUNT_VISUAL.new()
		visual.position = Vector2(450.0, 570.0)
		root.add_child(visual)
		_check(visual.setup(mount_id, "idle"), "%s idle could not load" % mount_id)
		_check(visual.get_registration_anchor().is_equal_approx(Vector2.ZERO), "%s did not retain its source armature origin" % mount_id)
		_check(visual.to_global(Vector2.ZERO).is_equal_approx(Vector2(450.0, 570.0)), "%s armature origin did not land on the ground marker" % mount_id)
		visual.set_process(false)
		var back: = visual.get_node_or_null("Back") as Sprite2D
		var front: = visual.get_node_or_null("Front") as Sprite2D
		_check(back != null and front != null, "%s front/back layers were not created" % mount_id)
		var rider: = visual.get_node_or_null("Rider") as Node2D
		_check(rider != null and not rider.visible, "%s preview unexpectedly displayed a rider" % mount_id)
		for action_name in REQUIRED_ACTIONS:
			_check(visual.has_animation(action_name), "%s is missing original %s" % [mount_id, action_name])
		if mount_id == "1003100":
			_check(visual.has_animation("aoyiSkill"), "1003100 final tiger is missing original ultimate animation")
		var action_names: = DirAccess.get_directories_at("res://Art/Mount/Runtime/Mounts/%s" % mount_id)
		for action_name in action_names:
			if not visual.play(action_name, true):
				failures.append("%s %s could not load" % [mount_id, action_name])
				continue
			visual.set_process(false)
			var animation_data_value: Variant = visual.get("_animation_data")
			_check(animation_data_value is Dictionary, "%s %s data is invalid" % [mount_id, action_name])
			if not (animation_data_value is Dictionary):
				continue
			var frames_value: Variant = (animation_data_value as Dictionary).get("frames", [])
			_check(frames_value is Array and not frames_value.is_empty(), "%s %s has no frames" % [mount_id, action_name])
			if not (frames_value is Array):
				continue
			for frame in range(frames_value.size()):
				visual.set("frame_index", frame)
				visual.call("_apply_frame")
				_check(
					(back != null and back.visible and back.texture != null)
					or (front != null and front.visible and front.texture != null), 
					"%s %s frame %d is not visible" % [mount_id, action_name, frame]
				)
		_check(visual.play("idle", true), "%s idle could not be restored" % mount_id)
		visual.set_process(false)
		_check(
			(back != null and back.visible and back.texture != null)
			or (front != null and front.visible and front.texture != null), 
			"%s idle atlas is not visible" % mount_id
		)
		print("MOUNT_GROUND_AUDIT:%s:origin=%s:bounds=%s" % [mount_id, visual.get_registration_anchor(), visual.get_current_visual_bounds()])

		RenderingServer.force_draw()
		await process_frame
		var image: = root.get_texture().get_image()
		_check(image != null and not image.is_empty(), "%s screenshot is empty" % mount_id)
		if image != null and not image.is_empty():
			_check(image.get_pixel(10, 10).a > 0.99, "%s screenshot was captured before rendering" % mount_id)
			var output_path: = OS.get_environment("TEMP").path_join("%s%s.png" % [OUTPUT_PREFIX, mount_id])
			_check(image.save_png(output_path) == OK, "%s screenshot could not be saved" % mount_id)
			print("MOUNT_VISUAL:%s:%s" % [mount_id, output_path])
		visual.queue_free()
		await process_frame

	if failures.is_empty():
		print("MOUNT_VISUAL_CATALOG_PROBE_OK")
		quit(0)
		return
	for failure in failures:
		push_error("MOUNT_VISUAL_CATALOG_PROBE_FAIL: %s" % failure)
	quit(1)
