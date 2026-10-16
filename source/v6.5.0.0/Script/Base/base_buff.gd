extends Node

class_name BaseBuff

@onready var BuffTime: Timer = $BuffLastTime
@onready var buff_reduce_time: Timer = $BuffValueReduceTime
@onready var specialeffectaddtime: Timer = $SpecialEffectAddTime
@onready var one_second: Timer = $OneSecond

var LastTime: float
var GetObj: BaseObject
var get_all_buff: Node
var BuffInfo = {
	"Name": "",
	"value": 0.0,
	"AddTime": 0.0,
	"ReduceInterval": 0.0,
	"AttackKind": "",
	"SpecialEffectAddInterval": 0.0,
	"CanAdd": false
}
var ini_buff = {"Name": "", "value": 0.0, "AddTime": 0.0, "AttackKind": "", "CanRemove": false}
var need_remove: bool
var total_times: int = 1
var inter_time: float
var is_set: bool = false
var on_set: bool = false
var buff_effect_list = []
var buff_array = []
var old_position
var new_position
var ini_speed
var IsCheck: bool = false
var last_value: float
var _voodoo_visual: Node = null


func _physics_process(_delta: float) -> void:
	if not is_set:
		GetObj = get_parent().get_parent()
		get_all_buff = get_parent()
		if not GetObj is BaseMonster and not GetObj is BaseHero:
			self.queue_free()
			return

		var reduce_control_duration := false
		if GetObj is BaseHero and GetObj.has_method("_is_sd_control_reduction_active"):
			reduce_control_duration = bool(GetObj.call("_is_sd_control_reduction_active"))
		if (
			reduce_control_duration
			and (
				str(BuffInfo.get("Name", ""))
				in [
					"Ice",
					"stun",
					"EyeFix",
					"DeadLink",
					"Boundground",
					"silent",
					"Immobilize",
					"Scary",
					"hanxiangzisleep"
				]
			)
		):
			BuffInfo["AddTime"] = float(BuffInfo.get("AddTime", 0.0)) * 0.5

		last_value = BuffInfo["value"]
		LastTime = BuffInfo["AddTime"]

		if (
			GetObj is BaseMonster
			and GetObj.is_control_immune()
			and Global.is_monster_control_buff(BuffInfo.get("Name", ""))
		):
			self.queue_free()
			return

		if (
			BuffInfo.get("DeBuff", false)
			and GetObj.NoDeBuff
			and BuffInfo["Name"] != "jgz"
			and BuffInfo["Name"] != "zznh"
		):
			print("NoDeBuff免疫了负面效果: ", BuffInfo["Name"])
			self.queue_free()
			return

		set_value()
		add_buff_effect_first()
		start_buff()
		is_set = true

		if BuffInfo["Name"] == "lljybuff" and GetObj != null:
			GetObj.velocity.x = 0

	set_special_buff_time()


