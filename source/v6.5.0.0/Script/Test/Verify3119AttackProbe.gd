extends Node



const MONSTER_SCENE: = "res://Scene/Monster/Monster_3119.tscn"
const OBSERVE_FRAMES: = 300


const SCENARIOS: = [
	{"name": "same_height", "spawn": Vector2(300.0, 300.0), "target": Vector2(400.0, 300.0)}, 
	{"name": "high_above_hero", "spawn": Vector2(2006.0, 301.0), "target": Vector2(2106.0, 445.0)}, 


	{"name": "far_above_hero", "spawn": Vector2(2006.0, 100.0), "target": Vector2(2106.0, 445.0)}, 


	{"name": "below_hero", "spawn": Vector2(2006.0, 600.0), "target": Vector2(2106.0, 445.0)}, 
]

var _attack_started: = false

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	MainSet.set_data["NoShowMonsterBody"] = false
	MainSet.set_data["MonsterDamageSHow"] = false
	RoleProp.SourcePlayer = null

	var all_ok: = true
	for scenario: Dictionary in SCENARIOS:
		var ok: = await _run_scenario(scenario)
		all_ok = all_ok and ok
	print("PROBE OVERALL=", "ATTACKS" if all_ok else "NO_ATTACK")
	get_tree().quit(0 if all_ok else 1)

func _run_scenario(scenario: Dictionary) -> bool:
	var spawn: Vector2 = scenario["spawn"]
	var target: Vector2 = scenario["target"]

	var packed: PackedScene = load(MONSTER_SCENE)
	if packed == null:
		print("PROBE FAIL: cannot load ", MONSTER_SCENE)
		return false
	var monster: Node = packed.instantiate()
	monster.position = spawn
	add_child(monster)
	RoleProp.role_pos = target

	var player: AnimationPlayer = monster.get("mr_player") as AnimationPlayer
	var hit_box: CollisionShape2D = monster.get("hit_box") as CollisionShape2D

	var attack_frames: = 0
	var longest_run: = 0
	var current_run: = 0
	var hit_box_enabled: = false
	_attack_started = false
	var anim_started: = func(anim_name: StringName) -> void :
		if anim_name == &"hit1":
			_attack_started = true
	player.animation_started.connect(anim_started)

	for _frame in range(OBSERVE_FRAMES):
		await get_tree().physics_frame
		if String(player.current_animation) == "hit1":
			attack_frames += 1
			current_run += 1
			longest_run = maxi(longest_run, current_run)
		else:
			current_run = 0
		if hit_box != null and not hit_box.disabled:
			hit_box_enabled = true

	var attack_count: = int(monster.get("_attack_serial"))
	var tip: String = str(scenario["name"])
	print("PROBE[%s] range=%.1f vertical=%.1f" % [tip, 
		float(monster.get("_effective_attack_range")), 
		float(monster.get("_effective_attack_vertical_range"))])
	print("PROBE[%s] attack_started=%s frames=%d longest_run=%d attacks_started=%d hit_box=%s pos=%s" % [
		tip, str(_attack_started), attack_frames, longest_run, attack_count, 
		str(hit_box_enabled), str(monster.global_position)])
	var ok: = _attack_started and attack_count > 0 and longest_run >= 30 and hit_box_enabled
	print("PROBE[%s] RESULT=%s" % [tip, "ATTACKS" if ok else "NO_ATTACK"])
	monster.queue_free()
	await get_tree().process_frame
	return ok
