extends SceneTree

const BODY_FRAMES_PATH: = "res://Art/HeroPicture/Role6/equipment_atlas/default_body/default_body.tres"
const FRONT_FRAMES_PATH: = "res://Art/HeroPicture/Role6/equipment_atlas/default_body_front/default_body_front.tres"
const POSE_ANIMATION: = &"skill4"
const POSE_FRAME: = 14
const OUTPUT_DIR: = "res://Art/Mount/RiderPoses"

func _initialize() -> void :
	call_deferred("_run")

func _run() -> void :
	_hide_debug_overlay()
	var body_frames: = load(BODY_FRAMES_PATH) as SpriteFrames
	var front_frames: = load(FRONT_FRAMES_PATH) as SpriteFrames
	if body_frames == null or front_frames == null:
		push_error("NEZHA_RIDER_RENDER_FAIL: original frames missing")
		quit(1)
		return
	if not body_frames.has_animation(POSE_ANIMATION) or POSE_FRAME >= body_frames.get_frame_count(POSE_ANIMATION):
		push_error("NEZHA_RIDER_RENDER_FAIL: source pose missing")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	root.size = Vector2i(1024, 1024)
	root.transparent_bg = true
	var sprite: = Sprite2D.new()
	sprite.position = Vector2(512.0, 700.0)
	sprite.offset = Vector2(0.0, -188.0)
	root.add_child(sprite)
	var outputs: = {
		"Role6RiderBody.png": body_frames.get_frame_texture(POSE_ANIMATION, POSE_FRAME), 
		"Role6RiderBodyFront.png": front_frames.get_frame_texture(
			POSE_ANIMATION, 
			mini(POSE_FRAME, front_frames.get_frame_count(POSE_ANIMATION) - 1)
		), 
	}
	for file_name in outputs:
		sprite.texture = outputs[file_name]
		await process_frame
		RenderingServer.force_draw()
		await process_frame
		var image: = root.get_texture().get_image()
		var output_path: = OUTPUT_DIR.path_join(file_name)
		if image == null or image.is_empty() or image.save_png(ProjectSettings.globalize_path(output_path)) != OK:
			push_error("NEZHA_RIDER_RENDER_FAIL: %s" % output_path)
			quit(1)
			return
		print("NEZHA_RIDER_LAYER:%s" % ProjectSettings.globalize_path(output_path))
	quit(0)

func _hide_debug_overlay() -> void :


	var global_node: = root.get_node_or_null("Global")
	if global_node == null:
		return
	var debug_label: = global_node.get("_debug_perf_label") as Label
	if debug_label != null:
		debug_label.visible = false
	var debug_layer: = global_node.get("_debug_perf_layer") as CanvasLayer
	if debug_layer != null:
		debug_layer.visible = false
