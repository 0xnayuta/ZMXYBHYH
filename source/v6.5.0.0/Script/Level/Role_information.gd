class_name RoleInfor
extends Node2D

var _gogo: AnimatedSprite2D
var gogo: AnimatedSprite2D:
	get:
		if _gogo == null:
			_gogo = get_node_or_null("roleLayer/Control/Control/Gogo") as AnimatedSprite2D
		return _gogo
@onready var roleLayer: Control = $roleLayer / Control
@onready var Control_: Control = $roleLayer / Control2
@onready var SetMenuCon: BoxContainer = $roleLayer / ButtonGroup

var set_key_tscn: PackedScene = preload("res://Scene/Tools/set_com.tscn")
var head_tscn: PackedScene = preload("res://Scene/Base/BaseRole.tscn")
var head_p2_tscn: PackedScene = preload("res://Scene/Base/BaseRoleP2.tscn")

var setComNode
var Player
var PlayerP2
var RoleP1
var RoleP2
var buff_box: HBoxContainer
var isStop: bool = false
var curProp: bool = false
const OLD_WUSHUANG_POSITION: = Vector2(735, 505)

func _ready() -> void :
	add_to_group("RoleInformation")
	Global.call_deferred("prewarm_permanent_small_ui_scenes")
	Player = _main_role()
	if Player == null:
		Player = RoleProp.SourcePlayer
	gogo.visible = false

	RoleP1 = head_tscn.instantiate()
	RoleP1.Player = Player
	roleLayer.add_child(RoleP1)
	buff_box = RoleP1.buff_box
	Global.buff_box = buff_box

	if _is_mobile():
		setComNode = set_key_tscn.instantiate()
		Control_.add_child(setComNode)

	PlayerP2 = _second_role()
	if PlayerP2 != null:
		RoleP2 = head_p2_tscn.instantiate()
		RoleP2.Player = PlayerP2
		roleLayer.add_child(RoleP2)

	if _is_mobile():
		_layout_mobile()

	_hide_role_hud(RoleP1)
	_hide_role_hud(RoleP2)
	SetMenuCon.visible = false

func _main_role():
	var level = get_parent()
	if level != null and level.get("Role_") != null:
		return level.get("Role_")
	return null

func _second_role():
	var level = get_parent()
	if level != null and level.get("RoleP2") != null:
		return level.get("RoleP2")
	return null

func _is_mobile() -> bool:
	return OS.has_feature("android")
	return true


func _show_role_hud(role_node: Node) -> void :
	if role_node == null:
		return
	role_node.visible = true
	if role_node is CanvasItem:
		role_node.modulate = Color(1, 1, 1, 1)
	var head_node = role_node.get("head")
	if head_node is CanvasItem:
		head_node.visible = true
		head_node.modulate = Color(1, 1, 1, 1)
	var menu_node = role_node.get("menu")
	if menu_node is CanvasItem:
		menu_node.visible = true
		menu_node.modulate = Color(1, 1, 1, 1)
	var grey_node = role_node.get("grey")
	if grey_node is CanvasItem:
		grey_node.visible = true
		grey_node.modulate = Color(1, 1, 1, 1)

func _hide_role_hud(role_node: Node) -> void :
	if role_node == null:
		return
	role_node.visible = false

func reveal_after_scene_loaded() -> void :
	_show_role_hud(RoleP1)
	_show_role_hud(RoleP2)
	SetMenuCon.visible = true
func _layout_mobile() -> void :
	SetMenuCon.visible = false
	if PlayerP2 != null:
		SetMenuCon.position.x -= 100
		SetMenuCon.position.y -= 17
	else:
		SetMenuCon.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		SetMenuCon.position.x -= 20
		SetMenuCon.position.y -= 17
	SetMenuCon.visible = true

	_show_role_hud(RoleP1)

	if RoleP2 != null:
		_show_role_hud(RoleP2)
		RoleP2.grey.position = RoleP1.grey.position

func switchRole() -> void :
	if not _is_mobile() or RoleP2 == null:
		return
	if curProp:
		RoleP1.grey.modulate.a = 1
		RoleP2.grey.modulate.a = 1
	else:
		RoleP1.grey.modulate.a = 1
		RoleP2.grey.modulate.a = 1
	curProp = not curProp

func is_full_ws() -> bool:
	return RoleP1 != null and RoleP1.is_full_ws()
