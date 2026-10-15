extends SceneTree

func _init() -> void :
	call_deferred("_run")

func _run() -> void :
	var target_scene: = load("res://Scene/Monster/Monster_1.tscn") as PackedScene
	var bullet_scene: = load("res://Scene/Pet/PetYinTigerBullet.tscn") as PackedScene
	if target_scene == null or bullet_scene == null:
		push_error("YIN_DAMAGE_PROBE_FAIL missing scenes")
		quit(1)
		return
	var level: = Node2D.new()
	level.name = "ProbeLevel"
	root.add_child(level)
	var target = target_scene.instantiate()
	level.add_child(target)
	await process_frame
	if target == null:
		push_error("YIN_DAMAGE_PROBE_FAIL no target")
		quit(1)
		return
	target.set_physics_process(false)
	target.set_process(false)
	target.set("Hp", 1000000)
	target.set("SHp", 1000000)
	target.set("mdef", 0)
	target.set("def", 0)
	target.set("miss", 0)
	target.set("llrdzs", 1.0)
	target.set("boss_protect_active", false)
	target.set("IsIndestructible", false)
	target.add_to_group("monsters")
	var bullet = bullet_scene.instantiate()
	bullet.AttList = {"power": 1000, "attackKind": "physics", "attackInterval": 10, "hurtBack": [0, 0], "HitProtect": 0}
	bullet.hit_name = "hit3"
	bullet.skill_name = "PetYinTiger1Bullet3"
	bullet.dir = false
	bullet.speed = 1.0
	bullet.set_meta("summoner", root)
	level.add_child(bullet)
	await process_frame
	bullet.bullet_ani.frame = 10
	var rect: Rect2 = bullet.call("_current_effect_rect")
	var hurt_rect: Rect2 = bullet.call("_target_hurt_rect", target)
	bullet.global_position = hurt_rect.get_center() - rect.get_center()
	var candidates: Array = bullet.call("_get_level_active_monster_candidates")
	print("YIN_DAMAGE_PROBE_SETUP target=%s hp=%d candidates=%d rect=%s hurt=%s attack=%s" % [str(target.global_position), int(target.Hp), candidates.size(), str(rect), str(hurt_rect), str(bullet.AttList)])
	var resolved_debug: = int(target.call("resolve_friendly_damage", 1000, "physics", root))
	var actual_debug: = int(target.call("reduce_pet_hp", resolved_debug, "physics")) if resolved_debug > 0 else 0
	print("YIN_DAMAGE_PROBE_DIRECT resolved=%d actual=%d hp=%d" % [resolved_debug, actual_debug, int(target.Hp)])
	target.set("Hp", 1000000)
	var hp_before: = int(target.Hp)
	bullet.call("_apply_damage")
	await process_frame
	var hp_after: = int(target.Hp)
	print("YIN_DAMAGE_PROBE_RESULT before=%d after=%d rect_intersects=%s" % [hp_before, hp_after, str((Rect2(bullet.global_position + rect.position, rect.size)).intersects(hurt_rect, true))])
	if hp_after >= hp_before:
		push_error("YIN_DAMAGE_PROBE_FAIL no hp change")
		quit(1)
		return
	bullet.queue_free()
	await process_frame
	target.set("Hp", 1000000)
	var pet_scene: = load("res://Scene/Pet/PetYinTigerSummon_4.tscn") as PackedScene
	var pet = pet_scene.instantiate() if pet_scene != null else null
	if pet == null:
		push_error("YIN_DAMAGE_PROBE_FAIL no pet scene")
		quit(1)
		return
	level.add_child(pet)
	await process_frame
	pet.call("apply_pet_data", {
		"类型": "PetYinTiger", "名称": "寅虎大元帅", "名字": "寅虎大元帅", 
		"阶段": 4, "等级": 50, "生命": 1000000, "生命上限": 1000000, 
		"魔法": 1000, "魔法上限": 1000, "攻击": 100, "防御": 0, 
		"物防": 0, "魔防": 0, "魔抗": 0, "暴击": 0, "闪避": 0, 
		"幸运": 0, "回血": 0, "回魔": 0, "悟性": 0, "根骨": 0, 
		"灵力": 0, "技能": ["虎啸", "猛虎下山", "寅虎奥义"], "装备": {}, "出战": true, 
	})
	await process_frame
	target.global_position = Vector2(470, 260)
	pet.global_position = target.global_position - Vector2(120.0, 0.0)
	pet.set("NoGrav", true)
	pet.velocity = Vector2.ZERO
	pet.set("current_target", target)
	pet.call("do_mhxs")
	var skill_attack_data: Dictionary = pet.get("objattackDic").get("hit3", {})
	if str(skill_attack_data.get("attackKind", "")) != "physics":
		push_error("YIN_DAMAGE_PROBE_FAIL skill 2 must use physical damage")
		quit(1)
		return
	var skill_start_position: Vector2 = pet.global_position
	var skill_effect_seen: = false
	var skill_rush_position: = skill_start_position
	var skill_hp_before: = int(target.Hp)
	var pet_resolved_debug: = int(target.call("resolve_friendly_damage", 800, "physics", pet))
	var pet_actual_debug: = int(target.call("reduce_pet_hp", pet_resolved_debug, "physics")) if pet_resolved_debug > 0 else 0
	print("YIN_DAMAGE_PROBE_PET_DIRECT resolved=%d actual=%d hp=%d" % [pet_resolved_debug, pet_actual_debug, int(target.Hp)])
	target.set("Hp", skill_hp_before)
	for _i in range(100):
		await process_frame
		if _i in [0, 5, 10, 15, 20, 30, 40, 60, 80, 99]:
			print("YIN_DAMAGE_PROBE_TICK i=%d action=%s tick=%s attacking=%s" % [_i, str(pet.get("_turtle_action")), str(pet.get("_turtle_action_tick")), str(pet.get("is_attacking"))])
		var action_tick: = int(pet.get("_turtle_action_tick"))
		if action_tick >= 10 and not skill_effect_seen:
			var effects: = pet.get_node("Bullet").get_children()
			for effect in effects:
				if effect.get("skill_name") != "PetYinTiger1Bullet3":
					continue
				skill_effect_seen = true
				var expected_effect_x: = skill_start_position.x + (400.0 if not pet.get("MonsterDirection") else -400.0)
				if absf(effect.global_position.x - expected_effect_x) > 1.0 or absf(effect.global_position.y - (skill_start_position.y - 100.0)) > 1.0:
					push_error("YIN_DAMAGE_PROBE_FAIL skill 2 effect has wrong official offset")
					quit(1)
					return
		if action_tick >= 20 and action_tick <= 28:
			skill_rush_position = pet.global_position
		if _i == 60:
			var spawned: Array = []
			for effect in pet.get_node("Bullet").get_children():
				var effect_rect: Rect2 = effect.call("_current_effect_rect") if effect.has_method("_current_effect_rect") else Rect2()
				var target_rect: Rect2 = effect.call("_target_hurt_rect", target) if effect.has_method("_target_hurt_rect") else Rect2()
				var resolved_effect: = int(effect.call("_pet_tiger_resolve_damage", target, 800, pet, "physics")) if effect.has_method("_pet_tiger_resolve_damage") else -1
				spawned.append({"skill": effect.get("skill_name"), "frame": effect.get_node("middle/BulletANI").frame, "pos": effect.global_position, "rect": effect_rect, "intersects": Rect2(effect.global_position + effect_rect.position, effect_rect.size).intersects(target_rect, true), "resolved": resolved_effect, "att": effect.get("AttList")})
				var hp_before_manual: = int(target.Hp)
				effect.call("_apply_damage")
				print("YIN_DAMAGE_PROBE_MANUAL before=%d after=%d" % [hp_before_manual, int(target.Hp)])
			print("YIN_DAMAGE_PROBE_EFFECTS %s" % str(spawned))
		if _i == 70 and DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			var pair_path: = OS.get_environment("TEMP").path_join("yin_tiger_double_damage.png")
			if root.get_texture().get_image().save_png(pair_path) != OK:
				push_error("YIN_DAMAGE_PROBE_FAIL cannot capture double damage")
				quit(1)
				return
			print("YIN_DOUBLE_DAMAGE_SCREENSHOT " + pair_path)
	var skill_hp_after: = int(target.Hp)
	print("YIN_DAMAGE_PROBE_SKILL before=%d after=%d pet_pos=%s target_pos=%s" % [skill_hp_before, skill_hp_after, str(pet.global_position), str(target.global_position)])
	if skill_hp_after >= skill_hp_before:
		push_error("YIN_DAMAGE_PROBE_FAIL skill path no hp change")
		quit(1)
		return
	if skill_hp_before - skill_hp_after != 2 * int(skill_attack_data["power"]):
		push_error("YIN_DAMAGE_PROBE_FAIL expected two distinct skill damage events")
		quit(1)
		return
	if not skill_effect_seen:
		push_error("YIN_DAMAGE_PROBE_FAIL skill 2 effect was not spawned")
		quit(1)
		return
	if absf(skill_rush_position.x - skill_start_position.x) < 100.0:
		push_error("YIN_DAMAGE_PROBE_FAIL skill 2 rush distance too short")
		quit(1)
		return
	if not await _verify_two_hits(pet, target_scene):
		quit(1)
		return
	if not await _verify_aoyi(pet):
		quit(1)
		return
	print("YIN_DAMAGE_PROBE_OK")
	quit(0)

