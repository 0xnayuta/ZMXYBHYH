extends Node2D

const MONSTER_SCENE: = preload("res://Scene/Monster/EastContinentMonster.tscn")

var _failed: = false


class ProbeHero:
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
	RoleProp.set_physics_process(false)
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	MainSet.set_data["NoShowMonsterBody"] = true
	_add_floor(540.0)
	var hero: = _create_hero()
	add_child(hero)
	Global.get_player = hero
	RoleProp.SourcePlayer = hero
	RoleProp.baseroleprop.Level = 90
	RoleProp.roleprop.SHp = 100000000
	RoleProp.roleprop.Def = 0
	RoleProp.roleprop.Mdef = 0
	RoleProp.roleprop.Miss = 0
	RoleProp.roleprop.CritReduce = 1000000
	RoleProp.roleprop.Toughness = 1000000

	await _probe_white_ape_effect2(hero)
	await _probe_white_ape_dash(hero)
	await _probe_six_ear_fire_dash(hero)
	await _probe_six_ear_fire_slash(hero)
	if not _failed:
		print("EAST_EARLY_BOSS_DAMAGE_DASH_PROBE_OK")
	get_tree().quit(1 if _failed else 0)


func _probe_white_ape_effect2(hero: ProbeHero) -> void :
	var monster: = await _spawn_monster(3161, Vector2(180.0, 540.0))
	_reset_hero(hero, Vector2(420.0, 540.0))
	monster.MonsterDirection = true
	monster._attack_serial = 1
	var hp_before: = int(RoleProp.roleprop.Hp)
	monster._start_3161_effect2(1)
	await get_tree().create_timer(0.9, false).timeout
	var effect: = _find_skill(monster, "WhiteApeEffect2_1")
	var damage: = hp_before - int(RoleProp.roleprop.Hp)
	print("WHITE_APE_EFFECT2_DAMAGE=%d" % damage)
	_check(damage > 0, "通臂白猿手拿日月特效命中未造成伤害")
	monster.queue_free()
	await get_tree().process_frame


func _probe_white_ape_dash(hero: ProbeHero) -> void :
	var monster: = await _spawn_monster(3161, Vector2(180.0, 540.0))
	monster.set_physics_process(true)
	_reset_hero(hero, Vector2(780.0, 540.0))
	monster.MonsterDirection = true
	monster.monster_dir.scale.x = -1.0
	monster.base_damage_box.scale.x = -1.0
	monster._attack_serial = 1
	var start_y: = monster.global_position.y
	var min_y: = start_y
	var max_y: = start_y
	var hp_before: = int(RoleProp.roleprop.Hp)
	var moving_damage: = -1
	monster._3161_attack_index = 1
	monster.attack_target()
	var started: = Time.get_ticks_msec()
	while Time.get_ticks_msec() - started < 950:
		await get_tree().physics_frame
		min_y = minf(min_y, monster.global_position.y)
		max_y = maxf(max_y, monster.global_position.y)
		var impact: = _find_skill(monster, "WhiteApeEffect3_2")
		if impact != null and int(RoleProp.roleprop.Hp) == hp_before:
			_move_hero_to_effect(hero, impact)
		var moving_effect: = _find_skill(monster, "WhiteApeEffect3_1")
		if moving_effect != null and int(RoleProp.roleprop.Hp) == hp_before:
			_move_hero_to_effect(hero, moving_effect)
		if moving_damage < 0 and Time.get_ticks_msec() - started >= 180:
			moving_damage = hp_before - int(RoleProp.roleprop.Hp)
	var end_y: = monster.global_position.y
	var damage: = hp_before - int(RoleProp.roleprop.Hp)
	print("WHITE_APE_DASH_DAMAGE=%d Y=%.2f..%.2f start=%.2f end=%.2f" % [
		damage, min_y, max_y, start_y, end_y, 
	])
	_check(damage > 0, "通臂白猿崩山直拳终点特效命中未造成伤害")
	_check(moving_damage > 0, "通臂白猿冲刺移动火焰命中未造成伤害")
	_check(absf(end_y - start_y) <= 1.0, "通臂白猿冲刺后模型下移 %.2f 像素" % (end_y - start_y))
	monster.queue_free()
	await get_tree().process_frame


