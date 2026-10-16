extends Node2D
class_name RoleBullet

@onready var bullet_player: AnimatedSprite2D = $Middle/BulletPlayer
@onready var bullet_players: AnimationPlayer = $Middle/BulletPlayers
@onready var middle: Node2D = $Middle
@onready var hit_box: Area2D = $Middle/HitBox
@onready var collion: CollisionShape2D = $Middle/HitBox/Collion
@onready var queue_timer: Timer = $QueueTimer

var inside_green: bool = false
var bullet_name: String = ""
var hit_dic: Dictionary = {}

var velocity: Vector2 = Vector2.ZERO
var speed_mag: float = 5000.0
var bounce_random_angle: float = 30.0
var is_exploding: bool = false

var _green_area: Area2D = null
var _green_rect: RectangleShape2D = null
var _cached_green_center: Vector2 = Vector2.ZERO
var _cached_half_extents: Vector2 = Vector2.ZERO
var _green_boundary_cached: bool = false

const SPRITE_ANGLE_OFFSET: float = PI

var IsCanCure: bool
var CureCount: int
var name_: String = "Role2Bullet5"
var Player: BaseHero
var Direction: bool = true
var is_set: bool = false
var tllz_awaken_extra: bool = false
var _tllz_awaken_targets: Dictionary = {}
var jhbhcount: int
var CheckCount: int = 0
var HitDic = {"power": 0, "hurtBack": [0, 0], "attackKind": "real"}
var BCRotationList = [30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 360]
var num: int = 0


func _ready() -> void:
	if hit_box:
		hit_box.area_entered.connect(_on_green_area_entered)
		hit_box.area_exited.connect(_on_green_area_exited)
	_update_green_area_cache()


func _exit_tree() -> void:
	if is_instance_valid(bullet_player):
		bullet_player.sprite_frames = null
	var special_effect := get_node_or_null("Middle/SpecialEffect") as AnimatedSprite2D
	if special_effect != null:
		special_effect.sprite_frames = null
	if is_instance_valid(collion):
		collion.shape = null


func spawn_reflect_effect(pos: Vector2, dir_velocity: Vector2, hit_dic: Dictionary) -> void:
	var effect_bullet = Global.addRoleBullet_(get_tree().root, pos, Direction, "Role2Bullet7_tx", hit_dic)
	if effect_bullet:
		var anim_player = effect_bullet.get_node("Middle/BulletPlayers")
		if anim_player:
			anim_player.play("Role2Bullet7_tx")

		var middle_node = effect_bullet.get_node("Middle")
		if middle_node:
			middle_node.scale.x = -1

		effect_bullet.is_set = true
		effect_bullet.rotation = dir_velocity.angle() + SPRITE_ANGLE_OFFSET


func _update_green_area_cache() -> void:
	if not _green_area:
		_green_area = get_tree().get_first_node_in_group("green_detector")
	if _green_area:
		var shape_node = _green_area.get_node_or_null("CollisionShape2D")
		if shape_node and shape_node.shape is RectangleShape2D:
			_green_rect = shape_node.shape as RectangleShape2D
			_green_boundary_cached = true
			_cached_green_center = _green_area.global_position
			_cached_half_extents = _green_rect.extents
		else:
			_green_boundary_cached = false
	else:
		_green_boundary_cached = false


func _apply_random_bounce(v: Vector2) -> Vector2:
	if bounce_random_angle > 0:
		var angle_offset = deg_to_rad(randf_range(-bounce_random_angle, bounce_random_angle))
		v = v.rotated(angle_offset)
		v = v.normalized() * speed_mag
	return v


func apply_green_area_boundary() -> void:
	if not _green_boundary_cached:
		_update_green_area_cache()
		if not _green_boundary_cached:
			return

	_cached_green_center = _green_area.global_position
	var half = _cached_half_extents
	var left = _cached_green_center.x - half.x
	var right = _cached_green_center.x + half.x
	var top = _cached_green_center.y - half.y
	var bottom = _cached_green_center.y + half.y

	var pos = global_position
	var margin = 2.0
	var changed = false

	if pos.x < left + margin:
		global_position.x = left + margin
		if velocity.x < 0:
			velocity.x = -velocity.x
			changed = true
	elif pos.x > right - margin:
		global_position.x = right - margin
		if velocity.x > 0:
			velocity.x = -velocity.x
			changed = true

	if pos.y < top + margin:
		global_position.y = top + margin
		if velocity.y < 0:
			velocity.y = -velocity.y
			changed = true
	elif pos.y > bottom - margin:
		global_position.y = bottom - margin
		if velocity.y > 0:
			velocity.y = -velocity.y
			changed = true

	if changed:
		velocity = _apply_random_bounce(velocity)
		self.rotation = velocity.angle() + SPRITE_ANGLE_OFFSET
		spawn_reflect_effect(global_position, velocity, HitDic)


