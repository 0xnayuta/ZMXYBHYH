extends BaseMonster

var moonlight_active = false
var moonlight_timer = 0.0
var moonlight_cooldown = 15.0
var phantom_summoned = false
var is_phantom = false

const PHANTOM_SCALE = 0.7


func monster_146():
	var phantom_multiplier = PHANTOM_SCALE if is_phantom else 1.0

	self.rush_speed = 450 if not is_phantom else 400
	self.is_boss = true
	self.my_mr_name = "赤月神君" if not is_phantom else "赤月神君·幻像"
	self.attack_in = 78 if not is_phantom else 82

	self.level = 60
	self.SHp = 5000000
	self.Hp = self.SHp

	self.def = 1290 * phantom_multiplier
	self.mdef = 1250 * phantom_multiplier
	self.Toughness = 30 * phantom_multiplier

	self.crit = 38 * phantom_multiplier
	self.miss = 42 if not is_phantom else 30
	self.lucky = 85 * phantom_multiplier
	self.Htarget = 99999
	self.ar = 285 * phantom_multiplier
	self.sp = 278 * phantom_multiplier
	self.Critreduce = 25 * phantom_multiplier
	self.speed = 19 * phantom_multiplier
	self.mysee = 750
	self.attackRange = 150
	self.attackDesire = 188 if not is_phantom else 80

	self.behit_calmtime = 0
	self.self_rhp = SHp * (0.00015 if not is_phantom else 0.0001)
	self.add_exp = 0
	self.fall_coin = 800 * phantom_multiplier
	self.ebol = 0

	self.fall_pro = 0.1
	self.fall_list = [
		{"name": "sqzlwzzs", "value": 1},
	]

	moonlight_active = false
	moonlight_timer = 0.0
	moonlight_cooldown = 15.0
	phantom_summoned = false

	self.objattackDic["hit1"] = {
		"power": int(2700 * phantom_multiplier),
		"hurtBack": [-5, -8],
		"attackKind": "physics",
		"HitProtect": 0,
	}
	self.objattackDic["hit2"] = {
		"power": int(2700 * phantom_multiplier),
		"hurtBack": [-8, -12],
		"attackKind": "physics",
		"HitProtect": 0,
	}
	self.objattackDic["hit3"] = {
		"power": int(5000 * phantom_multiplier),
		"hurtBack": [0, 0],
		"attackKind": "physics",
		"HitProtect": 0,
		"addeffect":
		{
			"Name": "Immobilize",
			"AddTime": 2,
			"ReduceInterval": 0,
			"value": 1,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
		}
	}


func _ready() -> void:
	super._ready()
	monster_146()

	if is_phantom:
		modulate = Color(0.7, 0.3, 0.3, 1.0)

	Skill_1_CD = 2.0
	Skill_2_CD = 10.0
	Skill_3_CD = 8.0


func _process(delta: float) -> void:
	if is_phantom:
		return

	if moonlight_timer > 0:
		moonlight_timer -= delta
		if moonlight_timer <= 0 and moonlight_active:
			_end_moonlight()

	if moonlight_cooldown > 0:
		moonlight_cooldown -= delta


func ai_think() -> void:
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		has_target = abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee

		if not is_phantom and has_target and moonlight_cooldown <= 0 and not moonlight_active:
			_activate_moonlight()

		if not has_target:
			normal_state()
			return

		var distance_to_player = abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x)

		if distance_to_player >= attackRange:
			have_target()
			_handle_ranged_combat(distance_to_player)
		else:
			stop_move()
			_handle_melee_combat(distance_to_player)


func _handle_ranged_combat(distance: float) -> void:
	if Skill_2_CD <= 0:
		do_hit_2()
	elif Skill_3_CD <= 0 and distance > 400 and _can_dash_towards_player():
		do_hit_3()
	elif Skill_1_CD <= 0 and distance <= 155:
		do_hit_1()


