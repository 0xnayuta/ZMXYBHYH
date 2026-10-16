extends BaseMonster
class_name Monster140801

var my_target: BaseHero


func monster_140801():
	self.cannot_attract = true
	self.is_boss = false
	self.my_mr_name = "寄生孑孓"
	self.attack_in = 90
	self.level = PlayerData.player_data[DataKeys.PLAYER_LEVEL]
	self.SHp = 100
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
	self.speed = 5
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
	monster_140801()

	if has_node("DeathCount"):
		$DeathCount.queue_free()


func _physics_process(delta: float) -> void:
	if Hp <= 0:
		mr_player.play("death")
		return

	super._physics_process(delta)
	reset_pro()

	if my_target == null:
		self.Hp = -100
	else:
		if self.position.x >= my_target.position.x:
			move_left()
		else:
			move_right()


func state_death():
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
	hurt_received = last_hurt

	if get_Player is BaseHero:
		if get_Player.is_dead_link:
			get_Player.effect_reducehp(last_hurt, "real")

	cure_ws_value()
	hurt_reduce_hp(last_hurt, get_target)

	if my_target != null and last_hurt > 0:
		my_target.effect_reducehp(last_hurt, "real")

	Global.total_role_hit += last_hurt
	if get_target is BaseHero or get_target is MgHit or get_target is Role1Shallow or get_target is RoleBullet:
		match get_target.HitDic["attackKind"]:
			"physics":
				Global.total_phy_hit += last_hurt
			"magic":
				Global.total_mag_hit += last_hurt
			"real":
				Global.total_real_hit += last_hurt

	if not is_miss and last_hurt > 0:
		if MainSet.set_data["MonsterLittleBlood"]:
			if monster_blood_bar == null:
				monster_blood_bar = Global.add_monster_blood(self, Vector2(-30, -90), Hp / float(SHp), Hp)
		Global.add_sound(self, "res://Music/MonsterHurt/6_BeattackByRole1.mp3")
		hurt_special_effect = Global.add_mr_hurt(pz, Vector2(0, 0))

	get_target = null


func _on_death_count_timeout():
	pass


func ai_think():
	pass


func reset_pro():
	pass


func cure_hp(value: int):
	pass


func wd_hurt():
	pass
