extends BaseObject
class_name SummonBaseMonster

const BaseHero = preload("res://Script/Base/BaseHero.gd")

@onready var bullet: Node = $Bullet
@onready var hit_box: CollisionShape2D = $BaseDamageBox/HitBox/HitBox
@onready var hurt_box: CollisionShape2D = $BaseDamageBox/HurtBox/HurtBox
@onready var base_damage_box: Node2D = $BaseDamageBox
@onready var buff: Node = $Buff
@onready var mr_player: AnimationPlayer = $mr_player
@onready var monster_dir: Node2D = $MonsterDir
@onready var remove_hurt_bl: Timer = $RemoveHurtBL

var is_summon: bool = true
var summoner: Node = null
var summon_duration: float = 0.0
var duration_timer: float = 0.0
var despawn_effect_enabled: bool = true
var is_friendly: bool = true
var MaxProtect: float = 100.0
var CurrentProtect: float = 0.0
var needProtect: bool = false
var need_removeProtect: bool = false
var protect_hold_time: float = 0.0

var current_target: BaseMonster = null
var has_target: bool = false
var all_monsters: Array = []
var target_search_timer: float = 0.0
var target_search_interval: float = 1.0
var player_reference: BaseHero = null
var _is_following_player_when_idle: bool = false
const PET_FOLLOW_START_DISTANCE := 300.0
const PET_FOLLOW_STOP_DISTANCE := 120.0

var return_to_player_distance: int = 1000
var return_timer: float = 0.0
var return_check_interval: float = 2.0

var Skill_1_CD: float = 0.0
var Skill_2_CD: float = 0.0
var Skill_3_CD: float = 0.0
var Skill_4_CD: float = 0.0
var Skill_5_CD: float = 0.0
var Skill_6_CD: float = 0.0

var RoundList = []

var monster_blood_bar = null

var ShouldInSky: bool = false
var IsSky: bool = false
var in_sky_timer: float = 0.0
var max_sky_time: float = 10.0

var count: int = 0
var ran_num: int = 0
var RndiCount: int = 0

var BaseLevel_: Node = null
var level_cache_valid: bool = false

enum State {
	IDLE,
	MOVE,
	ATTACK,
	HURT,
	DEATH,
	SKY,
}
var current_state: State = State.IDLE

var rush_speed: float = 0.0
var is_boss: bool = false
var my_mr_name: String = ""
var attack_in: int = 0
var level: int = 1
var def: int = 0
var mdef: int = 0
var crit: int = 0
var miss: int = 0
var lucky: int = 0
var Htarget: int = 0
var Toughness: int = 0
var ar: int = 0
var sp: int = 0
var Critreduce: int = 0
var behit_calmtime: float = 0.0
var self_rhp: int = 0
var add_exp: int = 0
var fall_coin: int = 0
var ebol: float = 0.0
var speed: int = 10
var mysee: int = 500
var attackRange: int = 160
var attackDesire: int = 80

var Islljy: bool = false
var IsLpz: bool = false
var lpzzs: float = 0.0
var tqzbs: float = 0.0
var llrdzs: float = 1.0
var llrdCount: int = 0
var jgz_bl: float = 1.0
var is_jgz: bool = false
var is_stun: bool = false
var is_sleep: bool = false
var is_Immobilize: bool = false
var is_speedDown: bool = false
var IsScary: bool = false
var IsSuperArmor: bool = false
var IsIndestructible: bool = false
var IsDefeReduce: bool = false
var DefeReduce: float = 0.0
var BloodFix: bool = false
var LifeManaLock: bool = false
var is_quiescent: bool = false
var is_death: bool = false
var HurtBl: float = 1.0
var hit_name: String = ""
var MonsterDirection: bool = false
var get_Player: Node = null
var hd: int = 0
var max_hd: int = 0
var is_bt: bool = false
var total_hurt: int = 0
var Therapeutic_effects: float = 0.0
var lpzjs: float = 0.0
var is_Fly: bool = false
var iniSpeed: int = 10
var NoGrav: bool = false
var isGXP: bool = false
var _gxp_base_speed: int = 0
var _gxp_serial: int = 0
const GXP_DAMAGE_MULTIPLIER: float = 2.0
const GXP_AFTERIMAGE_INTERVAL: float = 0.12


func turnToGxp(duration: int) -> void:
	_gxp_serial += 1
	var token := _gxp_serial
	if not isGXP:
		isGXP = true
		_gxp_base_speed = maxi(1, speed)
		_spawn_gxp_afterimage(token)
	speed = _gxp_base_speed * 2
	iniSpeed = _gxp_base_speed * 2
	get_tree().create_timer(maxi(duration, 1)).timeout.connect(_finish_gxp.bind(token), CONNECT_ONE_SHOT)


func get_gxp_damage_multiplier() -> float:
	return GXP_DAMAGE_MULTIPLIER if isGXP else 1.0


