extends BaseHero
class_name Role4Hero
const BI_LUO_TIAN_EFFECT = preload("res://Script/Hero/BiLuoTianEffect.gd")
const CANG_MU_LONG_YUN_EFFECT = preload("res://Script/Hero/CangMuLongYunEffect.gd")
const ROLE4_POISON_ARRAY_AWAKEN_EFFECT = preload("res://Script/Hero/Role4PoisonArrayAwakenEffect.gd")
const WDZT_SKILL_ID := "wdzt"
const WDZT_AWAKEN_MP_INTERVAL := 5.0
const WDWW_AWAKEN_TARGET_LIMIT := 4
const LHSQ_AWAKEN_BONUS_PER_STACK := 0.2
const LHSQ_AWAKEN_MAX_STACKS := 5
const LHSQ_AWAKEN_DURATION := 10.0
const SKILL_INPUT_ACTIONS := [&"slz", &"lys", &"lyfb", &"hmz", &"hytj"]
var WDWW: Monster138
@onready var hurt_box = $base_damagebox/HurtBox/HurtBox
var Interv: int
var IsFly: bool
var JDZ
var tkj_awaken_mode: int = 0
var _wdzt_awaken_enabled := false
var _wdzt_awaken_mp_elapsed := 0.0
var _wdzt_toggle_locked := false
var lhsq_awaken_stacks: int = 0
var lhsq_awaken_time_left: float = 0.0


func _ready() -> void:
	super._ready()

	add_to_group("Player")
	super.onEqchange()
	Role_4()


func _exit_tree() -> void:
	temp_max_hp_bonus_rate = 0.0
	temp_power_bonus_rate = 0.0
	if RoleProp.SourcePlayer == self:
		RoleProp.get_last_prop()
		RoleProp.check_hp()
	super._exit_tree()


func WSSkill() -> bool:
	if RoleProp.is_ws_state:
		return false
	RoleProp.is_ws_state = true
	var activated := super.WSSkill()
	if not activated:
		RoleProp.is_ws_state = false
	return activated


func get_skill(skill_name):
	if str(skill_name) == WDZT_SKILL_ID and _wdzt_toggle_locked:
		return
	if str(skill_name) == WDZT_SKILL_ID and _is_wdzt_awaken_active() and _wdzt_awaken_enabled:
		_disable_wdzt_awaken()
		_wdzt_toggle_locked = true
		return
	super.get_skill(skill_name)


func _is_auto_battle_skill_active(skill_id: String) -> bool:
	return skill_id == WDZT_SKILL_ID and _wdzt_awaken_enabled


