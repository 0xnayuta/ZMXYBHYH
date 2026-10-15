extends BaseMonster
class_name Monster63
var _is_casting_skill = false
var _combo_skill_queued: bool = false
static var instance_count: int = 0
const MAX_SUMMON_COUNT: int = 5

func init_monster(is_boss_flag: bool) -> void :
	self.rush_speed = 400
	self.is_boss = is_boss_flag
	self.my_mr_name = "五毒·卞城王"
	self.attack_in = 90
	self.level = RoleProp.baseroleprop.Level
	self.SHp = 180000 + int(RoleProp.baseroleprop.Level * 12000)
	self.Hp = self.SHp
	self.def = 180 + int(RoleProp.baseroleprop.Level * 3)
	self.mdef = 180 + int(RoleProp.baseroleprop.Level * 3)
	self.crit = 5 + int(RoleProp.baseroleprop.Level * 0.8)
	self.miss = 5 + int(RoleProp.baseroleprop.Level * 0.4)
	self.lucky = 0 + int(RoleProp.baseroleprop.Level * 1.5)
	self.Htarget = 0
	self.Toughness = 0
	self.ar = 20 + int(RoleProp.baseroleprop.Level * 0.6)
	self.sp = 20 + int(RoleProp.baseroleprop.Level * 0.6)
	self.Critreduce = 0
	self.speed = 13
	self.mysee = 500
	self.attackRange = 280
	self.attackDesire = 60
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 200
	self.ebol = 0


	self.objattackDic["hit1"] = {
		"power": 300 + int(RoleProp.baseroleprop.Level * 8), 
		"hurtBack": [-15, -12], 
		"attackKind": "physics", 
		"HitProtect": 10, 
	}
	self.objattackDic["hit2"] = {
		"power": 100 + int(RoleProp.baseroleprop.Level * 12), 
		"hurtBack": [-6, -10], 
		"attackKind": "physics", 
		"HitProtect": 10, 
	}
	self.objattackDic["hit3"] = {
		"power": 0, 
		"hurtBack": [0, 0], 
		"attackKind": "magic", 
		"HitProtect": 0, 
	}
	self.objattackDic["hit4"] = {
		"power": 100 + int(RoleProp.baseroleprop.Level * 10), 
		"hurtBack": [20, -10], 
		"attackKind": "magic", 
	}


	if is_boss_flag:
		self.fall_pro = 0.5
		self.fall_list = [{"name": "xzyj", "value": 1}]
	else:
		self.fall_pro = 0.0
		self.fall_list.clear()
	self.fall_stone_pro = 0
	self.fall_stone.clear()

func _ready() -> void :

	var is_clone = has_meta("is_clone") and get_meta("is_clone")
	init_monster( not is_clone)
	super._ready()

	Skill_1_CD = 2
	Skill_2_CD = 5
	Skill_3_CD = 0
	Skill_4_CD = 10
	instance_count += 1
	Global.combo_milestone_reached.connect(_on_combo_milestone_reached)

func _exit_tree():
	super._exit_tree()
	if Global.combo_milestone_reached.is_connected(_on_combo_milestone_reached):
		Global.combo_milestone_reached.disconnect(_on_combo_milestone_reached)
	instance_count -= 1

func Monster_Intelligence():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attackRange:
				have_target()
				if Skill_1_CD <= 0:
					do_hit_1()
				if Skill_2_CD <= 0:
					do_hit_2()



				if Skill_4_CD <= 0:
					do_hit_4()
			else:
				stop_move()
				if Skill_1_CD <= 0:
					do_hit_1()
				if Skill_2_CD <= 0:
					do_hit_2()


				if Skill_4_CD <= 0:
					do_hit_4()

func do_hit_1():
	if Skill_1_CD > 0 or is_attacking: return
	super.to_hero()
	Skill_1_CD = 2
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()

func do_hit_2():
	if Skill_2_CD > 0 or is_attacking: return
	super.to_hero()
	Skill_2_CD = randi_range(15, 20)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()

func do_hit_3():
	if Skill_3_CD > 0 or is_attacking: return
	if instance_count >= MAX_SUMMON_COUNT:
		return
	super.to_hero()
	Skill_3_CD = 20
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	_is_casting_skill = true
	mr_player.play("hit3")
	await get_tree().create_timer(0.2).timeout
	summon_clone()
	await mr_player.animation_finished
	_is_casting_skill = false
	is_attacking = false
	stop_move()