func set_value():
	if BuffInfo["Name"] == "speed_down":
		last_value = normalize_slow_ratio(last_value)
		for other in get_all_buff.get_children():
			if (
				other is BaseBuff
				and other != self
				and not other.is_queued_for_deletion()
				and other.BuffInfo.get("Name", "") == "speed_down"
			):
				last_value = maxf(last_value, normalize_slow_ratio(other.last_value))
				BuffInfo["AddTime"] = maxf(
					float(BuffInfo["AddTime"]),
					float(other.BuffTime.time_left) if other.BuffTime != null else float(other.LastTime)
				)
				other.queue_free()
		return

	var is_special = BuffInfo["Name"] in ["jgz", "zznh"]
	var is_negative = (
		BuffInfo["Name"]
		in [
			"poision",
			"Fire",
			"Bleed",
			"stun",
			"Ice",
			"EyeFix",
			"DeadLink",
			"speed_down",
			"silent",
			"Boundground",
			"Immobilize",
			"Scary",
			"DefeReduce",
			"lljybuff",
			"flls",
			"nlls",
			"BloodFix",
			"Voodoo",
			"LifeManaLock",
			"MagicDrain",
			"ReverseMove",
			"hanxiangzisleep",
			"jgz",
			"zznh"
		]
	)

	if is_negative and not is_special:
		if GetObj == null:
			GetObj = get_parent().get_parent()

		if GetObj != null and (GetObj is BaseHero or GetObj is BaseMonster):
			if GetObj.NoDeBuff:
				print("NoDeBuff免疫负面效果: ", BuffInfo["Name"])

				call_deferred("queue_free")
				return

	for i in get_all_buff.get_children():
		if i != null:
			if i is BaseBuff:
				match BuffInfo["Name"]:
					"speed_down", "DefeReduce", "nlls", "slzbuff", "lpzbuff", "tszbuff":
						if i != self and i.BuffInfo["Name"] == BuffInfo["Name"]:
							if i.BuffInfo.has("CanAdd"):
								if i.BuffInfo["CanAdd"]:
									last_value += i.last_value
									i.queue_free()
								else:
									if i.last_value > last_value:
										last_value = i.last_value
							else:
								if i.last_value > last_value:
									last_value = i.last_value
					"Ice", "stun", "EyeFix", "DeadLink", "Boundground", "silent", "Immobilize", "BloodFix", "LifeManaLock", "Scary", "SuperArmor", "DoubleFallPro", "PoisionBody", "NoDeBuff", "yxbuff", "HealOverTime":
						if i != self and i.BuffInfo["Name"] == BuffInfo["Name"]:
							if i.BuffInfo.has("CanAdd"):
								if i.BuffInfo.has("CanAdd"):
									if i.BuffInfo["CanAdd"]:
										if (
											GetObj is BaseHero
											and (
												BuffInfo["Name"]
												in [
													"Ice",
													"stun",
													"EyeFix",
													"DeadLink",
													"Boundground",
													"Immobilize",
													"Scary"
												]
											)
										):
											var remaining_time: float = (
												float(i.BuffTime.time_left) if i.BuffTime != null else float(i.LastTime)
											)
											BuffInfo["AddTime"] = maxf(float(BuffInfo["AddTime"]), remaining_time)
										else:
											BuffInfo["AddTime"] += i.LastTime
										i.queue_free()


static func normalize_slow_ratio(value: float) -> float:
	return clampf(absf(value) / 100.0 if absf(value) > 1.0 else absf(value), 0.0, 1.0)


func apply_slow_speed() -> void:
	last_value = normalize_slow_ratio(last_value)
	var multiplier := 1.0 - last_value
	if GetObj is BaseMonster:
		GetObj.speed = GetObj.iniSpeed * multiplier
	elif GetObj is BaseHero:
		var base_speed: float = GetObj._fabao_jiasu_base_speed * 2 if GetObj.is_fabao_jiasu else 240
		GetObj.walk_speed = base_speed * multiplier


