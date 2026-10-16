extends BaseMagicWeapon
class_name Cucurbit2
var ADDTime: float
var ADDBl: float = 1


func _physics_process(delta: float) -> void:
	self.FB_Level = PlayerData.get_most_level("xhhl") + 1
	needMp = 50 + self.FB_Level * 5
	if PlayerData.check_have_wx("xhhl", "木"):
		ADDTime = self.FB_Level * 0.1 + 3
	else:
		ADDTime = 3

	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func show_skill():
	mg_player.play("hit")
	await mg_player.animation_finished
	Useover()


func use_over():
	self.usecd = 5
	Global.FB_CD = 1
	is_use = false
	skill_cd.start(5)


func move_monster_and_add_buff():
	var LevelFather = Player.get_parent().get_parent()
	if not LevelFather is BaseLevel:
		return
	var MonsterList = LevelFather.monster.get_children()
	for i in MonsterList:
		if i != null:
			if i is BaseMonster:
				if i.is_control_immune() or i.CannotAttract:
					continue
				var tween = i.create_control_movement_tween()
				tween.tween_property(i, "position", Player.position + Vector2(0, -50), 0.5)
				i.HurtBl = ADDBl
				i.remove_hurt_bl.start(ADDTime)


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func ShowSkill():
	return await show_skill()


## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func Useover():
	return use_over()
