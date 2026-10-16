extends BaseMonster
class_name Monster62

var ShouldFly: bool
var IsCall: bool
var OnsetEatblood: bool
var RemoveBlood: bool


func monster_62():
	self.is_boss = false
	self.my_mr_name = "蛇棒"
	self.attack_in = 15
	self.level = RoleProp.baseroleprop.Level
	self.SHp = 105000
	self.Hp = self.SHp
	self.def = 0
	self.mdef = 0
	self.crit = 35
	self.miss = 0
	self.lucky = 0
	self.Htarget = 0
	self.Toughness = 0
	self.ar = 150
	self.sp = 150
	self.Critreduce = 0
	self.speed = 0
	self.mysee = 600
	self.attackRange = 600
	self.attackDesire = 60
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 200
	self.ebol = 0

	self.objattackDic["hit1"] = {
		"power": 300,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
	}

	self.fall_pro = 0.5
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_62()

	Skill_1_CD = 0


func ai_think():
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
				if Skill_3_CD <= 0:
					do_hit_3()
				if Skill_4_CD <= 0:
					do_hit_4()

			else:
				stop_move()
				if Skill_1_CD <= 0:
					do_hit_1()
				if Skill_2_CD <= 0:
					do_hit_2()
				if Skill_3_CD <= 0:
					do_hit_3()
				if Skill_4_CD <= 0:
					do_hit_4()


func do_hit_1():
	if Skill_1_CD > 0 or is_attacking:
		return
	super.to_hero()
	Skill_1_CD = 3
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_bullet_1():
	var po: Vector2
	if MonsterDirection:
		po = Vector2(50, -40)
	else:
		po = Vector2(-50, -40)
	var child = Global.add_bullet(
		"Monster62bull1", bullet, MonsterDirection, 2, position + po, "hit1", self.objattackDic["hit1"]
	)


func state_hurt():
	super.state_hurt()

	velocity.x = 0
	velocity.y = 0


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func CallBullet1():
	return call_bullet_1()
