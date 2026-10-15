extends Node

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	var pd: Dictionary = get_node("/root/PlayerData").get("player_data") as Dictionary
	pd["Myself"] = 4
	pd["玩家等级"] = 90
	pd["技能学习"]["技能11"]["等级"] = 1
	pd["技能学习"]["技能12"]["等级"] = 1
	pd["技能学习"]["技能键位"]["Y"] = "cmly"
	var level: = (load("res://Scene/Level/Level_1.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(level)
	for _i in range(24):
		await get_tree().process_frame
	var hero: BaseHero = level.get("Role_") as BaseHero
	var monster_root: Node = level.get_node_or_null("Monster")
	var timer: = level.get_node_or_null("create_control") as Timer
	if timer != null:
		timer.stop()
	if hero == null or monster_root == null:
		push_error("get skill setup failed")
		get_tree().quit(1)
		return
	for child in monster_root.get_children():
		if child is BaseMonster:
			child.queue_free()
	await get_tree().process_frame
	hero.set_process(false)
	hero.set_physics_process(false)
	hero.velocity = Vector2.ZERO
	hero.global_position = Vector2(500.0, 350.0)
	hero.PlayerDir = true
	var target: = (load("res://Scene/Monster/Monster_3008.tscn") as PackedScene).instantiate() as BaseMonster
	monster_root.add_child(target)
	target.global_position = hero.global_position + Vector2(120.0, 0.0)
	await get_tree().process_frame
	target.set_process(false)
	target.set_physics_process(false)
	target.miss = 0
	target.def = 0
	target.mdef = 0
	target.level = 90
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
	RoleProp.SourcePlayer = hero
	Global.get_player = hero
	RoleProp.roleprop.Mp = 1000000
	print("CMLY_GET_SETUP hero=%s path=%s parent=%s target=%s mp=%s need=%s cooldown=%s" % [str(hero.global_position), str(hero.get_path()), str(hero.get_parent().get_parent()), str(target.global_position), str(RoleProp.roleprop.Mp), str(hero.get_need_mp("cmly", false)), str(hero.Role1SkillInter.get("cmly"))])
	var before: = int(target.Hp)
	hero.get_skill("cmly")
	print("CMLY_GET_AFTER_CALL action=%s using=%s attacking=%s cooldown=%s children=%d hit=%s" % [str(hero.get_action), str(hero.is_using_skills), str(hero.is_attacking), str(hero.Role1SkillInter.get("cmly")), level.get_child_count(), str(hero.HitDic)])
	for frame in range(150):
		await get_tree().process_frame
		if frame % 10 == 0:
			var effects: = 0
			for child in level.get_children():
				if child is CangMuLongYunEffect:
					effects += 1
			print("CMLY_GET_FRAME f=%d hp=%d effects=%d cooldown=%s action=%s using=%s" % [frame, target.Hp, effects, str(hero.Role1SkillInter.get("cmly")), str(hero.get_action), str(hero.is_using_skills)])
	print("CMLY_GET_RESULT before=%d after=%d loss=%d" % [before, target.Hp, before - target.Hp])
	get_tree().quit(0)
