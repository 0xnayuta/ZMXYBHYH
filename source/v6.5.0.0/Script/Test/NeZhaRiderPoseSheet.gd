extends SceneTree

const BODY_FRAMES_PATH: = "res://Art/HeroPicture/Role6/equipment_atlas/default_body/default_body.tres"
const FRONT_FRAMES_PATH: = "res://Art/HeroPicture/Role6/equipment_atlas/default_body_front/default_body_front.tres"
const ANIMATIONS: = [&"wait", &"run", &"jump1", &"drop", &"jump2", &"hit5", &"hit1", &"hurt"]
const SAMPLE_COUNT: = 6
const CELL_SIZE: = Vector2(250.0, 280.0)

func _initialize() -> void :
	call_deferred("_run")

func _run() -> void :
	var body_frames: = load(BODY_FRAMES_PATH) as SpriteFrames
	var front_frames: = load(FRONT_FRAMES_PATH) as SpriteFrames
	if body_frames == null or front_frames == null:
		push_error("NEZHA_RIDER_POSE_SHEET_FAIL: original SpriteFrames missing")
		quit(1)
		return
	root.size = Vector2i(int(CELL_SIZE.x * SAMPLE_COUNT), int(CELL_SIZE.y * ANIMATIONS.size()))
	var background: = ColorRect.new()
	background.color = Color("20242c")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(background)
	for row in range(ANIMATIONS.size()):
		var animation_name: StringName = ANIMATIONS[row]
		var body_count: = body_frames.get_frame_count(animation_name)
		var front_count: = front_frames.get_frame_count(animation_name)
		for column in range(SAMPLE_COUNT):
			var frame_index: = 0
			if body_count > 1:
				frame_index = mini(body_count - 1, int(round(float(column) * float(body_count - 1) / float(SAMPLE_COUNT - 1))))
			var origin: = Vector2(
				CELL_SIZE.x * (float(column) + 0.5), 
				CELL_SIZE.y * float(row) + CELL_SIZE.y - 35.0
			)
			var cross: = Line2D.new()
			cross.width = 1.0
			cross.default_color = Color(0.2, 0.8, 0.35, 0.7)
			cross.points = PackedVector2Array([
				origin + Vector2(-65.0, 0.0), origin + Vector2(65.0, 0.0), 
				origin + Vector2(0.0, 18.0), origin + Vector2(0.0, -190.0), 
			])
			root.add_child(cross)
			var body: = Sprite2D.new()
			body.texture = body_frames.get_frame_texture(animation_name, frame_index)
			body.position = origin
			body.scale = Vector2(0.55, 0.55)
			root.add_child(body)
			if front_count > 0:
				var front: = Sprite2D.new()
				front.texture = front_frames.get_frame_texture(animation_name, mini(frame_index, front_count - 1))
				front.position = origin
				front.scale = body.scale
				front.z_index = 1
				root.add_child(front)
			var label: = Label.new()
			label.text = "%s  frame %d/%d" % [animation_name, frame_index, body_count - 1]
			label.position = Vector2(CELL_SIZE.x * column + 12.0, CELL_SIZE.y * row + 8.0)
			label.add_theme_font_size_override("font_size", 18)
			label.z_index = 2
			root.add_child(label)
	await process_frame
	await process_frame
	RenderingServer.force_draw()
	await process_frame
	var output: = OS.get_environment("TEMP").path_join("nezha_rider_pose_sheet.png")
	var image: = root.get_texture().get_image()
	if image == null or image.is_empty() or image.save_png(output) != OK:
		push_error("NEZHA_RIDER_POSE_SHEET_FAIL: screenshot save failed")
		quit(1)
		return
	print("NEZHA_RIDER_POSE_SHEET:%s" % output)
	quit(0)
