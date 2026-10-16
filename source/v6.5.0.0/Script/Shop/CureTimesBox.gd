extends TextureRect
@onready var lpline: LineEdit = $LPDH/lpline
@onready var lhline: LineEdit = $LHDH/lhline
@onready var title_4: Label = $Title4
@onready var title_5: Label = $Title5
@onready var title_6: Label = $Title6

var lpTimes: int = 0
var lhTimes: int = 0
var TotalTimes: int = 0
var Lhdhvalue: int = 50000
const MAX_EXCHANGE_TIMES: int = 9999


func _get_max_lh_times() -> int:
	if Lhdhvalue <= 0:
		return 0
	return min(int(PlayerData.get_soul() / Lhdhvalue), MAX_EXCHANGE_TIMES)


func _set_lp_times(value: int) -> void:
	lpTimes = clampi(value, 0, min(int(PlayerData.get_item_data("smlp")), MAX_EXCHANGE_TIMES))
	if lpline != null and lpline.text != str(lpTimes):
		lpline.text = str(lpTimes)


func _set_lh_times(value: int) -> void:
	lhTimes = clampi(value, 0, _get_max_lh_times())
	if lhline != null and lhline.text != str(lhTimes):
		lhline.text = str(lhTimes)


func _physics_process(delta: float) -> void:
	TotalTimes = lhTimes + lpTimes
	title_4.text = "令牌可兑换次数：" + str(lpTimes)
	title_5.text = "灵魂可兑换次数：" + str(lhTimes)
	title_6.text = "总次数：" + str(TotalTimes)


func _on_lpline_text_changed(new_text: String) -> void:
	var clean_text := new_text.strip_edges()
	if clean_text == "":
		_set_lp_times(0)
		return
	_set_lp_times(int(clean_text))


func _on_min_pressed() -> void:
	_set_lp_times(1)


func _on_max_pressed() -> void:
	_set_lp_times(int(PlayerData.get_item_data("smlp")))


func _on_lhline_text_changed(new_text: String) -> void:
	var clean_text := new_text.strip_edges()
	if clean_text == "":
		_set_lh_times(0)
		return
	_set_lh_times(int(clean_text))


func _on_lhmin_pressed() -> void:
	_set_lh_times(1)


func _on_lhmax_pressed() -> void:
	_set_lh_times(_get_max_lh_times())


func _on_dh_pressed() -> void:
	_set_lp_times(lpTimes)
	_set_lh_times(lhTimes)
	TotalTimes = lhTimes + lpTimes
	if TotalTimes > 0:
		if int(PlayerData.get_item_data("smlp")) < lpTimes:
			Global.add_message_show(Global.Windows_, "令牌不足！！", 1.5, Vector2(470, 300))
			return
		if lhTimes > _get_max_lh_times():
			Global.add_message_show(Global.Windows_, "灵魂不足！！", 1.5, Vector2(470, 300))
			return
		PlayerData.remove_dj("smlp", PlayerData.get_dj_page("smlp"), lpTimes)
		PlayerData.spend_soul(Lhdhvalue * lhTimes)
		PlayerData.player_data["购买次数"] += TotalTimes
		MemoryClass.save_game(Global.cd_path)
		Global.add_message_show(Global.Windows_, "成功兑换" + str(TotalTimes) + "次购买次数！！", 1.5, Vector2(470, 300))
	else:
		Global.add_message_show(Global.Windows_, "兑换次数为0！！", 1.5, Vector2(470, 300))


func _on_close_pressed() -> void:
	queue_free()
