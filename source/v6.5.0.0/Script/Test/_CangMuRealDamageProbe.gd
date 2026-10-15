extends Node

const LEVEL_SCENE: = preload("res://Scene/Level/Level_1.tscn")
const MONSTER_SCENE: = preload("res://Scene/Monster/Monster_1.tscn")
const EFFECT_SCRIPT: = preload("res://Script/Hero/CangMuLongYunEffect.gd")

var level: Node
var hero: BaseHero
var monster: BaseMonster

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	print("CMLY_REAL_START")
	var skill_data: Variant = PlayerData.player_data.get("技能学习", {})
	if skill_data is Dictionary:
		var skill_map: Dictionary = skill_data
		if skill_map.has("技能12") and skill_map["技能12"] is Dictionary:
			skill_map["技能12"]["等级"] = 1
	PlayerData.player_data["Myself"] = 4
	Global.Is_Show = true
	level = LEVEL_SCENE.instantiate()
	add_child(level)
	for frame in range(180):
		await get_tree().process_frame
		hero = level.get("Role_") as BaseHero
		if hero != null and is_instance_valid(hero):
			print("CMLY_REAL_HERO frame=%d pos=%s class=%s" % [frame, hero.global_position, hero.get_class()])
			break
	if hero == null:
		push_error("CMLY_REAL_FAIL hero")
		get_tree().quit(1)
		return
	if level.get("create_control") != null:
		level.get("create_control").stop()
	hero.set_process(false)
	hero.set_physics_process(false)
	hero.velocity = Vector2.ZERO
	hero.global_position = Vector2(500.0, 350.0)
	Global.get_player = hero
	RoleProp.SourcePlayer = hero
	RoleProp.baseroleprop.Level = 90
	RoleProp.baseroleprop.SHp = 1000000
	RoleProp.roleprop.SHp = 1000000
	RoleProp.roleprop.Hp = 1000000
	RoleProp.roleprop.Miss = 0
	RoleProp.roleprop.Def = 0
	RoleProp.roleprop.Mdef = 0
	RoleProp.roleprop.power = 1000
	hero.onEqchange()
	hero.set_process(false)
	hero.set_physics_process(false)

	var monster_root: Node = level.get("monster") as Node
	if monster_root == null:
		push_error("CMLY_REAL_FAIL monster root")
		get_tree().quit(1)
		return
	for child in monster_root.get_children():
		child.queue_free()
	await get_tree().process_frame
	monster = MONSTER_SCENE.instantiate() as BaseMonster
	monster_root.add_child(monster)
	monster.global_position = Vector2(720.0, 350.0)
	await get_tree().process_frame
	monster.set_process(false)
	monster.set_physics_process(false)
	monster.Hp = 1000000
	monster.SHp = 1000000
	monster.level = 90
	monster.miss = 0
	monster.def = 0
	monster.mdef = 0
	monster.ar = 0
	monster.sp = 0
	monster.NoTarget = false
	monster.boss_protect_active = false
	monster.is_death = false
	print("CMLY_REAL_SETUP hero=%s monster=%s hp=%d active_ready=%s active_count=%d data=%s" % [hero.global_position, monster.global_position, monster.Hp, level.has_method("has_active_monster_index") and level.has_active_monster_index(), level.get_active_monsters().size() if level.has_method("get_active_monsters") else -1, hero.objattackDic.get("cmly", {})])
	var effect: = EFFECT_SCRIPT.new()
	effect.setup(hero, true, hero.objattackDic.get("cmly", {}))
	level.add_child(effect)
	var hp_before: = monster.Hp
	var hit_before: = Global.TotalRoleHit
	print("CMLY_REAL_PRECALL valid=%s raw=%s" % [str(effect.call("_is_valid_target", monster)), str(monster.get_Role_last_hurt(hero))])
	for frame in range(150):
		await get_tree().process_frame
		if frame % 10 == 0:
			var cached: Variant = effect.get("_cached_targets")
			print("CMLY_REAL_FRAME=%d hp=%d cached=%d reach=%s dir=%s effect=%s" % [frame, monster.Hp, cached.size() if cached is Array else -1, effect.call("_get_head_forward_reach", effect.get("_spine").get_skeleton()) if effect.get("_spine") != null and effect.get("_spine").get_skeleton() != null else -1, effect.get("_head_sweep_direction"), is_instance_valid(effect)])
	print("CMLY_REAL_RESULT hp_before=%d hp_after=%d loss=%d role_hits=%d monster_miss=%s" % [hp_before, monster.Hp, hp_before - monster.Hp, Global.TotalRoleHit - hit_before, monster.is_miss])
	get_tree().quit(0 if monster.Hp < hp_before else 2)