func Role_4():
	RoleProp.Role1SXBJ = 0
	RoleProp.Role1SXxx = 0

	if not is_in_group("Player"):
		add_to_group("Player")
	var level_1 = PlayerData.player_data["技能学习"]["技能1"]["等级"] + 1
	var level_2 = PlayerData.player_data["技能学习"]["技能2"]["等级"] + 1
	var level_3 = PlayerData.player_data["技能学习"]["技能3"]["等级"] + 1
	var level_4 = PlayerData.player_data["技能学习"]["技能4"]["等级"] + 1
	var level_5 = PlayerData.player_data["技能学习"]["技能5"]["等级"] + 1
	var level_6 = PlayerData.player_data["技能学习"]["技能6"]["等级"] + 1
	var level_7 = PlayerData.player_data["技能学习"]["技能7"]["等级"] + 1
	var level_8 = PlayerData.player_data["技能学习"]["技能8"]["等级"] + 1
	var level_9 = PlayerData.player_data["技能学习"]["技能9"]["等级"] + 1
	var level_10 = PlayerData.player_data["技能学习"]["技能10"]["等级"]
	var level_11 = max(1, int(PlayerData.player_data["技能学习"]["技能11"]["等级"]))
	var level_12 = max(1, int(PlayerData.player_data["技能学习"]["技能12"]["等级"]))
	self.objattackDic["hit1"] = {
		"power": RoleProp.roleprop.power * randf_range(1, 1.2),
		"hurtBack": [2, 0],
		"attackKind": "physics",
		"HitInterv": 1,
		"WSValue": randi_range(3, 5)
	}
	self.objattackDic["hit2"] = {
		"power": RoleProp.roleprop.power * randf_range(0.9, 1.1),
		"hurtBack": [2, 0],
		"attackKind": "physics",
		"HitInterv": 1,
		"WSValue": randi_range(3, 5)
	}
	self.objattackDic["hit3"] = {
		"power": RoleProp.roleprop.power * randf_range(0.9, 1.1),
		"hurtBack": [2, -2],
		"attackKind": "physics",
		"HitInterv": 1,
		"WSValue": randi_range(3, 5)
	}
	self.objattackDic["qlj"] = {
		"power": RoleProp.roleprop.power * (2.5 + (level_1 * 0.4)),
		"hurtBack": [20, -8],
		"attackKind": "physics",
		"WSValue": randi_range(30, 34)
	}
	self.objattackDic["dcj"] = {
		"power": RoleProp.roleprop.power * (0.6 + (level_2 * 0.3)),
		"hurtBack": [8, -6],
		"attackKind": "magic",
		"WSValue": randi_range(12, 15)
	}
	self.objattackDic["tkj"] = {
		"power": 35 + RoleProp.roleprop.power * (3 + (level_4 * 0.5)),
		"hurtBack": [1, -45],
		"attackKind": "physics",
		"WSValue": randi_range(15, 20)
	}
	var mmw_attack := {
		"power": RoleProp.roleprop.power * (2 + (level_5 * 0.2)),
		"hurtBack": [-4, -2],
		"attackKind": "magic",
		"WSValue": randi_range(10, 12)
	}
	if (
		_is_skill_awakened("mmw")
		and _is_skill_awaken_enabled("mmw")
		and PlayerData.player_data["技能学习"]["技能10"]["等级"] > 0
	):
		mmw_attack["addeffect"] = {
			"Name": "Voodoo",
			"AddTime": 5,
			"ReduceInterval": 1,
			"value": int(RoleProp.roleprop.power * 0.1),
			"CanAdd": true,
			"AttackKind": "real",
			"DeBuff": true
		}
	self.objattackDic["mmw"] = mmw_attack
	self.objattackDic["bylt"] = {
		"power": RoleProp.roleprop.power * (1.8 + (level_11 - 1) * 0.25),
		"hurtBack": [2, -3],
		"attackKind": "magic",
		"WSValue": 4
	}
	self.objattackDic["cmly"] = {
		"power": RoleProp.roleprop.power * (1.8 + (level_12 - 1) * 0.25),
		"hurtBack": [2, -3],
		"attackKind": "magic",
		"WSValue": 4
	}
	if PlayerData.player_data["技能学习"]["技能10"]["等级"] > 0:
		self.objattackDic["jdz"] = {
			"power": RoleProp.roleprop.power * (1.5 + (level_6 * 0.1)),
			"hurtBack": [0, 0],
			"attackKind": "magic",
			"WSValue": randi_range(6, 8),
			"addeffect":
			{
				"Name": "Voodoo",
				"AddTime": 5,
				"ReduceInterval": 1,
				"value": int(RoleProp.roleprop.power * 0.1),
				"CanAdd": true,
				"AttackKind": "real",
				"DeBuff": true
			}
		}
		self.objattackDic["zq"] = {
			"power": RoleProp.roleprop.power * (0.7 + (level_8 * 0.2)),
			"hurtBack": [2, -6],
			"attackKind": "magic",
			"WSValue": randi_range(8, 10),
			"addeffect":
			{
				"Name": "Voodoo",
				"AddTime": 5,
				"ReduceInterval": 1,
				"value": int(RoleProp.roleprop.power * 0.1),
				"CanAdd": true,
				"AttackKind": "real",
				"DeBuff": true
			}
		}
		self.objattackDic["lhsq"] = {
			"power": RoleProp.roleprop.power * (1.35 + (level_7 * 0.1)),
			"hurtBack": [-12, -6],
			"attackKind": "magic",
			"WSValue": randi_range(8, 10),
			"addeffect":
			{
				"Name": "Voodoo",
				"AddTime": 5,
				"ReduceInterval": 1,
				"value": int(RoleProp.roleprop.power * 0.1),
				"CanAdd": true,
				"AttackKind": "real",
				"DeBuff": true
			}
		}
	else:
		self.objattackDic["jdz"] = {
			"power": RoleProp.roleprop.power * (1 + (level_6 * 0.1)),
			"hurtBack": [0, 0],
			"attackKind": "magic",
			"WSValue": randi_range(6, 8),
		}
		self.objattackDic["zq"] = {
			"power": RoleProp.roleprop.power * (1 + (level_8 * 0.1)),
			"hurtBack": [2, -6],
			"attackKind": "magic",
			"WSValue": randi_range(8, 10),
		}
		self.objattackDic["lhsq"] = {
			"power": RoleProp.roleprop.power * (1.35 + (level_7 * 0.1)),
			"hurtBack": [-12, -6],
			"attackKind": "magic",
			"WSValue": randi_range(8, 10),
		}


