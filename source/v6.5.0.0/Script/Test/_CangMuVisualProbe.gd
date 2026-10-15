extends Node2D

const ATLAS: = preload("res://Art/HeroPicture/Role4/CangMuLongYun/runtime/HeroF_6009_skill.atlas")
const SKELETON: = preload("res://Art/HeroPicture/Role4/CangMuLongYun/runtime/HeroF_6009_skill01_2.spine-json")

var spine: Variant
var data: Variant
var elapsed: = 0.0
var marks: Array[Vector2] = []
var frame_no: = 0

func _ready() -> void :
	data = ClassDB.instantiate("SpineSkeletonDataResource")
	data.set_atlas_res(ATLAS)
	data.set_skeleton_file_res(SKELETON)
	data.update_skeleton_data()
	spine = ClassDB.instantiate("SpineSprite")
	spine.position = Vector2(420, 300)
	spine.scale = Vector2(0.2, 0.2)
	add_child(spine as Node)
	spine.set_skeleton_data_res(data)
	await get_tree().process_frame
	var state: Variant = spine.get_animation_state()
	state.set_animation("skill01_2", false, 0)
	queue_redraw()

func _process(delta: float) -> void :
	elapsed += delta
	var skeleton: Variant = spine.get_skeleton() if spine != null and is_instance_valid(spine) else null
	if skeleton != null and skeleton.has_method("update_world_transform"):
		skeleton.update_world_transform(0)
	frame_no += 1
	if frame_no % 6 == 0 and skeleton != null:
		var bounds: Variant = skeleton.get_bounds() if skeleton.has_method("get_bounds") else null
		var positions: = []
		for n in ["mulong14", "mulong25", "mulong36", "mulong47", "mulong58", "tou_zong", "tou_zong2", "tou_zong3", "tou_zong4", "tou_zong5", "tou_zong6"]:
			var xf: Transform2D = spine.get_global_bone_transform(n)
			positions.append("%s=(%0.1f,%0.1f)" % [n, xf.origin.x, xf.origin.y])
		var heads: = []
		for slot_name in ["FX-st01", "FX-st1", "FX-st2", "FX-st3", "FX-st4", "FX-st5", "FX-st6", "FX-st7", "FX-st8", "FX-st9", "FX-st10", "FX-st11"]:
			var slot: Variant = skeleton.find_slot(slot_name)
			var pose: Variant = slot.get_pose() if slot != null and slot.has_method("get_pose") else null
			var attachment: Variant = pose.get_attachment() if pose != null and pose.has_method("get_attachment") else null
			if attachment != null and attachment.has_method("get_attachment_name"):
				heads.append("%s:%s" % [slot_name, str(attachment.get_attachment_name())])
		print("CMLY_VIS_FRAME=%d bounds=%s positions=%s heads=%s" % [frame_no, str(bounds), ";".join(positions), ";".join(heads)])
	marks.clear()
	if spine != null and spine.has_method("get_global_bone_transform"):
		for n in ["mulong3", "mulong15", "mulong26", "mulong37", "mulong48", "mulong59", "tou_zong", "tou_zong2", "tou_zong3", "tou_zong4", "tou_zong5", "tou_zong6"]:
			var xf: Transform2D = spine.get_global_bone_transform(n)
			marks.append(xf.origin)
	queue_redraw()
	for capture_time in [0.2, 0.5, 0.8, 1.1, 1.4, 1.7]:
		if absf(elapsed - capture_time) < delta * 0.6:
			var image: = get_viewport().get_texture().get_image()
			image.save_png("res://.tmp/cmly_visual_%0.1f.png" % capture_time)
	if elapsed > 2.0:
		get_tree().quit(0)

func _draw() -> void :
	draw_line(Vector2(0, 300), Vector2(1200, 300), Color(0.3, 0.3, 0.3), 1.0)
	draw_line(Vector2(420, 0), Vector2(420, 400), Color(0.3, 0.3, 0.3), 1.0)
	for p in marks:
		draw_circle(p, 7.0, Color.RED)
