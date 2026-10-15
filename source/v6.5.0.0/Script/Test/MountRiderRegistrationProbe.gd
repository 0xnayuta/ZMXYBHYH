extends SceneTree

const FRAME: = 49
const HFRAMES: = 6
const VFRAMES: = 14
const EQUIPMENT_ROOT: = "res://Art/HeroPicture/Role1AllEquipment"

func _initialize() -> void :
	call_deferred("_run")

func _run() -> void :
	var directory: = DirAccess.open(EQUIPMENT_ROOT)
	if directory == null:
		push_error("MOUNT_RIDER_REGISTRATION_PROBE_FAIL: equipment directory missing")
		quit(1)
		return
	var samples: = [
		"Role_1_Body_bsxj.png", "Role_1_Body_Empty.png", 
		"Role_1_Body_zqfjwk.png", "Role_1_Body_zxstj.png", 
	]
	for file_name in samples:
		var texture: = load(EQUIPMENT_ROOT.path_join(file_name)) as Texture2D
		if texture == null:
			push_error("MOUNT_RIDER_REGISTRATION_PROBE_FAIL: %s missing" % file_name)
			quit(1)
			return
		var image: = texture.get_image()
		var frame_size: = Vector2i(image.get_width() / HFRAMES, image.get_height() / VFRAMES)
		var frame_origin: = Vector2i(FRAME % HFRAMES, FRAME / HFRAMES) * frame_size
		var frame_image: = image.get_region(Rect2i(frame_origin, frame_size))
		print("RIDER_FRAME_BOUNDS %s %s" % [file_name, str(frame_image.get_used_rect())])
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(
		"res://Art/Mount/Runtime/Riders/2001/manifest.json"
	))
	var reference_frame: Dictionary = (manifest.get("frames", []) as Array)[1]
	print("RIDER_REFERENCE_FRAME %s" % str(reference_frame))
	if DisplayServer.get_name() != "headless":
		root.size = Vector2i(520, 320)
		var background: = ColorRect.new()
		background.color = Color("20242c")
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		root.add_child(background)
		var registration: = Node2D.new()
		registration.position = Vector2(260.0, 210.0)
		root.add_child(registration)
		var reference: = Sprite2D.new()
		reference.centered = false
		reference.texture = load("res://Art/Mount/Runtime/Riders/2001/001.png")
		var reference_origin: Array = reference_frame.get("origin", [0.0, 0.0])
		reference.position = - Vector2(float(reference_origin[0]), float(reference_origin[1]))
		reference.modulate = Color(1.0, 0.25, 0.25, 0.55)
		registration.add_child(reference)
		var equipment_pose: = Sprite2D.new()
		equipment_pose.texture = load(EQUIPMENT_ROOT.path_join("Role_1_Body_bsxj.png"))
		equipment_pose.hframes = HFRAMES
		equipment_pose.vframes = VFRAMES
		equipment_pose.frame = FRAME
		equipment_pose.position = Vector2(0.0, -30.0)
		equipment_pose.modulate = Color(0.25, 0.9, 1.0, 0.65)
		registration.add_child(equipment_pose)
		var cross: = Line2D.new()
		cross.width = 1.0
		cross.default_color = Color.WHITE
		cross.points = PackedVector2Array([
			Vector2(-120.0, 0.0), Vector2(120.0, 0.0), 
			Vector2.ZERO, Vector2(0.0, -180.0), 
		])
		registration.add_child(cross)
		await process_frame
		await process_frame
		RenderingServer.force_draw()
		await process_frame
		var output: = OS.get_environment("TEMP").path_join("mount_rider_registration_overlay.png")
		root.get_texture().get_image().save_png(output)
		print("MOUNT_RIDER_REGISTRATION_OVERLAY:%s" % output)
	quit(0)