func _physics_process(delta: float) -> void:
	if IsFly:
		gravity = 0
	else:
		gravity = -980.0
	Role_4()
	super._physics_process(delta)
	if _wdzt_toggle_locked and not _is_any_skill_action_pressed():
		_wdzt_toggle_locked = false
	_process_wdzt_awaken(delta)
	_process_lhsq_awaken(delta)
	if NoLimitBuff():
		if (
			not is_riding_mount()
			and Input.is_action_pressed("normalhit")
			and not is_be_attacking
			and not is_using_skills
			and Interv <= 0
		):
			match hit_count:
				0:
					ShovelHit_1()
				1:
					ShovelHit_2()
				2:
					ShovelHit_3()


func ShovelHit_1():
	super.get_hit_data("hit1")
	get_action = "hit1"
	velocity.x = 0
	is_attacking = true
	role_action_player.play("hit1_1")
	await role_action_player.animation_finished
	turn_to_wait()
	hit_count = 1
	is_attacking = false
	return


func ShovelHit_2():
	super.get_hit_data("hit2")
	get_action = "hit2"
	is_can_move_attack_in_sky()
	is_attacking = true
	role_action_player.play("hit2_1")
	await role_action_player.animation_finished
	turn_to_wait()
	hit_count = 2
	is_attacking = false
	return


func ShovelHit_3():
	super.get_hit_data("hit3")
	get_action = "hit3"
	if PlayerDir:
		velocity.x = 180
	else:
		velocity.x = -180
	is_attacking = true
	role_action_player.play("hit3_1")
	await role_action_player.animation_finished
	turn_to_wait()
	hit_count = 0
	is_attacking = false
	return


