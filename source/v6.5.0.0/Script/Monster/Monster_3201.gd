extends BaseMonster
var get_hero: BaseHero
@onready var wing: AnimatedSprite2D = $MonsterDir/Wing

@onready var mr_player_1: AnimationPlayer = $mr_player


func monster_3201():
	current_ = 0
	self.is_boss = true
	self.my_mr_name = "白骨精·改"
	self.attack_in = 120
	self.level = 30
	self.SHp = 20000
	self.Hp = self.SHp
	self.def = 150
	self.mdef = 150
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.Htarget = 0
	self.Toughness = 0
	self.ar = 30
	self.sp = 30
	self.Critreduce = 0
	self.speed = 9
	self.mysee = 300
	self.attackRange = 85
	self.attackDesire = 50
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.objattackDic["hit1"] = {"power": 350, "hurtBack": [-3, -9], "attackKind": "physics"}
	self.objattackDic["dmzw"] = {
		"power": 0,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "EyeFix",
			"AddTime": 5,
			"CanAdd": false,
			"DeBuff": true,
			"ReduceInterval": 0,
			"value": 0,
			"AttackKind": "",
		}
	}
	self.objattackDic["dmlhc"] = {
		"power": 280,
		"hurtBack": [-6, -8],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Bleed",
			"CanAdd": true,
			"AddTime": 2,
			"ReduceInterval": 0.5,
			"value": 5 + int(RoleProp.roleprop.SHp * 0.01),
			"AttackKind": "physics",
		}
	}
	self.fall_pro = 0.3
	self.fall_list = [
		{"name": "bsxj", "value": 0},
		{"name": "bszj", "value": 0},
		{"name": "bsyz", "value": 0},
		{"name": "bsbc", "value": 0},
		{"name": "bshq", "value": 0},
	]

	enable_treasure_box = true
	self.fall_stone_pro = 0
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_3201()
	is_bounds = false
	Skill_1_CD = 0
	Skill_2_CD = 0
	wing.set_frame_and_progress(0, true)


func Monster_Intelligence():
	if self.current_ < 3:
		wing.set_frame_and_progress(self.current_, true)
	if not self.is_bounds:
		if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
			has_target = true
		if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
			if has_target == false:
				normal_state()
			else:
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attackRange:
					have_target()
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 150:
						if Skill_1_CD <= 0:
							do_hit_1()
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 400:
						if Skill_2_CD <= 0:
							do_hit_3()
				else:
					if Skill_1_CD <= 0:
						do_hit_1()
					elif Skill_2_CD <= 0:
						do_hit_3()
					elif count % 60 == 0:
						attack_target()
					else:
						stop_move()


func attack_target():
	super.attack_target()


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


func state_death():
	super.state_death()