func _spawn_gxp_afterimage(token: int) -> void:
	if token != _gxp_serial or not isGXP or not is_inside_tree() or Hp <= 0:
		return
	if is_instance_valid(monster_dir):
		var level_node := get_level_node()
		if level_node != null and level_node != self:
			spawn_ws_effect(monster_dir, get_parent())
	get_tree().create_timer(GXP_AFTERIMAGE_INTERVAL, false).timeout.connect(
		_spawn_gxp_afterimage.bind(token), CONNECT_ONE_SHOT
	)


func _finish_gxp(token: int) -> void:
	if token != _gxp_serial or not isGXP:
		return
	cancelGxp()


func cancelGxp() -> void:
	if not isGXP:
		return
	isGXP = false
	speed = maxi(1, _gxp_base_speed)
	iniSpeed = speed


func _play_animation_if_exists(anim_name: String) -> bool:
	if mr_player.has_animation(anim_name):
		mr_player.play(anim_name)
		return true
	return false


func _get_gravity() -> float:
	return -980.0 if can_set_gravity() else 0.0


func _ready() -> void:
	randomize()
	ran_num = randi_range(0, 100)
	RndiCount = randi_range(0, 100)
	$CalmHit.start(1.0)

	if not has_node("Buff"):
		var buff_node = Node.new()
		buff_node.name = "Buff"
		add_child(buff_node)
		buff = buff_node

	initialize_monster_properties()
	iniSpeed = speed

	try_play_default_animation()
	base_damage_box.scale.x = 1
	monster_dir.scale.x = 1

	find_player_reference()
	setup_skills()
	current_state = State.IDLE


func try_play_default_animation() -> void:
	if is_Fly:
		if (
			_play_animation_if_exists("Fly_wait")
			or _play_animation_if_exists("fly_wait")
			or _play_animation_if_exists("Fly")
			or _play_animation_if_exists("fly")
		):
			return
	try_play_fallback_animation()


func try_play_fallback_animation() -> void:
	if _play_animation_if_exists("wait") or _play_animation_if_exists("idle"):
		return
	var anim_list = mr_player.get_animation_list()
	if anim_list.size() > 0:
		mr_player.play(anim_list[0])


func find_player_reference() -> void:
	var tree = get_tree()
	if not tree:
		return
	var current_scene = tree.current_scene
	if not current_scene or not current_scene.has_node("Hero"):
		return
	var hero_node = current_scene.get_node("Hero")
	if hero_node:
		for child in hero_node.get_children():
			if child is BaseHero:
				player_reference = child
				break


func follow_player_when_idle() -> void:
	if not is_instance_valid(player_reference):
		find_player_reference()
	if not is_instance_valid(player_reference):
		_is_following_player_when_idle = false
		stop_move()
		return
	var offset_x := player_reference.global_position.x - global_position.x
	var distance_x := absf(offset_x)
	if _is_following_player_when_idle and distance_x <= PET_FOLLOW_STOP_DISTANCE:
		_is_following_player_when_idle = false
	elif not _is_following_player_when_idle and distance_x > PET_FOLLOW_START_DISTANCE:
		_is_following_player_when_idle = true
	if not _is_following_player_when_idle:
		stop_move()
	elif offset_x > 0.0:
		move_right()
	else:
		move_left()


func _physics_process(delta: float) -> void:
	gravity = _get_gravity()
	handle_gravity_and_sky(delta)
	check_add_buff()
	update_timers(delta)

	llrdzs = 1.3 if llrdCount > 0 else 1.0
	if llrdCount > 0:
		llrdCount -= 1

	if target_search_timer >= target_search_interval:
		search_for_targets()
		target_search_timer = 0.0

	if return_timer >= return_check_interval and player_reference:
		check_return_to_player()
		return_timer = 0.0

	_process_pet_protect(delta)

	if summon_duration > 0:
		duration_timer += delta
		if duration_timer >= summon_duration:
			despawn()

	MonsterDirection = (monster_dir.scale.x == 1)

	if death():
		current_state = State.DEATH
	elif ShouldInSky:
		current_state = State.SKY
	elif is_attacking:
		current_state = State.ATTACK
	elif is_be_attacking:
		current_state = State.HURT
	elif velocity.x != 0:
		current_state = State.MOVE
	else:
		current_state = State.IDLE

	match current_state:
		State.DEATH:
			process_death(delta)
		State.SKY:
			process_sky(delta)
		State.ATTACK:
			process_attack(delta)
		State.HURT:
			process_hurt(delta)
		State.MOVE:
			process_move(delta)
		State.IDLE:
			process_idle(delta)

	if not death() and not ShouldInSky and not is_be_attacking and not is_attacking:
		if not is_limit_buff():
			ai_think()
		elif IsScary:
			when_scary()
		else:
			velocity.x = 0

	if not death():
		update_animation_and_direction()

	if MainSet.set_data.get("MonsterLittleBlood", false) and MainSet.set_data.get("NoShowMonsterBody", false):
		little_blood_bar_control()

	if not is_on_floor() and not is_Fly and not ShouldInSky:
		velocity.y -= gravity * delta

	move_and_slide()


