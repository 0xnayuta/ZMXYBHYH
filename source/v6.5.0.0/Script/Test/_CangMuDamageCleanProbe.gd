extends SceneTree

class ProbeMonster:
	extends BaseMonster
	func _ready() -> void :
		pass

class ProbeEffect:
	extends CangMuLongYunEffect
	var hit_count: = 0
	var hit_targets: Array[int] = []
	var probe_targets: Array[BaseMonster] = []

	func _is_valid_target(_target: Node) -> bool:
		return true

	func _apply_hit(target: BaseMonster) -> void :
		hit_count += 1
		hit_targets.append(target.get_instance_id())

	func _cache_targets() -> void :
		_cached_targets.clear()
		for target in probe_targets:
			_cached_targets.append(target)

func _init() -> void :
	call_deferred("_run")

func _run() -> void :
	print("CMLY_CLEAN_START")
	var world: = Node2D.new()
	root.add_child(world)
	var owner: = Node2D.new()
	owner.global_position = Vector2(600.0, 420.0)
	world.add_child(owner)
	var front: = ProbeMonster.new()
	front.global_position = owner.global_position + Vector2(-180.0, 0.0)
	var rear: = ProbeMonster.new()
	rear.global_position = owner.global_position + Vector2(180.0, 0.0)
	var effect: = ProbeEffect.new()
	effect.probe_targets = [front, rear]
	effect.setup(owner, true, {"power": 10000.0, "attackKind": "magic", "WSValue": 4})
	world.add_child(effect)
	for _frame in range(150):
		await process_frame
	print("CMLY_CLEAN_RESULT hits=%d targets=%d head_dir=%s" % [effect.hit_count, effect.hit_targets.size(), effect.get("_head_sweep_direction")])
	quit(0)
