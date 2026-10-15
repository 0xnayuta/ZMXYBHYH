extends Node

const LEVEL_SCENE: = preload("res://Scene/Level/Level_69.tscn")
const MONSTER_IDS: = [3198, 3199, 3200, 3201]


class TurtleLinkProbe:
	extends Node

	var Hp: = 1


func _ready() -> void :
	call_deferred("_run")


func _run() -> void :
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	MainSet.set_data["NoShowMonsterBody"] = true
	var level: = LEVEL_SCENE.instantiate() as Game4EastLateLevel
	if level == null:
		_fail("level 69 scene")
		return
	add_child(level)
	await get_tree().create_timer(0.8).timeout
	var hero: = level.Role_ as BaseHero
	if hero == null or not is_instance_valid(hero):
		_fail("runtime hero")
		return
	var hurt_shape: = hero.get_node_or_null("base_damagebox/HurtBox/HurtBox") as CollisionShape2D
	if hurt_shape == null or not hurt_shape.shape is CapsuleShape2D:
		_fail("runtime hero HurtBox")
		return

	hero.set_physics_process(false)
	hero.set_process(false)
	hero.SXYRCannotCure = true
	var turtle_link_probe: = TurtleLinkProbe.new()
	add_child(turtle_link_probe)
	hero.set_meta("pet_turtle_link_unit_ref", weakref(turtle_link_probe))
	hero.set_meta("pet_turtle_link_until_msec", Time.get_ticks_msec() + 600000)
	hero.set_meta("pet_turtle_link_percent", 0)
	RoleProp.baseroleprop.Level = 90
	RoleProp.baseroleprop.SHp = 10000000
	RoleProp.roleprop.SHp = 10000000
	RoleProp.roleprop.Miss = 0
	RoleProp.roleprop.CritReduce = 1000000
	RoleProp.roleprop.Toughness = 1000000
	RoleProp.roleprop.Def = 0
	RoleProp.roleprop.Mdef = 0
	var results: Array[String] = []
	for monster_id: int in MONSTER_IDS:
		RoleProp.roleprop.Hp = 10000000
		RoleProp.roleprop.SHp = 10000000
		RoleProp.role_pos = hero.global_position
		RoleProp.role_pos_x = hero.global_position.x
		RoleProp.role_pos_y = hero.global_position.y
		hero.needProtect = false
		hero.IsSuperArmor = true
		hero.velocity = Vector2.ZERO
		var hero_position: = hero.global_position
		var spawn_position: = _spawn_position(monster_id, hero_position)
		var monster: = Global.Create_Monster(monster_id, level.monster, spawn_position) as EastContinentMonster
		if monster == null:
			_fail("spawn monster %d" % monster_id)
			return
		var hp_before: = int(RoleProp.roleprop.Hp)
		var deadline: = Time.get_ticks_msec() + 8000
		while Time.get_ticks_msec() < deadline and int(RoleProp.roleprop.Hp) >= hp_before:
			await get_tree().physics_frame
		var hp_after: = int(RoleProp.roleprop.Hp)
		if hp_after >= hp_before:
			_fail("monster %d missed runtime hero monster_pos=%s hero_pos=%s action=%s" % [
				monster_id, monster.global_position, hero.global_position, monster.hit_name, 
			])
			return
		await get_tree().process_frame
		var screenshot_path: = ProjectSettings.globalize_path(
			"res://.tmp/bat_cave_combat_%d.png" % monster_id
		)
		DirAccess.make_dir_recursive_absolute(screenshot_path.get_base_dir())
		var image: = get_viewport().get_texture().get_image()
		if image == null or image.save_png(screenshot_path) != OK:
			_fail("monster %d screenshot" % monster_id)
			return
		results.append("%d:%d@y%.1f" % [
			monster_id, hp_before - hp_after, monster.global_position.y, 
		])
		monster.queue_free()
		await get_tree().process_frame

	print("BAT_CAVE_LEVEL_COMBAT_OK hero=%s " % hero.global_position + ",".join(results))
	get_tree().quit(0)


func _spawn_position(monster_id: int, hero_position: Vector2) -> Vector2:
	match monster_id:
		3198: return Vector2(hero_position.x + 40.0, 300.0)
		3199: return Vector2(hero_position.x + 160.0, 448.0)
		3200: return Vector2(hero_position.x + 240.0, 300.0)
		3201: return Vector2(hero_position.x + 80.0, 300.0)
	return Vector2(hero_position.x + 100.0, 300.0)


func _fail(reason: String) -> void :
	push_error("BAT_CAVE_LEVEL_COMBAT_FAIL %s" % reason)
	get_tree().quit(1)
