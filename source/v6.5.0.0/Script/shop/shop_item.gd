extends Node2D

@onready var item_name: Label = $BG/name_
@onready var lh_need: Label = $BG/lh_value
@onready var need_num = $BG/num_/num_kj/num_
@onready var items: Button = $BG/bgg/Items

const MAX_SHOP_BUY_NUM: int = 9999

var eq_prop = {}
var total_num: int = 1
var item_name_: String
var choose_jm
var need_lh: int


func _ready() -> void:
	items.is_in_shop = true


func _physics_process(_delta: float) -> void:
	items.is_in_shop = true
	if not need_num.has_focus():
		if total_num <= 1:
			_set_total_num(1)
		elif total_num > MAX_SHOP_BUY_NUM:
			_set_total_num(MAX_SHOP_BUY_NUM)
	if item_name_ != "" and AE.all_equipment.has(item_name_):
		item_name.text = str(AE.all_equipment[item_name_].get(DataKeys.NAME, item_name_))
		items.set_button_icon(load_(item_name_))
		items.qh_level = 0
		items.wx = []
		items.eq_prop = AE.all_equipment[item_name_]
	lh_need.text = str(_effective_price())


func _effective_price() -> int:
	if Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_FREE_SHOP):
		return 0
	return maxi(0, need_lh)


func _set_total_num(value: int) -> void:
	total_num = clampi(value, 1, MAX_SHOP_BUY_NUM)
	if need_num != null and need_num.text != str(total_num):
		need_num.text = str(total_num)


func _get_safe_buy_num() -> int:
	return clampi(total_num, 1, MAX_SHOP_BUY_NUM)


func _get_safe_total_cost(buy_num: int) -> int:
	var unit_price := _effective_price()
	if unit_price <= 0:
		return 0
	return unit_price * buy_num


func _can_pay_for_count(buy_num: int) -> bool:
	if buy_num <= 0:
		return false
	var unit_price := _effective_price()
	if unit_price <= 0:
		return true
	var coin_num: int = PlayerData.get_soul()
	return buy_num <= int(coin_num / unit_price)


func _get_backpack_list_name(item_type: String) -> String:
	match item_type:
		"武器", "防具", "饰品", "翅膀", "头衔", "时装", "法宝":
			return "装备列表"
		"道具":
			return "道具列表"
		"消耗品":
			return "消耗品列表"
		"宠物装备":
			return PlayerData.PET_BACKPACK_KEY
		_:
			return "装备列表"


func _get_free_item_capacity(item_type: String, list_name: String) -> int:
	if item_type == "宠物装备":
		return maxi(0, 40 - PlayerData.ensure_shared_pet_backpack().size())
	return int(PlayerData.check_can_use_page(list_name))


func _on_cure_num_pressed() -> void:
	_set_total_num(total_num + 1)


func _on_reduce_num_pressed() -> void:
	_set_total_num(total_num - 1)


func _on_num__text_changed(new_text: String) -> void:
	var clean_text := new_text.strip_edges()
	if clean_text == "":
		return
	total_num = clampi(int(clean_text), 1, MAX_SHOP_BUY_NUM)


func _on_num__editing_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		_set_total_num(total_num)


func _on_goumai_pressed() -> void:
	var parent_ = Global.get_parent_(self, 3)
	var buy_num := _get_safe_buy_num()
	if not _can_pay_for_count(buy_num):
		Global.add_message_show(parent_, "灵魂不足！", 1.5, Vector2(485, 295))
		return
	Signals.connect_choose_box_signal(self, "gm")
	choose_jm = Global.add_choose_text(
		parent_,
		Vector2(0, 0),
		"确定花费" + str(_get_safe_total_cost(buy_num)) + "灵魂购买" + str(buy_num) + "个" + str(item_name.text) + "吗？",
		0
	)


func add_item_toplayer(times):
	var parent_ = Global.get_parent_(self, 3)
	if item_name_ == "" or not AE.all_equipment.has(item_name_):
		Global.add_message_show(parent_, "商品信息错误！", 1.5, Vector2(485, 295))
		return

	var buy_num := clampi(int(times), 1, MAX_SHOP_BUY_NUM)
	_set_total_num(buy_num)
	var item_data: Dictionary = AE.all_equipment[item_name_]
	var lx = str(item_data.get(DataKeys.TYPE, ""))
	var cklb := _get_backpack_list_name(lx)

	if not _can_pay_for_count(buy_num):
		Global.add_message_show(parent_, "灵魂不足！", 1.5, Vector2(485, 295))
		return

	var free_page_count := _get_free_item_capacity(lx, cklb)
	if free_page_count == 0:
		Global.add_message_show(parent_, "背包已满！", 1.5, Vector2(485, 295))
		return
	if lx in ["武器", "防具", "饰品", "翅膀", "头衔", "时装", "法宝", "宠物装备"] and buy_num > free_page_count:
		Global.add_message_show(parent_, "背包空位不足！", 1.5, Vector2(485, 295))
		return

	PlayerData.spend_soul(_get_safe_total_cost(buy_num))

	match lx:
		"武器", "防具", "饰品", "翅膀", "头衔", "时装":
			for i in range(buy_num):
				PlayerData.add_zb(item_name_, 0, {})
		"法宝":
			for i in range(buy_num):
				PlayerData.add_fb(item_name_, 0, AE.get_wx(), {})
		"道具":
			PlayerData.add_dj(item_name_, buy_num)
		"消耗品":
			PlayerData.add_xhp(item_name_, buy_num)
		"宠物装备":
			PlayerData.add_pet_backpack_item(item_name_, buy_num)
		_:
			for i in range(buy_num):
				PlayerData.add_zb(item_name_, 0, {})

	Global.add_message_show(parent_, "购买成功！", 1.5, Vector2(485, 295))


func load_(name_):
	return load("res://Art/backpack/AllItems/" + str(name_) + ".png")


func gm():
	add_item_toplayer(total_num)