func add_buff_effect_first():
	match BuffInfo["Name"]:
		"PetLifeBonus", "PetAttackBonus", "PetDefenseBonus", "PetManaBonus":
			refresh_pet_owner_bonus(maxi(0, int(last_value)))
		"jgz":
			pass
		"zznh":
			pass

		"SanXianHuTi":
			inter_time = BuffInfo.get("SpecialEffectAddInterval", 1.0)

			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 0), "SanXianHuTi", Vector2(1, 1), false, 1)
			)

		"ReverseMove":
			inter_time = 1.0
			if GetObj is BaseHero:
				GetObj.is_reverse_move = true
				buff_effect_list.push_back(
					Global.add_special_effect(GetObj, Vector2(-20, -35), "ReverseMove", Vector2(1, 1), false, 1)
				)
			else:
				self.queue_free()

		"MagicDrain":
			inter_time = 1.0
			if GetObj is BaseHero:
				var current_mp = RoleProp.roleprop.Mp
				BuffInfo["stored_mp"] = current_mp

				GetObj.reduce_mp(current_mp)
				print("MagicDrain触发 | 扣除魔法:", current_mp)

		"flls":
			inter_time = 1
			buff_effect_list.push_back(Global.add_special_effect(GetObj, Vector2(0, 0), "flls", Vector2(1, 1), false, 1))

		"LifeManaLock":
			inter_time = 1

			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, -50), "jinliao", Vector2(1.5, 1.5), false, 1)
			)

		"NoDeBuff":
			inter_time = 1.0

		"lljybuff":
			inter_time = 0.81

			GetObj.velocity.x = 0

		"lpzbuff":
			if GetObj is BaseMonster:
				var levellpz = PlayerData.player_data["落魄阵"]["Level"]
				GetObj.lpzjs = levellpz * 0.02
			elif GetObj is BaseHero:
				GetObj.xrbl = 1 - last_value
			inter_time = 0.5
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 5), "lpzbuff", Vector2(1, 1), false, 1)
			)
		"tszbuff":
			if GetObj is BaseHero:
				var levellpz = PlayerData.player_data["腾蛇阵"]["Level"]
				GetObj.tszzs = levellpz * 0.015
			inter_time = 0.6
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 5), "tszbuff", Vector2(1, 1), false, 1)
			)
		"Scary":
			inter_time = 1
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, -35), "Scary", Vector2(1, 1), false, 1)
			)
		"Ice":
			inter_time = 1.29
			buff_effect_list.push_back(Global.add_bullet("bd", GetObj, false, 1, _ice_effect_offset(), "", ""))
		"BloodFix":
			inter_time = 1
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 15), "ThreeEyesFix", Vector2(1, 1), false, 1)
			)
		"LifeManaLock":
			inter_time = 1
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, -50), "jinliao", Vector2(1.5, 1.5), false, 1)
			)
		"DefeReduce":
			inter_time = 0.49
			if GetObj is BaseMonster:
				GetObj.DefeReduce = last_value
			elif GetObj is BaseHero:
				GetObj.DefeReduce = last_value
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(-5, -45), "DefeReduce", Vector2(1, 1), false, 1)
			)
		"Bleed":
			inter_time = 0.36
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 25), "BloodReduce", Vector2(1, 1), false, 1)
			)
		"poision":
			inter_time = 1
			buff_effect_list.push_back(Global.add_bullet("poision", GetObj, false, 1, Vector2(-20, -55), "", ""))
			buff_effect_list.push_back(Global.add_bullet("posion_fire", GetObj, false, 1, Vector2(10, -40), "", ""))
		"Fire":
			inter_time = 0.81
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(10, 10), "Fire", Vector2(1, 1), false, 1)
			)
		"stun":
			inter_time = 0.81
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, -50), "Stun", Vector2(0.7, 0.7), false, 1)
			)
		"EyeFix":
			inter_time = 0.45
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, -35), "EyeFix", Vector2(1, 1), false, 1)
			)
		"DeadLink":
			inter_time = 1.39
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 0), "DeadLink_2", Vector2(1, 1), false, 1)
			)
		"nlls":
			inter_time = 1.01
			old_position = GetObj.position.x
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(40, 35), "nlls", Vector2(1, 1), false, 1)
			)
		"silent":
			inter_time = 0.99
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(40, -35), "silent", Vector2(1, 1), false, 1)
			)
		"Boundground":
			inter_time = 0.99
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(-5, 55), "GroundFloor", Vector2(1, 1), false, 1)
			)
		"speed_down":
			inter_time = 0.61
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 20), "SpeedDown", Vector2(1, 1), false, 1)
			)
			apply_slow_speed()
		"slzbuff":
			if GetObj is BaseHero:
				var levelslz = PlayerData.player_data["森罗阵"]["Level"]
				GetObj.slzjs2 = levelslz * 0.02
			inter_time = 0.875
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 0), "slzbuff", Vector2(0.5, 1), false, 1)
			)
		"Immobilize":
			inter_time = 0.69
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 0), "Immobilize", Vector2(1, 1), false, 1)
			)
		"SuperArmor":
			pass
		"Indestructible":
			inter_time = 1
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 0), "Indestructible", Vector2(1, 1), false, 1)
			)
		"Indestructible1":
			inter_time = 1
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 0), "Indestructible1", Vector2(1, 1), false, 1)
			)
		"Voodoo":
			inter_time = 0.9
			_add_voodoo_visual_once()
		"DoubleFallPro":
			pass
		"PoisionBody":
			inter_time = 0.5
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, -10), "wdzt", Vector2(0.7, 0.7), false, 1)
			)
		"yxbuff":
			inter_time = 0.8

			if GetObj is BaseHero:
				var current_hp = RoleProp.roleprop.Hp
				var half_hp = int(current_hp * 0.5)
				GetObj.effect_reducehp(half_hp, "real")

				buff_effect_list.push_back(
					Global.add_special_effect(GetObj, Vector2(0, 0), "yxbuff", Vector2(1, 1), false, 1)
				)

		"HealOverTime":
			inter_time = BuffInfo.get("SpecialEffectAddInterval", 1.0)


