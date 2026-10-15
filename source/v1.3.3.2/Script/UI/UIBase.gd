extends Control
class_name UIBase

const UIMode = UIMgr_Component.UIMode

static var _ui_instances = {}


func get_ui_identifier() -> String:
	push_error("必须在子类中实现 get_ui_identifier() 方法")
	return ""



static func Show_UI(
	load_path: String, 
	ui_mode: UIMode = UIMode.NONE, 
	layer_name: String = "Layer_0", 
	params: Array = []
) -> Node:

	var existing_instance = _ui_instances.get(load_path)
	if existing_instance and is_instance_valid(existing_instance):
		return existing_instance


	var instance = Global.GameFrame.uIMgr_Component.Show_UI(load_path, ui_mode, layer_name, params)
	if instance is UIBase:
		var id = instance.get_ui_identifier()
		if id != "":
			_ui_instances[id] = instance
			_ui_instances[load_path] = instance


	return instance

static func GetUI(identifier: String) -> UIBase:
	return _ui_instances.get(identifier, null)

func SetVisible(visible: bool) -> void :
	self.visible = visible


	if get_child_count() > 0:
		var first_child = get_child(0)
		if first_child is CanvasLayer:
			first_child.visible = visible
			if self.has_method("_on_enable"):
				_on_enable()





func _on_enable() -> void :


	pass



func Close() -> void :
	var id = get_ui_identifier()
	if id != "" and _ui_instances.has(id):
		_ui_instances.erase(id)
	queue_free()

static func PrintAllInstances() -> void :
	print("当前注册的 UI 实例:")
	for id in _ui_instances:
		print("- ", id, " : ", _ui_instances[id])
