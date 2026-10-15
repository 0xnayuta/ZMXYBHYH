extends BaseMonster
class_name Boss_Xss
var CurrentStage: int = 0
var IsRelif: bool
var is_have_wdww: bool = false
var wdww: Boss_XieShaSeng_Wdww
func monster_79():
	self.rush_speed = 600
	self.is_boss = true
	self.my_mr_name = "邪沙僧"
	self.attack_in = 15
	self.level = 45
	self.SHp = 200000
	self.Hp = self.SHp
	self.def = 150
	self.mdef = 180
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.Htarget = 0
	self.Toughness = 20
	self.ar = 50
	self.sp = 50
	self.Critreduce = 0
	self.speed = 15
	self.mysee = 200
	self.attackRange = 200
	self.attackDesire = 90
	self.behit_calmtime = 0.3
	self.IsSmartMonster = true
	self.self_rhp = 0
	self.add_exp = 20
	self.fall_coin = 0
	self.objattackDic["hit1"] = {
		"power": 400, 
		"hurtBack": [-7, -9], 
		"attackKind": "physics", 
		"HitProtect": 10
	}
	self.objattackDic["hit2"] = {
		"power": 2000, 
		"hurtBack": [-7, -15], 
		"attackKind": "magic", 
		"HitProtect": 25, 
		"addeffect": {
			"Name": "stun", 
			"AddTime": 1.5, 
			"ReduceInterval": 0, 
			"value": 0, 
			"AttackKind": "", 
		}
	}
	self.objattackDic["hit3"] = {
		"power": 2000, 
		"hurtBack": [-16, -9], 
		"attackKind": "magic", 
		"HitProtect": 8, 
		"addeffect": {
			"Name": "speed_down", 
			"AddTime": 1, 
			"ReduceInterval": 0, 
			"value": 0.2, 
			"AttackKind": "", 
		}
	}
	self.fall_pro = 0.25
	self.fall_list = [
		{
			"name": "lxfs1", 
			"value": 0
		}, 
		{
			"name": "lxfs2", 
			"value": 0
		}, 
		{
			"name": "lxfs3", 
			"value": 0
		}, 
	]
	self.fall_stone_pro = 0
	self.fall_stone = [

	]
func _ready() -> void :
	super._ready()
	monster_79()
	Skill_1_CD = 0
	Skill_2_CD = 0









func Monster_Intelligence():

	var wdww_call_chance: float = 0.3
	var wdww_cooldown: float = 8.0
	var wdww_timer: float = 0.0


	if wdww_timer > 0:
		wdww_timer -= get_process_delta_time()


	if abs(RoleProp.role_pos_x - position.x) < mysee:
		has_target = true


	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:

			normal_state()

		else:
			if abs(position.x - RoleProp.role_pos_x) > attackRange:
				have_target()
				if abs(position.x - RoleProp.role_pos_x) <= 270:
					if Skill_2_CD <= 0:
						do_hit_2()
				if Skill_3_CD <= 0:
					do_hit_3()
			else:
				stop_move()
				if Skill_2_CD <= 0:
					do_hit_2()
				if Skill_3_CD <= 0:
					do_hit_3()





			if wdww_timer <= 0 and randf() <= wdww_call_chance and not is_have_wdww:
				CallWDWW()
				is_have_wdww = true
				wdww_timer = wdww_cooldown


