extends BaseMonster
var CureBl: float = 1


func monster_120():
	self.is_boss = false
	self.my_mr_name = "黑烟炼气师"
	self.attack_in = 30
	self.level = 55
	self.SHp = 45000
	self.Hp = self.SHp
	self.def = 355
	self.mdef = 365
	self.crit = 28
	self.miss = 28
	self.lucky = 40
	self.Htarget = 0
	self.Toughness = 35
	self.ar = 65
	self.sp = 65
	self.Critreduce = 0
	self.speed = 12
	self.mysee = 600
	self.attackRange = 135
	self.attackDesire = 85
	self.behit_calmtime = 0.4
	self.self_rhp = 0
	self.add_exp = 100
	self.fall_coin = 30
	self.objattackDic["hit1"] = {
		"power": 500,
		"hurtBack": [-4, -9],
		"attackKind": "physics",
		"HitProtect": 15,
	}
	self.objattackDic["hit2"] = {
		"power": 800,
		"hurtBack": [0, -7],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "lpzbuff",
			"AddTime": 5,
			"ReduceInterval": 0,
			"value": 0.4,
			"CanAdd": false,
			"CanRemove": false,
			"AttackKind": "",
		}
	}
	self.fall_pro = 0.5
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_120()
	Skill_1_CD = 6


func _physics_process(delta: float) -> void:
	super._physics_process(delta)


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attackRange:
				have_target()
				if Skill_1_CD <= 0:
					do_hit_2()
				if count % 90 == 0:
					if randi_range(0, 100) < attackDesire:
						attack_target()
						CallBullet1()
			else:
				if Skill_1_CD <= 0:
					do_hit_2()
				elif count % 60 == 0:
					var rad = randi_range(0, 100)
					if rad <= attackDesire:
						attack_target()
						CallBullet1()
				else:
					stop_move()


func do_hit_2():
	Skill_1_CD = 10
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	CallBullet2()
	await mr_player.animation_finished
	is_attacking = false


func call_bullet_1():
	var Bullets
	if self.MonsterDirection:
		Bullets = Global.add_bullet(
			"Monster120Bullet1", self.bullet, false, 1.5, Vector2(0, 0) + position, "hit1", self.objattackDic["hit1"]
		)
	else:
		Bullets = Global.add_bullet(
			"Monster120Bullet1", self.bullet, false, 1.5, Vector2(0, 0) + position, "hit1", self.objattackDic["hit1"]
		)
	Bullets.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func call_bullet_2():
	Global.add_bullet(
		"Monster120Bullet2",
		self.bullet,
		false,
		1.5,
		Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, 500),
		"hit2",
		self.objattackDic["hit2"]
	)


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func CallBullet1():
	return call_bullet_1()


## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func CallBullet2():
	return call_bullet_2()
