extends Node2D

class ProbeMonster:
	extends BaseMonster
	func _ready() -> void :
		pass
	func _process(_delta: float) -> void :
		pass
	func _physics_process(_delta: float) -> void :
		pass

class ProbeEffect:
	extends CangMuLongYunEffect
	var probe_targets: Array[BaseMonster] = []
	var hit_log: Array[String] = []

	func _ready() -> void :
		pass

	func _cache_targets() -> void :
		_cached_targets = probe_targets.duplicate()

	func _is_valid_target(_target: Node) -> bool:
		return true

	func _apply_hit(target: BaseMonster) -> void :
		hit_log.append("%d:%0.1f" % [Time.get_ticks_msec(), target.global_position.x - global_position.x])

func _ready() -> void :
	call_deferred("_run_probe")

func _run_probe() -> void :
	print("CMLY_GEOMETRY_START spine=" + str(ClassDB.class_exists("SpineSprite")))
	var atlas: Resource = load("res://Art/HeroPicture/Role4/CangMuLongYun/runtime/HeroF_6009_skill.atlas")
	var skeleton_file: Resource = load("res://Art/HeroPicture/Role4/CangMuLongYun/runtime/HeroF_6009_skill01_2.spine-json")
	var data: Variant = ClassDB.instantiate("SpineSkeletonDataResource")
	if data == null or atlas == null or skeleton_file == null:
		print("CMLY_GEOMETRY_LOAD_FAIL")
		get_tree().quit(2)
		return
	data.set_atlas_res(atlas)
	data.set_skeleton_file_res(skeleton_file)
	data.update_skeleton_data()
	print("CMLY_GEOMETRY_DATA loaded=" + str(data.is_skeleton_data_loaded()))
	var owner: = Node2D.new()
	owner.global_position = Vector2(600.0, 300.0)
	add_child(owner)
	var effect: = ProbeEffect.new()
	effect.owner_player = owner
	effect.face_right = true
	effect.global_position = owner.global_position
	effect.hit_data = {"power": 1000, "attackKind": "magic", "WSValue": 4}
	add_child(effect)

	var spine: Variant = ClassDB.instantiate("SpineSprite")
	spine.scale = Vector2(0.2, 0.2)
	effect.add_child(spine as Node)
	spine.set_skeleton_data_res(data)
	await get_tree().process_frame
	var state: Variant = spine.get_animation_state()
	if state == null:
		print("CMLY_GEOMETRY_STATE_FAIL")
		get_tree().quit(3)
		return
	state.set_animation("skill01_2", false, 0)
	effect.set("_spine", spine)
	var targets: Array[BaseMonster] = []
	var debug_skeleton: Variant = spine.get_skeleton()
	if debug_skeleton != null:
		for debug_name in ["mulong3", "mulong5", "mulong15", "mulong59"]:
			var debug_bone: Variant = debug_skeleton.find_bone(debug_name)
			if debug_bone != null and debug_bone.has_method("get_global_transform"):
				print("CMLY_BONE_DEBUG name=%s origin=%s spine_global=%s spine_scale=%s effect_global=%s" % [debug_name, str(debug_bone.get_global_transform().origin), str(spine.global_position), str(spine.global_scale), str(effect.global_position)])
	for rel_x in [-900.0, -600.0, -300.0, -150.0, 0.0, 150.0, 300.0, 450.0, 600.0, 900.0]:
		var target: = ProbeMonster.new()
		target.global_position = owner.global_position + Vector2(rel_x, 0.0)
		add_child(target)
		target.set_physics_process(false)
		targets.append(target)
	effect.probe_targets = targets

	for frame in range(120):
		await get_tree().process_frame
		(effect.get("_target_next_hit_msec") as Dictionary).clear()
		var skeleton: Variant = spine.get_skeleton()
		if skeleton != null and skeleton.has_method("update_world_transform"):
			skeleton.update_world_transform(0)
		var reach: float = effect.call("_get_head_forward_reach", skeleton)
		effect.call("_apply_node_damage")
		if frame % 5 == 0:
			print("CMLY_GEOMETRY_FRAME=%d reach=%0.1f dir=%0.1f hits=%s" % [frame, reach, float(effect.get("_head_sweep_direction")), ",".join(effect.hit_log)])
	print("CMLY_GEOMETRY_RESULT hits=%d log=%s" % [effect.hit_log.size(), ",".join(effect.hit_log)])
	get_tree().quit(0)
