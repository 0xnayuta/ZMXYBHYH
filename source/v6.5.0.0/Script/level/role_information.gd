extends Node2D

var _gogo: AnimatedSprite2D
var gogo: AnimatedSprite2D:
    get:
        if _gogo == null:
            _gogo = get_node_or_null("roleLayer/Control/Control/Gogo") as AnimatedSprite2D
        return _gogo
@onready var role_layer: Control = $roleLayer/Control
@onready var Control_: Control = $roleLayer/Control2
@onready var set_menu_con: BoxContainer = $roleLayer/ButtonGroup

var set_key_tscn: PackedScene = preload("res://Scene/tools/set_com.tscn")
var head_tscn: PackedScene = preload("res://Scene/base/base_role.tscn")
var head_p2_tscn: PackedScene = preload("res://Scene/base/base_role_p2.tscn")

var set_com_node
var Player
var player_p2
var role_p1
var RoleP2
var buff_box: HBoxContainer
var is_stop: bool = false
var cur_prop: bool = false
const OLD_WUSHUANG_POSITION := Vector2(735, 505)


func _ready() -> void:
    add_to_group("RoleInformation")
    Global.call_deferred("prewarm_permanent_small_ui_scenes")
    Player = _main_role()
    if Player == null:
        Player = RoleProp.source_player
    gogo.visible = false

    role_p1 = head_tscn.instantiate()
    role_p1.Player = Player
    role_layer.add_child(role_p1)
    buff_box = role_p1.buff_box
    Global.buff_box = buff_box

    if _is_mobile():
        set_com_node = set_key_tscn.instantiate()
        Control_.add_child(set_com_node)

    player_p2 = _second_role()
    if player_p2 != null:
        RoleP2 = head_p2_tscn.instantiate()
        RoleP2.Player = player_p2
        role_layer.add_child(RoleP2)

    if _is_mobile():
        _layout_mobile()

    _hide_role_hud(role_p1)
    _hide_role_hud(RoleP2)
    set_menu_con.visible = false


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


func _show_role_hud(role_node: Node) -> void:
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


func _hide_role_hud(role_node: Node) -> void:
    if role_node == null:
        return
    role_node.visible = false


func reveal_after_scene_loaded() -> void:
    _show_role_hud(role_p1)
    _show_role_hud(RoleP2)
    set_menu_con.visible = true


func _layout_mobile() -> void:
    set_menu_con.visible = false
    if player_p2 != null:
        set_menu_con.position.x -= 100
        set_menu_con.position.y -= 17
    else:
        set_menu_con.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
        set_menu_con.position.x -= 20
        set_menu_con.position.y -= 17
    set_menu_con.visible = true

    _show_role_hud(role_p1)

    if RoleP2 != null:
        _show_role_hud(RoleP2)
        RoleP2.grey.position = role_p1.grey.position


func switch_role() -> void:
    if not _is_mobile() or RoleP2 == null:
        return
    if cur_prop:
        role_p1.grey.modulate.a = 1
        RoleP2.grey.modulate.a = 1
    else:
        role_p1.grey.modulate.a = 1
        RoleP2.grey.modulate.a = 1
    cur_prop = not cur_prop


func is_full_ws() -> bool:
    return role_p1 != null and role_p1.is_full_ws()
