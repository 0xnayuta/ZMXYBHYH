extends TextureRect
@onready var buff_bar: TextureProgressBar = $BuffBar
@onready var buff_time: Label = $BuffTime
@onready var buff_icon_remove: Timer = $BuffIconRemove
@onready var add_times: Label = $AddTimes

var BuffTime: float
var BuffInfo
var BuffName: String = ""
var FatherBuff: Node = null
var TotalTimes: int = 1
var LastHurt: float = 0.0
var DataList = {}
var Parent
var _last_icon_name: String = ""
var _buff_count_elapsed: float = 0.0
var _cached_buff_count: int = 0
var _is_mouse_over: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	buff_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	buff_time.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_times.mouse_filter = Control.MOUSE_FILTER_IGNORE


func start_duration(seconds: float) -> void:
	if not is_node_ready():
		await ready
	buff_icon_remove.start(seconds)


func _physics_process(_delta: float) -> void:
	var PParent = Global.get_parent_(self, 2)
	if Parent != null:
		if PParent != null and PParent.get("GetObj") != null:
			Parent = PParent.get("GetObj")
		else:
			Parent = RoleProp.SourcePlayer
	else:
		Parent = RoleProp.SourcePlayer
	if DataList == {}:
		return
	var icon_name := str(DataList["Name"])
	BuffName = icon_name
	if _last_icon_name != icon_name:
		_last_icon_name = icon_name
		var icon_texture = Global.get_cached_texture("res://Art/AddEffect/Buff_icon/" + icon_name + ".png")
		if icon_texture == null and icon_name == "PetLifeBonus":
			icon_texture = Global.get_cached_texture("res://Art/Pet/skillicon/smjc.png")
		if icon_texture == null and icon_name == "DoubleFallPro":
			icon_texture = Global.get_cached_texture("res://Art/ItemIcon/xydxq.png")
		texture = icon_texture
		buff_bar.texture_progress = icon_texture
	if DataList["AddTime"] > 0:
		BuffTime = DataList["AddTime"]
	if buff_bar.size != self.size:
		buff_bar.size = self.size
	_buff_count_elapsed += _delta
	if _buff_count_elapsed >= 0.2:
		_buff_count_elapsed = 0.0
		if DataList.has("HaveCount"):
			_cached_buff_count = int(DataList["HaveCount"])
		else:
			_cached_buff_count = GetBuffCount()
	var count_text := str(_cached_buff_count) if _cached_buff_count > 1 else ""
	if add_times.text != count_text:
		add_times.text = count_text
	if not BuffTime >= 99999:
		buff_bar.value = buff_icon_remove.time_left / float(BuffTime)
		var remaining_text := str(snapped(buff_icon_remove.time_left, 0.1))
		if buff_time.text != remaining_text:
			buff_time.text = remaining_text
	else:
		if buff_time.text != "永久":
			buff_time.text = "永久"
	_update_hover_popup()


func _on_buff_icon_remove_timeout() -> void:
	self.visible = false


func _update_hover_popup() -> void:
	var mouse_over := visible and get_global_rect().has_point(get_viewport().get_mouse_position())
	if mouse_over:
		_show_buff_info()
	elif _is_mouse_over:
		_hide_buff_info()
	_is_mouse_over = mouse_over


func _show_buff_info() -> void:
	if DataList == {}:
		return
	if BuffInfo == null or not is_instance_valid(BuffInfo):
		BuffInfo = Global.add_buffinfor(
			Global.get_ui_popup_layer(), Global.screen_popup_position(Vector2(18, 22)), DataList
		)
		if BuffInfo == null:
			return
		BuffInfo.Parent = self
		BuffInfo.LastHurt = DataList.get("value", 0.0)
		BuffInfo.z_index = 4095
		BuffInfo.top_level = false
	else:
		Global.apply_popup_screen_layout(BuffInfo, Global.screen_popup_position(Vector2(18, 22)), Vector2(320, 120))


func _hide_buff_info() -> void:
	if BuffInfo != null and is_instance_valid(BuffInfo):
		BuffInfo.queue_free()
	BuffInfo = null


func _on_mouse_entered() -> void:
	_show_buff_info()


func _on_mouse_exited() -> void:
	_hide_buff_info()


func GetBuffCount():
	var Count: int = 0
	if Parent != null and Parent.get("buff") != null:
		var buff_parent: Node = Parent.buff
		var buff_child_count: int = buff_parent.get_child_count()
		var buff_child_index := 0
		while buff_child_index < buff_child_count:
			var i = buff_parent.get_child(buff_child_index)
			buff_child_index += 1
			if i.BuffInfo["Name"] == DataList["Name"]:
				Count += 1
	return Count
