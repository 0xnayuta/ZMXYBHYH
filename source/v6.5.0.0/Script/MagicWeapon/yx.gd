extends BaseMagicWeapon
class_name yx

var ADDTime: float
var ADDBl: float = 1
var CooldownTime: float = 20


var original_body_color: Color = Color.WHITE
var original_equipment_color: Color = Color.WHITE
var is_colored: bool = false

func _physics_process(delta: float) -> void :
	self.FB_Level = PlayerData.get_mostLevel("yx")
	needMp = 50 + self.FB_Level * 5

	ADDTime = 10
	CooldownTime = 20

	if PlayerData.CheckHaveWX("yx", "木"):
		ADDTime += self.FB_Level * 0.25
		CooldownTime -= self.FB_Level * 0.25
		if CooldownTime < ADDTime + 1:
			CooldownTime = ADDTime + 1

	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")

func ShowSkill():
	mg_player.play("hit")


	var base_level = self.FB_Level
	var max_level = 10
	var percentage_rate = 0.2 + (0.3 * min(base_level, max_level) / max_level)


	if Player != null:
		Global.AddBuff(Player.buff, {
			"Name": "yxbuff", 
			"AddTime": ADDTime, 
			"ReduceInterval": 0, 
			"value": percentage_rate, 
			"AttackKind": "", 
			"CanRemove": true, 
			"CanAdd": false, 
			"DeBuff": false
		})


		var role_body = Player.get_node_or_null("Action/RoleBody")
		var role_equipment = Player.get_node_or_null("Action/RoleEquipment")

		if role_body and role_equipment:

			if not is_colored:
				original_body_color = role_body.modulate
				original_equipment_color = role_equipment.modulate


			var base_hsv_color = Color.from_hsv(0.78, 0.5, 1, 1)


			role_body.modulate = base_hsv_color
			role_equipment.modulate = base_hsv_color
			is_colored = true

			if Player.has_meta("magic_pulse_tween"):
				var old_tween = Player.get_meta("magic_pulse_tween")
				if old_tween:
					old_tween.kill()




			var restore_timer = get_tree().create_timer(ADDTime)
			restore_timer.timeout.connect( func(): _restore_role_colors(role_body, role_equipment))
		else:
			print("警告：找不到角色身体或装备节点")

	await mg_player.animation_finished
	Useover()


func _restore_role_colors(body_node, equipment_node):
	if body_node and equipment_node and is_colored:

		if Player and Player.has_meta("magic_pulse_tween"):
			var pulse_tween = Player.get_meta("magic_pulse_tween")
			if pulse_tween:
				pulse_tween.kill()
			Player.remove_meta("magic_pulse_tween")


		body_node.modulate = original_body_color
		equipment_node.modulate = original_equipment_color
		is_colored = false

func Useover():
	self.usecd = CooldownTime
	Global.FB_CD = 1
	is_use = false
	skill_cd.start(CooldownTime)
