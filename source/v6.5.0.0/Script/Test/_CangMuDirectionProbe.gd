extends Node

var level: Node
var hero: role4
var monster_root: Node

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	var pd: Dictionary = get_node("/root/PlayerData").get("player_data") as Dictionary
	pd["Myself"] = 4
	pd["玩家等级"] = 90
	pd["技能学习"]["技能11"]["等级"] = 1
	level = (load("res://Scene/Level/Level_1.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(level)
	for _i in range(20): await get_tree().process_frame
	var hero_root: Node = level.get_node_or_null("Hero")
	if hero_root != null:
		for child in hero_root.get_children():
			if child is role4:
				hero = child
				break
	monster_root = level.get_node_or_null("Monster")
	var timer: = level.get_node_or_null("create_control") as Timer
	if timer != null: timer.stop()
	if hero == null or monster_root == null:
		push_error("direction probe setup failed")
		get_tree().quit(1)
		return
	for child in monster_root.get_children():
		if child is BaseMonster: child.queue_free()
	await get_tree().process_frame
	hero.set_process(false)
	hero.set_physics_process(false)
	hero.velocity = Vector2.ZERO
	print("CMLY_DIR_START hero=%s data=%s" % [str(hero.global_position), str(hero.objattackDic.get("cmly", {}))])
	for facing in [true, false]:
		hero.PlayerDir = facing
		hero.action.scale.x = -1.0 if facing else 1.0
		hero.base_damagebox.scale.x = -1.0 if facing else 1.0
		for rel_x in [-1200.0, -800.0, -500.0, -300.0, -150.0, 0.0, 150.0, 300.0, 500.0, 800.0, 1200.0]:
			var target: = (load("res://Scene/Monster/Monster_3008.tscn") as PackedScene).instantiate() as BaseMonster
			monster_root.add_child(target)
			target.global_position = hero.global_position + Vector2(rel_x, 0)
			await get_tree().process_frame
			target.set_process(false)
			target.set_physics_process(false)
			target.miss = 0
			target.def = 0
			target.mdef = 0
			target.level = 90
			target.Hp = 1000000
			target.SHp = 1000000
			target.is_death = false
			target.NoTarget = false
			target.is_boss = false
			target.boss_protect_active = false
			target.IsIndestructible = false
			var effect: = CangMuLongYunEffect.new()
			effect.setup(hero, facing, hero.objattackDic.get("cmly", {}))
			level.add_child(effect)
			var before: = target.Hp
			await get_tree().create_timer(2.0, false).timeout
			print("CMLY_DIR_RESULT facing=%s rel_x=%0.0f hp=%d loss=%d" % [str(facing), rel_x, target.Hp, before - target.Hp])
			if is_instance_valid(target): target.queue_free()
			if is_instance_valid(effect): effect.queue_free()
			await get_tree().process_frame
	get_tree().quit(0)
