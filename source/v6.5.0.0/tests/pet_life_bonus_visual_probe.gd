extends SceneTree

const SCREENSHOT_PATH: = "C:/Users/Administrator/AppData/Local/Temp/pet_life_bonus_popup.png"
const FORMATION_BUTTON_SCREENSHOT_PATH: = "C:/Users/Administrator/AppData/Local/Temp/pet_formation_button.png"


func _init() -> void :
	call_deferred("_run")


func _run() -> void :
	var interface_scene: PackedScene = load("res://Scene/Pet/PetInterface.tscn") as PackedScene
	if interface_scene == null:
		push_error("宠物界面无法加载")
		quit(1)
		return
	var interface: Node = interface_scene.instantiate()
	root.add_child(interface)
	await process_frame
	interface.set("current_pet_index", 0)
	interface.call("_refresh_all")
	await RenderingServer.frame_post_draw
	var formation_button_image: = root.get_viewport().get_texture().get_image()
	var formation_button_save_error: = formation_button_image.save_png(FORMATION_BUTTON_SCREENSHOT_PATH)
	if formation_button_save_error != OK:
		push_error("星宿阵法按钮截图保存失败：%s" % error_string(formation_button_save_error))
		quit(1)
		return
	interface.call("_on_learn_skill_pressed")
	await process_frame
	var player_data: Node = root.get_node_or_null("PlayerData")
	if player_data != null:
		var book_count: = int(player_data.call("get_item_data", "gjjc_skill_book"))
		if book_count > 0:
			player_data.call("remove_dj", "gjjc_skill_book", player_data.call("get_dj_page", "gjjc_skill_book"), book_count)
	interface.call("_learn_pet_skill", "攻击加成", "gjjc_skill_book")
	await physics_frame
	await process_frame
	var tip: Control = null
	for child in interface.get_children():
		if child is Control and child.get_node_or_null("background/text_tt") != null:
			tip = child as Control
	if tip == null:
		push_error("缺少技能书提示未创建")
		quit(1)
		return
	var tip_label: = tip.get_node("background/text_tt") as Label
	var learn_popup: = interface.get_node_or_null("PetSkillLearnPopup") as Control
	if tip_label.text != "缺少攻击加成技能书" or not tip_label.is_visible_in_tree():
		push_error("缺少技能书提示文字不可见")
		quit(1)
		return
	if learn_popup == null or tip.z_index <= learn_popup.z_index:
		push_error("缺少技能书提示没有位于学习页面上层")
		quit(1)
		return
	await RenderingServer.frame_post_draw
	var image: = root.get_viewport().get_texture().get_image()
	var save_error: = image.save_png(SCREENSHOT_PATH)
	if save_error != OK:
		push_error("学习页面截图保存失败：%s" % error_string(save_error))
		quit(1)
		return
	print("PET_LIFE_BONUS_VISUAL_OK ", SCREENSHOT_PATH)
	interface.queue_free()
	await process_frame
	quit(0)