func _handle_melee_combat(distance: float) -> void:
	if Skill_1_CD <= 0 and distance <= 155:
		do_hit_1()
	elif Skill_3_CD <= 0 and distance < 200 and _can_dash_towards_player():
		do_hit_3()
	elif Skill_2_CD <= 0:
		do_hit_2()


func _can_dash_towards_player() -> bool:
	var target_x = position.x + 600 * _get_dash_direction()
	return 0 <= target_x and target_x <= 1480


func _get_dash_direction() -> int:
	return 1 if position.x < RoleProp.get_nearest_monster_target_position(global_position).x else -1


func _activate_moonlight():
	if moonlight_active or is_phantom:
		return

	moonlight_active = true
	moonlight_timer = 8.0
	moonlight_cooldown = 15.0

	self.miss += 200

	if modulate:
		modulate.a = 0.5


func _end_moonlight():
	if not moonlight_active:
		return

	moonlight_active = false
	self.miss -= 200

	if modulate:
		modulate.a = 1.0


func hurt_reduce_hp(value, target):
	if is_phantom:
		return super.HurtReduceHp(value, target)

	if moonlight_active and value > 0 and not is_miss:
		var player_x = RoleProp.get_nearest_monster_target_position(global_position).x
		var blink_distance = 100
		var target_x = player_x - blink_distance if player_x > position.x else player_x + blink_distance
		position.x = target_x

		value = int(value * 0.5)
		to_hero()

	return super.HurtReduceHp(value, target)


func do_hit_1():
	if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > 155:
		return
	if Skill_1_CD > 0 or is_attacking:
		return
	super.to_hero()
	Skill_1_CD = 2.0
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	if Skill_2_CD > 0 or is_attacking:
		return
	super.to_hero()
	Skill_2_CD = 10.0
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	if Skill_3_CD > 0 or is_attacking:
		return
	super.to_hero()
	Skill_3_CD = 8.0
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")

	var dash_direction = 1 if position.x < RoleProp.get_nearest_monster_target_position(global_position).x else -1
	velocity.x = dash_direction * 900
	await get_tree().create_timer(0.5).timeout

	if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= attackRange:
		_perform_hit3_damage()

	velocity.x = 0
	is_attacking = false
	stop_move()


func _perform_hit3_damage():
	pass


func call_bullet_alt2():
	var attack_config = objattackDic.get("hit2", {})
	if not attack_config or not self.bullet:
		return

	var sp = 1 + RoleProp.baseroleprop.Level * 0.02
	var bullet_name = "Monster146Bullet"

	var bb = Global.add_bullet(
		bullet_name, self.bullet, !self.MonsterDirection, sp, Vector2(0, 0) + position, "hit2", attack_config
	)

	if bb:
		bb.rotation_degrees = 0


func state_death() -> void:
	if is_phantom:
		super.state_death()
		return

	if not phantom_summoned:
		phantom_summoned = true

		velocity.x = 0
		if mr_player:
			mr_player.play("death")

		await get_tree().create_timer(0.8).timeout
		_summon_phantom()

		if mr_player:
			await mr_player.animation_finished

		_handle_death_events()
	else:
		super.state_death()


func _summon_phantom():
	var phantom_scene = Global.load_scene_uncached("res://Scene/Monster/Monster_146.tscn")
	if phantom_scene:
		var phantom_instance = phantom_scene.instantiate() as BaseMonster
		phantom_instance.is_phantom = true

		var spawn_position = position + Vector2(randi_range(-50, 50), randi_range(-30, 30))
		spawn_position.x = clamp(spawn_position.x, 100, 1380)

		get_parent().add_child(phantom_instance)
		phantom_instance.position = spawn_position


func _handle_death_events():
	if not is_death:
		if not is_phantom and PlayerData.player_data.has(my_mr_name) and not get_parent().get_parent() is Lhhj:
			PlayerData.player_data[my_mr_name] += 1

	is_death = true
	settle_death_drops()
	set_gxp()
	set_exp()
	ADDMonsterDeathEffect()


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func HurtReduceHp(value, target):
	return hurt_reduce_hp(value, target)


## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func CallBullet_2():
	return call_bullet_alt2()
