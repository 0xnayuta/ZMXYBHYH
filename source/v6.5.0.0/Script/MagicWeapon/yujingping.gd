extends BaseMagicWeapon
class_name Yujingping


func _physics_process(delta: float) -> void:
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


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func ShowSkill():
	return await show_skill()


## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func Useover():
	return use_over()