func rush() -> void:
	velocity.x = 0
	velocity.x -= rush_speed if MonsterDirection else -rush_speed


func handle_gravity_and_sky(_delta: float) -> void:
	if IsSky or ShouldInSky or is_Fly:
		velocity.y = 0
	if ShouldInSky:
		in_sky_timer += _delta
		if in_sky_timer >= max_sky_time:
			drop()


func update_timers(delta: float) -> void:
	count += 1
	Skill_1_CD -= delta
	Skill_2_CD -= delta
	Skill_3_CD -= delta
	Skill_4_CD -= delta
	Skill_5_CD -= delta
	Skill_6_CD -= delta
	target_search_timer += delta
	return_timer += delta
	if count % 60 == 0:
		ran_num = randi_range(0, 100)


func update_animation_and_direction() -> void:
	if is_attacking or is_be_attacking:
		return

	if velocity.x != 0:
		if is_Fly:
			if not (_play_animation_if_exists("Fly") or _play_animation_if_exists("fly")):
				mr_player.play("walk")
		else:
			mr_player.play("walk")
	else:
		if is_Fly:
			if not (_play_animation_if_exists("Fly_wait") or _play_animation_if_exists("fly_wait")):
				mr_player.play("wait")
		else:
			mr_player.play("wait")

	if velocity.x > 0:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
	elif velocity.x < 0:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1


func check_add_buff() -> void:
	if not buff:
		return
	var not_ice = true
	var not_stun = true
	var not_sleep = true
	var not_Immobilize = true
	var not_speedDown = true
	var not_Scary = true
	var not_SuperArmor = true
	var not_Indestructible = true
	var not_DefeReduce = true
	var not_BloodFix = true
	var not_LifeManaLock = true
	var not_lljy = true
	var not_lpz = true
	var not_NoDeBuff = true

	var buff_child_count := buff.get_child_count()
	var buff_child_index := 0
	while buff_child_index < buff_child_count:
		var i = buff.get_child(buff_child_index)
		buff_child_index += 1
		if not i:
			continue
		var name = i.BuffInfo.get("Name", "")
		match name:
			"lljybuff":
				Islljy = true
				not_lljy = false
			"NoDeBuff":
				NoDeBuff = true
				not_NoDeBuff = false
			"lpzbuff":
				IsLpz = true
				not_lpz = false
			"Ice":
				is_ice = true
				not_ice = false
			"Indestructible":
				IsIndestructible = true
				not_Indestructible = false
			"DefeReduce":
				IsDefeReduce = true
				not_DefeReduce = false
			"SuperArmor":
				IsSuperArmor = true
				not_SuperArmor = false
			"DeadLink":
				is_DeadLink = true
			"EyeFix":
				is_EyeFix = true
			"Immobilize":
				is_Immobilize = true
				not_Immobilize = false
			"stun":
				is_stun = true
				not_stun = false
			"speed_down":
				is_speedDown = true
				not_speedDown = false
			"BloodFix":
				BloodFix = true
				not_BloodFix = false
			"LifeManaLock":
				LifeManaLock = true
				not_LifeManaLock = false
			"Scary":
				IsScary = true
				not_Scary = false

	if not_NoDeBuff:
		NoDeBuff = false
	if not_lljy:
		Islljy = false
	if not_lpz:
		IsLpz = false
		lpzjs = 0.0
	if not_Indestructible:
		IsIndestructible = false
	if not_DefeReduce:
		DefeReduce = 0.0
		IsDefeReduce = false
	if not_SuperArmor:
		IsSuperArmor = false
	if not_Scary:
		IsScary = false
	if not_BloodFix:
		BloodFix = false
	if not_LifeManaLock:
		LifeManaLock = false
	if not_Immobilize:
		is_Immobilize = false
	if not_ice:
		is_ice = false
	if not_stun:
		is_stun = false
	if not_speedDown:
		is_speedDown = false
		speed = iniSpeed

	if buff_child_count == 0:
		is_speedDown = false
		speed = iniSpeed
		is_stun = false
		is_ice = false
		is_DeadLink = false
		is_EyeFix = false


func can_set_gravity() -> bool:
	return not NoGrav and not Islljy and not ShouldInSky


func is_limit_buff() -> bool:
	return is_ice or is_stun or is_Immobilize or is_sleep or IsScary or Islljy


func is_super_armor() -> bool:
	return IsSuperArmor or IsIndestructible or is_DeadLink


func when_scary() -> void:
	if ran_num <= 20:
		stop_move()
	elif ran_num <= 60:
		move_left()
	else:
		move_right()


