extends BaseMagicWeapon
class_name GhostDoll
var FollowTarget: BaseMonster
var MonsterList = []
var _monster_refresh_elapsed: float = 0.0
var HitTimes: int = 0
var MaxTimes: int = 0
var isBegin: bool
var _hit_data := {"power": 0, "hurtBack": [1, -2], "attackKind": "magic"}


func _ready() -> void:
	objattackDic["hit1"] = _hit_data


func _get_active_monster_snapshot() -> Array:
	var level: Node = Player.get_parent().get_parent() if Player != null and Player.get_parent() != null else null
	if level != null and level.has_method("has_active_monster_index") and level.has_active_monster_index():
		return level.get_active_monsters()
	if level != null and "monster" in level and level.monster != null:
		return level.monster.get_children()
	return []


func _physics_process(delta: float) -> void:
	_monster_refresh_elapsed += delta
	if _monster_refresh_elapsed >= 0.1 or MonsterList.is_empty():
		_monster_refresh_elapsed = 0.0
		MonsterList = _get_active_monster_snapshot()
	self.FB_Level = PlayerData.get_mostLevel("xhmt") + 1
	if PlayerData.check_have_wx("xhmt", "木"):
		_hit_data["power"] = int(25 + RoleProp.roleprop.power * (0.15 + (self.FB_Level * 0.03)))
		MaxTimes = 5 + int(self.FB_Level / 3)
	else:
		_hit_data["power"] = int(12 + RoleProp.roleprop.power * (0.07 + (self.FB_Level * 0.02)))
		MaxTimes = 3 + int(self.FB_Level / 3)
	needMp = 25 + self.FB_Level * 5
	super._physics_process(delta)
	if HitTimes > 0:
		get_target()
		if FollowTarget != null:
			if not isBegin:
				var changepp: Vector2
				var tween = get_tree().create_tween()
				changepp = Vector2(0, 112)
				tween.tween_property(self, "position", FollowTarget.position - changepp, 0.25)
				isBegin = true
		else:
			Useover()
		if isBegin:
			mg_player.play("hit")
			await mg_player.animation_finished
			change_dir()
			isBegin = false
			get_target()
			if HitTimes <= 0:
				Useover()


func change_dir():
	if FollowTarget != null:
		if FollowTarget is BaseMonster:
			if self.position.x > FollowTarget.position.x:
				scale.x = 1
				self.SelfDir = false
			else:
				self.SelfDir = true
				scale.x = -1


func show_skill():
	var a_1
	var Monster: BaseMonster = null
	var a_2 = 0
	var Monster_2: BaseMonster = null
	var a_3
	Global.RemoveAllBuff()
	mg_player.play("Show")
	await mg_player.animation_finished
	a_1 = 5000
	a_2 = 0
	while a_2 < MonsterList.size():
		if MonsterList[a_2] != null and MonsterList[a_2] is BaseMonster:
			Monster_2 = MonsterList[a_2]
		else:
			Useover()
			FollowTarget = null
			return null
		if Monster_2 == null:
			Useover()
			FollowTarget = null
			return null
		if Monster_2 is Monster138:
			a_2 += 1
			continue
		a_3 = Global.GetDisBetweem(Player, Monster_2)
		if a_3 <= a_1:
			a_1 = a_3
			if Monster_2 is Monster48:
				if Monster_2.ChangeBody:
					Useover()
					FollowTarget = null
					return null
			Monster = Monster_2
		a_2 += 1
	if Monster != null:
		FollowTarget = Monster
		Global.FB_CD = 5
		HitTimes = MaxTimes
	change_dir()
	if FollowTarget == null:
		RoleProp.roleprop.Mp += needMp
		Useover()


func get_target():
	var a_1
	var Monster: BaseMonster = null
	var a_2 = 0
	var Monster_2: BaseMonster = null
	var a_3
	a_1 = 1000
	a_2 = 0
	while a_2 < MonsterList.size():
		if MonsterList[a_2] != null and MonsterList[a_2] is BaseMonster:
			Monster_2 = MonsterList[a_2]
		else:
			Useover()
			FollowTarget = null
			return null
		if Monster_2 == null:
			Useover()
			FollowTarget = null
			return null
		if Monster_2 is Monster138:
			a_2 += 1
			continue
		a_3 = Global.GetDisBetweem(Player, Monster_2)
		if a_3 <= a_1:
			a_1 = a_3
			if Monster_2 is Monster48:
				if Monster_2.ChangeBody:
					FollowTarget = null
					Useover()
					return null
			Monster = Monster_2
		a_2 += 1
	if Monster != null:
		if not Monster_2 is Monster138:
			FollowTarget = Monster


func use_over():
	FollowTarget = null
	HitTimes = 0
	isBegin = false
	is_use = false
	if PlayerData.check_have_wx("xhmt", "木"):
		self.usecd = 6
		skill_cd.start(6)
	else:
		self.usecd = 12
		skill_cd.start(12)
	self.visible = false


func reduceTimes():
	HitTimes -= 1


func GhostBullet_1():
	var Gh_1
	var attack_data := get_attack_snapshot()
	if self.SelfDir:
		Gh_1 = Global.addWeaponBullet_(self, Vector2(-60, 0), "GhostDollBullet_1", attack_data, self.SelfDir, 100)
	else:
		Gh_1 = Global.addWeaponBullet_(self, Vector2(-60, 0), "GhostDollBullet_1", attack_data, !self.SelfDir, 100)


func GhostBullet_2():
	var attack_data := get_attack_snapshot()
	if self.SelfDir:
		Global.addWeaponBullet_(self, Vector2(-60, 0), "GhostDollBullet_2", attack_data, self.SelfDir, 100)
	else:
		Global.addWeaponBullet_(self, Vector2(-60, 0), "GhostDollBullet_2", attack_data, !self.SelfDir, 100)


func GhostBullet_3():
	var attack_data := get_attack_snapshot()
	if self.SelfDir:
		Global.addWeaponBullet_(self, Vector2(-60, 30), "GhostDollBullet_3", attack_data, !self.SelfDir, 100)
	else:
		Global.addWeaponBullet_(self, Vector2(-60, 30), "GhostDollBullet_3", attack_data, self.SelfDir, 100)


func _on_check_monster_body_entered(body: Node2D) -> void:
	pass


func free() -> void:
	FollowTarget = null


func _on_skill_cd_timeout() -> void:
	super._on_skill_cd_timeout()
	self.visible = true


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func ShowSkill():
	return await show_skill()


## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func Useover():
	return use_over()