func _on_green_area_entered(area: Area2D) -> void:
	if area.is_in_group("green_detector"):
		inside_green = true


func _on_green_area_exited(area: Area2D) -> void:
	if area.is_in_group("green_detector"):
		inside_green = false


func _physics_process(_delta: float) -> void:
	TQZCure()
	CheckCount += 1

	if not is_set:
		if Global.get_parent_(self, 2) is BaseHero:
			Player = Global.get_parent_(self, 2)
		elif Global.get_parent_(self, 1) is BaseHero:
			Player = Global.get_parent_(self, 1)
		bullet_players.play(name_)
		if Direction:
			middle.scale.x = -1
		else:
			middle.scale.x = 1

		if name_ == "Role2Bullet7_zd":
			var dir_vec = Vector2.RIGHT if Direction else Vector2.LEFT
			velocity = dir_vec * speed_mag
			self.rotation = velocity.angle() + SPRITE_ANGLE_OFFSET
			middle.scale.x = 1
		is_set = true

	if name_ == "Role2Bullet7_zd":
		move_with_reflection(velocity, _delta)

		apply_green_area_boundary()

		if position.y > 2000 or position.y < -1000 or position.x < -1000 or position.x > 8000:
			queue_free()
	else:
		if name_ == "Role2Bullet5":
			if Direction:
				self.position.x += 2
			else:
				self.position.x -= 2
			CallJHBH1()


func move_with_reflection(current_velocity: Vector2, delta: float) -> void:
	var space_state = get_world_2d().direct_space_state
	var target_pos = position + current_velocity * delta

	var query = PhysicsRayQueryParameters2D.new()
	query.from = position
	query.to = target_pos
	query.collision_mask = 1
	query.exclude = [self]

	var result = space_state.intersect_ray(query)

	if result:
		var normal = result.normal
		var hit_point = result.position

		var new_velocity = current_velocity.bounce(normal)

		new_velocity = _apply_random_bounce(new_velocity)

		position = hit_point + new_velocity.normalized() * 2
		velocity = new_velocity
		self.rotation = velocity.angle() + SPRITE_ANGLE_OFFSET
		spawn_reflect_effect(hit_point, new_velocity, HitDic)
	else:
		position = target_pos


func CallJHBH1():
	if Player == null or not is_instance_valid(Player):
		return
	BCRotationList.reverse()
	if jhbhcount % 5 == 0:
		if num > 11:
			num = 0
		var bc = Global.addRoleBullet_(
			Player.Bullet, position + bullet_player.position, Player.PlayerDir, "Role2Bullet5_1", HitDic
		)
		bc.rotation_degrees = BCRotationList[num]
		bc.scale = Vector2(1.5, 1.5)
		num += 1
	jhbhcount += 1


