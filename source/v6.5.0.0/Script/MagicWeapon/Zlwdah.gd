
extends BaseMagicWeapon
class_name Zlwdah

var ADDTime: float
var ADDBl: float = 1

var role_6_scene = null
var current_summon: Node = null
var summon_timer: Timer = null


var weapon_level: int = 1
var summon_attribute_scale: float = 0.1

func _ready() -> void :

	summon_timer = Timer.new()
	summon_timer.one_shot = true
	summon_timer.autostart = false
	add_child(summon_timer)
	summon_timer.timeout.connect(_on_summon_timeout)

func _physics_process(delta: float) -> void :
	self.FB_Level = PlayerData.get_mostLevel("zlwdah") + 1
	weapon_level = self.FB_Level


	if weapon_level >= 10:
		summon_attribute_scale = 1.0
	else:
		summon_attribute_scale = 0.1 + (weapon_level - 1) * 0.1

	needMp = 50 + self.FB_Level * 5
	if PlayerData.CheckHaveWX("zlwdah", "木"):
		ADDTime = self.FB_Level * 0.1 + 3
	else:
		ADDTime = 3

	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")

func ShowSkill():
	mg_player.play("hit")
	await mg_player.animation_finished

	SummonZlw()
	Useover()

func Useover():
	self.usecd = 5
	Global.FB_CD = 1
	is_use = false
	skill_cd.start(5)

func SummonZlw():


	if Global.current_magic_summon == current_summon and is_instance_valid(Global.current_magic_summon):
		current_summon = null
		Global.current_magic_summon.queue_free()
		Global.current_magic_summon = null

	var summon_scene: = Global.load_scene_uncached("res://Scene/Monster/Monster_zhw/Monster_142_zhw.tscn")
	if summon_scene == null:
		return
	var summon_instance = summon_scene.instantiate()


	var summon_pos = global_position
	summon_pos.x += 100
	summon_instance.position = summon_pos


	if summon_instance.has_method("set_weapon_level"):
		summon_instance.set_weapon_level(weapon_level, summon_attribute_scale)


	get_tree().current_scene.add_child(summon_instance)
	current_summon = summon_instance
	Global.current_magic_summon = summon_instance


	var duration = 20.0 + (weapon_level - 1) * 2.0
	summon_timer.start(duration)

	print("召唤物Role_6已召唤，法宝等级: %d, 属性系数: %.1f%%, 持续时间: %.1f秒" % [weapon_level, summon_attribute_scale * 100, duration])

func _on_summon_timeout():
	if Global.current_magic_summon == current_summon and is_instance_valid(Global.current_magic_summon):
		print("召唤物Role_6持续时间结束，已销毁")
		current_summon = null
		Global.current_magic_summon.queue_free()
		Global.current_magic_summon = null


func _exit_tree():
	if Global.current_magic_summon == current_summon and is_instance_valid(Global.current_magic_summon):
		current_summon = null
		Global.current_magic_summon.queue_free()
		Global.current_magic_summon = null