func get_attacker_damage(attacker: Node) -> int:
	var base_damage = 0
	var attack_kind = "physics"

	if attacker is BaseMonster or attacker is MonsterBullet:
		var hit_name_val = attacker.get("hit_name")
		var obj_dic = attacker.get("objattackDic")
		if not (obj_dic is Dictionary) or obj_dic.is_empty():
			obj_dic = attacker.get("AttList")
		if hit_name_val and obj_dic is Dictionary:
			var hit_info = obj_dic.get(hit_name_val)
			if hit_info is Dictionary and hit_info.has("power"):
				base_damage = hit_info["power"]
				attack_kind = hit_info.get("attackKind", "physics")
			elif obj_dic.has("power"):
				base_damage = obj_dic["power"]
				attack_kind = obj_dic.get("attackKind", "physics")
			else:
				return 0
		else:
			return 0
	elif attacker is BaseHero or attacker is BaseMagicWeapon or attacker is RoleBullet:
		if attacker.has_method("get_hit_damage"):
			base_damage = attacker.get_hit_damage()
		elif "HitDic" in attacker and attacker.HitDic.has("power"):
			base_damage = attacker.HitDic["power"]
			attack_kind = attacker.HitDic.get("attackKind", "physics")
		else:
			return 0
	else:
		return 0

	var defense = def if attack_kind == "physics" else mdef
	var reduction = defense / float(defense + 100)
	var final_damage = int(base_damage * (1.0 - reduction))
	return max(1, final_damage)


func state_hurt(_attacker: Node) -> void:
	Global.add_special_effect(self, Vector2.ZERO, "RoleBeHit", Vector2.ONE, false, 1)
	Global.add_sound(self, "res://Music/MonsterHurt/6_BeattackByRole1.mp3")


func calculate_attack_damage(target: BaseMonster, base_damage: int, attack_kind: String) -> int:
	if target == null or not is_instance_valid(target):
		return 0
	return target.resolve_friendly_damage(base_damage, attack_kind, self)


func deal_summon_damage(target: BaseMonster, base_damage: int, attack_kind: String = "magic") -> int:
	if target == null or not is_instance_valid(target) or target == self or target.Hp <= 0:
		return 0
	var resolved_damage := calculate_attack_damage(target, base_damage, attack_kind)
	if resolved_damage <= 0:
		return 0
	return target.reduce_pet_hp(resolved_damage, attack_kind)


func process_idle(_delta: float) -> void:
	if not is_be_attacking and current_target:
		try_use_skills()


func process_move(_delta: float) -> void:
	pass


func process_attack(_delta: float) -> void:
	pass


func process_hurt(_delta: float) -> void:
	pass


func process_sky(_delta: float) -> void:
	velocity.x = 0
	velocity.y = 0


func process_death(_delta: float) -> void:
	velocity.x = 0
	velocity.y = 0
	mr_player.play("death")
	call_deferred("_handle_death")


func search_for_targets() -> void:
	all_monsters.clear()
	var tree = get_tree()
	if tree:
		var level_node: Node = get_level_node()
		if (
			level_node != null
			and level_node.has_method("has_active_monster_index")
			and level_node.has_active_monster_index()
		):
			for monster in level_node.get_active_monsters():
				_try_add_target(monster)
		else:
			for monster in tree.get_nodes_in_group("monsters"):
				_try_add_target(monster)
			if all_monsters.is_empty() and level_node != null and level_node.has_node("Monster"):
				_collect_targets_recursive(level_node.get_node("Monster"))
		if all_monsters.is_empty():
			var current_scene = tree.current_scene
			if current_scene and current_scene.has_node("Monster"):
				_collect_targets_recursive(current_scene.get_node("Monster"))
		if all_monsters.is_empty():
			_collect_targets_recursive(tree.root)

	if not all_monsters.is_empty():
		var closest = null
		var min_dist = INF
		for m in all_monsters:
			var d = position.distance_to(m.position)
			if d < min_dist:
				min_dist = d
				closest = m
		current_target = closest
		has_target = true
	else:
		current_target = null
		has_target = false
		stop_move()


func monster_is_summon(monster: BaseMonster) -> bool:
	return monster.get("is_summon") == true


func _try_add_target(monster: Node) -> void:
	if monster and monster != self and monster is BaseMonster and monster.Hp > 0 and not monster_is_summon(monster):
		if not all_monsters.has(monster):
			all_monsters.append(monster)


func _collect_targets_recursive(node: Node) -> void:
	if node == null:
		return
	_try_add_target(node)
	for child in node.get_children():
		_collect_targets_recursive(child)


func ai_think() -> void:
	if not is_instance_valid(current_target) or current_target.Hp <= 0:
		current_target = null
		stop_move()
		return
	var distance = abs(position.x - current_target.position.x)
	if distance < mysee:
		has_target = true
		if distance > attackRange:
			if current_target.position.x > position.x:
				move_right()
			else:
				move_left()
			if not is_be_attacking:
				try_use_skills()
		else:
			stop_move()
			if not is_be_attacking:
				try_use_skills()
	else:
		current_target = null
		has_target = false
		stop_move()


