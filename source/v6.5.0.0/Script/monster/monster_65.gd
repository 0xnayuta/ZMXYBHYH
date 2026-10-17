extends BaseMonster
class_name Monster65
const BODY_ATLAS_MANIFEST := "res://Art/Monster/Monster_65/atlas/manifest.json"

var is_top = false
var is_drop = false
var zz_list: Array[BaseMonster] = []
var _body_stream: StreamedPngEffect
var _body_action: StringName = &""


func monster_65():
	self.rush_speed = 600
	self.is_boss = true
	self.my_mr_name = "五毒·都市王"
	self.attack_in = 15
	self.level = RoleProp.baseroleprop.Level + 1
	self.SHp = 220000 + int(RoleProp.baseroleprop.Level * 16000)
	self.Hp = self.SHp
	self.def = 180 + int(RoleProp.baseroleprop.Level * 4.0)
	self.mdef = 180 + int(RoleProp.baseroleprop.Level * 4.0)
	self.crit = 5 + int(RoleProp.baseroleprop.Level * 1.2)
	self.miss = 5 + int(RoleProp.baseroleprop.Level * 0.6)
	self.lucky = 0 + int(RoleProp.baseroleprop.Level * 1.8)
	self.Htarget = 0
	self.Toughness = 0
	self.ar = 20 + int(RoleProp.baseroleprop.Level * 1.0)
	self.sp = 20 + int(RoleProp.baseroleprop.Level * 1.0)
	self.Critreduce = 0
	self.speed = 13
	self.mysee = 500
	self.attack_range = 250
	self.attack_desire = 60
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {
		"power": 400 + int(RoleProp.baseroleprop.Level * 8.6),
		"hurtBack": [-4, -9],
		"attackKind": "physics",
		"HitProtect": 10
	}
	self.obj_attack_dict["zhzz"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "physics", "HitProtect": 10}
	self.obj_attack_dict["hit2_1"] = {
		"power": 400 + int(RoleProp.baseroleprop.Level * 8.5),
		"hurtBack": [0, 0],
		"attackKind": "physics",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "Boundground",
			"AddTime": 4,
			"ReduceInterval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true,
			"CanAdd": false,
		}
	}
	self.obj_attack_dict["hit2_2"] = {
		"power": 600 + int(RoleProp.baseroleprop.Level * 8.7),
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 25,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 3,
			"ReduceInterval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.fall_pro = 0.15
	self.fall_list = [
		{"name": "zzyj", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_65()
	Skill_1_CD = 20
	Skill_2_CD = 10
	Skill_3_CD = 15
	_sync_body_visual()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_sync_body_visual()


func _sync_body_visual() -> void:
	var action := mr_ani.animation
	if action != _body_action:
		_replace_body_stream(action)
	if _body_stream == null or not is_instance_valid(_body_stream):
		return
	_body_stream.position = mr_ani.offset
	_body_stream.modulate = mr_ani.self_modulate
	_body_stream.flip_h = mr_ani.flip_h
	_body_stream.show_frame(mr_ani.frame)


func _replace_body_stream(action: StringName) -> void:
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.clear_texture()
		_body_stream.queue_free()
	_body_stream = null
	_body_action = action
	var stream := StreamedPngEffect.new()
	stream.name = "BodyStream"
	if not MonsterAtlasSequence.configure_stream(stream, BODY_ATLAS_MANIFEST, str(action)):
		stream.free()
		return
	stream.manual_frame_control = true
	stream.auto_free = false
	stream.hold_last_frame = true
	stream.modulate = mr_ani.self_modulate
	stream.flip_h = mr_ani.flip_h
	stream.position = mr_ani.offset
	stream.texture_filter = mr_ani.texture_filter
	mr_ani.add_child(stream)
	_body_stream = stream


func ai_think():
	if is_top:
		if not is_drop:
			velocity.y = -5
		return
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attack_range:
				have_target()
				if Skill_1_CD <= 0:
					do_hit_1()
				if Skill_2_CD <= 0:
					do_skill_2_1()
				if (
					count % 60 == 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 250
				):
					attack_target()
				if Skill_3_CD <= 0:
					do_hit_3()
			else:
				stop_move()
				if Skill_1_CD <= 0:
					do_hit_1()
				if Skill_2_CD <= 0:
					do_skill_2_1()
				if (
					count % 60 == 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 250
				):
					attack_target()
				if Skill_3_CD <= 0:
					do_hit_3()


func return_body():
	mr_ani.position = Vector2(0, 0)


func await_t_otop():
	is_top = true
	is_drop = false
	self.position = Vector2(self.position.x, 0)
	return_body()


func fall():
	velocity.y += 800
	is_top = true
	is_drop = true
	self.position = Vector2(self.position.x, self.position.y)


func return_normal():
	return_body()
	is_top = false
	is_drop = false


func do_hit_1():
	super.to_hero()
	Skill_1_CD = randi_range(30, 35)
	hit_name = "zhzz"
	velocity.x = 0
	is_attacking = true
	mr_player.play("zhzz")
	await mr_player.animation_finished
	is_attacking = false


func do_skill_2_1():
	super.to_hero()
	Skill_2_CD = randi_range(15, 20)
	hit_name = "zhzz"
	velocity.x = 0
	is_attacking = true
	mr_player.play("totop")
	await mr_player.animation_finished
	is_attacking = false
	await get_tree().create_timer(randi_range(0.5, 2), false).timeout
	do_skill_2_2()


func do_skill_2_2():
	super.to_hero()
	velocity.x = 0
	is_attacking = true
	self.position = Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, 300)
	if randi_range(0, 100) <= 50:
		hit_name = "hit2_1"
		mr_player.play("fall2")
	else:
		hit_name = "hit2_2"
		mr_player.play("fall")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	super.to_hero()
	Skill_3_CD = randi_range(20, 30)
	hit_name = "zhzz"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false


func move_to_player_local():
	self.position = RoleProp.get_nearest_monster_target_position(global_position)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	super._on_hurt_box_area_entered(area)
	if randi_range(0, 100) < 5:
		(
			Global
			. add_buff(
				get_player.buff,
				{
					"Name": "poision",
					"AddTime": 5,
					"ReduceInterval": 1,
					"value": 100,
					"AttackKind": "real",
					"DeBuff": true,
					"CanAdd": true,
				}
			)
		)


func call_wang():
	if MonsterDirection:
		Global.add_monster65_bullet(self.bullet, position + Vector2(240, -55))
	else:
		Global.add_monster65_bullet(self.bullet, position + Vector2(-240, -55))


func call_zz():
	for i in range(randi_range(2, 4)):
		Global.create_monster(66, get_parent(), position + Vector2(randi_range(-200, 200), 0))
