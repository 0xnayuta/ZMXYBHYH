extends Node2D
class_name MgHit

@onready var bullet_player: AnimationPlayer = $BulletPlayer
@onready var bullet_ani: AnimatedSprite2D = $Bullet

var source_weapon: BaseMagicWeapon = null
var Rnd: int
var name_
var objattackDic = {}
var dir: bool
var get_dir: bool
var is_set: bool = false
var PP
var HitDic = {"power": 0, "hurtBack": [0, 0], "attackKind": "real"}

var target_monster: BaseMonster = null
var speed: float = 600.0
var max_life: float = 3.0
var life_timer: float = 0.0

const ATTRACT_RADIUS: float = 1000.0
const ATTRACT_FORCE: float = 8.0
const MIN_DISTANCE: float = 30.0
var monster_container: Node = null
var _monster_level: Node = null
var _attraction_candidates: Array[BaseMonster] = []
var _attraction_index_version := -1

var _wdsl2_hit_count: Dictionary = {}


func _physics_process(delta: float) -> void:
	if not is_set:
		PP = get_parent()
		if PP is BaseMagicWeapon:
			pass
		else:
			PP = PP.get_parent()
		if dir:
			scale.x = -scale.x
		is_set = true

		if name_ == "wdsfBullet3":
			_monster_level = get_tree().current_scene
			monster_container = _monster_level.get_node_or_null("Monster")

	HitDic = objattackDic

	if name_ == "wdsfBullet1" or name_ == "wdshBullet1" or name_ == "wdstBullet1" or name_ == "wdslBullet1":
		update_tracking(delta)
		life_timer += delta
		if life_timer >= max_life:
			queue_free()
		return

	if name_ == "wdsfBullet3":
		update_attraction(delta)

		if not bullet_player.is_playing():
			bullet_player.play(name_)

		bullet_ani.position = Vector2.ZERO
		return

	do_action()


func do_action():
	bullet_player.play(str(name_))
	await bullet_player.animation_finished
	queue_free()


func update_tracking(delta: float):
	if not bullet_player.is_playing():
		bullet_player.play(name_)
	bullet_ani.position = Vector2.ZERO

	var target_invalid = false
	if target_monster == null or not is_instance_valid(target_monster):
		target_invalid = true
	elif target_monster.Hp <= 0:
		target_invalid = true
	elif target_monster.NoDeBuff:
		target_invalid = true
	elif target_monster.IsIndestructible:
		target_invalid = true
	else:
		var hurt_box = target_monster.get_node_or_null("BaseDamageBox/HurtBox/HurtBox")
		if hurt_box and hurt_box.disabled:
			target_invalid = true

	if target_invalid:
		queue_free()
		return

	var direction = global_position.direction_to(target_monster.global_position)
	global_position += direction * speed * delta
	if direction.x != 0:
		scale.x = abs(scale.x) * sign(direction.x)


func set_target(target: BaseMonster):
	target_monster = target


func set_bullet_params(spd: float, life: float):
	speed = spd
	max_life = life


func update_attraction(_delta: float):
	if monster_container == null:
		return

	var candidates: Array = monster_container.get_children()
	if (
		_monster_level != null
		and _monster_level.has_method("has_active_monster_index")
		and _monster_level.has_active_monster_index()
	):
		var version := int(_monster_level.get_active_monster_version())
		if version != _attraction_index_version:
			_attraction_candidates = _monster_level.get_active_monsters()
			_attraction_index_version = version
		candidates = _attraction_candidates

	for child in candidates:
		if not (child is BaseMonster):
			continue
		var monster: BaseMonster = child
		if monster.Hp <= 0:
			continue
		if monster.is_control_immune():
			continue
		if monster.CannotAttract:
			continue

		var distance = global_position.distance_to(monster.global_position)
		if distance <= MIN_DISTANCE or distance > ATTRACT_RADIUS:
			continue

		var strength = (ATTRACT_RADIUS - distance) / ATTRACT_RADIUS * ATTRACT_FORCE

		strength = max(strength, 0.5)

		var direction = (global_position - monster.global_position).normalized()

		monster.global_position += direction * strength

		monster.velocity = Vector2.ZERO


func remove_infor():
	BaseHit.Mg_hit = 0
	BaseHit.Mghitbakc_x = 0
	BaseHit.Mghitbakc_y = 0
	BaseHit.Mg_hit_lx = ""


func _on_area_2d_area_entered(area: Area2D) -> void:
	var target = area.get_parent().get_parent()

	if target is BaseMonster:
		var hurt_box = target.get_node_or_null("BaseDamageBox/HurtBox/HurtBox")
		if hurt_box and hurt_box.disabled:
			queue_free()
			return

		if name_ == "wdslBullet2" and self.get_meta("third_wave_stun", false):
			var stun_buff = {
				"Name": "stun",
				"AddTime": 1.0,
				"ReduceInterval": 0,
				"value": 0,
				"CanAdd": false,
				"DeBuff": true,
				"CanRemove": false,
				"AttackKind": ""
			}
			Global.add_buff(target.buff, stun_buff)

		if objattackDic.has("addeffect") and objattackDic["addeffect"].size() != 0:
			if randi_range(0, 100) < Rnd:
				Global.add_buff(target.buff, objattackDic["addeffect"])

		if name_ == "wdsfBullet1" or name_ == "wdshBullet1" or name_ == "wdstBullet1" or name_ == "wdslBullet1":
			if target == target_monster:
				queue_free()

			return

		if name_ == "wdsfBullet3":
			return

	if name_ == "MagicUmbrellaBullet":
		queue_free()