func try_use_skills() -> void:
	if ShouldInSky:
		return
	if randi_range(0, 100) >= attackDesire:
		return
	if Skill_1_CD <= 0:
		do_hit_1()
	elif Skill_2_CD <= 0:
		do_hit_2()
	elif Skill_3_CD <= 0:
		do_hit_3()
	elif Skill_4_CD <= 0:
		do_hit_4()
	elif Skill_5_CD <= 0:
		do_hit_5()
	elif Skill_6_CD <= 0:
		do_hit_6()


func move_left() -> void:
	base_damage_box.scale.x = 1
	monster_dir.scale.x = 1
	velocity.x = -speed * 10
	play_move_animation()


func move_right() -> void:
	base_damage_box.scale.x = -1
	monster_dir.scale.x = -1
	velocity.x = speed * 10
	play_move_animation()


func move_up() -> void:
	velocity.y = -speed * 8
	play_move_animation()


func move_down() -> void:
	velocity.y = speed * 8
	play_move_animation()


func play_move_animation() -> void:
	if is_Fly:
		if not (_play_animation_if_exists("Fly") or _play_animation_if_exists("fly")):
			mr_player.play("walk")
	else:
		mr_player.play("walk")


func to_monster() -> void:
	if not is_instance_valid(current_target):
		return
	if current_target.position.x > position.x:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1
	else:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1


func normal_state() -> void:
	if is_quiescent or is_be_attacking:
		return
	if is_Fly:
		if ran_num < 95:
			if RoleProp.role_pos_y > position.y + randi_range(125, 245):
				move_down()
			elif RoleProp.role_pos_y < position.y + randi_range(15, 65):
				move_up()
		else:
			move_down() if ran_num < 50 else move_up()
	if ran_num < 10:
		stop_move()
	elif ran_num <= 55:
		move_left()
	else:
		move_right()


func have_target() -> void:
	if is_quiescent or is_be_attacking:
		return
	if is_Fly:
		if current_target.position.y > position.y + randi_range(125, 245):
			move_down()
		elif current_target.position.y < position.y + randi_range(15, 45):
			move_up()
	if current_target.position.x > position.x + randi_range(65, 85):
		move_right()
	elif current_target.position.x < position.x - randi_range(65, 85):
		move_left()


func cannotchangestatewhenattorbeatt() -> bool:
	return is_attacking or is_be_attacking


func stop_move() -> void:
	velocity.x = 0
	if is_Fly:
		if not (_play_animation_if_exists("Fly_wait") or _play_animation_if_exists("fly_wait")):
			mr_player.play("wait")
	else:
		mr_player.play("wait")


func do_hit_1() -> void:
	pass


func do_hit_2() -> void:
	pass


func do_hit_3() -> void:
	pass


func do_hit_4() -> void:
	pass


func do_hit_5() -> void:
	pass


func do_hit_6() -> void:
	pass


func check_return_to_player() -> void:
	if not player_reference:
		return
	if global_position.distance_to(player_reference.global_position) > return_to_player_distance:
		return_to_player()
		return_timer = -0.5


func return_to_player() -> void:
	if not player_reference:
		return
	var offset_x = 100 * (1 if randf() > 0.5 else -1)
	var offset_y = -50
	global_position = player_reference.global_position + Vector2(offset_x, offset_y)
	velocity = Vector2.ZERO
	reset_attack_state()
	current_target = null
	has_target = false


func reset_attack_state() -> void:
	is_be_attacking = false
	is_attacking = false
	if death() or ShouldInSky:
		return
	if velocity.x != 0:
		if is_Fly:
			if not (_play_animation_if_exists("Fly") or _play_animation_if_exists("fly")):
				mr_player.play("walk")
		else:
			mr_player.play("walk")
	else:
		if is_Fly:
			if not (_play_animation_if_exists("Fly_wait") or _play_animation_if_exists("fly_wait")):
				mr_player.play("wait")
		else:
			mr_player.play("wait")


func little_blood_bar_control() -> void:
	if not (MainSet.set_data.get("MonsterLittleBlood", false) and MainSet.set_data.get("NoShowMonsterBody", false)):
		return
	if monster_blood_bar == null and Hp > 0:
		monster_blood_bar = Global.add_monster_blood(self, Vector2(-30, -90), Hp / float(SHp), Hp)
	elif monster_blood_bar:
		if not is_be_attacking:
			monster_blood_bar.can_show = false
		else:
			monster_blood_bar.can_show = true
		monster_blood_bar.bar_value = float(Hp) / float(SHp)
		monster_blood_bar.bar_text = Hp
		if Hp <= 0:
			monster_blood_bar.queue_free()
			monster_blood_bar = null


