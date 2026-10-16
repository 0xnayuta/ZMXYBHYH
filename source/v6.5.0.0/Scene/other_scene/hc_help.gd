extends Node2D

const RecipeData = preload("res://Script/LDL/recipe_data.gd")

@onready var page: Label = $BG/ChangePage/Page
var message

var PositonList = [Vector2(0, -10), Vector2(0, 45), Vector2(0, 100), Vector2(0, 155)]

var ZBlIST = []
var DJlIST = []
var FBlIST = []
var SZlIST = []
var TotalList = []

var L_zbList = {}
var L_djList = {}
var L_fbList = {}
var L_szList = {}
var L_totalList = {}

var TotalPage: int
var ZBPage: int
var DJPage: int
var FBPage: int
var SZPage: int

var CurrentPage: int = 1:
	set(vl):
		CurrentPage = vl
		add_help_items()

var MaxPage: int

var CurrentType: int = 0:
	set(vl):
		CurrentType = vl
		on_current_type_change()

var ItemList_ = []


func _ready():
	for recipe in RecipeData.RECIPES:
		var type = AE.AllEquipment_[recipe["result"]][DataKeys.TYPE]
		var display_recipe = {
			"cl_1": recipe["materials"][0],
			"cl_2": recipe["materials"][1],
			"cl_3": recipe["materials"][2],
			"scw": recipe["result"]
		}
		TotalList.append(display_recipe)
		match type:
			"武器", "防具", "饰品", "头衔":
				ZBlIST.append(display_recipe)
			"道具", "消耗品":
				DJlIST.append(display_recipe)
			"法宝":
				FBlIST.append(display_recipe)
			"时装":
				SZlIST.append(display_recipe)

	build_page_dicts()

	TotalPage = get_page(TotalList)
	ZBPage = get_page(ZBlIST)
	DJPage = get_page(DJlIST)
	FBPage = get_page(FBlIST)
	SZPage = get_page(SZlIST)

	add_help_items()


func _physics_process(delta):
	match CurrentType:
		0:
			MaxPage = TotalPage
		1:
			MaxPage = ZBPage
		2:
			MaxPage = DJPage
		3:
			MaxPage = FBPage
		4:
			MaxPage = SZPage
	page.text = str(CurrentPage) + "/" + str(MaxPage)


func build_page_dicts():
	L_totalList = build_page_dict(TotalList)
	L_zbList = build_page_dict(ZBlIST)
	L_djList = build_page_dict(DJlIST)
	L_fbList = build_page_dict(FBlIST)
	L_szList = build_page_dict(SZlIST)


func build_page_dict(list: Array) -> Dictionary:
	var page_dict = {}
	var pages = ceil(list.size() / 4.0)
	for i in range(pages):
		page_dict["page" + str(i + 1)] = []
	for i in range(list.size()):
		var page_idx = floor(i / 4) + 1
		page_dict["page" + str(page_idx)].append(list[i])
	return page_dict


func get_page(list: Array) -> int:
	return ceil(list.size() / 4.0)


func on_current_type_change():
	CurrentPage = 1
	add_help_items()


func add_help_items():
	remove_item()
	var target_count = 0
	var target_dict
	match CurrentType:
		0:
			target_dict = L_totalList
		1:
			target_dict = L_zbList
		2:
			target_dict = L_djList
		3:
			target_dict = L_fbList
		4:
			target_dict = L_szList
	if target_dict.has("page" + str(CurrentPage)):
		for recipe in target_dict["page" + str(CurrentPage)]:
			ItemList_.append(Global.add_help_thing(self, PositonList[target_count], recipe))
			target_count += 1


func remove_item():
	for i in ItemList_:
		if i != null:
			i.queue_free()
	ItemList_.clear()


func _on_last_pressed():
	if CurrentPage > 1:
		CurrentPage -= 1


func _on_next_pressed():
	if CurrentPage < MaxPage:
		CurrentPage += 1


func _on_total_pressed():
	CurrentType = 0


func _on_zb_pressed():
	CurrentType = 1


func _on_dj_pressed():
	CurrentType = 2


func _on_fb_pressed():
	CurrentType = 3


func _on_sz_pressed():
	CurrentType = 4


func _on_close_pressed():
	queue_free()


func add_text(text, parent):
	if message == null:
		message = Global.add_basic_monment_info(parent, text, get_global_mouse_position() + Vector2(40, 40))


func remove_text():
	if message != null:
		message.queue_free()


func _on_other_help_mouse_entered():
	add_text("同类型的装备均可以参与法宝合成！", get_parent())


func _on_other_help_mouse_exited():
	remove_text()
