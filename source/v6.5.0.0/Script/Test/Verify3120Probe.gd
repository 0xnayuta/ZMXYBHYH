extends Node


const MONSTER_SCENE: = "res://Scene/Monster/Monster_3120.tscn"
const OBSERVE_FRAMES: = 1800

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	MainSet.set_data["NoShowMonsterBody"] = false
	RoleProp.SourcePlayer = null
	var ok: = await _run_scenario()
	print("PROBE OVERALL=", "OK" if ok else "REGRESSION")
	get_tree().quit(0 if ok else 1)

func _run_scenario() -> bool:
	var spawn: = Vector2(400.0, 445.0)
	var target: = Vector2(420.0, 445.0)
	var packed: PackedScene = load(MONSTER_SCENE)
	var monster: Node = packed.instantiate()
	monster.position = spawn
	add_child(monster)
	RoleProp.role_pos = target

	var player: AnimationPlayer = monster.get("mr_player") as AnimationPlayer
	var mr_ani: AnimatedSprite2D = monster.get("mr_ani") as AnimatedSprite2D
	var bullet_node: Node = monster.get("bullet")
	var seen_attacks: = {}
	var projectiles_spawned: = 0
	var stone_seen: = false
	var dust_seen: = false
	var wind_seen: = false
	var whirlwind_seen: = false
	var sprite_y_history: = []
	var max_sprite_y_drift: = 0.0

	for f in range(OBSERVE_FRAMES):
		await get_tree().physics_frame
		var cur: = String(player.current_animation)
		if cur.begins_with("hit"):
			seen_attacks[cur] = true
		var sprite_y: = mr_ani.position.y
		sprite_y_history.append(sprite_y)
		var expected_sprite_y: = -55.0
		if cur == "hit1":
			expected_sprite_y = -87.0
		elif cur == "hit2":
			expected_sprite_y = -71.0
		if absf(sprite_y - expected_sprite_y) > max_sprite_y_drift:
			max_sprite_y_drift = absf(sprite_y - expected_sprite_y)
		var children: = bullet_node.get_children()
		projectiles_spawned = maxi(projectiles_spawned, children.size())
		for child in children:
			var name: = str(child.get("skill_name"))
			if name == "SandBossStoneThrow":
				stone_seen = true
			elif name == "SandBossStoneImpact":
				dust_seen = true
			elif name == "SandBossWindBlade":
				wind_seen = true
			elif name.begins_with("SandBossWhirlwind"):
				whirlwind_seen = true
		if f % 120 == 0:
			print("PROBE frame=%d pos=%s cur=%s proj=%d" % [
				f, str(monster.global_position), cur, children.size()])
	print("PROBE RESULT attacks=%s wind=%s stone=%s dust=%s whirlwind=%s max_sprite_drift=%.2f max_projs=%d" % [
		str(seen_attacks.keys()), str(wind_seen), str(stone_seen), str(dust_seen), 
		str(whirlwind_seen), max_sprite_y_drift, projectiles_spawned])
	monster.queue_free()
	await get_tree().process_frame
	var ok: = seen_attacks.has("hit1") and seen_attacks.has("hit2")\
	and wind_seen and stone_seen and dust_seen and not whirlwind_seen\
	and max_sprite_y_drift < 1.0
	return ok
