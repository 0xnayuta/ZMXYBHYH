extends Node2D

var monster: Node2D
var _active: Array[BaseMonster] = []
var lj_tt: Node2D
var monster_blood: Node2D
var fall_it: Node2D

func has_active_monster_index() -> bool:
	return true

func get_active_monsters() -> Array[BaseMonster]:
	var result: Array[BaseMonster] = []
	for target in _active:
		if target != null and is_instance_valid(target) and target.is_inside_tree() and target.Hp > 0:
			result.append(target)
	return result

func _ready() -> void :
	add_to_group("BaseLevel")
	lj_tt = Node2D.new()
	lj_tt.name = "lj_tt"
	add_child(lj_tt)
	monster_blood = Node2D.new()
	monster_blood.name = "monster_blood"
	add_child(monster_blood)
	fall_it = Node2D.new()
	fall_it.name = "fall_it"
	add_child(fall_it)
	call_deferred("_run")

func _run() -> void :
	print("CMLY_FULL_START")
	PlayerData.player_data["Myself"] = 4
	PlayerData.player_data["玩家等级"] = 90
	PlayerData.player_data["技能学习"]["技能11"]["等级"] = 1
	PlayerData.player_data["技能学习"]["技能12"]["等级"] = 1
	var hero_scene: = load("res://Scene/Hero/Role_4/Role_4.tscn") as PackedScene
	var hero: = hero_scene.instantiate() as role4
	if hero == null:
		push_error("CMLY_FULL_FAIL hero")
		get_tree().quit(1)
		return
	hero.global_position = Vector2(500, 350)
	add_child(hero)
	await get_tree().process_frame
	await get_tree().process_frame
	print("CMLY_FULL_HERO type=%s power=%s cmly=%s hit=%s" % [str(hero), str(RoleProp.roleprop.power), str(hero.objattackDic.get("cmly", {})), str(hero.HitDic)])

	var monster_scene: = load("res://Scene/Monster/Monster_3008.tscn") as PackedScene
	var target: = monster_scene.instantiate() as BaseMonster
	if target == null:
		push_error("CMLY_FULL_FAIL target")
		get_tree().quit(1)
		return
	target.global_position = hero.global_position + Vector2(120, 0)
	add_child(target)
	_active.append(target)
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
	print("CMLY_FULL_TARGET type=%s hp=%s class=%s pos=%s" % [str(target), str(target.Hp), str(target.get_script()), str(target.global_position)])

	var effect: = CangMuLongYunEffect.new()
	effect.setup(hero, true, hero.objattackDic["cmly"])
	add_child(effect)
	var hp_before: = int(target.Hp)
	await get_tree().create_timer(2.2, false).timeout
	print("CMLY_FULL_RESULT before=%d after=%d total=%d effect_valid=%s cached=%d spine=%s" % [hp_before, int(target.Hp), int(target.total_hurt), str(is_instance_valid(effect)), (effect.get("_cached_targets") as Array).size() if is_instance_valid(effect) else -1, str(effect.get("_spine")) if is_instance_valid(effect) else "freed"])
	get_tree().quit(0)