func _probe_six_ear_fire_dash(hero: ProbeHero) -> void :
	var monster: = await _spawn_monster(3179, Vector2(180.0, 540.0))
	monster.set_physics_process(true)
	_reset_hero(hero, Vector2(500.0, 540.0))
	monster.MonsterDirection = true
	monster.monster_dir.scale.x = -1.0
	monster.base_damage_box.scale.x = -1.0
	monster._3179_attack_index = 1
	var start_y: = monster.global_position.y
	var min_y: = start_y
	var max_y: = start_y
	var min_x: = monster.global_position.x
	var max_x: = monster.global_position.x
	var x_at_stop: = NAN
	var invincible_during_dash: = false
	var enabled_frames: = 0
	var last_hit_center: = Vector2.ZERO
	var last_hit_size: = Vector2.ZERO
	var hp_before: = int(RoleProp.roleprop.Hp)
	monster.attack_target()
	var started: = Time.get_ticks_msec()
	while Time.get_ticks_msec() - started < 650:
		await get_tree().physics_frame
		min_y = minf(min_y, monster.global_position.y)
		max_y = maxf(max_y, monster.global_position.y)
		min_x = minf(min_x, monster.global_position.x)
		max_x = maxf(max_x, monster.global_position.x)
		if not monster.hit_box.disabled:
			enabled_frames += 1
			last_hit_center = monster.hit_box.global_position
			if monster.hit_box.shape is RectangleShape2D:
				last_hit_size = (monster.hit_box.shape as RectangleShape2D).size
		if x_at_stop != x_at_stop and Time.get_ticks_msec() - started >= 480:
			x_at_stop = monster.global_position.x
		if Time.get_ticks_msec() - started >= 220 and Time.get_ticks_msec() - started <= 300:
			invincible_during_dash = monster._3179_fire_dash_invincible
	var end_y: = monster.global_position.y
	var damage: = hp_before - int(RoleProp.roleprop.Hp)
	print("SIX_EAR_FIRE_DASH_DAMAGE=%d Y=%.2f..%.2f start=%.2f end=%.2f" % [
		damage, min_y, max_y, start_y, end_y, 
	])
	print("SIX_EAR_FIRE_DASH_TRACE X=%.2f..%.2f enabled=%d center=%s size=%s action=%s" % [
		min_x, max_x, enabled_frames, last_hit_center, last_hit_size, 
		monster._active_attack_name, 
	])
	_check(damage > 0, "六耳猕猴烈焰闪特效命中未造成伤害")
	_check(absf(end_y - start_y) <= 1.0, "六耳猕猴烈焰闪后模型下移 %.2f 像素" % (end_y - start_y))
	_check( not is_nan(x_at_stop) and absf(monster.global_position.x - x_at_stop) <= 2.0, 
		"六耳猕猴烈焰闪334毫秒后仍在持续冲刺")
	_check(invincible_during_dash, "六耳猕猴烈焰闪冲刺期间没有无敌")
	_check( not monster._3179_fire_dash_invincible and not monster._special_attack_active\
	and monster.mr_player.current_animation == &"wait" and not monster.is_attacking, 
		"六耳猕猴烈焰闪结束后没有立即回到待机")
	monster.queue_free()
	await get_tree().process_frame


func _probe_six_ear_fire_slash(hero: ProbeHero) -> void :
	var monster: = await _spawn_monster(3179, Vector2(180.0, 540.0))
	_reset_hero(hero, Vector2(400.0, 445.0))
	monster.MonsterDirection = true
	monster.monster_dir.scale.x = -1.0
	monster._attack_serial = 1
	var hp_before: = int(RoleProp.roleprop.Hp)
	monster._start_six_ear_dash(1)
	await get_tree().create_timer(0.2, false).timeout
	_move_hero_to_effect(hero, _find_skill(monster, "SixEarEffect5_1"))
	await get_tree().create_timer(1.4, false).timeout
	var damage: = hp_before - int(RoleProp.roleprop.Hp)
	print("SIX_EAR_FIRE_SLASH_DAMAGE=%d" % damage)
	_check(damage > 0, "六耳猕猴火魔斩特效命中未造成伤害")
	monster.queue_free()
	await get_tree().process_frame


func _spawn_monster(monster_id: int, spawn_position: Vector2) -> EastContinentMonster:
	var monster: = MONSTER_SCENE.instantiate() as EastContinentMonster
	monster.monster_kind = monster_id
	monster.position = spawn_position
	add_child(monster)
	monster.set_process(false)
	monster.set_physics_process(false)
	await get_tree().process_frame
	monster.has_target = false
	return monster