func do_hit_2():
	to_hero()
	Skill_2_CD = 5
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
func do_hit_3():
	to_hero()
	Skill_3_CD = 8
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
func destroy():
	CurrentStage += 1
	if CurrentStage >= 3:
		fall_items()
		fall_medicine()
		fall_stone_()
		Global.GameFrame.pool_mgr_component.release_object(wdww)
		await mr_player.animation_finished
		self.queue_free()
	var tween = create_tween()
	match CurrentStage:
		1:
			tween.tween_property(self, "scale", Vector2(1.1, 1.1), 1)
			await get_tree().create_timer(0.8, false).timeout
			self.def = 200
			self.mdef = 200
			self.SHp = 250000
			self.speed = 12
			self.miss = 100
			self.objattackDic["hit1"] = {
				"power": 500, 
				"hurtBack": [-7, -9], 
				"attackKind": "physics", 
				"HitProtect": 10
			}
			self.objattackDic["hit2"] = {
				"power": 500, 
				"hurtBack": [-7, -15], 
				"attackKind": "magic", 
				"HitProtect": 25, 
				"addeffect": {
					"Name": "stun", 
					"AddTime": 2, 
					"ReduceInterval": 0, 
					"value": 0, 
					"AttackKind": "", 
				}
			}
			self.objattackDic["hit3"] = {
				"power": 500, 
				"hurtBack": [-16, -9], 
				"attackKind": "magic", 
				"HitProtect": 8, 
				"addeffect": {
					"Name": "speed_down", 
					"AddTime": 1, 
					"ReduceInterval": 0, 
					"value": 0.2, 
					"AttackKind": "", 
				}
			}
			set_fullHp()
		2:
			tween.tween_property(self, "scale", Vector2(0.8, 0.8), 1)
			await get_tree().create_timer(0.8, false).timeout
			self.def = 1500
			self.mdef = 1500
			self.SHp = 300000
			self.speed = 50
			self.miss = 150
			self.objattackDic["hit1"] = {
				"power": 900, 
				"hurtBack": [-7, -9], 
				"attackKind": "physics", 
				"HitProtect": 10
			}
			self.objattackDic["hit2"] = {
				"power": 900, 
				"hurtBack": [-7, -15], 
				"attackKind": "magic", 
				"HitProtect": 25, 
				"addeffect": {
					"Name": "stun", 
					"AddTime": 3, 
					"ReduceInterval": 0, 
					"value": 0, 
					"AttackKind": "", 
				}
			}
			self.objattackDic["hit3"] = {
				"power": 900, 
				"hurtBack": [-16, -9], 
				"attackKind": "magic", 
				"HitProtect": 8, 
				"addeffect": {
					"Name": "speed_down", 
					"AddTime": 2, 
					"ReduceInterval": 0, 
					"value": 0.5, 
					"AttackKind": "", 
				}
			}
			set_fullHp()


func call_attack2_bullet():
	velocity.x = 0
	var fz
	var dir = self.MonsterDirection
	if dir:
		fz = Global.CallFlyBullet(self.bullet, "Monster17Bullet", 1, Vector2(position.x + 100, 400), 1000, -3400, "hit2", self.objattackDic["hit2"])
		fz.animated_sprite_2d.flip_v = false
	else:
		fz = Global.CallFlyBullet(self.bullet, "Monster17Bullet", 1, Vector2(position.x - 100, 400), 1000, 3400, "hit2", self.objattackDic["hit2"])
		fz.animated_sprite_2d.flip_v = false


func call_attack3_bullet():
	velocity.x = 0
	var fz
	var dir = self.MonsterDirection
	if dir:
		fz = Global.CallFlyBullet(self.bullet, "Monster63Bullet", 1, Vector2(position.x + 100, 450), 1000, -3400, "hit3", self.objattackDic["hit3"])
		fz.animated_sprite_2d.flip_v = false
	else:
		fz = Global.CallFlyBullet(self.bullet, "Monster63Bullet", 1, Vector2(position.x - 100, 450), 1000, 3400, "hit3", self.objattackDic["hit3"])
		fz.animated_sprite_2d.flip_v = false



func CallWDWW():
	var Position: Vector2
	if direction >= 0:
		Position = Vector2(30, -30)
	else:
		Position = Vector2(-30, -30)
	wdww = Global.GameFrame.pool_mgr_component.GetObject(preload("res://Scene/Boss/邪沙僧/Boss_XieShaSeng_Wdww.tscn"), get_parent())
	wdww.entity = self







func state_hurt():
	is_jgz = false
	if CurrentStage >= 2:
		is_be_attacking = false
		return
	super.state_hurt()
