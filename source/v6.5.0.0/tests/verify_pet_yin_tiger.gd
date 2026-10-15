extends SceneTree

func _init() -> void :
	call_deferred("_run")

func _run() -> void :
	var failures: Array[String] = []
	for stage in range(1, 5):
		var scene_path: = "res://Scene/Pet/PetYinTigerSummon_%d.tscn" % stage
		if ResourceLoader.load(scene_path, "PackedScene") == null:
			failures.append(scene_path)
	if ResourceLoader.load("res://Scene/Pet/PetYinTigerBullet.tscn", "PackedScene") == null:
		failures.append("res://Scene/Pet/PetYinTigerBullet.tscn")
	for effect_name in ["PetYinTiger1Bullet1", "PetYinTiger1Bullet2", "PetYinTiger1Bullet3"]:
		var expected: = 20 if effect_name.ends_with("Bullet1") else 30
		for index in range(1, expected + 1):
			var path: = "res://Art/Pet/PetYinTiger/effects/%s/%d.png" % [effect_name, index]
			if not FileAccess.file_exists(path):
				failures.append(path)
				break
	for source_stage in [1, 2]:
		for action in ["wait", "walk", "hurt", "death", "hit1", "hit2"]:
			var count: = 6 if action in ["wait", "death"] else 4 if action == "walk" else 1 if action == "hurt" else 5 if action == "hit1" else 3
			if source_stage == 2 and action == "hit3":
				count = 4
			for index in range(count):
				var path: = "res://Art/Pet/PetYinTiger/model/actions/stage%d/%s/%d.png" % [source_stage, action, index + 1]
				if not FileAccess.file_exists(path):
					failures.append(path)
					break
	for source_stage in [1, 2]:
		var expected_size: = Vector2(160, 160) if source_stage == 1 else Vector2(200, 200)
		var first_wait_data: PackedByteArray = PackedByteArray()
		for index in range(1, 7):
			var wait_path: = "res://Art/Pet/PetYinTiger/model/actions/stage%d/wait/%d.png" % [source_stage, index]
			var wait_texture: = ResourceLoader.load(wait_path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
			if wait_texture == null or wait_texture.get_size() != expected_size:
				failures.append("%s expected %s" % [wait_path, expected_size])
			elif source_stage == 1:
				var wait_data: = FileAccess.get_file_as_bytes(ProjectSettings.globalize_path(wait_path))
				if index == 1:
					first_wait_data = wait_data
				elif wait_data == first_wait_data:
					failures.append("stage1 wait frame %d is duplicated" % index)
	for path in [
		"res://Script/Pet/PetYinTigerBullet.gd", 
		"res://Script/Pet/PetYinTigerSummonBase.gd", 
		"res://Art/Pet/skillicon/hx.png", 
		"res://Art/Pet/skillicon/mhxs.png", 
		"res://Art/Pet/skillicon/yhaoyi.png", 
	]:
		if not FileAccess.file_exists(path):
			failures.append(path)
	var yin_bullet_source: = FileAccess.get_file_as_string("res://Script/Pet/PetYinTigerBullet.gd")
	var role_source: = FileAccess.get_file_as_string("res://Script/Base/BaseRole.gd")
	for skill_id in ["\"hx\"", "\"mhxs\"", "\"yhaoyi\""]:
		if not role_source.contains(skill_id):
			failures.append("missing Yin Tiger HUD skill id: " + skill_id)
	for offset_text in [
		"\"PetYinTiger1Bullet1\": Vector2(6.0, 0.0)", 
		"\"PetYinTiger1Bullet2\": Vector2(-94.0, -25.0)", 
		"\"PetYinTiger1Bullet3\": Vector2(-79.0, 0.0)", 
	]:
		if not yin_bullet_source.contains(offset_text):
			failures.append("missing effect registration correction: " + offset_text)
	if not yin_bullet_source.contains("var hit_tick := 3 if skill_name == \"PetYinTiger1Bullet1\" else 10"):
		failures.append("Yin Tiger Bullet3 damage hit tick must be 10")
	if not yin_bullet_source.contains("get_meta(\"yin_tiger_locked_target\")"):
		failures.append("Yin Tiger bullet must retain summoner target fallback")
	if not yin_bullet_source.contains("locked_target_in_skill_range"):
		failures.append("Yin Tiger skill 2 must damage its locked target at close range")
	var yin_summon_source: = FileAccess.get_file_as_string("res://Script/Pet/PetYinTigerSummonBase.gd")
	if not yin_summon_source.contains("objattackDic[\"hit3\"]") or not yin_summon_source.contains("\"physics\", 10"):
		failures.append("Yin Tiger skill 2 must use physical damage")
	if not yin_summon_source.contains("const HIT3_RUSH_SPEED := 240.0"):
		failures.append("Yin Tiger skill 2 rush speed must match 10 px per 24 FPS tick")
	if not yin_summon_source.contains("velocity.x = -HIT3_RUSH_SPEED if MonsterDirection else HIT3_RUSH_SPEED"):
		failures.append("Yin Tiger skill 2 must rush in facing direction")
	if not yin_summon_source.contains("_front_offset(400.0, -100.0)"):
		failures.append("Yin Tiger Bullet3 must spawn 400 px ahead of the pet")
	if not yin_summon_source.contains("distance <= 300.0"):
		failures.append("Yin Tiger skill 2 cast range must match official 300 px")
	if not yin_summon_source.contains("set_meta(\"yin_tiger_locked_target\", current_target)"):
		failures.append("Yin Tiger skill 2 must retain its cast target")
	if failures.is_empty():
		print("PET_YIN_TIGER_VERIFY_OK")
		quit(0)
		return
	print("PET_YIN_TIGER_VERIFY_FAILED: " + ", ".join(failures))
	quit(1)
