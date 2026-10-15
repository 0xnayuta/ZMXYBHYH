extends Node

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	var spine: Variant = ClassDB.instantiate("SpineSprite")
	print("SPINE_API_INSTANCE=" + str(spine))
	if spine == null:
		get_tree().quit(1)
		return
	var atlas: Variant = load("res://Art/HeroPicture/Role4/CangMuLongYun/runtime/HeroF_6009_skill.atlas")
	var skeleton_file: Variant = load("res://Art/HeroPicture/Role4/CangMuLongYun/runtime/HeroF_6009_skill01_2.spine-json")
	var data: Variant = ClassDB.instantiate("SpineSkeletonDataResource")
	if data != null and atlas != null and skeleton_file != null:
		data.set_atlas_res(atlas)
		data.set_skeleton_file_res(skeleton_file)
		data.update_skeleton_data()
		spine.set_skeleton_data_res(data)
		await get_tree().process_frame
	print("SPINE_API_METHOD_NAMES=" + ",".join(spine.get_method_list().map( func(item): return str(item.get("name", "")))))
	var skel: Variant = spine.get_skeleton()
	print("SPINE_API_SKEL=" + str(skel))
	var state: Variant = spine.get_animation_state()
	if state != null:
		var state_names: = []
		for item in state.get_method_list(): state_names.append(str(item.get("name", "")))
		print("SPINE_API_STATE_METHOD_NAMES=" + ",".join(state_names))
		if state.has_method("set_animation"):
			state.set_animation("skill01_2", false, 0)
		if state.has_method("update"):
			state.update(0.5)
		if state.has_method("apply"):
			state.apply(skel)
	if skel != null and skel.has_method("update_world_transform"):
		skel.update_world_transform(0)
	if skel != null:
		for method_data in skel.get_method_list():
			if str(method_data.get("name", "")).contains("attachment") or str(method_data.get("name", "")) == "get_bounds":
				print("SPINE_API_SPECIAL_METHOD=" + str(method_data))
		var sm: = []
		for item in skel.get_method_list():
			sm.append(str(item.get("name", "")))
		print("SPINE_API_SKEL_METHOD_NAMES=" + ",".join(sm))
		var slots: Variant = skel.get_slots() if skel.has_method("get_slots") else skel.get("slots")
		print("SPINE_API_SLOTS_TYPE=" + str(slots) + " count=" + str(slots.size() if slots is Array else -1))
		if slots is Array and slots.size() > 0:
			var slot: Variant = slots[0]
			var names: = []
			for item in slot.get_method_list():
				names.append(str(item.get("name", "")))
			print("SPINE_API_SLOT_METHOD_NAMES=" + ",".join(names))
			var pose0: Variant = slot.get_pose() if slot.has_method("get_pose") else null
			var pose_names: = []
			if pose0 != null:
				for item in pose0.get_method_list(): pose_names.append(str(item.get("name", "")))
			print("SPINE_API_POSE_METHOD_NAMES=" + ",".join(pose_names))
			print("SPINE_API_POSE_PROPS=" + str(pose0.get_property_list()) if pose0 != null else "SPINE_API_POSE_PROPS=null")
			for slot_name in ["FX-st01", "FX-st1", "FX-st2", "FX-st3", "FX-st4", "FX-st5", "FX-st6"]:
				var slot_obj: Variant = skel.find_slot(slot_name) if skel.has_method("find_slot") else null
				var attachment: Variant = skel.get_attachment_by_slot_name("default", slot_name) if skel.has_method("get_attachment_by_slot_name") else null
				var slot_data: Variant = slot_obj.get_data() if slot_obj != null and slot_obj.has_method("get_data") else null
				var pose: Variant = slot_obj.get_pose() if slot_obj != null and slot_obj.has_method("get_pose") else null
				var applied_pose: Variant = slot_obj.get_applied_pose() if slot_obj != null and slot_obj.has_method("get_applied_pose") else null
				var pose_attachment: Variant = pose.get_attachment() if pose != null and pose.has_method("get_attachment") else null
				var applied_attachment: Variant = applied_pose.get_attachment() if applied_pose != null and applied_pose.has_method("get_attachment") else null
				print("SPINE_API_ATTACHMENT=" + slot_name + " slot_data=" + str(slot_data) + " pose_attachment=" + str(pose_attachment) + " applied_attachment=" + str(applied_attachment) + " attachment=" + str(attachment))
				if pose_attachment != null and pose_attachment.has_method("get_attachment_name"):
					print("SPINE_API_ACTIVE_ATTACHMENT=" + slot_name + " name=" + str(pose_attachment.get_attachment_name()))
				if slot_data != null:
					var attachment_name: = str(slot_data.get_attachment_name()) if slot_data.has_method("get_attachment_name") else ""
					print("SPINE_API_SLOT_DATA=" + slot_name + " attachment_name=" + attachment_name)
					for candidate_name in ["FX/st01", "FX/st02", "FX/st03", "FX/st04", "FX/st1", "FX/st2"]:
						var candidate: Variant = skel.get_attachment_by_slot_name(slot_name, candidate_name)
						print("SPINE_API_ATTACHMENT_CANDIDATE=" + slot_name + " name=" + candidate_name + " value=" + str(candidate) + " class=" + (candidate.get_class() if candidate != null else "null"))
						if candidate != null and slot_name == "FX-st01" and candidate_name == "FX/st01":
							var candidate_names: = []
							for item in candidate.get_method_list(): candidate_names.append(str(item.get("name", "")))
							print("SPINE_API_ATTACHMENT_METHOD_NAMES=" + ",".join(candidate_names))
							print("SPINE_API_ATTACHMENT_PROPS=" + str(candidate.get_property_list()))
				if attachment != null:
					print("SPINE_API_ATTACHMENT_CLASS=" + slot_name + ":" + attachment.get_class())
	spine.free()
	get_tree().quit(0)