func _on_buff_last_time_timeout() -> void:
	match BuffInfo["Name"]:
		"ReverseMove":
			if GetObj is BaseHero:
				GetObj.reverse_move_speed_multiplier = 1.0
				GetObj.is_reverse_move = false

		"MagicDrain":
			if GetObj is BaseHero:
				var stored_mp = BuffInfo.get("stored_mp", 0)

				RoleProp.roleprop.Mp += stored_mp

				if RoleProp.roleprop.Mp > RoleProp.roleprop.SMp:
					RoleProp.roleprop.Mp = RoleProp.roleprop.SMp
				print("MagicDrain结束 | 返还魔法:", stored_mp, " | 当前魔法:", RoleProp.roleprop.Mp)

	if str(BuffInfo.get("AttackKind", "")) == "SpecialBuff_1":
		for i in PlayerData.player_data["初始Buff"]:
			if i["Name"] == BuffInfo["Name"]:
				PlayerData.player_data["初始Buff"].erase(i)

	if BuffInfo["AddTime"] < 99999:
		remove_buff()


func _on_buff_value_reduce_time_timeout() -> void:
	match BuffInfo["Name"]:
		"Ice", "stun", "EyeFix", "DeadLink", "speed_down", "Boundground", "silent", "Immobilize", "Scary", "SuperArmor", "Indestructible", "Indestructible1":
			return
		"DefeReduce", "DoubleFallPro", "slzbuff", "lpzbuff", "tszbuff", "tszbuff", "yxbuff", "MagicDrain":
			return

		"SanXianHuTi":
			return

		"ReverseMove":
			return

		"lljybuff":
			GetObj.velocity.x = 0
			return

		"Bleed", "poision", "Fire", "Voodoo", "hanxiangzisleep":
			if GetObj is BaseHero:
				GetObj.effect_reducehp(last_value, str(BuffInfo.get("AttackKind", "")))
			elif GetObj is BaseMonster:
				if last_value > 0:
					if BuffInfo["Name"] == "hanxiangzisleep":
						GetObj.reduce_pet_hp(int(last_value), "real")
					else:
						var Hurt = GetObj.get_role_last_hurt(self)
						GetObj.hurt_reduce_hp(Hurt, self)

		"flls":
			if GetObj is BaseHero:
				var current_mp = RoleProp.roleprop.Mp
				var reduce_amount = current_mp * 0.1
				reduce_amount = round(reduce_amount)
				if reduce_amount < 1 and current_mp > 0:
					reduce_amount = 1
				print("flls触发 | 当前MP:", current_mp, " | 减少:", reduce_amount, " | 减少后:", current_mp - reduce_amount)
				GetObj.reduce_mp(int(reduce_amount))

		"HealOverTime":
			if GetObj is BaseHero:
				var max_hp = RoleProp.roleprop.SHp
				var heal_amount = int(max_hp * last_value)
				GetObj.effect_reducehp(-heal_amount, "cure")
			elif GetObj is BaseMonster:
				var max_hp = GetObj.SHp
				var heal_amount = int(max_hp * last_value)
				GetObj.cure_hp(heal_amount)

		"nlls":
			new_position = GetObj.position.x
			if GetObj is BaseHero:
				var get_value_hp = int(abs(new_position - old_position) * last_value * 0.3)
				var get_value_mp = int(abs(new_position - old_position) * last_value * 0.3)
				GetObj.effect_reducehp(get_value_hp, "real")
				RoleProp.roleprop.Mp -= get_value_mp
			elif GetObj is BaseMonster:
				var get_value_hp = abs(new_position - old_position) * last_value
				GetObj.reduce_hp(get_value_hp)
			old_position = GetObj.position.x


