extends Node2D

const BOSS_SCENE: = preload("res://Scene/Monster/Monster_3223.tscn")
const OUTPUT_PATH: = "res://.tmp/yellow_brow_official_skills.png"

var _failed: = false
var _pulse_hp_samples: Array[String] = []


class ProbeHero:
	extends BaseHero

	func _ready() -> void :
		pass

	func _physics_process(_delta: float) -> void :
		pass

	func _add_role_hit_effect_throttled() -> void :
		pass

	func _pet_turtle_link_unit() -> Node:
		return null


func _ready() -> void :
	call_deferred("_run")


func _run() -> void :
	RoleProp.set_physics_process(false)
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	MainSet.set_data["NoShowMonsterBody"] = true
	var background: = ColorRect.new()
	background.color = Color("18212a")
	background.size = Vector2(1152.0, 648.0)
	background.z_index = -100
	add_child(background)

	var host: = Node2D.new()
	host.name = "Monster"
	add_child(host)
	var hero: = _create_hero()
	hero.position = Vector2(620.0, 430.0)
	add_child(hero)
	RoleProp.SourcePlayer = hero
	RoleProp.role_pos = hero.position
	RoleProp.role_pos_x = hero.position.x
	RoleProp.role_pos_y = hero.position.y
	RoleProp.baseroleprop.Level = 90
	RoleProp.roleprop.SHp = 100000000
	RoleProp.roleprop.Hp = 100000000
	RoleProp.roleprop.Def = 0
	RoleProp.roleprop.Mdef = 0
	RoleProp.roleprop.Miss = 0
	RoleProp.roleprop.CritReduce = 1000000
	RoleProp.roleprop.Toughness = 1000000

	var boss: = BOSS_SCENE.instantiate() as EastContinentMonster
	boss.position = Vector2(500.0, 430.0)
	host.add_child(boss)
	await get_tree().process_frame
	boss.NoGrav = true
	boss.velocity = Vector2.ZERO
	boss.MonsterDirection = true
	boss.set_process(false)
	boss.set_physics_process(false)
	boss.mr_player.stop()
	boss._disable_attack_box()
	await get_tree().physics_frame
	RoleProp.roleprop.SHp = 100000000
	RoleProp.roleprop.Hp = 100000000

	var hit_times: Array[int] = []
	var previous_hp: = int(RoleProp.roleprop.Hp)
	var initial_hp: = previous_hp
	var started: = Time.get_ticks_msec()
	boss._start_3223_official_attack(&"hit1")
	var pulse: = boss.bullet.get_child(0) as WutaiMinghaiProjectile
	pulse.hit_callback = Callable(self, "_record_pulse_hit")
	var max_internal_hits: = 0
	var max_pulse_index: = -1
	while Time.get_ticks_msec() - started < 1450:
		await get_tree().physics_frame
		if pulse != null and is_instance_valid(pulse):
			max_internal_hits = maxi(max_internal_hits, pulse._hit_count)
			max_pulse_index = maxi(max_pulse_index, pulse._pulse_index)
		var current_hp: = int(RoleProp.roleprop.Hp)
		if current_hp < previous_hp:
			hit_times.append(roundi(pulse._elapsed * 1000.0) if pulse != null and is_instance_valid(pulse) else -1)
			previous_hp = current_hp
	_check(hit_times.size() == 3, "三连击实际扣血次数=%d internal=%d pulse=%d protect=%s current=%s" % [
		hit_times.size(), max_internal_hits, max_pulse_index, hero.needProtect, hero.CurrentProtect, 
	])
	if hit_times.size() != 3:
		print("YELLOW_BROW_PULSE_TRACE " + ",".join(_pulse_hp_samples))
	if hit_times.size() == 3:
		var pulse_area: = pulse.get_node("middle/HitBox") as Area2D if pulse != null and is_instance_valid(pulse) else null
		print("YELLOW_BROW_HIT_TIMES %s trace=%s layer=%s mask=%s" % [
			hit_times, 
			_pulse_hp_samples, 
			pulse_area.collision_layer if pulse_area != null else -1, 
			pulse_area.collision_mask if pulse_area != null else -1, 
		])
		for index in range(1, hit_times.size()):
			var interval: = hit_times[index] - hit_times[index - 1]
			_check(interval >= 450 and interval <= 620, "三连击间隔%dms" % interval)
	_check(
		int(boss.objattackDic["hit1"]["power"]) == roundi(43000.0 * 0.67), 
		"三连击不是0.67倍攻击"
	)

	boss._start_3223_official_attack(&"hit2")
	boss._start_3223_official_attack(&"hit2")
	await get_tree().process_frame
	var cymbal: = boss._3223_summons.get(3224) as EastContinentMonster
	_check(cymbal != null and is_instance_valid(cymbal), "召唤金铙失败")
	_check(_count_kind(host, 3224) == 1, "金铙没有保持唯一实例")

	boss._start_3223_official_attack(&"hit3")
	boss._start_3223_official_attack(&"hit3")
	await get_tree().process_frame
	var bag: = boss._3223_summons.get(3225) as EastContinentMonster
	_check(bag != null and is_instance_valid(bag), "召唤后天魔袋失败")
	_check(_count_kind(host, 3225) == 1, "后天魔袋没有保持唯一实例")
	if cymbal != null and is_instance_valid(cymbal):
		cymbal._attack_serial = 1
		cymbal._start_late_skill_effect(&"hit1", 1)
		await get_tree().create_timer(0.12, false).timeout
		var fissure: WutaiMinghaiProjectile = null
		for child: Node in cymbal.bullet.get_children():
			if child is WutaiMinghaiProjectile:
				fissure = child as WutaiMinghaiProjectile
				break
		_check(fissure != null, "金铙裂地没有生成独立特效")
		if fissure != null:
			_check(fissure.atlas_sequence == "effect1_1", "金铙裂地特效序列错误")
			_check(fissure.max_hits == 6, "金铙裂地命中上限不是6")
			_check(is_equal_approx(fissure.damage_pulse_interval, 0.334), "金铙裂地间隔不是334ms")
			var stream: = fissure.get_node_or_null("middle/VisualStream") as StreamedPngEffect
			_check(stream != null and not stream.frame_paths.is_empty(), "金铙裂地没有可见帧")

	await get_tree().process_frame
	var output: = ProjectSettings.globalize_path(OUTPUT_PATH)
	if DisplayServer.get_name() != "headless":
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.tmp"))
		var image: = get_viewport().get_texture().get_image()
		_check(image != null and image.save_png(output) == OK, "技能截图保存失败")
	if not _failed:
		print("YELLOW_BROW_OFFICIAL_SKILL_PROBE_OK initial=%d hits=%s summons=3224,3225 screenshot=%s" % [initial_hp, hit_times, output])
	get_tree().quit(1 if _failed else 0)