func _verify_two_hits(pet: Node2D, target_scene: PackedScene) -> bool:
	pet.set_physics_process(false)
	pet.set_process(false)
	for effect in pet.get_node("Bullet").get_children():
		effect.queue_free()
	await process_frame
	var targets: Array[Node2D] = []
	for index in range(3):
		var target: Node2D = target_scene.instantiate()
		pet.get_parent().add_child(target)
		target.set_physics_process(false)
		target.set_process(false)
		for property in ["def", "mdef", "miss"]:
			target.set(property, 0)
		target.set("llrdzs", 1.0)
		target.set("Hp", 1000000)
		target.set("SHp", 1000000)
		target.add_to_group("monsters")
		targets.append(target)
	var original_target: Variant = pet.get("current_target")
	pet.set("current_target", targets[0])
	pet.set("crit", 0)
	for facing_left in [false, true]:
		pet.call("_face_left" if facing_left else "_face_right")
		for attack in ["hit1", "hit2", "hit3"]:
			for cast_index in range(2):
				var attack_data: Dictionary = pet.get("objattackDic")[attack].duplicate(true)
				var expected_interval: = 15 if attack == "hit2" else 10 if attack == "hit3" else 5
				if int(attack_data["attackInterval"]) != expected_interval:
					push_error("YIN_TWO_HITS_FAIL original interval changed")
					return false

				attack_data["attackInterval"] = 6
				var effect_name: = {"hit1": "PetYinTiger1Bullet1", "hit2": "PetYinTiger1Bullet2", "hit3": "PetYinTiger1Bullet3"}
				var effect: Node2D = pet.call("_spawn_yin_effect", effect_name[attack], attack, attack_data, Vector2.ZERO)
				effect.set_physics_process(false)
				var sprite: AnimatedSprite2D = effect.get_node("middle/BulletANI")
				sprite.pause()
				sprite.frame = 3 if attack == "hit1" else 10
				var hit_rect: Rect2 = effect.call("_current_effect_rect")
				for index in range(targets.size()):
					targets[index].global_position = effect.global_position + hit_rect.get_center() + Vector2(index * 5, 0)
					if index == 2:
						targets[index].global_position += Vector2(2000, 2000)
					targets[index].set("Hp", 1000000)
				var hits: = [0, 0, 0]
				var segments: = 1 if attack == "hit1" else 2
				for pulse in range(4):
					var pulse_time: = (10.0 + pulse * 6.0) / 24.0
					effect.set("_elapsed", pulse_time)
					var previous_hp: Array[int] = []
					for target in targets:
						previous_hp.append(int(target.get("Hp")))
					effect.call("_apply_damage")
					for index in range(2):
						if previous_hp[index] - int(targets[index].get("Hp")) != int(attack_data["power"]):
							push_error("YIN_TWO_HITS_FAIL first hit must be one damage event")
							return false
					effect.set("_elapsed", pulse_time + 0.1)
					effect.call("_process_pending_hits")
					for index in range(2):
						if previous_hp[index] - int(targets[index].get("Hp")) != int(attack_data["power"]):
							push_error("YIN_TWO_HITS_FAIL second hit was not delayed")
							return false
					effect.set("_elapsed", pulse_time + 0.13)
					effect.call("_process_pending_hits")
					effect.call("_process_pending_hits")
					for index in range(targets.size()):
						var damage: = previous_hp[index] - int(targets[index].get("Hp"))
						var expected_damage: = segments * int(attack_data["power"]) if index < 2 else 0
						if damage != expected_damage:
							push_error("YIN_TWO_HITS_FAIL action=%s pulse=%d target=%d damage=%d expected=%d" % [attack, pulse, index, damage, expected_damage])
							return false
						if damage > 0:
							hits[index] += segments

					effect.call("_apply_damage")
					for index in range(2):
						if previous_hp[index] - int(targets[index].get("Hp")) != segments * int(attack_data["power"]):
							push_error("YIN_TWO_HITS_FAIL repeated damage in same tick")
							return false
				if hits != [4 * segments, 4 * segments, 0]:
					push_error("YIN_TWO_HITS_FAIL action=%s left=%s cast=%d hits=%s" % [attack, facing_left, cast_index, hits])
					return false
				for index in range(2):
					if 1000000 - int(targets[index].get("Hp")) != 4 * segments * int(attack_data["power"]):
						push_error("YIN_TWO_HITS_FAIL damage per hit changed")
						return false
				print("YIN_TWO_HITS_OK action=%s left=%s cast=%d hits=%s" % [attack, facing_left, cast_index, hits])
				targets[0].set("Hp", int(attack_data["power"]) - 1)
				effect.set("_elapsed", 34.0 / 24.0)
				effect.call("_apply_damage")
				effect.set("_elapsed", 34.0 / 24.0 + 0.13)
				effect.call("_process_pending_hits")
				if int(targets[0].get("Hp")) != -1:
					push_error("YIN_TWO_HITS_FAIL extra damage after target death")
					return false
				effect.queue_free()
				await process_frame
	pet.set("current_target", original_target)
	for target in targets:
		target.queue_free()
	await process_frame
	return true

