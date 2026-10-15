extends Node2D

const LEVEL_SCRIPT_PATH: = "res://Script/Level/Level_61.gd"
const BOSS_SCENE_PATH: = "res://Scene/Monster/Monster_3077.tscn"


class LevelConfigHost:
	extends Node2D

	var provider: Node
	var monster_blood: Node2D
	var fall_it: Node2D

	func get_level_monster_config(monster_id: int) -> Dictionary:
		return provider.call("get_level_monster_config", monster_id)


class DamageProbeHero:
	extends BaseHero

	func _ready() -> void :
		pass

	func _physics_process(_delta: float) -> void :
		pass

	func _add_role_hit_effect_throttled() -> void :
		pass


func _ready() -> void :
	call_deferred("_run")


func _run() -> void :
	var provider: Node = (load(LEVEL_SCRIPT_PATH) as Script).new()
	var host: = LevelConfigHost.new()
	host.provider = provider
	host.monster_blood = Node2D.new()
	host.monster_blood.name = "monster_blood"
	host.add_child(host.monster_blood)
	host.fall_it = Node2D.new()
	host.fall_it.name = "fall_it"
	host.add_child(host.fall_it)
	host.add_to_group("BaseLevel")
	add_child(host)

	var role_container: = Node2D.new()
	role_container.name = "Role"
	host.add_child(role_container)
	var hero: = _create_damage_probe_hero()
	role_container.add_child(hero)
	RoleProp.SourcePlayer = hero
	RoleProp.baseroleprop.Level = 90
	RoleProp.roleprop.SHp = 1000000
	RoleProp.roleprop.Hp = 1000000
	RoleProp.roleprop.Miss = 0
	RoleProp.roleprop.CritReduce = 1000000
	RoleProp.roleprop.Toughness = 1000000
	RoleProp.roleprop.Def = 0
	RoleProp.roleprop.Mdef = 0

	var boss: = (load(BOSS_SCENE_PATH) as PackedScene).instantiate() as BaseMonster
	if boss == null:
		_fail("3077 scene")
		return
	boss.set("_prewarm_requested", true)
	boss.position = Vector2(1000.0, 500.0)
	host.add_child(boss)
	await get_tree().process_frame
	await get_tree().process_frame
	boss.set_physics_process(false)
	boss.call("_begin_small_wind_skill")
	await get_tree().process_frame
	await get_tree().physics_frame

	var wind: = _single_monster(host, 3080)
	if wind == null:
		_fail("small wind spawn")
		return
	var damage_area: Node = wind.get("_damage_area") as Node
	if damage_area == null:
		_fail("small wind damage area")
		return
	var hit_name: = str(damage_area.get("hit_name"))
	if hit_name.is_empty() or not boss.objattackDic.has(hit_name):
		_fail("small wind owner damage route")
		return
	var hit_shape: = damage_area.get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
	if hit_shape == null:
		_fail("small wind damage shape")
		return

	hero.global_position = hit_shape.global_position
	var hp_before: = int(RoleProp.roleprop.Hp)
	var hits_before: = int(Global.TotalHurtCount)
	await get_tree().physics_frame
	await get_tree().create_timer(0.65).timeout
	var hp_after: = int(RoleProp.roleprop.Hp)
	var received_hits: = int(Global.TotalHurtCount) - hits_before
	if hp_after >= hp_before:
		_fail("small wind did not reduce hero HP")
		return
	if received_hits < 2:
		_fail("small wind sustained overlap hits = %d" % received_hits)
		return

	print("LEVEL_61_WIND_DAMAGE_OK hits=%d hp_loss=%d" % [received_hits, hp_before - hp_after])
	get_tree().quit(0)


func _create_damage_probe_hero() -> DamageProbeHero:
	var hero: = DamageProbeHero.new()
	hero.name = "DamageProbeHero"
	hero.add_child(_named_node(Timer.new(), "ZhenFa"))
	hero.add_child(_named_node(AnimationPlayer.new(), "RolePlayer"))
	hero.add_child(_named_node(Node2D.new(), "Damage_Text"))
	hero.add_child(_named_node(CollisionShape2D.new(), "pz"))
	hero.add_child(_named_node(Timer.new(), "WSTimer"))
	hero.add_child(_named_node(Node2D.new(), "MagicWeapon"))
	hero.add_child(_named_node(Label.new(), "Name_"))
	hero.add_child(_named_node(Node2D.new(), "Bullet"))
	hero.add_child(_named_node(Node.new(), "Buff"))
	hero.add_child(_named_node(AnimatedSprite2D.new(), "tx"))

	var action: = _named_node(Node2D.new(), "Action") as Node2D
	hero.add_child(action)
	action.add_child(_named_node(Sprite2D.new(), "RoleBody"))
	action.add_child(_named_node(Sprite2D.new(), "RoleEquipment"))
	action.add_child(_named_node(AnimatedSprite2D.new(), "Wings"))
	var effect_body: = _named_node(Node2D.new(), "EffectBody") as Node2D
	action.add_child(effect_body)
	for part_name in ["toukui", "jianjia", "huwan", "shenti", "yaodai", "xiabai", "wuqi"]:
		effect_body.add_child(_named_node(AnimatedSprite2D.new(), part_name))

	var damage_box: = _named_node(Node2D.new(), "base_damagebox") as Node2D
	hero.add_child(damage_box)
	var hurt_area: = _named_node(Area2D.new(), "HurtBox") as Area2D
	hurt_area.collision_layer = 128
	hurt_area.collision_mask = 0
	damage_box.add_child(hurt_area)
	var hurt_shape: = _named_node(CollisionShape2D.new(), "HurtBox") as CollisionShape2D
	var rectangle: = RectangleShape2D.new()
	rectangle.size = Vector2(20.0, 20.0)
	hurt_shape.shape = rectangle
	hurt_area.add_child(hurt_shape)
	return hero


func _named_node(node: Node, node_name: String) -> Node:
	node.name = node_name
	return node


func _single_monster(parent: Node, monster_kind: int) -> Node:
	var match_node: Node
	for child in parent.get_children():
		if child is CharacterBody2D and int(child.get("monster_kind")) == monster_kind:
			if match_node != null:
				return null
			match_node = child
	return match_node


func _fail(reason: String) -> void :
	push_error("LEVEL_61_WIND_DAMAGE_FAIL %s" % reason)
	get_tree().quit(1)
