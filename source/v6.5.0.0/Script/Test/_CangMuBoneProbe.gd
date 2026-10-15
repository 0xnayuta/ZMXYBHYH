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
	var spine: Variant = ClassDB.instantiate("SpineSprite")
	spine.scale = Vector2(0.2, 0.2)
	add_child(spine as Node)
	spine.set_skeleton_data_res(data)
	await get_tree().process_frame
	var state: Variant = spine.get_animation_state()
	state.set_animation("skill01_2", false, 0)
	var names: = ["mulong2", "mulong3", "mulong5", "mulong5t", "tou_zong", "tou1", "shitouzong", "shitou0", "mulong13", "mulong14", "tou_zong2", "tou5", "shitou1", "mulong24", "mulong25", "tou_zong3", "tou9", "shitou2", "mulong35", "mulong36", "tou_zong4", "tou13", "shitou3", "mulong46", "mulong47", "tou_zong5", "tou17", "shitou4", "mulong57", "mulong58", "tou_zong6", "tou21", "shitou5"]
	for frame in range(0, 120, 5):
		await get_tree().process_frame
		var skeleton: Variant = spine.get_skeleton()
		if skeleton != null and skeleton.has_method("update_world_transform"):
			skeleton.update_world_transform(0)
		var row: = []
		for n in names:
			var bone: Variant = skeleton.find_bone(n)
			if bone != null and bone.has_method("get_global_transform"):
				row.append("%s=(%.1f,%.1f)" % [n, bone.get_global_transform().origin.x, bone.get_global_transform().origin.y])
		print("CMLY_BONE_FRAME=%d %s" % [frame, " ".join(row)])
		for _i in range(4):
			await get_tree().process_frame
	get_tree().quit(0)
