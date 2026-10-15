extends SceneTree

const HURT_DURATION: = 0.28
const HURT_ANIMATION_CASES: = {
	"res://Scene/Monster/Monster_3065.tscn": 35, 
	"res://Scene/Monster/Monster_3069.tscn": 35, 
	"res://Scene/Monster/Monster_3070.tscn": 35, 
}
const VELOCITY_STOP_SCENES: = [
	"res://Scene/Monster/Monster_3065.tscn", 
	"res://Scene/Monster/Monster_3069.tscn", 
	"res://Scene/Monster/Monster_3070.tscn", 
	"res://Scene/Monster/Monster_3076.tscn", 
	"res://Scene/Monster/Monster_3117.tscn", 
]
const STATIC_PLATFORM_NAMES: = [
	"TopStageFloor", 
	"StaticPlatform_bg19Z", 
	"StaticPlatform_bg19G", 
	"StaticPlatform_bg19F", 
	"StaticPlatform_bg19C", 
	"StaticPlatform_bg19B", 
	"StaticPlatform_bg19A", 
	"StaticPlatform_bg17", 
	"StaticPlatform_bg15", 
	"StaticPlatform_bg14A", 
	"StaticPlatform_bg13", 
	"StaticPlatform_bg12", 
	"StaticPlatform_bg11", 
	"StaticPlatform_bg10", 
]


func _init() -> void :
	call_deferred("_run")


func _run() -> void :
	for scene_path: String in HURT_ANIMATION_CASES:
		var monster: = _instantiate_scene(scene_path) as CharacterBody2D
		if monster == null:
			return
		var animation: Animation = monster.call(
			"_make_animation", &"hurt", int(HURT_ANIMATION_CASES[scene_path]), false
		)
		if not is_equal_approx(animation.length, HURT_DURATION):
			monster.free()
			_fail("hurt duration %s = %s" % [scene_path, animation.length])
			return
		monster.free()

	for scene_path: String in VELOCITY_STOP_SCENES:
		var monster: = _instantiate_scene(scene_path) as CharacterBody2D
		if monster == null:
			return
		var generation: = int(monster.call("_begin_hurt_reaction"))
		monster.velocity.x = 300.0
		monster.call("_finish_hurt_reaction", generation)
		if not is_zero_approx(monster.velocity.x):
			var remaining_velocity: = monster.velocity.x
			monster.free()
			_fail("knockback stop %s = %s" % [scene_path, remaining_velocity])
			return
		monster.free()

	var level: = _instantiate_scene("res://Scene/Level/Level_60.tscn")
	if level == null:
		return
	var wall: = level.get_node_or_null("wall")
	if wall == null:
		level.free()
		_fail("Level_60 wall")
		return
	for platform_name: String in STATIC_PLATFORM_NAMES:
		var platform: = wall.get_node_or_null(platform_name) as Node2D
		if platform == null or not bool(platform.get("one_way_collision")):
			level.free()
			_fail("one-way static platform %s" % platform_name)
			return
	for platform_index in range(1, 7):
		var path: = "MovingPlatforms/MovingPlatform%d/CollisionShape2D" % platform_index
		var platform: = level.get_node_or_null(path) as CollisionShape2D
		if platform == null or not platform.one_way_collision:
			level.free()
			_fail("one-way moving platform %d" % platform_index)
			return
	for boundary_name: String in ["wall_left", "right_wall"]:
		var boundary: = wall.get_node_or_null(boundary_name) as CollisionShape2D
		if boundary == null or boundary.one_way_collision:
			level.free()
			_fail("solid boundary %s" % boundary_name)
			return
	level.free()

	print("LEVEL_59_TO_62_KNOCKBACK_OK hurt=%.2fs one_way_platforms=%d" % [
		HURT_DURATION, STATIC_PLATFORM_NAMES.size() + 6, 
	])
	quit(0)


func _instantiate_scene(path: String) -> Node:
	var packed: = load(path) as PackedScene
	if packed == null:
		_fail("scene load %s" % path)
		return null
	return packed.instantiate()


func _fail(reason: String) -> void :
	push_error("LEVEL_59_TO_62_KNOCKBACK_FAIL %s" % reason)
	quit(1)