func death() -> bool:
	return Hp <= 0


func reduce_hp(value: int, _attacker = null) -> void:
	if _pet_protect_active():
		return
	if IsIndestructible and value >= Hp:
		return
	Hp -= value
	total_hurt += value
	if value > 0:
		var level_node = get_level_node()
		if level_node:
			Global.add_damage_text(level_node, Vector2(position.x, position.y - 110), value, "physics", false, self)


func cure_hp(value: int = 0) -> int:
	if Hp <= 0 or BloodFix or LifeManaLock:
		return 0
	value = int(value * (1 + Therapeutic_effects))
	if Hp + value >= SHp:
		value = SHp - Hp
	Hp += value
	if value > 0:
		var level_node = get_level_node()
		if level_node:
			call_deferred("_show_heal_text", level_node, Vector2(position.x, position.y - 110), value)
	return value


func _show_heal_text(level_node, po: Vector2, value: int) -> void:
	Global.add_damage_text(level_node, po, value, "cure", false, self)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	var attacker = null
	if area is BaseRoleHitBox or area is RolehmzBullet:
		attacker = get_Player
	elif area.get_parent() is BaseMonster:
		attacker = area.get_parent()
	elif area.get_parent().get_parent() is BaseMonster:
		attacker = area.get_parent().get_parent()
	elif area.get_parent() is MonsterBullet:
		attacker = area.get_parent()
	elif area.get_parent().get_parent() is MonsterBullet:
		attacker = area.get_parent().get_parent()
	else:
		return
	if not is_instance_valid(attacker):
		return
	var last_hurt = get_attacker_damage(attacker)
	if last_hurt <= 0:
		return
	if _pet_protect_active():
		return
	if is_attacking:
		Hp -= last_hurt
		if Hp <= 0:
			Hp = 0
			death()
		else:
			var level_node = get_level_node()
			if level_node:
				Global.add_damage_text(
					level_node, Vector2(position.x, position.y - 110), last_hurt, "physics", false, self
				)
	else:
		reduce_hp(last_hurt, attacker)
		if not is_super_armor():
			state_hurt(attacker)
	_add_pet_protect(_get_pet_protect_gain(attacker))


func _on_hit_box_area_entered(area: Area2D) -> void:
	if not (is_attacking and hit_name != ""):
		return

	var parent = area.get_parent()
	var target_node = parent.get_parent() if parent else null

	if not target_node or not (target_node is BaseMonster) or target_node == self:
		return

	var hit_data: Dictionary = objattackDic.get(hit_name, {}) if objattackDic.has(hit_name) else {}
	var damage := int(hit_data.get("power", 500))
	var attack_kind := str(hit_data.get("attackKind", "magic"))
	if deal_summon_damage(target_node, damage, attack_kind) <= 0:
		return
	target_node.play_hit_effect(self)
	apply_knockback(target_node)
	if objattackDic.has(hit_name) and objattackDic[hit_name].has("addeffect"):
		_apply_attack_effect(target_node, objattackDic[hit_name]["addeffect"])


func _apply_attack_effect(target: BaseMonster, effect: Dictionary) -> void:
	if not is_instance_valid(target) or target.Hp <= 0:
		return
	if not target.has_node("Buff"):
		var buff_node = Node.new()
		buff_node.name = "Buff"
		target.add_child(buff_node)
	Global.add_buff(target.get_node("Buff"), effect)


func _on_summon_bullet_hit(area: Area2D, bullet_instance) -> void:
	var parent = area.get_parent()
	var target = parent.get_parent() if parent else null

	if not target or not (target is BaseMonster) or target == self:
		return

	var attack_name = bullet_instance.get("hit_name")
	if not objattackDic.has(attack_name):
		return

	var hit_data: Dictionary = objattackDic[attack_name]
	var damage := int(hit_data.get("power", 0))
	var attack_kind := str(hit_data.get("attackKind", "magic"))
	if deal_summon_damage(target, damage, attack_kind) <= 0:
		return
	target.play_hit_effect(self)
	apply_knockback(target)
	if objattackDic[attack_name].has("addeffect"):
		_apply_attack_effect(target, objattackDic[attack_name]["addeffect"])


func apply_knockback(target: BaseMonster) -> void:
	if not is_instance_valid(target):
		return
	if target.is_control_immune() or target.get("IsIndestructible") == true:
		return
	var hurt_back = objattackDic.get(hit_name, {}).get("hurtBack", [0, 0]) if hit_name else [0, 0]
	var knockback_x = hurt_back[0]
	var knockback_y = hurt_back[1]

	if monster_dir.scale.x == -1:
		target.velocity.x = -knockback_x * 10
	else:
		target.velocity.x = knockback_x * 10
	target.velocity.y = knockback_y * 5


