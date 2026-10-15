extends Node

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	var pd: Dictionary = (get_node("/root/PlayerData").get("player_data") as Dictionary)
	pd["Myself"] = 4
	pd["玩家等级"] = 90
	pd["技能学习"]["技能11"]["等级"] = 1
	var level: = (load("res://Scene/Level/Level_1.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(level)
	for _i in range(12):
		await get_tree().process_frame
	var hero: role4 = null
	var hero_root: Node = level.get_node_or_null("Hero")
	if hero_root != null:
		for child in hero_root.get_children():
			if child is role4:
				hero = child
				break
	var monster_root: Node = level.get_node_or_null("Monster")
	if hero == null or monster_root == null:
		push_error("probe setup failed")
		get_tree().quit(1)
		return
	var timer: = level.get_node_or_null("create_control") as Timer
	if timer != null: timer.stop()
	for child in monster_root.get_children():
		if child is BaseMonster: child.queue_free()
	await get_tree().process_frame
	var target: = (load("res://Scene/Monster/Monster_3008.tscn") as PackedScene).instantiate() as BaseMonster
	monster_root.add_child(target)
	target.global_position = hero.global_position + Vector2(120, 0)
	await get_tree().process_frame
	target.set_physics_process(false)
	target.miss = 0
	target.def = 0
	target.mdef = 0
	target.Hp = 1000000
	target.SHp = 1000000
	target.is_death = false
	target.NoTarget = false
	target.is_boss = false
	target.boss_protect_active = false
	target.IsIndestructible = false

	print("CMLY_NULL_LLR_SETUP llrdzs=%s hp=%d" % [str(target.llrdzs), target.Hp])
	hero.call("ShovelCMLY")
	await get_tree().create_timer(2.3, false).timeout
	print("CMLY_NULL_LLR_RESULT llrdzs=%s hp=%d" % [str(target.llrdzs), target.Hp])
	get_tree().quit(0)