func _on_special_effect_add_time_timeout() -> void:
	match BuffInfo["Name"]:
		"jgz":
			pass
		"zznh":
			pass
		"SanXianHuTi":
			inter_time = BuffInfo.get("SpecialEffectAddInterval", 1.0)

			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 0), "SanXianHuTi", Vector2(1, 1), false, 1)
			)

		"ReverseMove":
			inter_time = 1.0
			if GetObj is BaseHero:
				buff_effect_list.push_back(
					Global.add_special_effect(GetObj, Vector2(-20, -35), "ReverseMove", Vector2(1, 1), false, 1)
				)
				pass

		"MagicDrain":
			pass

		"flls":
			inter_time = 1
			buff_effect_list.push_back(Global.add_special_effect(GetObj, Vector2(0, 0), "flls", Vector2(1, 1), false, 1))

		"tszbuff":
			inter_time = 0.6
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 5), "tszbuff", Vector2(1, 1), false, 1)
			)
		"lpzbuff":
			inter_time = 0.5
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 5), "lpzbuff", Vector2(1, 1), false, 1)
			)
		"Ice":
			buff_effect_list.push_back(Global.add_bullet("bd", GetObj, false, 1, _ice_effect_offset(), "", ""))
		"BloodFix":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 15), "ThreeEyesFix2", Vector2(1, 1), false, 1)
			)
		"LifeManaLock":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, -50), "jinliao", Vector2(1.5, 1.5), false, 1)
			)
		"Bleed":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 25), "BloodReduce", Vector2(1, 1), false, 1)
			)
		"poision":
			buff_effect_list.push_back(Global.add_bullet("posion_fire", GetObj, false, 1, Vector2(10, -40), "", ""))
		"Fire":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(10, 10), "Fire", Vector2(1, 1), false, 1)
			)
		"stun":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, -50), "Stun", Vector2(0.7, 0.7), false, 1)
			)
		"EyeFix":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, -35), "EyeFix", Vector2(1, 1), false, 1)
			)
		"DeadLink":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 0), "DeadLink_2", Vector2(1, 1), false, 1)
			)
		"nlls":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(40, 35), "nlls", Vector2(1, 1), false, 1)
			)
		"speed_down":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 20), "SpeedDown", Vector2(1, 1), false, 1)
			)
		"silent":
			inter_time = 1.01
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(40, -35), "silent", Vector2(1, 1), false, 1)
			)
		"Boundground":
			inter_time = 1.01
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(-5, 55), "GroundFloor", Vector2(1, 1), false, 1)
			)
		"Immobilize":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 0), "Immobilize", Vector2(1, 1), false, 1)
			)
		"Scary":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, -35), "Scary", Vector2(1, 1), false, 1)
			)
		"DefeReduce":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(-5, -45), "DefeReduce", Vector2(1, 1), false, 1)
			)
		"SuperArmor":
			pass
		"Indestructible":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 0), "Indestructible", Vector2(1, 1), false, 1)
			)
		"Indestructible1":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 0), "Indestructible1", Vector2(1, 1), false, 1)
			)
		"DoubleFallPro":
			pass
		"Voodoo":
			_add_voodoo_visual_once()
		"PoisionBody":
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, -10), "wdzt", Vector2(0.7, 0.7), false, 1)
			)
		"slzbuff":
			inter_time = 0.875
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 0), "slzbuff", Vector2(0.5, 1), false, 1)
			)
		"yxbuff":
			inter_time = 0.8
			buff_effect_list.push_back(
				Global.add_special_effect(GetObj, Vector2(0, 0), "yxbuff", Vector2(1, 1), false, 1)
			)

		"HealOverTime":
			pass


func _ice_effect_offset() -> Vector2:
	if GetObj != null and GetObj.has_method(&"get_ice_effect_offset"):
		var custom_offset: Variant = GetObj.call(&"get_ice_effect_offset")
		if custom_offset is Vector2:
			return custom_offset
	return Vector2(0, 10)


func add_buff_icon():
	if GetObj is BaseHero:
		if Global.buff_box == null:
			return
		var Icon = null
		for existing_icon in Global.buff_box.get_children():
			if (
				str(existing_icon.name) == str(BuffInfo["Name"])
				or str(existing_icon.get("BuffName")) == str(BuffInfo["Name"])
			):
				Icon = existing_icon
				break
		if Icon == null:
			Icon = Global.add_buffIcon(Global.buff_box, BuffInfo)
		if Icon == null:
			return
		Icon.father_buff = self
		Icon.total_times = total_times
		Icon.last_hurt = last_value
		Icon.data_list = BuffInfo.duplicate(true)
		Icon.visible = true
		Icon.start_duration(float(BuffInfo.get("AddTime", 0.0)))
	elif GetObj is BaseMonster:
		return
		if GetObj.my_blood != null:
			for i in GetObj.my_blood.buff_list.get_children():
				if i.BuffName == BuffInfo["Name"]:
					i.queue_free()
			var Icon = Global.add_buffIcon(GetObj.my_blood.buff_list, BuffInfo)
			Icon.father_buff = self
			Icon.total_times = total_times
			Icon.last_hurt = last_value