func _persist_active_pet_death() -> void:
	var is_tiger := bool(get_meta("pet_tiger_unit", false))
	var is_dragon := bool(get_meta("pet_dragon_unit", false)) and not bool(get("is_dragon_clone"))
	var is_phoenix := bool(get_meta("pet_phoenix_unit", false))
	var is_rabbit := bool(get_meta("pet_rabbit_unit", false))
	var is_mouse := bool(get_meta("pet_mouse_unit", false))
	var is_neat := bool(get_meta("pet_neat_unit", false))
	var is_yin_tiger := bool(get_meta("pet_yin_tiger_unit", false))
	var is_turtle := bool(get_meta("pet_turtle_unit", false)) and not is_rabbit and not is_mouse
	if (
		not is_tiger
		and not is_dragon
		and not is_phoenix
		and not is_turtle
		and not is_rabbit
		and not is_mouse
		and not is_neat
		and not is_yin_tiger
	):
		return
	var level_node := get_level_node()
	if level_node == null:
		return
	var pet_type := (
		"PetYinTiger"
		if is_yin_tiger
		else (
			"PetNeat"
			if is_neat
			else (
				"PetMouse"
				if is_mouse
				else (
					"PetRabbit"
					if is_rabbit
					else (
						"PetTurtle"
						if is_turtle
						else "PetTiger" if is_tiger else "PetPhoenix" if is_phoenix else "PetDragon"
					)
				)
			)
		)
	)
	var pet_display_name := ""
	var data_value: Variant = get("pet_data")
	if data_value is Dictionary:
		data_value[DataKeys.HP] = 0
		pet_display_name = str(data_value.get(DataKeys.ALT_NAME, ""))
	if pet_display_name == "":
		pet_display_name = str(PlayerData.player_data.get("出战宠物", ""))
	var dead_pet_keys_value: Variant = level_node.get_meta("active_pet_dead_keys", [])
	var dead_pet_keys: Array = dead_pet_keys_value.duplicate() if dead_pet_keys_value is Array else []
	for dead_key in [pet_type, pet_display_name]:
		if dead_key != "" and not dead_pet_keys.has(dead_key):
			dead_pet_keys.append(dead_key)
	level_node.set_meta("active_pet_dead_keys", dead_pet_keys)
	level_node.set_meta("active_pet_dead_this_level", true)
	level_node.set_meta("active_pet_dead_name", pet_type)
	level_node.set_meta("active_pet_dead_type", pet_type)
	level_node.set_meta("active_pet_dead_display_name", pet_display_name)


func _handle_death() -> void:
	_persist_active_pet_death()
	if monster_blood_bar:
		monster_blood_bar.queue_free()
		monster_blood_bar = null
	await get_tree().create_timer(1.5).timeout
	queue_free()


func _exit_tree() -> void:
	_clear_visual_resources(self)
	if monster_blood_bar:
		monster_blood_bar.queue_free()
	for i in RoundList:
		if is_instance_valid(i):
			i.queue_free()
	RoundList.clear()


func _clear_visual_resources(node: Node) -> void:
	if node is AnimatedSprite2D:
		var animated_sprite := node as AnimatedSprite2D
		animated_sprite.stop()
		animated_sprite.sprite_frames = null
	elif node is Sprite2D:
		var sprite := node as Sprite2D
		sprite.texture = null
	for child in node.get_children():
		_clear_visual_resources(child)


func _get_pet_protect_gain(_attacker: Node) -> int:
	return randi_range(3, 7)


func _pet_protect_active() -> bool:
	return needProtect or CurrentProtect >= MaxProtect


func _add_pet_protect(value: int) -> void:
	if value <= 0 or Hp <= 0 or needProtect:
		return
	CurrentProtect = clampf(CurrentProtect + float(value), 0.0, MaxProtect)
	if CurrentProtect >= MaxProtect:
		CurrentProtect = MaxProtect
		needProtect = true
		need_removeProtect = true
		protect_hold_time = randf_range(3.0, 4.0)
		if hurt_box != null:
			hurt_box.set_deferred("disabled", true)
		modulate = Color(1, 1, 1, 0.5)


func _clear_pet_protect() -> void:
	needProtect = false
	need_removeProtect = false
	protect_hold_time = 0.0
	CurrentProtect = 0.0
	if hurt_box != null:
		hurt_box.set_deferred("disabled", false)
	modulate = Color(1, 1, 1, 1)


func _process_pet_protect(delta: float) -> void:
	if CurrentProtect > 0.0:
		if need_removeProtect:
			CurrentProtect = max(0.0, CurrentProtect - 1.0)
		else:
			CurrentProtect = max(0.0, CurrentProtect - 0.05)
	if needProtect:
		protect_hold_time -= delta
		if protect_hold_time <= 0.0:
			_clear_pet_protect()