func _verify_aoyi(pet: Node2D) -> bool:
	pet.set_physics_process(false)
	pet.set_process(false)
	pet.global_position = Vector2(350, 260)
	var target: Node2D = pet.get("current_target")
	target.global_position = Vector2(470, 260)
	var effects: = pet.get_node("Bullet")
	for effect in effects.get_children():
		effect.queue_free()
	await process_frame
	var emitted: Array[String] = []
	effects.child_entered_tree.connect( func(effect: Node): emitted.append(str(effect.get("skill_name"))))
	pet.set("pet_skill_cooldown_multiplier", 1.0)
	pet.set("Mp", 1000)
	pet.set("Skill_1_CD", 5.0)
	pet.set("Skill_2_CD", 7.0)
	var cost: = int(pet.call("_yin_skill_cost", "yhaoyi"))
	pet.call("do_yin_aoyi")
	if not is_equal_approx(float(pet.get("Skill_3_CD")), 30.0):
		push_error("YIN_AOYI_FAIL cooldown must be 30 seconds")
		return false
	for action in ["hit2", "hit3", "hit2", "hit3"]:
		if pet.get("_turtle_action") != action or not pet.get("_aoyi_running"):
			push_error("YIN_AOYI_FAIL expected action " + action)
			return false
		var ticks: = int(pet.call("_turtle_action_total_ticks", action))
		for tick in range(ticks):
			pet.call("_tick_turtle_action", 1.0 / 24.0)
			if DisplayServer.get_name() != "headless":
				await process_frame
				if emitted.size() == 4 and tick == 19:
					await RenderingServer.frame_post_draw
					var capture: = root.get_texture().get_image()
					var path: = OS.get_environment("TEMP").path_join("yin_tiger_aoyi_fourth_skill.png")
					if capture.save_png(path) != OK:
						push_error("YIN_AOYI_FAIL screenshot save failed")
						return false
					print("YIN_AOYI_SCREENSHOT " + path)
	if emitted != ["PetYinTiger1Bullet2", "PetYinTiger1Bullet3", "PetYinTiger1Bullet2", "PetYinTiger1Bullet3"]:
		push_error("YIN_AOYI_FAIL incorrect effect sequence: " + str(emitted))
		return false
	if pet.get("_aoyi_running") or int(pet.get("_aoyi_step")) != 0 or pet.get("is_attacking") or pet.get("_turtle_action") != "":
		push_error("YIN_AOYI_FAIL combo did not finish")
		return false
	if int(pet.get("Mp")) != 1000 - cost or float(pet.get("Skill_1_CD")) != 5.0 or float(pet.get("Skill_2_CD")) != 7.0:
		push_error("YIN_AOYI_FAIL combo charged extra mana or reset skill cooldowns")
		return false
	pet.set("pet_skill_cooldown_multiplier", 0.5)
	pet.call("do_yin_aoyi")
	if not is_equal_approx(float(pet.get("Skill_3_CD")), 15.0):
		push_error("YIN_AOYI_FAIL cooldown reduction changed")
		return false
	pet.call("state_hurt", null)
	pet.call("_tick_turtle_action", 1.0 / 24.0)
	if pet.get("_aoyi_running") or int(pet.get("_aoyi_step")) != 0 or emitted.size() != 4:
		push_error("YIN_AOYI_FAIL interrupted combo continued")
		return false
	print("YIN_AOYI_OK sequence=1,2,1,2 cooldown=30 physical_skill2=true")
	return true
