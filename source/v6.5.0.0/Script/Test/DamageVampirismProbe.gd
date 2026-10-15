extends Node

class ProbeHero extends BaseHero:
	var received_heal: int = 0

	func cure_Hp(value: int = 0):
		received_heal += value
		return value


func _ready() -> void :
	var old_roleprop: Dictionary = RoleProp.roleprop
	var old_source: Variant = RoleProp.SourcePlayer
	RoleProp.roleprop = {"vampirism": 0.005}

	var monster: = BaseMonster.new()
	var hero: = ProbeHero.new()
	hero.HitDic = {"power": 100, "hurtBack": [0, 0], "attackKind": "magic"}

	monster._apply_damage_vampirism(hero, 100)
	_check(hero.received_heal == 1, "不足1点的吸血未按1点回复")
	monster._apply_damage_vampirism(hero, 100)
	_check(hero.received_heal == 2, "冰雨每段伤害未独立触发最低吸血")
	monster._apply_damage_vampirism(hero, 1000)
	_check(hero.received_heal == 7, "水魔爆法术伤害未按0.5%吸血")

	hero.HitDic["attackKind"] = "physics"
	monster._apply_damage_vampirism(hero, 200)
	_check(hero.received_heal == 8, "物理伤害吸血回归")
	hero.HitDic["attackKind"] = "real"
	monster._apply_damage_vampirism(hero, 200)
	_check(hero.received_heal == 9, "真实伤害吸血未生效")

	RoleProp.roleprop = old_roleprop
	RoleProp.SourcePlayer = old_source
	monster.free()
	hero.free()
	print("DAMAGE_VAMPIRISM_PROBE_OK")
	get_tree().quit()


func _check(condition: bool, message: String) -> void :
	if condition:
		return
	push_error(message)
	get_tree().quit(1)
