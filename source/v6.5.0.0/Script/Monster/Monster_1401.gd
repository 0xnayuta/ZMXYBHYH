extends BaseMonster
class_name Monster1401

var ShouldFly: bool
var IsCall: bool
var OnsetEatblood: bool
var RemoveBlood: bool

func monster_1401():

	self.rush_speed = 420
	self.is_boss = true
	self.my_mr_name = "花豹圣者·高友乾"
	self.attack_in = 95
	self.level = 55
	self.SHp = 600000
	self.Hp = self.SHp
	self.def = 420
	self.mdef = 420
	self.crit = 18
	self.miss = 38
	self.lucky = 45
	self.Htarget = 80
	self.Toughness = 5
	self.ar = 60
	self.sp = 60
	self.Critreduce = 5
	self.speed = 13
	self.mysee = 550
	self.attackRange = 350
	self.attackDesire = 75
	self.behit_calmtime = 0.18
	self.self_rhp = 2000
	self.add_exp = 2500
	self.fall_coin = 1000
	self.ebol = 0


	self.objattackDic["hit1"] = {
		"power": 550, 
		"hurtBack": [-8, -12], 
		"attackKind": "magic", 
		"HitProtect": 10, 
	}


	self.objattackDic["hit2"] = {
		"power": 440, 
		"hurtBack": [-10, -5], 
		"attackKind": "physics", 
		"HitProtect": 15, 
	}


	self.objattackDic["hit2_2"] = {
		"power": 600, 
		"hurtBack": [-10, -8], 
		"attackKind": "physics", 
		"HitProtect": 12, 
		"addeffect": {
			"Name": "Fire", 
			"AddTime": 2, 
			"ReduceInterval": 0.5, 
			"value": 500, 
			"AttackKind": "real", 
			"CanAdd": true, 
			"DeBuff": true, 
		}, 
	}


	self.objattackDic["hit2_3"] = {
		"power": 800, 
		"hurtBack": [-10, -10], 
		"attackKind": "magic", 
		"HitProtect": 8, 
		"addeffect": {
			"Name": "stun", 
			"AddTime": 2, 
			"ReduceInterval": 0, 
			"value": 0, 
			"AttackKind": "", 
			"CanAdd": false, 
			"DeBuff": true, 
		}, 
	}


	self.objattackDic["hit3"] = {
		"power": 0, 
		"hurtBack": [0, 0], 
		"attackKind": "magic", 
		"HitProtect": 9, 
		"addeffect": {
			"Name": "DefeReduce", 
			"AddTime": 8, 
			"ReduceInterval": 0, 
			"value": 0.8, 
			"AttackKind": "", 
			"CanAdd": false, 
			"DeBuff": true, 
		}, 
	}

	self.fall_pro = 0.5
	self.fall_list = [
		{
			"name": "241007001zzs", 
			"value": 1
		}, 
		{
			"name": "dzzzs", 
			"value": 1
		}, 
		{
			"name": "jtzzs", 
			"value": 1
		}, 
		{
			"name": "jszzs", 
			"value": 1
		}, 
		{
			"name": "ztzzs", 
			"value": 1
		}, 
		{
			"name": "tlzzs", 
			"value": 1
		}, 
	]
	self.fall_stone_pro = 0
	self.fall_stone = []

func _ready() -> void :
	super._ready()
	monster_1401()

	Skill_1_CD = 2
	Skill_2_CD = 5
	Skill_3_CD = 0
	Skill_4_CD = 0

func Monster_Intelligence():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true

	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if not has_target:
			normal_state()
		else:
			var distance = abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x)

			if distance >= attackRange:

				have_target()
				if Skill_2_CD <= 0 and distance > 200:
					do_hit_2()
				elif Skill_1_CD <= 0:
					do_hit_1()
			else:

				stop_move()
				var random_choice = randi_range(1, 100)

				if Skill_3_CD <= 0 and random_choice <= 30:
					do_hit_3()
				elif Skill_2_CD <= 0 and random_choice <= 60 and distance > 100:
					do_hit_2()
				elif Skill_1_CD <= 0:
					do_hit_1()


func do_hit_1():
	"普通攻击"
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
	"冲锋连招：冲锋→攻击→眩晕终结"
	super.to_hero()

	Skill_2_CD = randi_range(15, 20)
	is_attacking = true


	hit_name = "hit2"
	velocity.x = 0
	mr_player.play("hit2")


	var direction = 1 if monster_dir.scale.x == -1 else -1
	velocity.x = direction * rush_speed


	await get_tree().create_timer(0.5).timeout
	velocity.x = 0


	if mr_player.is_playing():
		await mr_player.animation_finished


	hit_name = "hit2_2"
	mr_player.play("hit2_2")
	await mr_player.animation_finished


	hit_name = "hit2_3"
	mr_player.play("hit2_3")
	await mr_player.animation_finished


	is_attacking = false
	stop_move()

func do_hit_3():
	"特殊技能 - 防御削减"
	super.to_hero()

	Skill_3_CD = randi_range(20, 25)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished


	Global.AddBuff(get_Player.buff, objattackDic["hit3"]["addeffect"])

	is_attacking = false
	stop_move()
