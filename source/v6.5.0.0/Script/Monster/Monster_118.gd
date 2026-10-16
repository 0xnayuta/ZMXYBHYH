extends BaseMonster
class_name Monster118


func monster_118():
	self.is_boss = false
	self.my_mr_name = "地狱练气师"
	self.attack_in = 20
	self.level = 55
	self.SHp = 45000
	self.Hp = self.SHp
	self.def = 300
	self.mdef = 300
	self.crit = 25
	self.miss = 25
	self.lucky = 0
	self.Htarget = 0
	self.Toughness = 0
	self.ar = 60
	self.sp = 60
	self.Critreduce = 0
	self.speed = 12
	self.mysee = 600
	self.attackRange = 225
	self.attackDesire = 80
	self.behit_calmtime = 0.1
	self.self_rhp = 0
	self.add_exp = 240
	self.fall_coin = 240
	self.objattackDic["hit1"] = {"power": 500, "hurtBack": [-6, -5], "attackKind": "magic"}
	self.objattackDic["hit2"] = {
		"power": 800,
		"hurtBack": [-6, -5],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "poision",
			"AddTime": 5,
			"CanAdd": true,
			"DeBuff": true,
			"CanRemove": false,
			"ReduceInterval": 1,
			"value": 900,
			"AttackKind": "magic",
		}
	}
	self.fall_pro = 0.0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_118()
	Skill_1_CD = 5


func Monster_Intelligence():
	var role_position_x = RoleProp.get_nearest_monster_target_position(global_position).x
	if role_position_x == null:
		has_target = false
		stop_move()
		return
	var distance := absf(float(role_position_x) - position.x)
	has_target = distance < mysee
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if distance > attackRange:
				have_target()
				if Skill_1_CD <= 0:
					if distance <= 300:
						do_hit_2()
					else:
						have_target()
				else:
					have_target()
			else:
				if Skill_1_CD <= 0:
					do_hit_2()
				else:
					if count % 90 == 0:
						attack_target()
					else:
						stop_move()


func do_hit_2():
	Skill_1_CD = 5
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false


func CallBullet1():
	var Bullets
	var bullet_parent: Node = self.bullet
	var level_node := get_level_node()
	if level_node != null:
		var level_bullet := level_node.get_node_or_null("Bullet")
		if level_bullet != null:
			bullet_parent = level_bullet
	elif get_tree() != null and get_tree().current_scene != null:
		bullet_parent = get_tree().current_scene
	var hit_data: Dictionary = self.objattackDic["hit2"].duplicate(true)
	if self.MonsterDirection:
		Bullets = Global.add_Bullet(
			"Monster118Bullet2", bullet_parent, false, 1, Vector2(35, 25) + global_position, "hit2", hit_data
		)
	else:
		Bullets = Global.add_Bullet(
			"Monster118Bullet2", bullet_parent, false, 1, Vector2(-35, 25) + global_position, "hit2", hit_data
		)
	if Bullets != null and get_Player != null:
		Bullets.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func state_death():
	mr_player.play("death")

	await mr_player.animation_finished

	CallBullet1()
	settle_death_drops_and_free()