func apply_stun_to_target(target: BaseMonster, duration: float = 3.0) -> void:
	if not is_instance_valid(target) or target.Hp <= 0:
		return
	var stun_buff = {
		"Name": "stun",
		"AddTime": duration,
		"ReduceInterval": 0,
		"value": 0,
		"AttackKind": "",
		"DeBuff": true,
		"CanRemove": false
	}
	if not target.has_node("Buff"):
		target.add_child(Node.new())
		target.get_node("Buff").name = "Buff"
	Global.add_buff(target.get_node("Buff"), stun_buff)


func apply_defense_reduce_to_target(target: BaseMonster, duration: float = 20.0, reduce_value: float = 1.0) -> void:
	if not is_instance_valid(target) or target.Hp <= 0:
		return
	var defense_reduce_buff = {
		"Name": "DefeReduce",
		"AddTime": duration,
		"ReduceInterval": 0,
		"value": reduce_value,
		"AttackKind": "",
		"DeBuff": true,
		"CanRemove": false
	}
	if not target.has_node("Buff"):
		target.add_child(Node.new())
		target.get_node("Buff").name = "Buff"
	Global.add_buff(target.get_node("Buff"), defense_reduce_buff)


func get_level_node() -> Node:
	if level_cache_valid and is_instance_valid(BaseLevel_):
		return BaseLevel_
	var tree = get_tree()
	if not tree:
		BaseLevel_ = self
		level_cache_valid = true
		return BaseLevel_
	var node = get_parent()
	while node:
		if node is BaseLevel:
			BaseLevel_ = node
			level_cache_valid = true
			return BaseLevel_
		node = node.get_parent()
	var base_levels = tree.get_nodes_in_group("BaseLevel")
	if not base_levels.is_empty():
		BaseLevel_ = base_levels[0]
		level_cache_valid = true
		return BaseLevel_
	var scene_root = tree.current_scene
	if scene_root and scene_root.has_node("BaseLevel"):
		BaseLevel_ = scene_root.get_node("BaseLevel")
		level_cache_valid = true
		return BaseLevel_
	var all_nodes = tree.get_nodes_in_group("level_container")
	if not all_nodes.is_empty():
		BaseLevel_ = all_nodes[0]
		level_cache_valid = true
		return BaseLevel_
	BaseLevel_ = tree.current_scene if tree.current_scene else self
	level_cache_valid = true
	return BaseLevel_


func invalidate_level_cache() -> void:
	level_cache_valid = false


func setup_bullet_collision(bullet_instance) -> Node:
	if bullet_instance and bullet_instance.has_node("middle/HitBox"):
		var hit_box_area = bullet_instance.get_node("middle/HitBox") as Area2D
		if hit_box_area:
			hit_box_area.collision_layer = 2
			hit_box_area.collision_mask = 2048
			bullet_instance.set_meta("is_summon_bullet", true)
			bullet_instance.set_meta("summoner", self)
			hit_box_area.connect("area_entered", Callable(self, "_on_summon_bullet_hit").bind(bullet_instance))
	return bullet_instance


func despawn() -> void:
	if despawn_effect_enabled:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
		tween.tween_callback(queue_free)
	else:
		queue_free()


func set_summon_properties(summoner_node: Node, duration: float = 60.0) -> void:
	summoner = summoner_node
	summon_duration = duration
	is_friendly = true
	is_summon = true
	if summoner_node is BaseHero:
		player_reference = summoner_node
		var summoner_level = summoner_node.get("level")
		level = (
			int(summoner_level)
			if summoner_level != null
			else int(PlayerData.player_data.get(DataKeys.PLAYER_LEVEL, level))
		)
	else:
		find_player_reference()
		level = int(PlayerData.player_data.get(DataKeys.PLAYER_LEVEL, level))


func tween_to_top() -> void:
	ShouldInSky = true
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(0, -250) + position, 0.2)


func TweenToTop2() -> void:
	ShouldInSky = true
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, 100), 1)


func drop() -> void:
	ShouldInSky = false
	in_sky_timer = 0.0


func move_monster_to_boss(target_monster, movetime: float = 1.0) -> void:
	if is_instance_valid(target_monster):
		var tween = create_tween()
		tween.tween_property(target_monster, "position", position, movetime)


func attract_monsters(movetime: float = 1.0) -> void:
	var level_node = get_level_node()
	if level_node and level_node.has_node("Monster"):
		var monster_container = level_node.get_node("Monster")
		for monster in monster_container.get_children():
			if monster is BaseMonster and monster != self and monster.Hp > 0:
				move_monster_to_boss(monster, movetime)


func initialize_monster_properties() -> void:
	pass


func setup_skills() -> void:
	pass


func get_attack_animations() -> Dictionary:
	return {}


func _on_calm_hit_timeout() -> void:
	RndiCount = randi_range(0, 100)


func _on_remove_hurt_bl_timeout() -> void:
	HurtBl = 1.0


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func TweenToTop() -> void:
	tween_to_top()
