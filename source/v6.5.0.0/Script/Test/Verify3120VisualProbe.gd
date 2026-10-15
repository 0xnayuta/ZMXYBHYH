extends Node2D




const MONSTER_SCENE: = "res://Scene/Monster/Monster_3120.tscn"
const OBSERVE_FRAMES: = 600
const SNAP_EVERY: = 20
const OUT_DIR: = "D:/造梦八荒2/.codex_tmp/3120_shot2"
const FLOOR_Y: = 445.0

var monster: Node

func _ready() -> void :
	call_deferred("_run")

func _physics_process(_delta: float) -> void :
	if monster != null and is_instance_valid(monster):
		if monster.global_position.y != FLOOR_Y:
			monster.global_position.y = FLOOR_Y
			monster.velocity.y = 0.0

func _run() -> void :
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	MainSet.set_data["NoShowMonsterBody"] = false
	MainSet.set_data["MonsterDamageSHow"] = false
	RoleProp.SourcePlayer = null

	monster = load(MONSTER_SCENE).instantiate()
	monster.position = Vector2(400.0, FLOOR_Y)
	add_child(monster)
	RoleProp.role_pos = Vector2(760.0, FLOOR_Y)

	var mr_ani: AnimatedSprite2D = monster.get("mr_ani")
	var player: AnimationPlayer = monster.get("mr_player")
	var bullet_node: Node = monster.get("bullet")

	for f in range(OBSERVE_FRAMES):
		await get_tree().physics_frame
		if f % SNAP_EVERY != 0:
			continue
		var cur: = String(player.current_animation)
		var sprite_anim: = mr_ani.animation
		var sprite_frame: = mr_ani.frame
		var names: = []
		for child in bullet_node.get_children():
			names.append(str(child.get("skill_name")))
		var tex_ok: = mr_ani.texture != null
		print("SNAP f=%d gp=%s anim=%s sprite=%s/%d vis=%s tex=%s projs=%s" % [
			f, str(monster.global_position.snapped(Vector2.ONE)), cur, 
			String(sprite_anim), sprite_frame, str(mr_ani.is_visible_in_tree()), 
			str(tex_ok), str(names), 
		])
		await RenderingServer.frame_post_draw
		var img: = get_viewport().get_texture().get_image()
		img.save_png("%s/f%04d.png" % [OUT_DIR, f])
	print("VISUAL PROBE DONE")
	get_tree().quit(0)
