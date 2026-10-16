extends Node2D
const FULLSCREEN_DESIGN_SIZE := Vector2(922.0, 564.0)
const FULLSCREEN_CONTENT_CENTER := Vector2(451.0, 273.0)
@onready var ceng_shu_text: Label = $BG/CengShuText
var Max
var CurrentCengShu: int = 1
var SourcePopup: Node = null


func _fit_to_fullscreen() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale = min(
		1.0, min(viewport_size.x / FULLSCREEN_DESIGN_SIZE.x, viewport_size.y / FULLSCREEN_DESIGN_SIZE.y)
	)
	scale = Vector2(fit_scale, fit_scale)
	position = viewport_size * 0.5 - FULLSCREEN_CONTENT_CENTER * fit_scale


func _ready() -> void:
	_fit_to_fullscreen()
	if not get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.connect(_fit_to_fullscreen)


var _is_closing := false


func _ensure_llbt_progress() -> void:
	if PlayerData.has_method("ensure_special_dungeon_progress"):
		PlayerData.ensure_special_dungeon_progress()


func _llbt_reached_level() -> int:
	_ensure_llbt_progress()
	return clampi(int(PlayerData.player_data.get("玲珑宝塔层数", 0)), 0, 25)


func _close_popup_chain() -> void:
	if _is_closing:
		return
	_is_closing = true
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	if SourcePopup != null and is_instance_valid(SourcePopup) and not SourcePopup.is_queued_for_deletion():
		if SourcePopup is CanvasItem:
			(SourcePopup as CanvasItem).visible = false
		SourcePopup.queue_free()
	queue_free()


func _enter_llbt_level() -> void:
	if _is_closing:
		return
	var scene_tree := get_tree()
	if scene_tree == null:
		push_error("当前节点不在场景树中，无法进入玲珑宝塔")
		return
	_close_popup_chain()
	Global.cleanup_transient_ui()
	Global.call_deferred("change_scene", "res://Scene/Level/Level_llbt.tscn")


func _physics_process(delta: float) -> void:
	Max = _llbt_reached_level()
	if Max >= 24:
		Max = 24
	if ceng_shu_text != null and is_instance_valid(ceng_shu_text):
		ceng_shu_text.text = str(CurrentCengShu) + "/" + str(Max)


func _on_wxms_pressed() -> void:
	Global.LLBTBOSSMS = false
	Global.LLBTCGMS = false
	Global.LLBTWXMS = true

	_enter_llbt_level()


func _on_cgms_pressed() -> void:
	Global.LLBTBOSSMS = false
	Global.LLBTCGMS = true
	Global.LLBTWXMS = false
	_enter_llbt_level()


func _on_tztxs_pressed() -> void:
	if _llbt_reached_level() > 6:
		Global.LLBTLevel = 6
		Global.LLBTBOSSMS = true
		Global.LLBTWXMS = false
		Global.LLBTCGMS = false
		_enter_llbt_level()
	else:
		Global.AddMessageShow(Global.Windows_, "请先至少到达第7层！！", 1.5, Vector2(470, 300))


func _on_tslzz_pressed() -> void:
	if _llbt_reached_level() > 12:
		Global.LLBTLevel = 12
		Global.LLBTBOSSMS = true
		Global.LLBTWXMS = false
		Global.LLBTCGMS = false
		_enter_llbt_level()
	else:
		Global.AddMessageShow(Global.Windows_, "请先至少到达第13层！！", 1.5, Vector2(470, 300))


func _on_tznz_pressed() -> void:
	if _llbt_reached_level() > 18:
		Global.LLBTLevel = 18
		Global.LLBTBOSSMS = true
		Global.LLBTWXMS = false
		Global.LLBTCGMS = false
		_enter_llbt_level()
	else:
		Global.AddMessageShow(Global.Windows_, "请先至少到达第19层！！", 1.5, Vector2(470, 300))


func _on_tztttw_pressed() -> void:
	if _llbt_reached_level() >= 25:
		Global.LLBTLevel = 24
		Global.LLBTBOSSMS = true
		Global.LLBTWXMS = false
		Global.LLBTCGMS = false
		_enter_llbt_level()
	else:
		Global.AddMessageShow(Global.Windows_, "请先通关玲珑塔！！", 1.5, Vector2(470, 300))


func _on_close_pressed() -> void:
	_close_popup_chain()


func _on_help_pressed() -> void:
	Global.AddMessageShow(Global.Windows_, "玲珑塔帮助还没做！！", 1.5, Vector2(470, 300))
	pass


func _on_cure_pressed() -> void:
	if CurrentCengShu >= _llbt_reached_level() or CurrentCengShu >= 24:
		Global.AddMessageShow(Global.Windows_, "已达当前通关最高层数！！", 1.5, Vector2(470, 300))
		return
	CurrentCengShu += 1


func _on_reduce_pressed() -> void:
	if CurrentCengShu <= 1:
		Global.AddMessageShow(Global.Windows_, "最低传送至1层！！", 1.5, Vector2(470, 300))
		return
	CurrentCengShu -= 1


func _on_change_pressed() -> void:
	if CurrentCengShu > _llbt_reached_level():
		Global.AddMessageShow(Global.Windows_, "超出最高限制层数！！", 1.5, Vector2(470, 300))
		return
	if CurrentCengShu < 1:
		Global.AddMessageShow(Global.Windows_, "低于最低限制层数！！", 1.5, Vector2(470, 300))
		return
	Global.LLBTCGMS = true
	Global.LLBTLevel = CurrentCengShu
	_enter_llbt_level()
