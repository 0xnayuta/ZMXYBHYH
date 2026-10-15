extends BaseMagicWeapon
class_name Yujingping

func _physics_process(delta: float) -> void :

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