func remove_buff():
	_clear_pet_owner_bonus()

	if BuffInfo["Name"] == "ReverseMove" and GetObj is BaseHero:
		if ini_speed != null:
			GetObj.walk_speed = ini_speed

	for i in buff_effect_list:
		if is_instance_valid(i):
			i.queue_free()
	self.queue_free()


func _exit_tree() -> void:
	for effect in buff_effect_list:
		if is_instance_valid(effect):
			effect.queue_free()
	buff_effect_list.clear()
	if GetObj != null and is_instance_valid(GetObj):
		if GetObj.has_meta("voodoo_effect_owner") and GetObj.get_meta("voodoo_effect_owner") == self:
			GetObj.remove_meta("voodoo_effect_owner")
			if GetObj.has_meta("voodoo_effect_visual"):
				GetObj.remove_meta("voodoo_effect_visual")
	_clear_pet_owner_bonus()


func _add_voodoo_visual_once() -> void:
	if GetObj == null or not is_instance_valid(GetObj):
		return
	var existing: Variant = GetObj.get_meta("voodoo_effect_visual", null)
	var visual_active: bool = is_instance_valid(existing) and not existing.is_queued_for_deletion()
	if visual_active:
		return
	var effect: Node = Global.add_special_effect(GetObj, Vector2(0, -35), "Voodoo", Vector2(1, 1), false, 1) as Node
	if effect == null:
		return
	_voodoo_visual = effect
	buff_effect_list.push_back(effect)
	GetObj.set_meta("voodoo_effect_owner", self)
	GetObj.set_meta("voodoo_effect_visual", effect)


func refresh_pet_owner_bonus(value: int) -> void:
	var bonus := maxi(0, value)
	match str(BuffInfo.get("Name", "")):
		"PetLifeBonus":
			var old_life := int(RoleProp.pet_life_bonus)
			RoleProp.pet_life_bonus = bonus
			RoleProp.roleprop.Hp = int(RoleProp.roleprop.get("Hp", 0)) + maxi(0, bonus - old_life)
		"PetAttackBonus":
			RoleProp.pet_attack_bonus = bonus
		"PetDefenseBonus":
			RoleProp.pet_defense_bonus = bonus
			RoleProp.pet_magic_defense_bonus = maxi(0, int(BuffInfo.get("magic_value", bonus)))
		"PetManaBonus":
			var old_mana := int(RoleProp.pet_mana_bonus)
			RoleProp.pet_mana_bonus = bonus
			RoleProp.roleprop.Mp = int(RoleProp.roleprop.get("Mp", 0)) + maxi(0, bonus - old_mana)
		_:
			return
	add_buff_icon()


func _clear_pet_owner_bonus() -> void:
	match str(BuffInfo.get("Name", "")):
		"PetLifeBonus":
			RoleProp.pet_life_bonus = 0
		"PetAttackBonus":
			RoleProp.pet_attack_bonus = 0
		"PetDefenseBonus":
			RoleProp.pet_defense_bonus = 0
			RoleProp.pet_magic_defense_bonus = 0
		"PetManaBonus":
			RoleProp.pet_mana_bonus = 0


func start_buff():
	BuffTime.start(float(BuffInfo["AddTime"]))
	if BuffInfo.has("ReduceInterval"):
		buff_reduce_time.start(float(BuffInfo["ReduceInterval"]))
	specialeffectaddtime.start(inter_time)


func set_special_buff_time():
	if PlayerData.player_data["初始Buff"].size() <= 0:
		return
	for i in PlayerData.player_data["初始Buff"]:
		if i["Name"] == BuffInfo["Name"]:
			i["AddTime"] = BuffTime.time_left


func _on_one_second_timeout() -> void:
	pass