func _on_hit_box_area_entered(area: Area2D) -> void:
	if get_meta("liusha_boss_visual_only", false):
		return
	var Target := _get_monster_from_hit_area(area)
	if Target == null:
		return
	if _is_summon_or_pet_target(Target):
		return
	else:
		if name_ == "Role2Bullet7":
			var tree := get_tree()
			if tree == null:
				return
			await tree.create_timer(0.5).timeout
			if not is_inside_tree() or is_queued_for_deletion():
				return
			if is_instance_valid(Target):
				Global.addRoleBullet_(tree.root, Target.global_position, Direction, "Role2Bullet7_1", HitDic)

		match name_:
			"SwordArrayHit":
				if HitDic.has("addeffect"):
					Global.AddBuff(Target.buff, HitDic["addeffect"])
				if HitDic.has("defe_reduce"):
					(
						Global
						. AddBuff(
							Target.buff,
							{
								"Name": "DefeReduce",
								"AddTime": 8,
								"ReduceInterval": 0,
								"value": float(HitDic.get("defe_reduce", 0.0)),
								"AttackKind": "",
								"DeBuff": true,
							}
						)
					)
			"Role5Bullet4":
				Global.AddBuff(
					Target.buff,
					{
						"Name": "speed_down",
						"AddTime": 1,
						"ReduceInterval": 0,
						"value": 0.5,
						"CanAdd": false,
						"AttackKind": "",
						"DeBuff": true
					}
				)
				_apply_tllz_awaken_effect(Target)
			"Role5Bullet2":
				if Target != null:
					Target.llrdCount = 300
					if not Target.CannotAttract:
						TweenToLLRDCenter(Target)
			"SMSRBullet", "TtzsszBullet", "NMWBullet2":
				if HitDic.has("addeffect"):
					Global.AddBuff(Target.buff, HitDic["addeffect"])
			"Role4Bullet6":
				if Global.CheckWD(Target) < 7 and HitDic.has("addeffect"):
					Global.AddBuff(Target.buff, HitDic["addeffect"])
				Global.AddBuff(
					Target.buff,
					{
						"Name": "speed_down",
						"AddTime": 0.6,
						"ReduceInterval": 0,
						"value": 0.5,
						"CanAdd": false,
						"AttackKind": "",
						"DeBuff": true
					}
				)
			"Role4Bullet3":
				if Global.CheckWD(Target) < 10 and HitDic.has("addeffect"):
					Global.AddBuff(Target.buff, HitDic["addeffect"])
			"ZLWBullet":
				if HitDic.has("addeffect"):
					Global.AddBuff(Target.buff, HitDic["addeffect"])
			"LPZBullet":
				var Levellpz = PlayerData.player_data["落魄阵"]["Level"]
				var Value = 0.02 * Levellpz
				var Rnd = 10 * Levellpz
				randomize()
				if randi_range(0, 100) <= Rnd:
					Global.AddBuff(
						Target.buff,
						{
							"Name": "lpzbuff",
							"AddTime": 10,
							"ReduceInterval": 0,
							"value": Value,
							"CanAdd": false,
							"AttackKind": "",
							"DeBuff": true
						}
					)

		if PlayerData.player_data["技能学习"]["技能10"]["等级"] <= 0:
			return
		var level_10 = PlayerData.player_data["技能学习"]["技能10"]["等级"]
		var threshold = 0.0
		if name_ == "Role2Bullet3":
			threshold = 3 + level_10 * 0.5
		elif name_ == "Role2Bullet4":
			threshold = 2 + level_10
		else:
			return

		var jgz_level = 0
		if Target and Target.has_node("Buff"):
			for buff_node in Target.buff.get_children():
				if buff_node.BuffInfo.get("Name") == "jgz":
					jgz_level = buff_node.BuffInfo.get("value", 1)
					break
		if jgz_level > 0:
			threshold += jgz_level * 3.5
			if threshold > 100:
				threshold = 100

		var rand_val = randi_range(0, 100)
		if rand_val > threshold:
			return
		if HitDic.has("addeffect"):
			Global.AddBuff(Target.buff, HitDic["addeffect"])


func ADDMusic(num):
	match num:
		1:
			Global.addSound_(self, "res://Music/Hero/58_Role2_hit1.mp3")
		2:
			Global.addSound_(self, "res://Music/Hero/59_Role2_hit2.mp3")
		3:
			Global.addSound_(self, "res://Music/Hero/57_Role2_hit8.mp3")
		4:
			Global.addSound_(self, "res://Music/Hero/60_Role2_hit3.mp3")
		5:
			Global.addSound_(self, "res://Music/Hero/51_Role2_hit10.mp3")
		6:
			Global.addSound_(self, "res://Music/Hero/11_Role2_hit4.mp3")
		7:
			Global.addSound_(self, "res://Music/Hero/effect8.mp3")
		8:
			Global.addSound_(self, "res://Music/Hero/Role5/attack_repeat.mp3")


func _is_summon_or_pet_target(target: Node) -> bool:
	if target == null or not is_instance_valid(target):
		return true
	if target.get_meta("pet_tiger_unit", false) or target.get_meta("is_summon", false):
		return true
	if target.has_method("get") and target.get("is_summon") == true:
		return true
	return false


func _apply_tllz_awaken_effect(target: BaseMonster) -> void:
	if target == null or not is_instance_valid(target):
		return
	var source_player: BaseHero = Player
	if source_player == null or not is_instance_valid(source_player):
		var source_candidate: Variant = RoleProp.SourcePlayer
		if source_candidate is BaseHero and is_instance_valid(source_candidate):
			source_player = source_candidate as BaseHero
	if source_player == null or not is_instance_valid(source_player):
		return
	if not source_player.has_method("_is_skill_awakened") or not source_player.has_method("_is_skill_awaken_enabled"):
		return
	if (
		not bool(source_player.call("_is_skill_awakened", "tllz"))
		or not bool(source_player.call("_is_skill_awaken_enabled", "tllz"))
	):
		return

	Global.AddBuff(
		target.buff,
		{
			"Name": "DefeReduce",
			"AddTime": 10.0,
			"ReduceInterval": 0,
			"value": 0.5,
			"CanAdd": false,
			"AttackKind": "",
			"DeBuff": true
		}
	)
	if tllz_awaken_extra:
		return

	var target_id := target.get_instance_id()
	if _tllz_awaken_targets.has(target_id):
		return
	_tllz_awaken_targets[target_id] = true
	if source_player.Bullet == null or not is_instance_valid(source_player.Bullet):
		return
	var extra_hit_data: Dictionary = HitDic.duplicate(true)
	var extra_bullet = Global.addRoleBullet_(
		source_player.Bullet, target.global_position, false, "Role5Bullet4", extra_hit_data
	)
	if extra_bullet == null or not is_instance_valid(extra_bullet):
		return
	extra_bullet.tllz_awaken_extra = true
	extra_bullet.set_meta("tllz_awaken_extra", true)
	extra_bullet.scale = Vector2(1.4, 1.4)


