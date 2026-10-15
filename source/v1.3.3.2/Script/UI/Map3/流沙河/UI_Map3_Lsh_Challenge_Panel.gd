class_name UI_Map3_Lsh_Challenge_Panel extends UIBase


var UI_ID: = "UI_Map3_Lsh_Challenge_Panel"
@onready var close_btn: TextureButton = $BG / Close_Btn



func get_ui_identifier() -> String:
	return UI_ID


func _ready() -> void :
	close_btn.pressed.connect(close_btn_pressed)
	pass

func close_btn_pressed() -> void :
	Close()

	pass



func OnShowUI(_params: Array) -> void :




	pass
