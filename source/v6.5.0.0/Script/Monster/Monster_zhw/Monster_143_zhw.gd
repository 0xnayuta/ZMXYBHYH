extends SummonBaseMonster
class_name Monster143zhw

const BODY_ATLAS_MANIFEST: = "res://Art/Monster/Monster143zhw/atlas/manifest.json"

var _body_stream: StreamedPngEffect
var _body_action: StringName = &""
@onready var body_animation: AnimatedSprite2D = $MonsterDir / mr_ani


var my_summoner: role2 = null




var is_skill_1_active: bool = false
var is_skill_2_active: bool = false
var is_skill_3_active: bool = false
var is_skill_4_active: bool = false
var is_skill_5_active: bool = false
var is_skill_6_active: bool = false




func _ready():
	super._ready()
	add_to_group("Monster143zhw")
	set_meta("is_summon", true)
	RoleProp.register_monster_attack_target(self)
	_sync_body_visual()

func _exit_tree() -> void :
	RoleProp.unregister_monster_attack_target(self)
	super._exit_tree()

func _physics_process(delta: float) -> void :
	super._physics_process(delta)
	_sync_body_visual()

func _sync_body_visual() -> void :
	var action: = body_animation.animation
	if action != _body_action:
		_replace_body_stream(action)
	if _body_stream == null or not is_instance_valid(_body_stream):
		return
	_body_stream.position = body_animation.offset
	_body_stream.modulate = body_animation.self_modulate
	_body_stream.flip_h = body_animation.flip_h
	_body_stream.show_frame(body_animation.frame)

func _replace_body_stream(action: StringName) -> void :
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.clear_texture()
		_body_stream.queue_free()
	_body_stream = null
	_body_action = action
	var stream: = StreamedPngEffect.new()
	stream.name = "BodyStream"
	if not MonsterAtlasSequence.configure_stream(stream, BODY_ATLAS_MANIFEST, str(action)):
		stream.free()
		return
	stream.manual_frame_control = true
	stream.auto_free = false
	stream.hold_last_frame = true
	stream.modulate = body_animation.self_modulate
	stream.flip_h = body_animation.flip_h
	stream.position = body_animation.offset
	stream.texture_filter = body_animation.texture_filter
	body_animation.add_child(stream)
	_body_stream = stream

func initialize_monster_properties():
	var owner_power: = int(RoleProp.roleprop.power)

	SHp = int(RoleProp.roleprop.SHp)
	Hp = SHp
	is_Fly = true
	def = int(RoleProp.roleprop.Def)
	mdef = int(RoleProp.roleprop.Mdef)
	crit = int(RoleProp.roleprop.Crit)
	miss = int(RoleProp.roleprop.Miss)
	lucky = int(RoleProp.roleprop.Lucky)

	rush_speed = 600
	my_mr_name = "正法金刚"
	level = int(RoleProp.baseroleprop.Level)
	is_boss = true
	attack_in = 90
	Toughness = int(RoleProp.roleprop.Toughness)
	Htarget = int(RoleProp.roleprop.Htarget)
	ar = int(RoleProp.roleprop.ar)
	sp = int(RoleProp.roleprop.sp)
	Critreduce = int(RoleProp.roleprop.CritReduce)
	behit_calmtime = 0
	self_rhp = int(RoleProp.roleprop.R_hp)
	ebol = 0


	attackRange = 350
	mysee = 99990
	speed = 20
	attackDesire = 80


	objattackDic["hit1"] = {
		"power": owner_power * 2, 
		"hurtBack": [-8, -10], 
		"attackKind": "magic", 
		"HitProtect": 0, 
	}
	objattackDic["hit2"] = {
		"power": owner_power * 4, 
		"hurtBack": [-20, -10], 
		"attackKind": "magic", 
		"HitProtect": 0, 
	}
	objattackDic["hit3"] = {
		"power": owner_power * 6, 
		"hurtBack": [-15, -10], 
		"attackKind": "magic", 
		"HitProtect": 0, 
		"addeffect": {
			"Name": "DefeReduce", 
			"AddTime": 20, 
			"ReduceInterval": 0, 
			"value": 0.3, 
			"AttackKind": "", 
			"DeBuff": true, 
			"CanRemove": false, 
		}
	}

func setup_skills():

	Skill_1_CD = 0
	Skill_2_CD = 2
	Skill_3_CD = 3


func Monster_Intelligence():

	if current_target == null or not is_instance_valid(current_target) or current_target.Hp <= 0:
		current_target = null
		has_target = false
		if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
			normal_state()
		return

	var distance = position.distance_to(current_target.position)
	has_target = true
	_to_monster()


	if is_ice or is_sleep or is_stun or cannotchangestatewhenattorbeatt():
		return


	if distance > 350:

		if Skill_3_CD <= 0:
			do_hit_3()
		else:
			have_target()

	elif distance > 175:

		if Skill_2_CD <= 0:
			stop_move()
			do_hit_2()
		else:
			have_target()

	else:

		stop_move()
		if Skill_3_CD <= 0:
			do_hit_3()
		elif Skill_2_CD <= 0:
			do_hit_2()
		elif Skill_1_CD <= 0:
			do_hit_1()


func do_hit_1():
	if is_attacking or is_be_attacking or ShouldInSky:
		return

	if current_target == null or position.distance_to(current_target.position) > 175:
		return

	Skill_1_CD = randi_range(1, 3)
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()

func do_hit_2():
	if is_attacking or is_be_attacking or ShouldInSky:
		return

	if current_target == null or position.distance_to(current_target.position) > 350:
		return
	Skill_2_CD = randi_range(5, 10)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()

func do_hit_3():
	if is_attacking or is_be_attacking or ShouldInSky:
		return

	if current_target == null or position.distance_to(current_target.position) > 600:
		return
	Skill_3_CD = randi_range(8, 12)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()

func _to_monster() -> void :
	if not is_instance_valid(current_target):
		return
	if current_target.position.x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1
