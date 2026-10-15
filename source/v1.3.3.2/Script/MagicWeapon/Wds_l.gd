extends BaseMagicWeapon
class_name Wds_l
var FollowTarget: BaseMonster
var MonsterList: Array[BaseMonster] = []
var HitTimes: int = 0
var MaxTimes: int = 0
var isBegin: bool
const WDS_SKILL_EFFET = preload("res://Scene/MagicWeapon/五毒兽/Wds_Skill_Effet.tscn")

func _physics_process(delta: float) -> void :
	super._physics_process(delta)

	self.FB_Level = PlayerData.get_mostLevel("Wds_l") + 1
	if PlayerData.CheckHaveWX("Wds_l", "木"):
		MaxTimes = 3
		pass
	else:
		MaxTimes = 6
		pass


func ShowSkill() -> void :
	print("法寶使用中")
	mg_player.play("skill1")













	await mg_player.animation_finished


	Useover()


func Useover():
	Global.FB_CD = MaxTimes
	self.usecd = MaxTimes
	is_use = false
	skill_cd.start(MaxTimes)


func free() -> void :
	FollowTarget = null
func _on_skill_cd_timeout() -> void :
	super._on_skill_cd_timeout()
	self.visible = true


func add_wds_fire_skill() -> void :
	var skill = WDS_SKILL_EFFET.instantiate()
	add_child(skill)
	skill.sel_skill("Lei_Skill")

	var screen_center = Vector2(get_screen_center())
	skill.global_position = screen_center + Vector2(0, 0)
	pass

func get_screen_center():
	var camera = get_viewport().get_camera_2d()
	if camera:
		return camera.get_screen_center_position()
	return get_viewport_rect().size / 2
