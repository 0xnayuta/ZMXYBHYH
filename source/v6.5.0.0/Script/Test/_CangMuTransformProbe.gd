extends Node

const ATLAS: = preload("res://Art/HeroPicture/Role4/CangMuLongYun/runtime/HeroF_6009_skill.atlas")
const SKELETON: = preload("res://Art/HeroPicture/Role4/CangMuLongYun/runtime/HeroF_6009_skill01_2.spine-json")

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	var data: Variant = ClassDB.instantiate("SpineSkeletonDataResource")
	data.set_atlas_res(ATLAS)
	data.set_skeleton_file_res(SKELETON)
	data.update_skeleton_data()
	var effect: = Node2D.new()
	effect.global_position = Vector2(600, 300)
	add_child(effect)
	var spine: Variant = ClassDB.instantiate("SpineSprite")
	spine.scale = Vector2(0.2, 0.2)
	effect.add_child(spine as Node)
	spine.set_skeleton_data_res(data)
	await get_tree().process_frame
	var state: Variant = spine.get_animation_state()
	state.set_animation("skill01_2", false, 0)
	var names: = ["mulong_zong", "mulong14", "tou_zong2", "tou5", "mulong15", "shitouzong2", "shitou1", "mulong25", "tou_zong3", "tou9", "shitou2", "mulong58", "tou_zong6", "tou21", "shitou5"]
	for frame in range(0, 110, 5):
		await get_tree().process_frame
		var skeleton: Variant = spine.get_skeleton()
		if skeleton != null and skeleton.has_method("update_world_transform"):
			skeleton.update_world_transform(0)
		var row: Array[String] = []
		for n in names:
			var api_value: Variant = spine.get_global_bone_transform(n) if spine.has_method("get_global_bone_transform") else null
			var bone: Variant = skeleton.find_bone(n) if skeleton != null else null
			var raw: Variant = bone.get_global_transform() if bone != null and bone.has_method("get_global_transform") else null
			row.append("%s api=%s raw=%s" % [n, str(api_value), str(raw)])
		print("CMLY_TRANSFORM frame=%d spine=%s %s" % [frame, str(spine.global_transform), " | ".join(row)])
		for _i in range(4):
			await get_tree().process_frame
	get_tree().quit(0)
