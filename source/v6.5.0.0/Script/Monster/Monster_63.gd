extends BaseMonster
var DeathCount: int = 0
var Hurtcount: int = 0
var Should_FS: bool = false
var _fs_queued: bool = false
var Is_Fs = false
var FSList = []
var ReduceCount: int = 0
var TotalHit: int = 0


func monster_63():
	self.is_boss = true
	self.my_mr_name = "五毒·卞城王"
	self.attack_in = 0
	self.level = RoleProp.baseroleprop.Level
	self.SHp = 180000 + int(RoleProp.baseroleprop.Level * 12000)
	self.Hp = self.SHp
	self.def = 150 + int(RoleProp.baseroleprop.Level * 3)
	self.mdef = 150 + int(RoleProp.baseroleprop.Level * 3)
	self.crit = 5 + int(RoleProp.baseroleprop.Level * 0.8)
	self.miss = 5 + int(RoleProp.baseroleprop.Level * 0.4)
	self.lucky = 0 + int(RoleProp.baseroleprop.Level * 1.5)
	self.Htarget = 0
	self.Toughness = 0
	self.ar = 20 + int(RoleProp.baseroleprop.Level * 0.6)
	self.sp = 20 + int(RoleProp.baseroleprop.Level * 0.6)
	self.Critreduce = 0
	self.speed = 11
	self.mysee = 0
	self.attackRange = 280
	self.attackDesire = 0
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0

	self.objattackDic["hit1"] = {
		"power": 300 + int(RoleProp.baseroleprop.Level * 8),
		"hurtBack": [0, 0],
		"attackKind": "physics",
		"HitProtect": 6
	}

	self.objattackDic["hit2"] = {
		"power": 100 + int(RoleProp.baseroleprop.Level * 12),
		"hurtBack": [-10, 0],
		"attackKind": "magic",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "Boundground",
			"AddTime": 4,
			"ReduceInterval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.objattackDic["hit4"] = {
		"power": 100 + int(RoleProp.baseroleprop.Level * 10),
		"hurtBack": [20, -10],
		"attackKind": "magic",
	}
	self.fall_pro = 0.15
	self.fall_list = [{"name": "xzyj", "value": 1}]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_63()
	Skill_1_CD = 10
	Skill_2_CD = 0
	Skill_3_CD = 0
	Skill_4_CD = 15
	Should_FS = false


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	ReduceCount += 1

	if ReduceCount % 120 == 0:
		if Hurtcount > 0:
			Hurtcount -= 1
		if TotalHit > 0:
			TotalHit -= 1

	if not Is_Fs and TotalHit >= randi_range(4, 8):
		if get_Player != null:
			get_Player.effect_reducehp(int(TotalHit * randi_range(10, 15)), "real")
			cure_hp((SHp - Hp) * TotalHit * 0.001)
			TotalHit = 0

	if Should_FS:
		mr_player.play("hit3")
		await mr_player.animation_finished
		Should_FS = false
		stop_move()
		return

	if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attackRange:
				have_target()
				if Skill_1_CD <= 0:
					do_hit_1()
				if Skill_4_CD <= 0:
					do_hit_4()
			else:
				if Skill_1_CD <= 0:
					do_hit_1()
				if Skill_4_CD <= 0:
					do_hit_4()
				elif count % 120 == 0:
					attack_target()
				else:
					stop_move()


func do_hit_1():
	Skill_1_CD = randi_range(20, 30)
	super.to_hero()
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_4():
	if Skill_4_CD > 0 or is_attacking:
		return
	super.to_hero()
	Skill_4_CD = randi_range(25, 30)
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func move_player_to_boss(movetime: float = 0.0):
	var player = get_Player
	if not player or not is_instance_valid(player):
		return

	var elapsed_time = 0.0
	var max_radius = 2000
	var min_radius = 5
	var base_pull = 8

	while true:
		if not is_instance_valid(self) or not is_inside_tree() or not is_instance_valid(player):
			return

		if movetime > 0:
			elapsed_time += get_process_delta_time()
			if elapsed_time >= movetime:
				break

		var distance = position.distance_to(player.position)

		if distance > min_radius and distance < max_radius:
			var pull_strength = (max_radius - distance) / max_radius
			pull_strength = clamp(pull_strength * base_pull, 0.5, base_pull * 1.5)
			var direction = (position - player.position).normalized()
			player.position += direction * pull_strength

		await get_tree().process_frame


func _on_hurt_box_area_entered(area: Area2D) -> void:
	super._on_hurt_box_area_entered(area)
	Hurtcount += 1

	if not Is_Fs:
		TotalHit += 1

	if not Is_Fs and get_parent().get_children().size() < 5:
		if Hurtcount >= 40:
			if randi_range(0, 100) <= 15:
				Hurtcount = 0
				Should_FS = true


func CallFS():
	if _fs_queued:
		return
	_fs_queued = true
	call_deferred("_call_fs_deferred")


func _call_fs_deferred() -> void:
	var tree := get_tree()
	if tree == null:
		return
	await tree.process_frame
	await tree.process_frame
	if not is_inside_tree() or is_queued_for_deletion():
		return
	_fs_queued = false
	if get_parent().get_children().size() >= 6:
		Should_FS = false
		return
	var FS = Global.create_monster(63, get_parent(), position)
	if FS == null:
		Should_FS = false
		return

	await FS.ready

	FS.Should_FS = false
	FS.Is_Fs = true
	FS.is_boss = false
	FS.fall_list.clear()
	FS.fall_stone.clear()

	if FS.mr_player:
		FS.mr_player.stop()

	FS.stop_move()
	FS.modulate = Color(0.5, 0.5, 0.5)

	FS.SHp = int(self.SHp * 0.5)
	FS.Hp = FS.SHp
	FS.def = int(self.def * 0.5)
	FS.mdef = int(self.mdef * 0.5)
	FS.crit = int(self.crit * 0.5)
	FS.miss = int(self.miss * 0.5)
	FS.lucky = int(self.lucky * 0.5)
	FS.ar = int(self.ar * 0.5)
	FS.sp = int(self.sp * 0.5)
	FS.speed = int(self.speed * 0.5)

	for attack_key in self.objattackDic:
		if attack_key in FS.objattackDic:
			var original_power = self.objattackDic[attack_key]["power"]
			FS.objattackDic[attack_key]["power"] = int(original_power * 0.5)

	Should_FS = false


func CallBullet2():
	var bullet_pos
	for i in range(randi_range(6, 10)):
		if MonsterDirection:
			bullet_pos = Vector2(-100, randi_range(-65, 35))
		else:
			bullet_pos = Vector2(100, randi_range(-65, 35))
		Global.add_bullet(
			"Monster63Bullet1",
			self.bullet,
			!MonsterDirection,
			1,
			bullet_pos + position,
			"hit2",
			self.objattackDic["hit2"]
		)
		await get_tree().create_timer(0.1, false).timeout


func _on_death_timeout() -> void:
	if Is_Fs:
		self.Hp = -990


func _on_hit_box_area_exited(_area: Area2D) -> void:
	if not Is_Fs:
		TotalHit += 1
