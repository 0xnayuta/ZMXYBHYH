class_name Level_35 extends BaseLevel
@onready var stop_1: CollisionShape2D = $wall / stop1
var is_cc = false


@export var yinfu_light_Array: Array[Sprite2D]

@export var yinfu_Array: Array[Sprite2D]
@export var yinfu_texture: Array[Texture2D]


var yinfu_Name: Array[String] = ["橙色", "黄色", "绿色", "浅蓝色", "深蓝色", "红色", "紫色"]


var yinfu_light_Name: Array[String] = []


signal all_notes_activated()
@export var floor_YinFu_Area2D_Array: Array[Area2D]

func _ready() -> void :
	Global.CurrentLevel = ""
	Global.addBGM_(self, "res://Music/level/34_bg5.mp3")
	preload("res://Scene/Monster/Monster_149.tscn")
	self.level_stage = 40
	super._ready()
	Monster_group = {
		"stage_1": [149], 
		"stage_2": [], 
		"stage_3": [], 
		"stage_4": [], 
	}
	Monster_position_x = {
		"stage_1": [850], 
		"stage_2": [], 
		"stage_3": [], 
		"stage_4": [], 
	}
	Monster_position_y = {
		"stage_1": [200], 
		"stage_2": [], 
		"stage_3": [], 
		"stage_4": [], 
	}

	hide_all_lights()

	shuffle_colors()


	update_sprites_textures()


func _physics_process(delta: float) -> void :
	if not is_cc:
		if Role_.position.x >= 600:
			create_control.wait_time = 3
			create_control.start()
			is_cc = true
			role_information.gogo.visible = false
		else:
			create_control.wait_time = 3
			create_control.start()
	super._physics_process(delta)
	my_camera.max_right = 1080
	if current_stage >= 1:
		if check_can_pass() and current_stage < 1:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false






func shuffle_colors():

	var fixed_first = "橙色"


	var original_order: Array[String] = ["黄色", "绿色", "浅蓝色", "深蓝色", "红色", "紫色"]


	var new_order: Array[String] = []
	new_order.append(fixed_first)


	while original_order.size() > 0:

		var current_position = new_order.size()


		var original_index = current_position - 1


		var start_idx = max(0, original_index - 2)
		var end_idx = min(original_order.size() - 1, original_index + 2)


		if start_idx > end_idx:
			start_idx = end_idx


		var available_colors = original_order.slice(start_idx, end_idx + 1)
		if available_colors.size() == 0:
			break

		var random_index = randi() % available_colors.size()
		var selected_color = available_colors[random_index]


		original_order.erase(selected_color)


		new_order.append(selected_color)


	yinfu_Name = new_order


func update_sprites_textures():
	for i in range(yinfu_Array.size()):
		if i < yinfu_Name.size():
			var color_name = yinfu_Name[i]
			var texture_index = get_color_index(color_name)
			if texture_index != -1 and texture_index < yinfu_texture.size():
				yinfu_Array[i].texture = yinfu_texture[texture_index]


func get_color_index(color_name: String) -> int:
	var default_order = ["橙色", "黄色", "绿色", "浅蓝色", "深蓝色", "红色", "紫色"]
	return default_order.find(color_name)


func hide_all_lights():
	for light_sprite in yinfu_light_Array:
		if light_sprite:
			light_sprite.visible = false




func check_color_sequence(current_color: String):

	if yinfu_light_Name.is_empty():
		if yinfu_Name[0] == current_color:
			light_up_color(0)
		else:
			reset_sequence()
	else:

		var next_index = yinfu_light_Name.size()
		if next_index < yinfu_Name.size() and yinfu_Name[next_index] == current_color:
			light_up_color(next_index)
		else:
			reset_sequence()

func light_up_color(index: int):
	if index < yinfu_light_Array.size():
		yinfu_light_Array[index].visible = true
		yinfu_light_Name.append(yinfu_Name[index])


		if yinfu_light_Name.size() == yinfu_Name.size():
			print("所有音符已按顺序点亮！")


			disable_all_floor_areas()

			activate_child_monster_149()






func activate_child_monster_149():
	for child in monster.get_children():
		if child.name == "Monster_149":
			if child.has_method("_on_all_notes_activated"):
				child._on_all_notes_activated()
				print("已触发子节点 Monster_149 的方法")
			else:
				push_error("子节点 Monster_149 没有 _on_all_notes_activated 方法！")
			return


	print("警告：当前节点下没有名为 Monster_149 的子节点")




func disable_all_floor_areas():
	for area in floor_YinFu_Area2D_Array:
		if is_instance_valid(area) and area is Area2D:
			area.set_deferred("monitoring", false)
			area.set_deferred("monitorable", false)

			area.set_deferred("collision_layer", 0)
			area.set_deferred("collision_mask", 0)
func reset_sequence():
	hide_all_lights()
	yinfu_light_Name.clear()
	print("顺序错误，已重置")




func _on_floor_1_yin_fu_area_2d_area_entered(area: Area2D) -> void :
	if area.is_in_group("Role_Interactive"):
		check_color_sequence("橙色")


func _on_floor_1_yin_fu_area_2d_2_area_entered(area: Area2D) -> void :
	if area.is_in_group("Role_Interactive"):
		check_color_sequence("黄色")


func _on_floor_1_yin_fu_area_2d_3_area_entered(area: Area2D) -> void :
	if area.is_in_group("Role_Interactive"):
		check_color_sequence("绿色")


func _on_floor_1_yin_fu_area_2d_4_area_entered(area: Area2D) -> void :
	if area.is_in_group("Role_Interactive"):
		check_color_sequence("浅蓝色")


func _on_floor_1_yin_fu_area_2d_5_area_entered(area: Area2D) -> void :
	if area.is_in_group("Role_Interactive"):
		check_color_sequence("深蓝色")



func _on_floor_1_yin_fu_area_2d_6_area_entered(area: Area2D) -> void :
	if area.is_in_group("Role_Interactive"):
		check_color_sequence("红色")


func _on_floor_1_yin_fu_area_2d_7_area_entered(area: Area2D) -> void :
	if area.is_in_group("Role_Interactive"):
		check_color_sequence("紫色")
