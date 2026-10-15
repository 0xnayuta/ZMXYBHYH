extends Node2D

const CAVE_MONSTERS: = [3198, 3199, 3200, 3201]
const FLYING_MONSTERS: = {3198: true, 3200: true, 3201: true}
const HERO_POSITION: = Vector2(540.0, 365.5)


class LevelHost:
	extends Node2D

	var monster_blood: Node2D
	var fall_it: Node2D

	func get_level_monster_config(monster_id: int) -> Dictionary:
		var boss: = monster_id == 3200
		return {
			"name": "蝙蝠窟怪物", "level": 90, 
			"hp": 52000000 if boss else 7200000, 
			"attack": 68000 if boss else 34000, 
			"def": 9800 if boss else 1800, "mdef": 9800 if boss else 1800, 
			"crit": 0, "miss": 0, "hit": 900, 
			"armor_break": 3500, "magic_break": 3500, 
			"speed": 10.0 if boss else 12.0, 
			"range": 320.0 if boss else 190.0, "sight": 1200.0 if boss else 900.0, 
			"is_boss": boss, "is_flying": FLYING_MONSTERS.has(monster_id), 
		}


class DamageProbeHero:
	extends BaseHero

	func _ready() -> void :
		pass

	func _physics_process(_delta: float) -> void :
		pass

	func _add_role_hit_effect_throttled() -> void :
		pass

	func _pet_turtle_link_unit() -> Node:
		return null


func _ready() -> void :
	call_deferred("_run")


func _run() -> void :
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	MainSet.set_data["NoShowMonsterBody"] = true

	var host: = LevelHost.new()
	host.monster_blood = Node2D.new()
	host.monster_blood.name = "monster_blood"
	host.add_child(host.monster_blood)
	host.fall_it = Node2D.new()
	host.fall_it.name = "fall_it"
	host.add_child(host.fall_it)
	host.add_to_group("BaseLevel")
	add_child(host)

	var role_container: = Node2D.new()
	role_container.name = "Role"
	host.add_child(role_container)
	var hero: = _create_damage_probe_hero()
	hero.position = HERO_POSITION
	role_container.add_child(hero)
	RoleProp.SourcePlayer = hero
	RoleProp.baseroleprop.Level = 90
	RoleProp.roleprop.SHp = 1000000
	RoleProp.roleprop.Hp = 1000000
	RoleProp.roleprop.Miss = 0
	RoleProp.roleprop.CritReduce = 1000000
	RoleProp.roleprop.Toughness = 1000000
	RoleProp.roleprop.Def = 0
	RoleProp.roleprop.Mdef = 0

	var results: Array[String] = []
	for monster_id: int in CAVE_MONSTERS:
		hero.position = HERO_POSITION
		RoleProp.role_pos = HERO_POSITION
		RoleProp.role_pos_x = HERO_POSITION.x
		RoleProp.role_pos_y = HERO_POSITION.y
		RoleProp.roleprop.Hp = 1000000
		var scene: = load("res://Scene/Monster/Monster_%d.tscn" % monster_id) as PackedScene
		var monster: = scene.instantiate() as EastContinentMonster if scene != null else null
		if monster == null:
			_fail("monster %d scene" % monster_id)
			return
		monster.position = _spawn_position(monster_id)
		host.add_child(monster)
		await get_tree().process_frame
		await get_tree().physics_frame
		if FLYING_MONSTERS.has(monster_id) and monster._fixed_flight_height_ready:
			_fail("flying monster %d height is locked" % monster_id)
			return
		if monster_id == 3199:

			monster.NoGrav = true
			monster.velocity.y = 0.0

		var hp_before: = int(RoleProp.roleprop.Hp)
		var saw_attack: = false
		var saw_enabled_box: = false
		var deadline: = Time.get_ticks_msec() + 7000
		while Time.get_ticks_msec() < deadline and int(RoleProp.roleprop.Hp) >= hp_before:
			await get_tree().physics_frame
			saw_attack = saw_attack or monster.is_attacking
			saw_enabled_box = saw_enabled_box or (monster.hit_box != null and not monster.hit_box.disabled)
		var hp_after: = int(RoleProp.roleprop.Hp)
		if hp_after >= hp_before:
			_fail("monster %d did not damage real hero shape pos=%s attack=%s box=%s" % [
				monster_id, monster.global_position, saw_attack, saw_enabled_box, 
			])
			return
		results.append("%d:%d" % [monster_id, hp_before - hp_after])
		monster.queue_free()
		await get_tree().process_frame

	print("BAT_CAVE_COMBAT_OK " + ",".join(results))
	get_tree().quit(0)


func _spawn_position(monster_id: int) -> Vector2:
	match monster_id:
		3198: return Vector2(500.0, 300.0)
		3199: return Vector2(700.0, 405.5)
		3200: return Vector2(780.0, 300.0)
		3201: return Vector2(620.0, 300.0)
	return Vector2(600.0, 300.0)


func _create_damage_probe_hero() -> DamageProbeHero:
	var hero: = DamageProbeHero.new()
	hero.name = "DamageProbeHero"
	hero.add_child(_named_node(Timer.new(), "ZhenFa"))
	hero.add_child(_named_node(AnimationPlayer.new(), "RolePlayer"))
	hero.add_child(_named_node(Node2D.new(), "Damage_Text"))
	hero.add_child(_named_node(CollisionShape2D.new(), "pz"))
	hero.add_child(_named_node(Timer.new(), "WSTimer"))
	hero.add_child(_named_node(Node2D.new(), "MagicWeapon"))
	hero.add_child(_named_node(Label.new(), "Name_"))
	hero.add_child(_named_node(Node2D.new(), "Bullet"))
	hero.add_child(_named_node(Node.new(), "Buff"))
	hero.add_child(_named_node(AnimatedSprite2D.new(), "tx"))

	var action: = _named_node(Node2D.new(), "Action") as Node2D
	hero.add_child(action)
	action.add_child(_named_node(Sprite2D.new(), "RoleBody"))
	action.add_child(_named_node(Sprite2D.new(), "RoleEquipment"))
	action.add_child(_named_node(AnimatedSprite2D.new(), "Wings"))
	var effect_body: = _named_node(Node2D.new(), "EffectBody") as Node2D
	action.add_child(effect_body)
	for part_name in ["toukui", "jianjia", "huwan", "shenti", "yaodai", "xiabai", "wuqi"]:
		effect_body.add_child(_named_node(AnimatedSprite2D.new(), part_name))

	var damage_box: = _named_node(Node2D.new(), "base_damagebox") as Node2D
	damage_box.position = Vector2(0.0, -30.0)
	hero.add_child(damage_box)
	var hurt_area: = _named_node(Area2D.new(), "HurtBox") as Area2D
	hurt_area.collision_layer = 128
	hurt_area.collision_mask = 4
	damage_box.add_child(hurt_area)
	var hurt_shape: = _named_node(CollisionShape2D.new(), "HurtBox") as CollisionShape2D
	hurt_shape.position = Vector2(0.0, 25.0)
	var capsule: = CapsuleShape2D.new()
	capsule.radius = 20.0
	capsule.height = 98.0
	hurt_shape.shape = capsule
	hurt_area.add_child(hurt_shape)
	hurt_area.area_entered.connect(hero._on_hurt_box_area_entered)
	return hero


func _named_node(node: Node, node_name: String) -> Node:
	node.name = node_name
	return node


func _fail(reason: String) -> void :
	push_error("BAT_CAVE_COMBAT_FAIL %s" % reason)
	get_tree().quit(1)
