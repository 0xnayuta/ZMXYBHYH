extends Node2D


const OUTPUT_PATH: = "res://.codex_tmp/liusha_coordinates_both_directions.png"
const BOSS_SCENES: = [
	"res://Scene/Monster/Monster_13101.tscn", 
	"res://Scene/Monster/Monster_13401.tscn", 
	"res://Scene/Monster/Monster_19201.tscn", 
]
const BOSS_NAMES: = ["邪·唐僧", "邪·悟空", "邪·后羿"]
const EFFECTS: = ["Role2Bullet1", "Role1Bullet1", "Monster172Bullet1"]
const SOURCE_OFFSETS: = [Vector2(50, 10), Vector2(120, 5), Vector2(50, 0)]

func _ready() -> void :
	MainSet.set_data["NoShowMonsterBody"] = true
	var background: = ColorRect.new()
	background.color = Color("16232a")
	background.size = Vector2(1200, 800)
	background.z_index = -100
	add_child(background)
	for row in range(2):
		var facing_right: = row == 1
		var direction: = 1.0 if facing_right else -1.0
		for index in range(BOSS_SCENES.size()):
			var boss: = (load(BOSS_SCENES[index]) as PackedScene).instantiate() as LiuShaRiverBoss
			boss.process_mode = Node.PROCESS_MODE_DISABLED
			boss.position = Vector2(200 + index * 400, 300 + row * 350)
			add_child(boss)
			boss.monster_dir.scale.x = - direction
			boss._play_body_action("hit1")
			boss.mr_ani.stop()
			boss.mr_ani.frame = 2 if index != 2 else 3
			boss._align_body_frame()
			var source: Vector2 = SOURCE_OFFSETS[index]
			boss._spawn_effect(EFFECTS[index], boss._world(Vector2(direction * source.x, source.y)), facing_right, "hit1")
			for child in boss.get_children():
				if child is LiuShaRiverBoss.AttackOrigin:
					for effect in child.get_children():
						if effect is StreamedPngEffect:
							effect.process_mode = Node.PROCESS_MODE_ALWAYS
							effect.manual_frame_control = true
							effect._show_frame(2, true)
			var floor_line: = Line2D.new()
			floor_line.points = PackedVector2Array([Vector2(boss.position.x - 150, boss.position.y), Vector2(boss.position.x + 150, boss.position.y)])
			floor_line.width = 1
			floor_line.default_color = Color("526c75")
			add_child(floor_line)
			var pivot: = Line2D.new()
			pivot.points = PackedVector2Array([boss.position + Vector2(0, -145), boss.position + Vector2(0, 15)])
			pivot.width = 1
			pivot.default_color = Color("526c75")
			add_child(pivot)
			var label: = Label.new()
			label.text = BOSS_NAMES[index] + (" →" if facing_right else " ←")
			label.position = boss.position + Vector2(-60, 25)
			label.add_theme_font_size_override("font_size", 22)
			add_child(label)
	await get_tree().create_timer(0.1, false).timeout
	await RenderingServer.frame_post_draw
	var result: = get_viewport().get_texture().get_image().save_png(OUTPUT_PATH)
	if result != OK:
		push_error("流沙河双向坐标截图失败: %s" % result)
		get_tree().quit(1)
		return
	print("LIUSHA_BOSS_VISUAL_OK: " + OUTPUT_PATH)
	get_tree().quit(0)