func ShovelQLJ():
	self.Role1SkillInter["qlj"] = 4.8
	velocity.x = 0
	get_action = "qlj"
	is_using_skills = true
	super.get_hit_data("qlj")
	is_attacking = true
	role_action_player.play("qlj_1")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func ShovelDCJ():
	self.Role1SkillInter["dcj"] = 4.8
	velocity.x = 0
	get_action = "dcj"
	is_using_skills = true
	super.get_hit_data("dcj")
	is_attacking = true
	role_action_player.play("dcj_1")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func ShovelTKJ():
	self.Role1SkillInter["tkj"] = 2.4
	var tkj_awakened: bool = _is_skill_awakened("tkj") and _is_skill_awaken_enabled("tkj")
	tkj_awaken_mode = 2 if tkj_awakened and Input.is_action_pressed("Exit") else (1 if tkj_awakened else 0)
	if tkj_awaken_mode == 1:
		velocity.x = 600.0 if PlayerDir else -600.0
		velocity.y = 0.0
		$Action/SpecialEffect1.global_rotation = -PI / 2.0
		$base_damagebox/HitBox.global_rotation = -PI / 2.0
	elif tkj_awaken_mode == 2:
		velocity = Vector2(0.0, -600.0)
		$Action/SpecialEffect1.rotation = 0.0
		$base_damagebox/HitBox.rotation = 0.0
	get_action = "tkj"
	is_using_skills = true
	super.get_hit_data("tkj")
	if tkj_awaken_mode != 0:
		HitDic = HitDic.duplicate(true)
		HitDic["hurtBack"] = [0, 0]
	is_attacking = true
	role_action_player.play("tkj_1")
	await role_action_player.animation_finished
	if tkj_awaken_mode != 0:
		velocity = Vector2.ZERO
		$Action/SpecialEffect1.rotation = 0.0
		$base_damagebox/HitBox.rotation = 0.0
	tkj_awaken_mode = 0
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func ShovelMMW():
	self.Role1SkillInter["mmw"] = 3
	velocity.x = 0
	get_action = "mmw"
	is_using_skills = true
	super.get_hit_data("mmw")
	is_attacking = true
	role_action_player.play("mmw_1")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func ShovelZQ():
	self.Role1SkillInter["zq"] = 4.8
	velocity.x = 0
	get_action = "zq"
	is_using_skills = true
	super.get_hit_data("zq")
	is_attacking = true
	role_action_player.play("zq_1")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func ShovelWDWW():
	self.Role1SkillInter["wdww"] = 4.8
	if is_on_floor():
		velocity.x = 0
	get_action = "wdww"
	is_using_skills = true
	is_attacking = true
	role_action_player.play("wdww_2")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func ShovelBYLT():
	self.Role1SkillInter["bylt"] = 6.0
	velocity.x = 0
	get_action = "bylt"
	is_using_skills = true
	is_attacking = true
	role_action_player.play("jdz")
	var level = get_parent().get_parent()
	var effect = BI_LUO_TIAN_EFFECT.new()
	effect.setup(self, PlayerDir, objattackDic["bylt"])
	level.add_child(effect)
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func ShovelCMLY():
	self.Role1SkillInter["cmly"] = 3.0
	velocity.x = 0
	get_action = "cmly"
	is_using_skills = true
	is_attacking = true
	role_action_player.speed_scale = 1.0
	role_action_player.play("jdz")
	var level = get_parent().get_parent()
	var effect = CANG_MU_LONG_YUN_EFFECT.new()
	effect.setup(self, PlayerDir, objattackDic["cmly"])
	level.add_child(effect)
	await get_tree().create_timer(0.5, false).timeout
	if role_action_player.current_animation == "jdz":
		role_action_player.stop()
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func ShovelMBYJ():
	self.Role1SkillInter["lhsq"] = 4.8
	velocity.x = 0
	get_action = "lhsq"
	is_using_skills = true
	super.get_hit_data("lhsq")
	is_attacking = true
	role_action_player.play("mbyj")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func ShovelJDZ():
	self.Role1SkillInter["jdz"] = 6
	velocity.x = 0
	get_action = "jdz"
	is_using_skills = true
	super.get_hit_data("jdz")
	is_attacking = true
	role_action_player.play("jdz")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func ShovelWDZT():
	self.Role1SkillInter["wdzt"] = 4
	if is_on_floor():
		velocity.x = 0
	get_action = "wdzt"
	is_using_skills = true
	is_attacking = true
	if _is_wdzt_awaken_active():
		_wdzt_awaken_enabled = true
		_wdzt_awaken_mp_elapsed = 0.0
		_wdzt_toggle_locked = true
	role_action_player.play("wdzt")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func AddShovelEffect1():
	var bullet_pos = Vector2()
	if PlayerDir:
		bullet_pos = Vector2(35, 0)
	else:
		bullet_pos = Vector2(-35, 0)
	Global.addRoleBullet_(self.Bullet, bullet_pos + position, !PlayerDir, "Role4Bullet3", objattackDic["mmw"])
	if _is_skill_awakened("mmw") and _is_skill_awaken_enabled("mmw"):
		Global.addRoleBullet_(self.Bullet, bullet_pos + position, PlayerDir, "Role4Bullet3", objattackDic["mmw"])


func ADDMBYJ():
	Global.AddRole4Bullet(self.Bullet, self, position)


func CallWDWW():
	var bullet_pos: Vector2
	if PlayerDir:
		bullet_pos = Vector2(30, -30)
	else:
		bullet_pos = Vector2(-30, -30)
	if WDWW != null:
		WDWW.queue_free()
	var target_limit := (
		WDWW_AWAKEN_TARGET_LIMIT if _is_skill_awakened("wdww") and _is_skill_awaken_enabled("wdww") else 1
	)
	var targets := _get_wdww_targets(target_limit)
	if targets.is_empty():
		return
	var Target: BaseMonster = targets[0]
	WDWW = Global.create_monster(138, get_parent().get_parent().monster, position + bullet_pos) as Monster138
	if WDWW == null:
		return
	WDWW.SHp = Target.SHp * (0.25 + PlayerData.player_data["技能学习"]["技能9"]["等级"] * 0.02)
	WDWW.Hp = WDWW.SHp
	WDWW.set_linked_targets(targets)