func do_hit_4():
	if Skill_4_CD > 0 or is_attacking: return
	super.to_hero()
	Skill_4_CD = randi_range(20, 25)
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func _on_hurt_box_area_entered(area):
	if _is_casting_skill:
		return
	super._on_hurt_box_area_entered(area)














func summon_clone() -> void :
	if instance_count >= MAX_SUMMON_COUNT:
		return
	var scene_path = scene_file_path
	if not scene_path:
		return


	var new_monster = Global.preload_scene_path(scene_path).instantiate()
	if not new_monster:
		return


	new_monster.set_meta("is_clone", true)

	new_monster.set_meta("original_monster", self)



	new_monster.SHp = int(self.SHp * 0.5)
	new_monster.Hp = new_monster.SHp
	new_monster.def = int(self.def * 0.5)
	new_monster.mdef = int(self.mdef * 0.5)
	new_monster.crit = int(self.crit * 0.5)
	new_monster.miss = int(self.miss * 0.5)
	new_monster.lucky = int(self.lucky * 0.5)
	new_monster.ar = int(self.ar * 0.5)
	new_monster.sp = int(self.sp * 0.5)
	new_monster.rush_speed = int(self.rush_speed * 0.5)
	new_monster.speed = int(self.speed * 0.5)


	for attack_key in self.objattackDic:

		if attack_key in new_monster.objattackDic:

			var original_power = self.objattackDic[attack_key]["power"]
			new_monster.objattackDic[attack_key]["power"] = int(original_power * 0.5)


	new_monster.position = position + Vector2(randi_range(-200, 200), randi_range(-30, 30))


	get_parent().add_child(new_monster)

func move_player_to_boss(movetime: float = 0.0):
	var player = get_Player
	if not player or not is_instance_valid(player):
		return

	var elapsed_time = 0.0
	var max_radius = 2000
	var min_radius = 5
	var base_pull = 8

	while true:

		if not is_instance_valid(self) or not is_inside_tree():
			return

		if movetime > 0 and elapsed_time >= movetime:
			break

		var distance = position.distance_to(player.position)
		if distance < min_radius:
			break

		if distance < max_radius:
			var pull_strength = (max_radius - distance) / max_radius
			pull_strength = clamp(pull_strength * base_pull, 0.5, base_pull * 1.5)
			var direction = (position - player.position).normalized()
			player.position += direction * pull_strength

		await get_tree().process_frame
		elapsed_time += get_process_delta_time()

func CallBullet2():
	var offset_values = [10, 20, 30, 40, 50, 60]
	var bullet_spacing = 0.2
	var wave_count = 6

	for i in range(wave_count):

		var abs_val = offset_values[randi() % offset_values.size()]

		var y_offset = abs_val if randi() % 2 == 0 else - abs_val


		var po: Vector2
		if MonsterDirection:
			po = Vector2(30, 0)
		else:
			po = Vector2(-30, 0)


		var bullet_dir = !MonsterDirection

		Global.add_Bullet("Monster63Bullet1", bullet, bullet_dir, 1, position + po + Vector2(0, y_offset), "hit2", self.objattackDic["hit2"])

		await get_tree().create_timer(bullet_spacing, false).timeout



func _on_combo_milestone_reached(milestone: int):
	if has_meta("is_clone") and get_meta("is_clone"):
		return
	if _combo_skill_queued:
		return
	if instance_count >= MAX_SUMMON_COUNT:
		return
	if Skill_3_CD > 0:
		return
	if is_attacking:
		return
	_combo_skill_queued = true
	call_deferred("_run_combo_milestone_skill")

func _run_combo_milestone_skill() -> void :
	var tree: = get_tree()
	if tree == null:
		return
	await tree.process_frame
	await tree.process_frame
	if not is_inside_tree() or is_queued_for_deletion():
		return
	_combo_skill_queued = false
	if has_meta("is_clone") and get_meta("is_clone"):
		return
	if instance_count >= MAX_SUMMON_COUNT or Skill_3_CD > 0 or is_attacking:
		return
	do_hit_3()