func _reset_hero(hero: ProbeHero, hero_position: Vector2) -> void :
	hero.position = hero_position
	hero.needProtect = false
	hero.CurrentProtect = 0
	RoleProp.role_pos = hero_position
	RoleProp.role_pos_x = hero_position.x
	RoleProp.role_pos_y = hero_position.y
	RoleProp.roleprop.Hp = 100000000


func _find_skill(monster: EastContinentMonster, skill: String) -> WutaiMinghaiProjectile:
	for child: Node in monster.bullet.get_children():
		if child is WutaiMinghaiProjectile and (child as WutaiMinghaiProjectile).skill_name == skill:
			return child as WutaiMinghaiProjectile
	return null


func _move_hero_to_effect(hero: ProbeHero, effect: WutaiMinghaiProjectile) -> void :
	if effect == null or not is_instance_valid(effect):
		print("EFFECT_TRACE missing")
		return
	var shape_node: = effect.get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
	var center: = shape_node.global_position if shape_node != null else effect.global_position
	_reset_hero(hero, center + Vector2(0.0, 48.0))
	effect._process_overlapping_player_bodies()


func _add_floor(y: float) -> void :
	var floor_body: = StaticBody2D.new()
	floor_body.position = Vector2(600.0, y + 20.0)
	var floor_shape: = CollisionShape2D.new()
	var rectangle: = RectangleShape2D.new()
	rectangle.size = Vector2(2000.0, 40.0)
	floor_shape.shape = rectangle
	floor_body.add_child(floor_shape)
	add_child(floor_body)


func _create_hero() -> ProbeHero:
	var hero: = ProbeHero.new()
	hero.name = "ProbeHero"
	hero.add_child(_named(Timer.new(), "ZhenFa"))
	hero.add_child(_named(AnimationPlayer.new(), "RolePlayer"))
	hero.add_child(_named(Node2D.new(), "Damage_Text"))
	var body_shape: = _named(CollisionShape2D.new(), "pz") as CollisionShape2D
	var body_capsule: = CapsuleShape2D.new()
	body_capsule.radius = 20.0
	body_capsule.height = 96.0
	body_shape.shape = body_capsule
	body_shape.position = Vector2(0.0, -48.0)
	hero.add_child(body_shape)
	hero.add_child(_named(Timer.new(), "WSTimer"))
	var protect: = _named(Timer.new(), "Protect") as Timer
	protect.one_shot = true
	hero.add_child(protect)
	hero.add_child(_named(Node2D.new(), "MagicWeapon"))
	hero.add_child(_named(Label.new(), "Name_"))
	hero.add_child(_named(Node2D.new(), "Bullet"))
	hero.add_child(_named(Node.new(), "Buff"))
	hero.add_child(_named(AnimatedSprite2D.new(), "tx"))
	var action: = _named(Node2D.new(), "Action") as Node2D
	hero.add_child(action)
	action.add_child(_named(Sprite2D.new(), "RoleBody"))
	action.add_child(_named(Sprite2D.new(), "RoleEquipment"))
	action.add_child(_named(AnimatedSprite2D.new(), "Wings"))
	var effect_body: = _named(Node2D.new(), "EffectBody") as Node2D
	action.add_child(effect_body)
	for part_name in ["toukui", "jianjia", "huwan", "shenti", "yaodai", "xiabai", "wuqi"]:
		effect_body.add_child(_named(AnimatedSprite2D.new(), part_name))
	var damage_box: = _named(Node2D.new(), "base_damagebox") as Node2D
	hero.add_child(damage_box)
	var hurt_area: = _named(Area2D.new(), "HurtBox") as Area2D
	hurt_area.collision_layer = 128
	hurt_area.collision_mask = 4
	damage_box.add_child(hurt_area)
	var hurt_shape: = _named(CollisionShape2D.new(), "HurtBox") as CollisionShape2D
	var hurt_capsule: = CapsuleShape2D.new()
	hurt_capsule.radius = 20.0
	hurt_capsule.height = 96.0
	hurt_shape.shape = hurt_capsule
	hurt_shape.position = Vector2(0.0, -48.0)
	hurt_area.add_child(hurt_shape)
	hurt_area.area_entered.connect(hero._on_hurt_box_area_entered)
	return hero


func _named(node: Node, node_name: String) -> Node:
	node.name = node_name
	return node


func _check(condition: bool, message: String) -> void :
	if condition:
		return
	_failed = true
	push_error("EAST_EARLY_BOSS_DAMAGE_DASH_PROBE_FAIL " + message)