func CallJDZ():
	if get_action == "bylt" or get_action == "cmly":
		return
	if JDZ != null:
		JDZ.queue_free()
	JDZ = Global.addRoleBullet_(self.Bullet, position + Vector2(0, 30), false, "Role4Bullet6", objattackDic["jdz"])
	if JDZ != null:
		JDZ.start_auto_free(10)
		if _is_skill_awakened("jdz") and _is_skill_awaken_enabled("jdz"):
			var level = get_parent().get_parent()
			var effect := ROLE4_POISON_ARRAY_AWAKEN_EFFECT.new()
			effect.setup(self, PlayerDir, objattackDic["jdz"], JDZ)
			level.add_child(effect)


func AddWDZT():
	for i in buff.get_children():
		if i != null:
			if i.BuffInfo["Name"] == "PoisionBody":
				i.queue_free()
	(
		Global
		. AddBuff(
			self.buff,
			{
				"Name": "PoisionBody",
				"AddTime": 99999 if _wdzt_awaken_enabled and _is_wdzt_awaken_active() else 6,
				"ReduceInterval": 0,
				"value": 0,
				"CanAdd": false,
				"CanRemove": false,
				"AttackKind": "",
			}
		)
	)


func _process_wdzt_awaken(delta: float) -> void:
	if not _wdzt_awaken_enabled:
		return
	if IsDeath or not _is_wdzt_awaken_active():
		_disable_wdzt_awaken()
		return
	_wdzt_awaken_mp_elapsed += delta
	if _wdzt_awaken_mp_elapsed < WDZT_AWAKEN_MP_INTERVAL:
		return
	_wdzt_awaken_mp_elapsed -= WDZT_AWAKEN_MP_INTERVAL
	var mp_cost := int(get_need_mp(WDZT_SKILL_ID, false))
	if RoleProp.roleprop.Mp < mp_cost:
		_disable_wdzt_awaken()
		return
	reduce_Mp(mp_cost)


func _disable_wdzt_awaken() -> void:
	if not _wdzt_awaken_enabled:
		return
	_wdzt_awaken_enabled = false
	_wdzt_awaken_mp_elapsed = 0.0
	for child in buff.get_children():
		if (
			child != null
			and child.get("BuffInfo") is Dictionary
			and str(child.BuffInfo.get("Name", "")) == "PoisionBody"
		):
			child.queue_free()
	IsWDZT = false


func _is_wdzt_awaken_active() -> bool:
	return _is_skill_awakened(WDZT_SKILL_ID) and _is_skill_awaken_enabled(WDZT_SKILL_ID)


func _add_lhsq_awaken_stack() -> void:
	if not _is_lhsq_awaken_active():
		return
	lhsq_awaken_time_left = LHSQ_AWAKEN_DURATION
	if lhsq_awaken_stacks >= LHSQ_AWAKEN_MAX_STACKS:
		return
	var old_max_hp := int(RoleProp.roleprop.SHp)
	lhsq_awaken_stacks += 1
	_refresh_lhsq_awaken_stats()
	RoleProp.roleprop.Hp += maxi(0, int(RoleProp.roleprop.SHp) - old_max_hp)
	RoleProp.check_hp()


func _process_lhsq_awaken(delta: float) -> void:
	if lhsq_awaken_stacks <= 0:
		return
	if IsDeath or not _is_lhsq_awaken_active():
		_clear_lhsq_awaken_bonus()
		return
	lhsq_awaken_time_left = maxf(0.0, lhsq_awaken_time_left - delta)
	if lhsq_awaken_time_left <= 0.0:
		_clear_lhsq_awaken_bonus()


func _refresh_lhsq_awaken_stats() -> void:
	var bonus_rate := float(lhsq_awaken_stacks) * LHSQ_AWAKEN_BONUS_PER_STACK
	temp_max_hp_bonus_rate = bonus_rate
	temp_power_bonus_rate = bonus_rate
	RoleProp.get_last_prop()


func _clear_lhsq_awaken_bonus() -> void:
	lhsq_awaken_stacks = 0
	lhsq_awaken_time_left = 0.0
	temp_max_hp_bonus_rate = 0.0
	temp_power_bonus_rate = 0.0
	RoleProp.get_last_prop()
	RoleProp.check_hp()


func _is_lhsq_awaken_active() -> bool:
	return _is_skill_awakened("lhsq") and _is_skill_awaken_enabled("lhsq")


func _is_any_skill_action_pressed() -> bool:
	for action_name in SKILL_INPUT_ACTIONS:
		if Input.is_action_pressed(action_name):
			return true
	return false


func GetMonster():
	var targets := _get_wdww_targets(1)
	return targets[0] if not targets.is_empty() else null


