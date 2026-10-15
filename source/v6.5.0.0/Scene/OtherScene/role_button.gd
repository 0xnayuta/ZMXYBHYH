extends Button
var MyName: String
var MyFather
@onready var role_name: Label = $RoleName


func _physics_process(delta: float) -> void :
	self.set_button_icon(load("res://Art/MainGame/ChoosePlayer/" + str(MyName) + ".png"))
	match MyName:
		"swk":
			role_name.text = "孙悟空"
		"zbj":
			role_name.text = "猪八戒"
		"tsz":
			role_name.text = "唐三藏"
		"swj":
			role_name.text = "沙悟净"
		"xbl":
			role_name.text = "小白龙"
	set_physics_process(false)



func _on_pressed() -> void :
	var role_id: = 0
	match MyName:
		"swk":
			role_id = 1
		"tsz":
			role_id = 2
		"zbj":
			role_id = 3
		"swj":
			role_id = 4
		"xbl":
			role_id = 5
	if role_id > 0 and MyFather and MyFather.has_method("SetRole"):
		MyFather.SetRole(role_id)