func _count_kind(parent: Node, kind: int) -> int:
	var result: = 0
	for child: Node in parent.get_children():
		if child is EastContinentMonster and (child as EastContinentMonster).monster_kind == kind:
			result += 1
	return result


func _create_hero() -> ProbeHero:
	var hero: = ProbeHero.new()
	hero.name = "ProbeHero"
	hero.add_child(_named(Timer.new(), "ZhenFa"))
	hero.add_child(_named(AnimationPlayer.new(), "RolePlayer"))
	hero.add_child(_named(Node2D.new(), "Damage_Text"))
	hero.add_child(_named(CollisionShape2D.new(), "pz"))
	hero.add_child(_named(Timer.new(), "WSTimer"))
	var protect: = _named(Timer.new(), "Protect") as Timer
	protect.one_shot = true
	hero.add_child(protect)
	hero.add_child(_named(Node2D.new(), "MagicWeapon"))
	hero.add_child(_named(Label.new(), "Name_"))
	hero.add_child(_named(Node2D.new(), "Bullet"))
	hero.add_child(_named(Node.new(), "Buff"))
	hero.add_child(_named(AnimatedSprite2D.new(), "tx"))
	var action: = _named(Node2D.new(), "Action") as Node2D
	hero.add_child(action)
	action.add_child(_named(Sprite2D.new(), "RoleBody"))
	action.add_child(_named(Sprite2D.new(), "RoleEquipment"))
	action.add_child(_named(AnimatedSprite2D.new(), "Wings"))
	var effect_body: = _named(Node2D.new(), "EffectBody") as Node2D
	action.add_child(effect_body)
	for part_name in ["toukui", "jianjia", "huwan", "shenti", "yaodai", "xiabai", "wuqi"]:
		effect_body.add_child(_named(AnimatedSprite2D.new(), part_name))
	var damage_box: = _named(Node2D.new(), "base_damagebox") as Node2D
	hero.add_child(damage_box)
	var hurt_area: = _named(Area2D.new(), "HurtBox") as Area2D
	hurt_area.collision_layer = 128
	hurt_area.collision_mask = 4
	damage_box.add_child(hurt_area)
	var hurt_shape: = _named(CollisionShape2D.new(), "HurtBox") as CollisionShape2D
	var rectangle: = RectangleShape2D.new()
	rectangle.size = Vector2(40.0, 96.0)
	hurt_shape.shape = rectangle
	hurt_shape.position = Vector2(0.0, -48.0)
	hurt_area.add_child(hurt_shape)
	hurt_area.area_entered.connect(hero._on_hurt_box_area_entered)
	return hero


func _named(node: Node, node_name: String) -> Node:
	node.name = node_name
	return node


func _record_pulse_hit(projectile: WutaiMinghaiProjectile, player: BaseHero) -> void :
	_pulse_hp_samples.append("pulse=%d hp=%d protect=%s current=%.1f" % [
		projectile._pulse_index, 
		int(RoleProp.roleprop.Hp), 
		player.needProtect, 
		player.CurrentProtect, 
	])


func _check(condition: bool, message: String) -> void :
	if condition:
		return
	_failed = true
	push_error("YELLOW_BROW_OFFICIAL_SKILL_PROBE_FAIL " + message)
