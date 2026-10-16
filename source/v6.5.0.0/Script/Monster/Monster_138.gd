extends BaseMonster
class_name Monster138
var MyTarget: BaseMonster
var LinkedTargets: Array[BaseMonster] = []


func set_linked_targets(targets: Array[BaseMonster]) -> void:
	LinkedTargets.clear()
	for target in targets:
		if target != null and is_instance_valid(target) and not LinkedTargets.has(target):
			LinkedTargets.append(target)
	MyTarget = LinkedTargets[0] if not LinkedTargets.is_empty() else null


func transfer_linked_damage(damage: int) -> void:
	if damage <= 0:
		return
	if LinkedTargets.is_empty():
		_transfer_damage_to_target(MyTarget, damage)
		return
	for target in LinkedTargets:
		_transfer_damage_to_target(target, damage)


func _transfer_damage_to_target(target: BaseMonster, damage: int) -> void:
	if target == null or not is_instance_valid(target) or target.Hp <= 0:
		return
	target.has_target = true
	target.reduce_hp(damage)


func _get_primary_target() -> BaseMonster:
	if MyTarget != null and is_instance_valid(MyTarget) and MyTarget.Hp > 0:
		return MyTarget
	for target in LinkedTargets:
		if target != null and is_instance_valid(target) and target.Hp > 0:
			MyTarget = target
			return target
	MyTarget = null
	return null


func monster_138():
	self.CannotAttract = true
	self.is_boss = false
	self.my_mr_name = "巫毒娃娃"
	self.attack_in = 90
	self.level = PlayerData.player_data[DataKeys.PLAYER_LEVEL]
	if self.SHp == 0:
		self.SHp = 100
		self.Hp = self.SHp

	else:
		self.Hp = self.SHp
	self.Hp = self.SHp
	self.def = 0
	self.mdef = 0
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.Htarget = 0
	self.Toughness = 0
	self.ar = 0
	self.sp = 0
	self.Critreduce = 0
	self.speed = 9
	self.mysee = 0
	self.attackRange = 0
	self.attackDesire = 0
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.objattackDic["hit1"] = {
		"power": 0,
		"hurtBack": [0, 0],
		"attackKind": "",
		"HitProtect": 0,
	}
	self.fall_pro = 0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_138()


func _physics_process(delta: float) -> void:
	if Hp <= 0:
		mr_player.play("death")
		return
	super._physics_process(delta)
	reset_pro()
	var primary_target := _get_primary_target()
	if primary_target == null:
		self.Hp = -100
	else:
		if self.position.x >= primary_target.position.x:
			move_left()
		else:
			move_right()


func ai_think():
	pass


func _on_hurt_box_area_entered(area: Area2D) -> void:
	is_jgz = false
	has_target = true
	if area is BaseRoleHitBox or area is RolehmzBullet:
		get_target = get_Player
	elif area is MagicWeaponHit:
		return
	elif area.get_parent() is Role1Shallow:
		get_target = area.get_parent()
	elif area is RoleBullet1:
		get_target = area
	elif area.get_parent().get_parent() is RoleBullet:
		get_target = area.get_parent().get_parent()
	else:
		return
	var last_hurt = get_role_last_hurt(get_target) * RoleProp.ws_up_power
	last_hurt *= (0.8 + PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能9"][DataKeys.LEVEL] * 0.005)
	if last_hurt >= Hp:
		last_hurt = Hp
	GetHurt = last_hurt
	if get_Player is BaseHero:
		if get_Player.is_DeadLink:
			get_Player.effect_reducehp(last_hurt, "real")
	cure_ws_value()
	hurt_reduce_hp(last_hurt, get_target)
	transfer_linked_damage(last_hurt)
	Global.TotalRoleHit += last_hurt
	if get_target is BaseHero or get_target is MgHit or get_target is Role1Shallow or get_target is RoleBullet:
		match get_target.HitDic["attackKind"]:
			"physics":
				Global.TotalPhyHit += last_hurt
			"magic":
				Global.TotalMagHit += last_hurt
			"real":
				Global.TotalRealHit += last_hurt
	if not is_miss and last_hurt > 0:
		if MainSet.set_data["MonsterLittleBlood"]:
			if monster_blood_bar == null:
				monster_blood_bar = Global.add_monster_blood(self, Vector2(-30, -90), Hp / float(SHp), Hp)
		Global.add_sound(self, "res://Music/MonsterHurt/6_BeattackByRole1.mp3")
		HurtSpecialEffect = Global.add_mr_hurt(pz, Vector2(0, 0))
	get_target = null


func reset_pro():
	var primary_target := _get_primary_target()
	if primary_target != null:
		self.Toughness = primary_target.Toughness
		self.def = primary_target.def
		self.mdef = primary_target.mdef
		self.Critreduce = primary_target.Critreduce
		self.miss = primary_target.miss


func cure_hp(value: int):
	pass


func _on_death_count_timeout() -> void:
	Hp = -100


func wd_hurt():
	pass
