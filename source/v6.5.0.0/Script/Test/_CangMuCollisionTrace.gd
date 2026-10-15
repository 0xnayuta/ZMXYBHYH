extends Node

class TraceEffect:
	extends CangMuLongYunEffect
	var label: = ""
	func _apply_hit(target: BaseMonster) -> void :
		print("CMLY_TRACE_HIT label=%s face=%s dir=%s effect=%s target=%s rel=%0.1f" % [label, str(face_right), str(_head_sweep_direction), str(global_position), str(target.global_position), target.global_position.x - global_position.x])

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	var pd: Dictionary = get_node("/root/PlayerData").get("player_data") as Dictionary
	pd["Myself"] = 4
	pd["玩家等级"] = 90
	pd["技能学习"]["技能11"]["等级"] = 1
	var level: = (load("res://Scene/Level/Level_1.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(level)
	for _i in range(20): await get_tree().process_frame
	var hero: role4 = null
	var hero_root: Node = level.get_node_or_null("Hero")
	if hero_root != null:
		for child in hero_root.get_children():
			if child is role4: hero = child;break
	var monster_root: Node = level.get_node_or_null("Monster")
	var timer: = level.get_node_or_null("create_control") as Timer
	if timer != null: timer.stop()
	if hero == null or monster_root == null:
		push_error("trace setup failed");get_tree().quit(1);return
	for child in monster_root.get_children():
		if child is BaseMonster: child.queue_free()
	await get_tree().process_frame
	hero.set_process(false);hero.set_physics_process(false)
	hero.global_position = Vector2(600, 420)
	print("CMLY_TRACE_START hero=%s" % str(hero.global_position))
	for facing in [true, false]:
		hero.PlayerDir = facing
		for rel_x in [-800.0, -300.0, 0.0, 300.0, 800.0]:
			var target: = (load("res://Scene/Monster/Monster_3008.tscn") as PackedScene).instantiate() as BaseMonster
			monster_root.add_child(target)
			target.global_position = hero.global_position + Vector2(rel_x, 0)
			await get_tree().process_frame
			target.set_process(false);target.set_physics_process(false)
			target.miss = 0;target.def = 0;target.mdef = 0;target.level = 90
			target.Hp = 1000000;target.SHp = 1000000;target.is_death = false;target.NoTarget = false
			target.is_boss = false;target.boss_protect_active = false;target.IsIndestructible = false
			var effect: = TraceEffect.new()
			effect.label = "%s/%s" % [str(facing), str(rel_x)]
			effect.setup(hero, facing, hero.objattackDic.get("cmly", {}))
			level.add_child(effect)
			await get_tree().create_timer(1.9, false).timeout
			if is_instance_valid(effect): effect.queue_free()
			if is_instance_valid(target): target.queue_free()
			await get_tree().process_frame
	get_tree().quit(0)