func _get_wdww_targets(limit: int) -> Array[BaseMonster]:
	var targets: Array[BaseMonster] = []
	var MonsterList = get_parent().get_parent().monster.get_children()
	for i in MonsterList:
		if not _is_valid_wdww_target(i):
			continue
		targets.append(i as BaseMonster)
	targets.sort_custom(_sort_wdww_targets_by_hp)
	if targets.size() > limit:
		targets.resize(limit)
	return targets


func _sort_wdww_targets_by_hp(left: BaseMonster, right: BaseMonster) -> bool:
	return left.Hp > right.Hp


func _is_valid_wdww_target(target: Node) -> bool:
	if not _is_valid_role4_skill_target(target):
		return false
	if target is Monster138 or target is Monster133:
		return false
	if target is Monster49 or target is Monster50:
		return not target.is_stop
	return true


func _is_valid_role4_skill_target(target: Node) -> bool:
	if target == null:
		return false
	if not is_instance_valid(target):
		return false
	if not (target is BaseMonster):
		return false
	if target.Hp <= 0:
		return false
	if target.NoTarget:
		return false
	if target.get_meta("pet_tiger_unit", false) or target.get_meta("is_summon", false):
		return false
	return true


func ADDMusic(num: int):
	match int(num):
		1:
			Global.add_sound(self, "res://Music/Hero/Role4/ShovelHit1.mp3")
		2:
			Global.add_sound(self, "res://Music/Hero/Role4/ShovelHit2.mp3")
		3:
			Global.add_sound(self, "res://Music/Hero/Role4/ShovelHit3.mp3")
		4:
			Global.add_sound(self, "res://Music/Hero/Role4/ArrowHit1.mp3")
		5:
			Global.add_sound(self, "res://Music/Hero/Role4/ArrowHit2.mp3")
		6:
			Global.add_sound(self, "res://Music/Hero/Role4/Shovelqlj.mp3")
		7:
			Global.add_sound(self, "res://Music/Hero/Role4/Arrowqlj.mp3")
		8:
			Global.add_sound(self, "res://Music/Hero/Role4/Shoveldcj.mp3")
		9:
			Global.add_sound(self, "res://Music/Hero/Role4/Arrowdcj.mp3")
		10:
			Global.add_sound(self, "res://Music/Hero/Role4/Shovelmmw.mp3")
		11:
			Global.add_sound(self, "res://Music/Hero/Role4/Arrowmmw.mp3")
		12:
			Global.add_sound(self, "res://Music/Hero/Role4/Shovelzq.mp3")
		13:
			Global.add_sound(self, "res://Music/Hero/Role4/Arrowzq.mp3")
		14:
			Global.add_sound(self, "res://Music/Hero/Role4/Arrowtkj.mp3")
		15:
			Global.add_sound(self, "res://Music/Hero/Role4/jdz.mp3")
		16:
			Global.add_sound(self, "res://Music/Hero/Role4/lhsq.mp3")
		17:
			Global.add_sound(self, "res://Music/Hero/Role4/mds.mp3")
		18:
			Global.add_sound(self, "res://Music/Hero/Role4/wdww.mp3")
		19:
			Global.add_sound(self, "res://Music/Hero/Role4/effect6_repeat.mp3")


func _on_nor_mal_hit_interv_timeout() -> void:
	Interv -= 1


func ToTop():
	if PlayerDir:
		velocity = Vector2(-750, -800)
	else:
		velocity = Vector2(750, -800)


func RemoveSpeed():
	velocity = Vector2(0, 0)


func Rush():
	if PlayerDir:
		velocity.x = 600
	else:
		velocity.x = -600


func FlyTop():
	if tkj_awaken_mode == 1:
		velocity.y = 0.0
		return
	if tkj_awaken_mode == 2:
		velocity = Vector2(0.0, -600.0)
		return
	velocity.y = 0
	velocity.y = -600


