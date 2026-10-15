extends Node

func _init() -> void :
	call_deferred("_run")

func _run() -> void :
	print("CMLY_LEVEL_START")
	var player_data_node: Node = get_node("/root/PlayerData")
	var player_data: Dictionary = player_data_node.get("player_data") as Dictionary
	player_data["Myself"] = 4
	player_data["玩家等级"] = 90
	player_data["技能学习"]["技能11"]["等级"] = 1
	player_data["技能学习"]["技能12"]["等级"] = 1
	var level_scene: = load("res://Scene/Level/Level_1.tscn") as PackedScene
	var level: = level_scene.instantiate()
	get_tree().root.add_child(level)
	for _i in range(12):
		await get_tree().process_frame
	var hero: role4 = null
	var hero_root: = level.get_node_or_null("Hero") as Node
	if hero_root != null:
		for child in hero_root.get_children():
			if child is role4:
				hero = child as role4
				break
	print("CMLY_LEVEL_HERO hero=%s children=%d" % [str(hero), hero_root.get_child_count() if hero_root != null else -1])
	if hero == null:
		push_error("CMLY_LEVEL_FAIL hero")
		get_tree().quit(1)
		return
	var create_control: Timer = level.get_node_or_null("create_control") as Timer
	if create_control != null:
		create_control.stop()
	var monster_root: = level.get_node_or_null("Monster") as Node
	if monster_root == null:
		push_error("CMLY_LEVEL_FAIL monster root")
		get_tree().quit(1)
		return
	for child in monster_root.get_children():
		if child is BaseMonster:
			child.queue_free()
		await get_tree().process_frame
	var monster_scene: = load("res://Scene/Monster/Monster_3008.tscn") as PackedScene
	var target: = monster_scene.instantiate() as BaseMonster
	target.global_position = hero.global_position + Vector2(120, 0)
	monster_root.add_child(target)
	await get_tree().process_frame
	await get_tree().process_frame
	target.set_physics_process(false)
	target.miss = 0
	target.def = 0
	target.mdef = 0
	target.Hp = 1000000
	target.SHp = 1000000
	target.hd = 0
	target.max_hd = 0
	target.is_death = false
	target.NoTarget = false
	target.is_boss = false
	target.boss_protect_active = false
	target.IsIndestructible = false
	target.llrdzs = 1.0
	hero.action.scale.x = -1
	hero.base_damagebox.scale.x = -1
	hero.PlayerDir = true
	var hp_before: = int(target.Hp)
	print("CMLY_LEVEL_SETUP hero_pos=%s dir=%s target_pos=%s active=%s cmly=%s" % [str(hero.global_position), str(hero.PlayerDir), str(target.global_position), str(level.get_active_monsters()), str(hero.objattackDic.get("cmly", {}))])
	hero.call("ShovelCMLY")
	await get_tree().create_timer(2.3, false).timeout
	print("CMLY_LEVEL_RESULT before=%d after=%d total=%d active=%s" % [hp_before, int(target.Hp), int(target.total_hurt), str(level.get_active_monsters())])
	get_tree().quit(0)
