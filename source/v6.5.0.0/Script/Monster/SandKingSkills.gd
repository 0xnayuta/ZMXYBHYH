extends RefCounted

const PROJECTILE: GDScript = preload("res://Script/Monster/SandKingProjectile.gd")
const ROOT: String = "res://Art/Monster/Game4SpecialEffect/3120"

const ACTION_OFFSETS: Dictionary = {&"hit1": Vector2(-12.15, -32.2), &"hit2": Vector2(-84.7, -14.75)}


static func spawn(caster: BaseMonster, action: StringName) -> void:
	if not is_instance_valid(caster) or caster.death() or not caster.is_inside_tree():
		return
	var right: bool = caster.MonsterDirection
	var direction: float = 1.0 if right else -1.0
	var wind: bool = action == &"hit1"
	var attack: Dictionary = caster.objattackDic[str(action)].duplicate(true)

	attack["power"] = roundi(float(attack["power"]) * (0.3 if wind else 1.5))
	attack["attackKind"] = "magic" if wind else "physics"
	attack["HitProtect"] = 1112 if wind else 3334
	var config: Dictionary = {
		"owner": caster,
		"position": caster.global_position,
		"right": right,
		"hit_name": str(action),
		"attack_data": attack,
		"frame_fps": 30.0,
		"expire_on_hit": false,
		"visual_faces_right": true,
	}
	if wind:
		(
			config
			. merge(
				{
					"skill_name": "SandKingWind",
					"frame_root": ROOT.path_join("effect1_1"),
					"frame_count": 29,
					"loop_visual": false,
					"position": caster.global_position + Vector2(150.0 * direction, 8.0),
					"visual_offset": Vector2(-70.05, -79.05),
					"velocity": Vector2(270.0 * direction, 0.0),
					"lifetime": 0.934,
					"damage_duration": 0.934,
					"damage_pulse_interval": 0.167,
					"poll_overlaps_on_damage_pulse": true,
					"max_hits": 5,
					"collision_size": Vector2(263.85, 198.05),
					"collision_offset": Vector2(-21.025, -80.975),
				},
				true
			)
		)
	else:
		var target: Variant = RoleProp.get_nearest_monster_target_position(caster.global_position)
		var target_x: float = (
			float(target.x) + direction * 600.0 if target != null else caster.global_position.x + direction * 100.0
		)

		(
			config
			. merge(
				{
					"skill_name": "SandKingStone",
					"frame_root": ROOT.path_join("effect2_3"),
					"frame_count": 2,
					"loop_visual": true,
					"position": caster.global_position + Vector2(0.0, -2.0),
					"velocity": Vector2(absf(target_x - caster.global_position.x) * direction, -495.0),
					"acceleration": Vector2(0.0, 2700.0),
					"lifetime": 1.0,
					"damage_duration": 1.0,
					"max_hits": 1,
					"collision_size": Vector2(88.2, 86.05),
					"collision_offset": Vector2(-5.6, -6.575),
					"finished_callback": _impact.bind(caster, right, attack),
				},
				true
			)
		)
	var projectile: WutaiMinghaiProjectile = PROJECTILE.new() as WutaiMinghaiProjectile
	projectile.configure(config)
	projectile.set("collide_with_terrain", not wind)
	caster.bullet.add_child(projectile)


static func _impact(at: Vector2, caster: BaseMonster, right: bool, attack: Dictionary) -> void:
	if not is_instance_valid(caster) or caster.death() or caster.is_queued_for_deletion():
		return
	var impact: WutaiMinghaiProjectile = PROJECTILE.new() as WutaiMinghaiProjectile
	(
		impact
		. configure(
			{
				"owner": caster,
				"position": at,
				"right": right,
				"hit_name": "hit2",
				"attack_data": attack,
				"skill_name": "SandKingStoneImpact",
				"frame_root": ROOT.path_join("effect2_4"),
				"frame_count": 9,
				"frame_fps": 30.0,
				"loop_visual": false,
				"lifetime": 0.3,
				"damage_duration": 8.0 / 30.0,
				"expire_on_hit": false,
				"max_hits": 1,
				"collision_size": Vector2(223.5, 192.15),
				"collision_offset": Vector2(0.0, -0.025),
			}
		)
	)
	caster.bullet.add_child(impact)