func ToTop2():
	IsFly = true
	if PlayerDir:
		velocity = Vector2(0, -1800)
	else:
		velocity = Vector2(0, -1800)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if IsDeath or needProtect:
		return
	IsInSky = false
	CUreCureCount = 0
	CureValue = 1
	IdleCount = 0

	Global.TotalHurtCount += 1
	var Target = area.get_parent().get_parent()
	var MonsterTarget: BaseMonster
	MonsterTarget = checkMonster(area)
	if Target == null or MonsterTarget == null:
		return
	if Target.objattackDic.size() == 0:
		return
	if MonsterTarget is Monster47:
		Global.PlayerBeHitCount += 1
	var last_hit = get_Monster_last_hurt(MonsterTarget, Target) * (1 - slzjs) * (1 - slzjs2)
	if MonsterTarget != null:
		if MonsterTarget.IsLpz:
			var Levellpz = PlayerData.player_data["落魄阵"]["Level"]
			MonsterTarget.lpzjs = Levellpz * 0.01
			last_hit *= (1 - MonsterTarget.lpzjs)
	var TotalCureMonster = int(MonsterTarget.ebol * last_hit)
	MonsterTarget.cure_hp(TotalCureMonster)
	if self.IsWDZT:
		var ReduecHurt = int(last_hit * (0.7 - PlayerData.player_data["技能学习"]["技能3"]["等级"] * 0.02))
		var CureHurt = last_hit - ReduecHurt
		last_hit = ReduecHurt
		if randi_range(0, 100) < 20:
			cure_Hp(CureHurt)
	if MonsterTarget != null:
		MonsterTarget.total_hit += last_hit
		if MonsterTarget is Monster141:
			effect_reducehp(int(RoleProp.roleprop.SHp * 0.01), "real")
			Global.AddMonster141Aura(self.Bullet, self.position, MonsterTarget)
		if self.IsWDZT:
			if Global.CheckWD(MonsterTarget) < 7:
				Global.add_buff(
					MonsterTarget.buff,
					{
						"Name": "Voodoo",
						"AddTime": 5,
						"ReduceInterval": 1,
						"value": int(RoleProp.roleprop.power * 0.1),
						"CanAdd": true,
						"CanRemove": false,
						"AttackKind": "real",
						"DeBuff": true
					}
				)
	Global.TotalRoleHurt += int(last_hit)
	if not is_miss:
		Global.add_sound(self, "res://Music/Hero/68_Role3_beAttack.mp3")
		Global.add_mr_hurt(pz, Vector2(5, -20))
		if not IsTMc:
			_add_role_protect(randi_range(3, 7))
	if is_miss or RoleProp.is_ws_state or IsSuperArmor or IsWDZT or needProtect:
		is_be_attacking = false
	else:
		be_hit_back(MonsterTarget, Target)
		_queue_hit_stiff(MonsterTarget, Target)
		state_behit()
	reduce_hp(last_hit, MonsterTarget, Target)


func _prepare_hit_reaction() -> void:
	IsFly = false


func Fall():
	IsFly = false


func _on_hit_box_area_entered(area: Area2D) -> void:
	if get_action == "lhsq":
		var mm = area.get_parent().get_parent()
		var CureValue: float = 1
		CureValue += 0.3 * float(RoleProp.roleprop.SHp - RoleProp.roleprop.Hp) / float(RoleProp.roleprop.SHp)
		if mm is BaseMonster and not _is_summon_or_pet_target(mm):
			var CurePower = (
				objattackDic["lhsq"]["power"] * (0.2 + (PlayerData.player_data["技能学习"]["技能7"]["等级"]) * 0.03) * CureValue
			)
			cure_Hp(CurePower)
			_add_lhsq_awaken_stack()
	if objattackDic.has(get_action):
		if objattackDic[get_action].has("addeffect"):
			var Monster = area.get_parent().get_parent()
			if Monster != null:
				if Monster is BaseMonster and not _is_summon_or_pet_target(Monster):
					if objattackDic[get_action]["addeffect"]["Name"] == "Voodoo":
						if Global.CheckWD(Monster) < 7:
							Global.add_buff(Monster.buff, objattackDic[get_action]["addeffect"])
					else:
						Global.add_buff(Monster.buff, objattackDic[get_action]["addeffect"])


func _is_skill_awakened(skill_id: String) -> bool:
	var awaken_data: Variant = PlayerData.player_data.get("技能觉醒", {})
	return awaken_data is Dictionary and bool(awaken_data.get(skill_id, false))


func _is_skill_awaken_enabled(skill_id: String) -> bool:
	var enabled_data: Variant = PlayerData.player_data.get("技能觉醒启用", {})
	if not enabled_data is Dictionary or not enabled_data.has(skill_id):
		return true
	return bool(enabled_data.get(skill_id, false))
