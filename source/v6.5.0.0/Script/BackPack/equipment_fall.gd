extends CharacterBody2D
var item_name: String
var num_: int
var Is_set: bool
var Is_set2: bool
@onready var item_pic: Sprite2D = $item_pic
@onready var remove_pl = $remove_player
@onready var get_area: CollisionShape2D = $Area2D/get_area
var IsPick: bool
var Player: BaseHero


func _physics_process(delta: float) -> void:
	if not Is_set2:
		set_pic(item_name)
		if MainSet.set_data["AutomaticallyPickUpItems"]:
			get_area.disabled = true
		else:
			get_area.disabled = false
		Is_set2 = true
	Player = get_parent().get_parent().Role_

	if not is_on_floor():
		velocity.y -= delta * -980
	if MainSet.set_data["AutomaticallyPickUpItems"]:
		if not IsPick:
			AutomaticallyPickUpItems()

	move_and_slide()


func set_pic(name_):
	var texture_path = "res://Art/ItemIcon/" + str(name_) + ".png"
	var texture = load_soft(texture_path)

	if not texture:
		texture_path = "res://Art/BackPack/AllItems/" + str(name_) + ".png"
		texture = load_soft(texture_path)

	if not texture:
		var item_data: Dictionary = AE.AllEquipment_.get(str(name_), {})
		var custom_icon_path := str(item_data.get("图标", ""))
		if custom_icon_path != "":
			texture = load_soft(custom_icon_path)

	if not texture:
		texture = load_soft("res://Art/ItemIcon/zxbx_3.png")

	if item_pic:
		item_pic.visible = true
		item_pic.scale = Vector2(1, 1)
		item_pic.modulate = Color(1, 1, 1, 1)
		item_pic.region_enabled = false
		item_pic.centered = true
		item_pic.z_index = 100
		item_pic.flip_h = false
		item_pic.flip_v = false
		item_pic.texture = texture

	if item_name == "peach" or item_name == "Bble" or item_name == "radish":
		await get_tree().create_timer(6).timeout
		queue_free()


func load_soft(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return Global.get_cached_texture(path)
	return null


func AutomaticallyPickUpItems():
	PickUpItems(Player)


func _on_area_2d_body_entered(body: Node2D) -> void:
	PickUpItems(body)


func PickUpItems(body):
	if MainSet.set_data["PickUpItemsMusic"]:
		Global.addSound_(self, "res://Music/level/86_pickup.mp3")
	if item_name != "peach" and item_name != "Bble" and item_name != "radish":
		var get_type = AE.AllEquipment_[item_name]["类型"]
		match get_type:
			"武器", "防具", "饰品", "翅膀", "时装", "头衔":
				if not PlayerData.CheckCanUsePage("装备列表") == 0:
					PlayerData.add_zb(item_name, 0, {})
				else:
					return
			"法宝":
				if not PlayerData.CheckCanUsePage("装备列表") == 0:
					PlayerData.add_fb(item_name, 0, AE.get_wx(), {})
				else:
					return
			"道具":
				if PlayerData.get_dj_page(item_name) != 0 or not PlayerData.CheckCanUsePage("道具列表") == 0:
					PlayerData.add_dj(item_name, max(1, num_))
				else:
					return
			"消耗品":
				if PlayerData.get_xhp_page(item_name) != 0 or not PlayerData.CheckCanUsePage("消耗品列表") == 0:
					PlayerData.add_xhp(item_name, num_)
				else:
					return
			"宠物装备":
				if PlayerData.has_method("add_pet_backpack_item"):
					var added_count := int(PlayerData.add_pet_backpack_item(item_name, max(1, num_)))
					if added_count <= 0:
						return
					_save_pet_backpack_pickup()
				else:
					return
	match item_name:
		"peach":
			body.cure_Hp(RoleProp.roleprop.SHp * 0.45)
			body.cure_Mp(RoleProp.roleprop.SMp * 0.45)
		"Bble":
			body.cure_Mp(RoleProp.roleprop.SMp * 0.2)

		"radish":
			body.cure_Hp(RoleProp.roleprop.SHp * 0.25)
	IsPick = true
	remove_pl.play("remove")


func _save_pet_backpack_pickup() -> void:
	var save_path := str(Global.cd_path)
	if save_path != "" and save_path.contains("Ar_") and FileAccess.file_exists(save_path):
		MemoryClass.保存游戏(save_path)


func Pick():
	IsPick = true
