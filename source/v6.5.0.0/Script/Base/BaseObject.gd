extends CharacterBody2D
class_name BaseObject

var IsReverseMove: bool = false
var ReverseMoveSpeedMultiplier: float = 1.0

var NoDeBuff: bool = false

var walk_speed: int = 240
var run_speed: int
var gravity: float = -980.0
var direction: int
var objattackDic: Dictionary
var jump_count: int = 0
var jump_power: float = -540.0
var hit_count: int = 0
var is_using_skills: bool = false
var is_attacking: bool = false
var is_be_attacking: bool = false
var SHp: int
var Hp: int
var is_crit: bool
var is_miss: bool
var is_ice: bool
var is_DeadLink: bool
var is_EyeFix: bool


func spawn_ws_effect(visual_node: Node, parent_node: Node) -> void:
	if visual_node == null or not is_instance_valid(visual_node):
		return
	var ws_effect_scene = Global.preload_scene_path("res://Scene/Hero/Role_1/WS_Effect.tscn")
	if ws_effect_scene == null:
		return
	var ws_effect = ws_effect_scene.instantiate()
	if ws_effect == null:
		return
	var visual_copy = visual_node.duplicate()
	if visual_copy == null:
		ws_effect.queue_free()
		return
	ws_effect.add_child(visual_copy)
	ws_effect.position = position
	if parent_node == null:
		ws_effect.queue_free()
		return
	parent_node.add_child(ws_effect)


func _physics_process(_delta: float) -> void:
	if Hp >= SHp:
		Hp = SHp
	if Hp <= 0:
		Hp = 0


func set_data():
	gravity = -980.0
	objattackDic = {}
	jump_count = 0
	jump_power = -540.0


func get_hurt(hit_name):
	var hurt = objattackDic[hit_name].power
	return hurt


func get_hurt_lx(hit_name):
	var hurt_kind = objattackDic[hit_name].attackKind
	return hurt_kind


func CheckFashionAndAddFallPro():
	if PlayerData.player_data["时装"].size() <= 0:
		return 0.0
	else:
		if (
			PlayerData.check_fashion_clothes("wklzyf")
			or PlayerData.check_fashion_clothes("tslzyf")
			or PlayerData.check_fashion_clothes("bjlzyf")
			or PlayerData.check_fashion_clothes("sslzyf")
		):
			return 0.05
		if (
			PlayerData.check_fashion_clothes("wkhzyf")
			or PlayerData.check_fashion_clothes("tshzyf")
			or PlayerData.check_fashion_clothes("bjhzyf")
			or PlayerData.check_fashion_clothes("sshzyf")
		):
			return 0.08
	return 0
