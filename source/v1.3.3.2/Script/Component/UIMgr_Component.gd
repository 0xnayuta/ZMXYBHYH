
extends Control
class_name UIMgr_Component


enum UIMode{
	NONE, 
	CLOSE_CURR, 
	HIDE_CURR
}


@onready var layers = {
	"Layer_0": $Node / Layer_0, 
	"Layer_1": $Node / Layer_1, 
	"Layer_2": $Node / Layer_2
}



var ui_stack = []

func _init():
	pass

func _ready():

	process_mode = Node.PROCESS_MODE_ALWAYS


func Show_UI(ui_class: String = "", UI_Mode: UIMode = UIMode.NONE, layer_name: String = "Layer_0", params: Array = []) -> Node:

	_handle_current_ui(UI_Mode)


	if not layers.has(layer_name):
		push_error("UI层级不存在: ", layer_name)
		layer_name = "Layer_0"


	var ui_instance = load(ui_class).instantiate()


	layers[layer_name].add_child(ui_instance)



	if ui_instance.has_method("OnShowUI"):
		ui_instance.call("OnShowUI", params)


	ui_stack.push_back({
		"node": ui_instance, 
		"layer": layer_name
	})
	ui_instance.visible = true
	return ui_instance


func _handle_current_ui(ui_mode: UIMode):
	if ui_stack.is_empty():
		return

	var current_data = ui_stack.back()
	var current_ui = current_data["node"]

	match ui_mode:
		UIMode.CLOSE_CURR:
			current_ui.queue_free()
			ui_stack.pop_back()
		UIMode.HIDE_CURR:
			current_ui.visible = false
		_:
			pass


func back():
	if ui_stack.size() <= 1:
		return


	var current_data = ui_stack.pop_back()
	current_data["node"].queue_free()


	var previous_data = ui_stack.back()
	previous_data["node"].visible = true
