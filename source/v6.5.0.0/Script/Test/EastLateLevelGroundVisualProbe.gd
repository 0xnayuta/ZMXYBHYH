extends Node

const OUTPUT_PATH: = "res://.tmp/east_late_level_ground.png"
const EXPECTED_FLOOR_Y: = 405.5

var _failed: = false

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	var packed: = load("res://Scene/Level/Level_69.tscn") as PackedScene
	_check(packed != null, "无法加载蝙蝠窟场景")
	if packed == null:
		get_tree().quit(1)
		return
	var level: = packed.instantiate() as Game4EastLateLevel
	add_child(level)
	var flying_monster: = Global.Create_Monster(3198, level.monster, Vector2(650.0, 300.0)) as EastContinentMonster
	var ground_monster: = Global.Create_Monster(3199, level.monster, Vector2(900.0, 300.0)) as EastContinentMonster
	await get_tree().create_timer(1.5).timeout

	var floor_node: = level.get_node_or_null("wall/floor") as CollisionShape2D
	_check(floor_node != null and floor_node.shape is RectangleShape2D, "蝙蝠窟缺少地板碰撞")
	var floor_y: = 0.0
	if floor_node != null and floor_node.shape is RectangleShape2D:
		floor_y = floor_node.position.y - (floor_node.shape as RectangleShape2D).size.y * 0.5
		_check(is_equal_approx(floor_y, EXPECTED_FLOOR_Y), "蝙蝠窟运行时地面高度错误")
	_check(level.Role_ != null and is_instance_valid(level.Role_), "蝙蝠窟未生成人物")
	if level.Role_ != null and is_instance_valid(level.Role_):
		var role_shape: = level.Role_.get_node_or_null("pz") as CollisionShape2D
		_check(role_shape != null and role_shape.shape is CapsuleShape2D, "人物缺少移动碰撞体")
		if role_shape != null and role_shape.shape is CapsuleShape2D:
			var role_bottom: = role_shape.global_position.y + (role_shape.shape as CapsuleShape2D).height * 0.5
			var floor_global_y: = floor_node.global_position.y - (floor_node.shape as RectangleShape2D).size.y * 0.5
			_check(absf(role_bottom - floor_global_y) <= 1.0, "人物没有落在蝙蝠窟地面上")
	_check(flying_monster != null and is_instance_valid(flying_monster), "蝙蝠窟未生成飞行怪")
	_check(ground_monster != null and is_instance_valid(ground_monster), "蝙蝠窟未生成陆地怪")
	if flying_monster != null and is_instance_valid(flying_monster):
		_check(flying_monster.is_Fly and flying_monster.NoGrav, "蝙蝠没有保持飞行状态")
		var flying_shape: = flying_monster.get_node_or_null("pz") as CollisionShape2D
		_check(flying_shape != null and flying_shape.shape is CapsuleShape2D, "蝙蝠缺少移动碰撞体")
		if flying_shape != null and flying_shape.shape is CapsuleShape2D:
			var flying_bottom: = flying_shape.global_position.y + (flying_shape.shape as CapsuleShape2D).height * 0.5
			var floor_global_y: = floor_node.global_position.y - (floor_node.shape as RectangleShape2D).size.y * 0.5
			_check(flying_bottom < floor_global_y - 5.0, "蝙蝠落到了地面")
	if ground_monster != null and is_instance_valid(ground_monster):
		_check( not ground_monster.is_Fly and not ground_monster.NoGrav, "陆地怪被错误标记为飞行")
		_check(ground_monster.is_on_floor(), "陆地怪没有正常落地")

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.tmp"))
	var image: = get_viewport().get_texture().get_image()
	var output_path: = ProjectSettings.globalize_path(OUTPUT_PATH)
	_check(image != null and image.save_png(output_path) == OK, "无法保存蝙蝠窟验证截图")
	if not _failed:
		print("EAST_LATE_GROUND_VISUAL_PROBE_OK floor=%.1f flying_y=%.1f ground_y=%.1f screenshot=%s" % [floor_y, flying_monster.position.y, ground_monster.position.y, output_path])
	get_tree().quit(1 if _failed else 0)

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	_failed = true
	push_error("EAST_LATE_GROUND_VISUAL_PROBE_FAIL " + message)