func _get_monster_from_hit_area(area: Area2D) -> BaseMonster:
	if area == null or not is_instance_valid(area):
		return null
	var node: Node = area
	for _index in range(4):
		if node == null or not is_instance_valid(node):
			return null
		if node is BaseMonster:
			return node as BaseMonster
		node = node.get_parent()
	return null


func FaceToBoss():
	var MrList = []
	var desired_angle := rotation
	if Player is BaseHero:
		MrList = Player.get_parent().get_parent().monster.get_children()
	var nearest_target: BaseMonster = null
	var nearest_target_position := Vector2.ZERO
	var nearest_distance := INF
	for Target in MrList:
		if (
			Target == null
			or not is_instance_valid(Target)
			or Target.is_queued_for_deletion()
			or not Target is BaseMonster
		):
			continue
		var target := Target as BaseMonster
		if target is Monster48 or _is_summon_or_pet_target(target):
			continue
		if target.Hp <= 0 or target.is_death:
			continue
		var target_position := _get_monster_aim_position(target)
		var target_distance := global_position.distance_squared_to(target_position)
		if target_distance < nearest_distance:
			nearest_distance = target_distance
			nearest_target = target
			nearest_target_position = target_position
	if nearest_target != null:
		desired_angle = global_position.angle_to_point(nearest_target_position)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", desired_angle, 0.5)


func _get_monster_aim_position(target: BaseMonster) -> Vector2:
	if target == null or not is_instance_valid(target):
		return Vector2.ZERO
	var target_hurt_box := target.get_node_or_null("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
	if target_hurt_box != null and is_instance_valid(target_hurt_box) and target_hurt_box.shape != null:
		return target_hurt_box.global_position
	return target.global_position


func TweenToLLRDCenter(body: BaseMonster):
	if body == null or not is_instance_valid(body) or body.is_control_immune():
		return
	var tween = body.create_control_movement_tween()
	tween.tween_property(body, "position", Vector2(position.x, position.y - 30), 0.15)


func _on_queue_timer_timeout() -> void:
	queue_free()


func _on_hit_box_body_entered(body: Node2D) -> void:
	match name_:
		"TQZBullet":
			if body is BaseHero:
				IsCanCure = true


func _on_hit_box_body_exited(body: Node2D) -> void:
	match name_:
		"TQZBullet":
			if body is BaseHero:
				IsCanCure = false


func AddslzBuff():
	Global.AddBuff(
		RoleProp.SourcePlayer.buff,
		{
			"Name": "slzbuff",
			"AddTime": 10,
			"ReduceInterval": 0,
			"value": 0,
			"CanAdd": false,
			"CanRemove": false,
			"AttackKind": ""
		}
	)


func AddtszBuff():
	Global.AddBuff(
		RoleProp.SourcePlayer.buff,
		{
			"Name": "tszbuff",
			"AddTime": 10,
			"ReduceInterval": 0,
			"value": 0,
			"CanAdd": false,
			"CanRemove": false,
			"AttackKind": ""
		}
	)


func ADDTQZBuff():
	if not IsCanCure:
		return
	Global.RemoveAllBuff()
	Global.add_SpecialEffect(RoleProp.SourcePlayer, Vector2(0, 0), "tqzbuff", Vector2(1, 1), false, 1)
	Global.AddBuff(
		RoleProp.SourcePlayer.buff,
		{
			"Name": "SuperArmor",
			"AddTime": 1,
			"ReduceInterval": 0,
			"value": 0,
			"CanAdd": false,
			"CanRemove": false,
			"AttackKind": ""
		}
	)


func TQZCure():
	if name_ == "TQZBullet":
		if IsCanCure:
			if CureCount % 60 == 0 and CureCount != 0:
				var Levellpz = PlayerData.player_data["太清阵"]["Level"]
				var CureValue = int(Levellpz * 0.05 * RoleProp.roleprop.power)
				RoleProp.SourcePlayer.cure_Hp(CureValue)
			CureCount += 1
		else:
			CureCount = 0


func TLLZQueue():
	if queue_timer.is_stopped():
		queue_timer.start(10)


func start_auto_free(delay: float = 10.0):
	if queue_timer:
		queue_timer.start(delay)
	else:
		await ready
		queue_timer.start(delay)
