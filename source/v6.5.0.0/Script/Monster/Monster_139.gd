extends BaseMonster
var ShowBox: bool = false
var BigBody: bool = false
var CanMove: bool = false
var CanAttack: bool = false
var SecondHurt: int
var AllHurt: int
var IsAttacking: bool
var AttackingCount: int
var AttackTime: int
var EveryHurt: int
@onready var remove_all_hurt: Timer = $RemoveAllHurt
@onready var total_dam: Label = $HurtInfo/TotalDam
@onready var total_dam_2: Label = $HurtInfo/TotalDam2
@onready var total_dam_3: Label = $HurtInfo/TotalDam3

@onready var buttonlist: VBoxContainer = $buttonlist
@onready var bt: Button = $buttonlist/bt
@onready var bt_2: Button = $buttonlist/bt2
@onready var bt_3: Button = $buttonlist/bt3
var ShowBoxCount: int = 0
var _last_all_hurt: int = -1
var _last_second_hurt: int = -1
var _last_every_hurt: int = -1
var _last_big_body := not BigBody
var _last_can_move := not CanMove
var _last_can_attack := not CanAttack


func monster_139():
	self.is_boss = true
	self.my_mr_name = "草木皆兵"
	self.attack_in = 0
	self.level = 5
	self.SHp = 5000000000
	self.Hp = self.SHp
	self.def = 100
	self.mdef = 100
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.Htarget = 0
	self.Toughness = 0
	self.ar = 0
	self.sp = 0
	self.Critreduce = 0
	self.speed = 10
	self.mysee = 300
	self.attackRange = 145
	self.attackDesire = 70
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.objattackDic["hit1"] = {
		"power": 1000,
		"hurtBack": [-3, -6],
		"attackKind": "physics",
		"HitProtect": 10,
	}
	self.fall_pro = 0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_139()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("假人攻击"):
		if CanAttack:
			CanAttack = false
		else:
			CanAttack = true
	if Input.is_action_just_pressed("假人霸体"):
		if BigBody:
			BigBody = false
		else:
			BigBody = true
	if Input.is_action_just_pressed("假人移动"):
		if CanMove:
			CanMove = false
		else:
			CanMove = true
	if IsAttacking:
		AttackingCount += 1
		if AttackingCount % 60 == 0:
			AttackTime += 1
	if AllHurt != _last_all_hurt:
		_last_all_hurt = AllHurt
		if AllHurt > 0:
			total_dam.text = "累计受到伤害：" + str(AllHurt)
		else:
			total_dam.text = ""
	var current_second_hurt := int(AllHurt) / int(AttackTime) if AttackTime > 0 and AllHurt > 0 else 0
	if current_second_hurt != _last_second_hurt:
		_last_second_hurt = current_second_hurt
		SecondHurt = current_second_hurt
		if SecondHurt > 0:
			total_dam_2.text = "每秒受到伤害：" + str(SecondHurt)
		else:
			total_dam_2.text = ""
	if EveryHurt != _last_every_hurt:
		_last_every_hurt = EveryHurt
		if EveryHurt > 0:
			total_dam_3.text = "每一秒受到伤害：" + str(EveryHurt)
		else:
			total_dam_3.text = ""
	if BigBody != _last_big_body:
		_last_big_body = BigBody
		bt.text = "当前不可击退，快捷键：Q" if BigBody else "当前可以击退，快捷键：Q"
	if CanMove != _last_can_move:
		_last_can_move = CanMove
		bt_2.text = "当前可以移动，快捷键：R" if CanMove else "当前不可移动，快捷键：R"
	if CanAttack != _last_can_attack:
		_last_can_attack = CanAttack
		bt_3.text = "当前可以攻击，快捷键：E" if CanAttack else "当前不可攻击，快捷键：E"

	super._physics_process(delta)


func ai_think():
	if CanMove:
		if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
			has_target = true
		if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt() and not is_Immobilize:
			if has_target == false:
				normal_state()
			else:
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attackRange:
					have_target()
				else:
					stop_move()
					if CanAttack:
						if count % 60 == 0:
							if randi_range(0, 100) < attackDesire:
								attack_target()
	else:
		if not is_be_attacking:
			stop_move()


func state_hurt():
	is_jgz = false
	if BigBody:
		is_be_attacking = false
		return
	super.state_hurt()


func _on_buttonlist_mouse_entered() -> void:
	ShowBox = true


func _on_bt_pressed() -> void:
	if BigBody:
		BigBody = false
	else:
		BigBody = true


func _on_bt_2_pressed() -> void:
	if CanMove:
		CanMove = false
	else:
		CanMove = true


func _on_bt_3_pressed() -> void:
	if CanAttack:
		CanAttack = false
	else:
		CanAttack = true


func _on_buttonlist_mouse_exited() -> void:
	ShowBox = false


func hurt_reduce_hp(value, target):
	IsAttacking = true
	var skip_mds_combo: bool = (
		target is BaseBuff and str(target.BuffInfo.get("Name", "")) == "Voodoo" and _is_mds_awaken_active()
	)
	if value > 0:
		remove_all_hurt.start(4)
	if Monster_18_protect():
		cure_hp(value * 1)
		return 0
	if Monster102Protect():
		cure_hp(value)
		return 0
	if IsIndestructible:
		if value >= Hp:
			return 0
	if skip_mds_combo:
		set_meta("mds_awaken_skip_combo", true)
	var last_value = hd_reduce(value)
	if skip_mds_combo:
		remove_meta("mds_awaken_skip_combo")
	Hp -= last_value
	if not skip_mds_combo:
		total_hurt += last_value
	_apply_damage_vampirism(target, int(last_value))
	EveryHurt += last_value
	AllHurt += last_value
	if last_value > 0:
		addHurtText(last_value, target)
	else:
		if is_miss:
			addHurtText(last_value, target)
	is_crit = false
	is_miss = false
	return int(last_value)


func reduce_hp(value: int):
	IsAttacking = true
	if value > 0:
		remove_all_hurt.start(4)
	if Monster_18_protect():
		cure_hp(value * 1)
		return 0
	if Monster102Protect():
		cure_hp(value)
		return 0
	if IsIndestructible:
		if value >= Hp:
			return 0
	var last_value = hd_reduce(value)
	Hp -= last_value
	if not bool(get_meta("mds_awaken_skip_combo", false)):
		total_hurt += last_value
	AllHurt += last_value
	EveryHurt += last_value
	Global.TotalRoleHit += last_value
	Global.TotalRealHit += last_value
	var pp = get_parent().get_parent()
	var po = Vector2(self.position.x - 20, self.position.y - 240)
	if last_value > 0:
		Global.add_damage_text(pp, po, last_value, "real", false, self)
	is_crit = false
	is_miss = false


func _on_remove_all_hurt_timeout() -> void:
	AllHurt = 0
	AttackTime = 0
	IsAttacking = false
	AttackingCount = 0


func _on_every_second_timeout() -> void:
	EveryHurt = 0


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func HurtReduceHp(value, target):
	return hurt_reduce_hp(value, target)
