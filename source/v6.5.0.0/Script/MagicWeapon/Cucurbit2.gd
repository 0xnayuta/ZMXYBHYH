extends BaseMagicWeapon
class_name Cucurbit2
var ADDTime: float
var ADDBl: float = 1


func _physics_process(delta: float) -> void:
	self.FB_Level = PlayerData.get_mostLevel("xhhl") + 1
	needMp = 50 + self.FB_Level * 5
	if PlayerData.CheckHaveWX("xhhl", "木"):
		ADDTime = self.FB_Level * 0.1 + 3
	else:
		ADDTime = 3

	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func ShowSkill():
	mg_player.play("hit")
	await mg_player.animation_finished
	Useover()


func Useover():
	self.usecd = 5
	Global.FB_CD = 1
	is_use = false
	skill_cd.start(5)


func MoveMonsterAndAddBuff():
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
