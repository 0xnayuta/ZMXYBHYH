extends BaseObject
class_name BaseHero
var hd: int = 0
var shield_timer: Timer = null
var wdsl_damage_reduction: float = 0.0
var dikong_field_invincible_count: int = 0

var smsrsz_timer: Timer
const SMSR_SHENQI_LIGHTNING_EFFECT := preload("res://Script/Hero/SMSRShenqiLightningEffect.gd")
const MOUNT_RUNTIME_SCRIPT := preload("res://Script/Mount/MountRuntime.gd")
const MAIN_SWORD_ARRAY_WEAPON_SCENE_PATH := "res://Scene/MagicWeapon/MainSwordArrayWeapon.tscn"
const XIANYU_WING_PATHS := {
	"res://Script/Hero/Role1.gd": "res://Art/HeroPicture/Wings/xyzy/role1.tres",
	"res://Script/Hero/Role_2.gd": "res://Art/HeroPicture/Wings/xyzy/role2.tres",
	"res://Script/Hero/Role_3.gd": "res://Art/HeroPicture/Wings/xyzy/role3.tres",
	"res://Script/Hero/Role_4.gd": "res://Art/HeroPicture/Wings/xyzy/role4.tres",
	"res://Script/Hero/Role_5.gd": "res://Art/HeroPicture/Wings/xyzy/role5.tres",
	"res://Script/Hero/NeZhaHero.gd": "res://Art/HeroPicture/Wings/xyzy/role6.tres",
}
const HUAHAO_WING_FRAME_DIR := "res://Art/HeroPicture/Wings/hhyq"
var zlwsz_shenqi_timer: Timer
var zlwsz_shenqi_gear_scene: PackedScene
var zlwsz_shenqi_gears: Array = []
var zcld_level: int = 0
var has_smsrsz_fashion: bool = false
var current_fashion_quality: String = ""
var was_ws_state: bool = false
var _last_fashion_name := ""
var _last_fashion_power: int = -1
var _last_fashion_max_hp: int = -1
var _fashion_values_initialized := false
var _last_title_name := ""
var _last_archive_name := ""
var _last_hero_formation := ""
var _last_hero_formation_level: int = -1
var _last_wings_name := ""
var _wings_base_position := Vector2.ZERO
var _wings_base_offset := Vector2.ZERO
var _wings_base_rotation := 0.0
var _wings_base_scale := Vector2.ONE
var _wings_base_flip_h := false
var _wings_base_transform_initialized := false
var _static_wing_tracks_disabled := false
var _static_wing_track_states: Array[Dictionary] = []
var _xyzy_wing_flip_tracks_disabled := false
var _xyzy_wing_flip_track_states: Array[Dictionary] = []
var _sword_array_sync_elapsed := 0.0
var _auto_battle_elapsed := 0.0
var _auto_battle_skill_cursor := 0
var _auto_battle_skill_cast_counts: Dictionary = {}
var _auto_battle_target: Variant = null
var _auto_battle_target_search_elapsed := 0.0
var _auto_battle_jump_elapsed := 0.0
const AUTO_BATTLE_INTERVAL := 0.22
const AUTO_BATTLE_TARGET_SEARCH_INTERVAL := 0.15
const AUTO_BATTLE_TARGET_SEARCH_RANGE := 1800.0
const AUTO_BATTLE_ATTACK_RANGE := 260.0
const AUTO_BATTLE_JUMP_COOLDOWN := 0.8
const AUTO_BATTLE_MOVE_SPEED_SCALE := 1.0

var temp_def_bonus: int = 0
var temp_mdef_bonus: int = 0
var temp_max_hp_bonus_rate: float = 0.0
var temp_power_bonus_rate: float = 0.0
var mount_speed_multiplier: float = 1.0
var Islljy: bool = false
var IsYxBuff: bool = false
var YxBuffPowerRate: float = 0.0
var YxBuffCritRate: float = 0.0
var YxBuffLuckyRate: float = 0.0

var IsMagicDrain: bool = false
var StoredMP: int = 0
var IsSanXianHuTiUsed: bool = false

@onready var zhen_fa: Timer = $ZhenFa
@onready var effect_body: Node2D = $Action/EffectBody

@onready var role_action_player: AnimationPlayer = $RolePlayer
@onready var base_damagebox: Node2D = $base_damagebox
@onready var damage_text: Node2D = $Damage_Text
@onready var pz: CollisionShape2D = $pz
@onready var action: Node2D = $Action
@onready var WSTimer = $WSTimer
@onready var magic_weapon: Node2D = $MagicWeapon
@onready var MyHurtBox = $base_damagebox/HurtBox/HurtBox
@onready var name_: Label = $Name_
@onready var RoleBody: Sprite2D = $Action/RoleBody
@onready var RoleEq: Sprite2D = $Action/RoleEquipment
@onready var Bullet = $Bullet
@onready var wings: AnimatedSprite2D = $Action/Wings
@onready var buff: Node = $Buff
@onready var role_equipment: Sprite2D = $Action/RoleEquipment
@onready var tx: AnimatedSprite2D = $tx
@onready var toukui: AnimatedSprite2D = $Action/EffectBody/toukui
@onready var jianjia: AnimatedSprite2D = $Action/EffectBody/jianjia
@onready var huwan: AnimatedSprite2D = $Action/EffectBody/huwan
@onready var shenti: AnimatedSprite2D = $Action/EffectBody/shenti
@onready var yaodai: AnimatedSprite2D = $Action/EffectBody/yaodai
@onready var xiabai: AnimatedSprite2D = $Action/EffectBody/xiabai
@onready var wuqi: AnimatedSprite2D = $Action/EffectBody/wuqi

var xrbl: float
var IsXr: bool
var tszzs: float
var Role5Bt: bool
var CanMoveWhenUseSkill: bool
var tszbsjm: float
var slzjs: float
var slzjs2: float
var ZhenFaCd: float
var Istsz: bool
var canglongremove: bool
var SXYRCannotCure: bool
var MyShallow: role2shallow
var IsDoubleFallPro: bool
var IsIndestructible: bool
var IsIndestructible1: bool = false
var ran_num = randi_range(0, 100)
var Onfloor: bool
var IsSuperArmor: bool
var IsScary: bool
var IsDefeReduce: bool
var IsDeath: bool = false
var DefeReduce: float
var NewPosition: float
var OldPosition: float
var OldIsCheck: bool
var IsTMc: bool
var Is_sdBuff: bool
var IdleCount: int = 0
var IsInSky: bool = false
var CureValue: float = 1
var IsUseSMB = false
var CUreCureCount: int = 0
var is_silent: bool
var is_Bound_to_the_ground: bool
var is_jdy: bool
var is_CureHp: bool
var CureHpValue: int
var Skill_Clam: float
var PlayerDir: bool = false
var is_fabao_jiasu: bool = false
var _fabao_jiasu_base_speed: int = 240
var MaxProtect: float = 100
var CurrentProtect: float = 0.0
var Mgtarget
var MainSwordArrayTarget: Node2D
var _last_main_sword_array_id: String = ""
var lyfb_calm: float
var slz_calm: float
var hmz_calm: float
var is_stun = false
var is_jump = false
var is_speedDown: bool
var get_action = "wait"
var is_Immobilize = false
var needProtect = false
var need_removeProtect = false
var _hit_reaction_generation: int = 0
var _pending_hit_stiff_seconds: Array[float] = []
var BloodFix: bool = false
var LifeManaLock: bool = false
var IsWDZT: bool
var SMB1
var Isslz: bool

var HitDic = {"power": 0, "hurtBack": [0, 0], "attackKind": "real"}
var Role1SkillInter = {
	"slz": 0,
	"hytj": 0,
	"lys": 0,
	"lyfb": 0,
	"hmz": 0,
	"hmz_ws": 0,
	"hyjj_ws": 0,
	"hyjj": 0,
	"jdy": 0,
	"qsez": 0,
	"zz": 0,
	"gsrs": 0,
	"jdy2": 0,
	"blb": 0,
	"xbz": 0,
	"shy": 0,
	"tjgl": 0,
	"smb": 0,
	"sgq": 0,
	"myhc": 0,
	"jhsj": 0,
	"jgz": 0,
	"by": 0,
	"zfjg": 0,
	"sd": 0,
	"ssp": 0,
	"jsp": 0,
	"dgq": 0,
	"xgq": 0,
	"tmc": 0,
	"syzq": 0,
	"dj": 0,
	"zznh": 0,
	"bdqk": 0,
	"qlj": 0,
	"dcj": 0,
	"wdzt": 0,
	"tkj": 0,
	"mmw": 0,
	"jdz": 0,
	"lhsq": 0,
	"zq": 0,
	"wdww": 0,
	"bylt": 0,
	"cmly": 0,
	"slq": 0,
	"blq": 0,
	"cxq": 0,
	"llrd": 0,
	"lljy": 0,
	"tllz": 0,
	"ygth": 0,
	"xyq": 0,
	"fhf": 0,
	"ltjz": 0
}
var Role1SkillMaxInter = {
	"slz": 0,
	"hytj": 0,
	"lys": 0,
	"lyfb": 0,
	"hmz": 0,
	"hmz_ws": 0,
	"hyjj_ws": 0,
	"hyjj": 0,
	"jdy": 0,
	"qsez": 0,
	"zz": 0,
	"gsrs": 0,
	"blb": 0,
	"xbz": 0,
	"shy": 0,
	"tjgl": 0,
	"smb": 0,
	"sgq": 0,
	"myhc": 0,
	"jhsj": 0,
	"jgz": 0,
	"by": 0,
	"zfjg": 0,
	"sd": 0,
	"ssp": 0,
	"jsp": 0,
	"dgq": 0,
	"xgq": 0,
	"tmc": 0,
	"syzq": 0,
	"dj": 0,
	"zznh": 0,
	"bdqk": 0,
	"qlj": 0,
	"dcj": 0,
	"wdzt": 0,
	"tkj": 0,
	"mmw": 0,
	"jdz": 0,
	"lhsq": 0,
	"zq": 0,
	"wdww": 0,
	"bylt": 0,
	"cmly": 0,
	"slq": 0,
	"blq": 0,
	"cxq": 0,
	"llrd": 0,
	"lljy": 0,
	"tllz": 0,
	"ygth": 0,
	"xyq": 0,
	"fhf": 0,
	"ltjz": 0
}
var hit_name: String
var is_call = false
var _last_role_hit_effect_msec: int = 0


func _ready() -> void:
	RoleProp.SourcePlayer = self

	_capture_wings_base_transform()
	call_deferred("_scan_late_static_wing_tracks")

	walk_speed = 240
	PlayerData.enforce_level_caps()
	RoleProp.baseroleprop.Level = PlayerData.player_data.玩家等级
	RoleProp.baseroleprop.exp = PlayerData.player_data.玩家当前经验
	RoleProp.set_basic_prop()
	RoleProp.set_full_Hp()
	RoleProp.set_full_Mp()
	_ensure_title_animation("htd", "res://Art/AllTX/htd.png")
	_ensure_title_animation("ymqzq", "res://Art/AllTX/ymqzq.png")
	AddTx()
	call_deferred("_load_equipped_magic_weapon_deferred")
	call_deferred("_load_main_sword_array_weapon_deferred")
	call_deferred("_attach_mount_runtime")


func _attach_mount_runtime() -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null or not str(current_scene.scene_file_path).contains("/Level/"):
		return
	if get_node_or_null("MountRuntime") != null:
		return
	var mount_runtime := Node.new()
	mount_runtime.name = "MountRuntime"
	mount_runtime.set_script(MOUNT_RUNTIME_SCRIPT)
	add_child(mount_runtime)
	mount_runtime.call("setup", self)


func _exit_tree() -> void:
	set_process(false)
	set_physics_process(false)
	_auto_battle_target = null
	_auto_battle_skill_cast_counts.clear()
	_auto_battle_skill_cursor = 0
	_auto_battle_elapsed = 0.0
	_clear_visual_resources(self)


func fabaoJiasu() -> void:
	if is_fabao_jiasu:
		return
	is_fabao_jiasu = true
	_fabao_jiasu_base_speed = maxi(1, walk_speed)
	walk_speed = _fabao_jiasu_base_speed * 2


func resetFabaoJiasu() -> void:
	if not is_fabao_jiasu:
		return
	is_fabao_jiasu = false
	walk_speed = maxi(1, _fabao_jiasu_base_speed)


func _clear_visual_resources(node: Node) -> void:
	if node is AnimatedSprite2D:
		var animated_sprite := node as AnimatedSprite2D
		animated_sprite.stop()
		animated_sprite.sprite_frames = null
	elif node is Sprite2D:
		var sprite := node as Sprite2D
		sprite.texture = null
	for child in node.get_children():
		_clear_visual_resources(child)


func _load_main_sword_array_weapon_deferred() -> void:
	var tree := get_tree()
	if tree == null:
		return
	await tree.process_frame
	await tree.process_frame
	if not is_inside_tree() or is_queued_for_deletion():
		return
	_sync_main_sword_array_weapon()


func _load_equipped_magic_weapon_deferred() -> void:
	var tree := get_tree()
	if tree == null:
		return
	await tree.process_frame
	await tree.process_frame
	if not is_inside_tree() or is_queued_for_deletion():
		return
	var equipped_weapon = PlayerData.player_data.get("实战法宝", "")
	if str(equipped_weapon) == "" and PlayerData.player_data.get("法宝", []).size() > 0:
		equipped_weapon = PlayerData.player_data["法宝"][0].get("名字", "")
	await Global.prepare_magic_weapon_resources(equipped_weapon)
	if not is_inside_tree() or is_queued_for_deletion():
		return
	addMagicWeapon()


func _add_role_hit_effect_throttled() -> void:
	var now := Time.get_ticks_msec()
	if now - _last_role_hit_effect_msec < 55:
		return
	_last_role_hit_effect_msec = now
	Global.add_SpecialEffect(self, Vector2(0, 0), "RoleBeHit", Vector2(1, 1), false, 1)


func NullSZFBCase():
	if PlayerData.player_data["实战法宝"] == "":
		if Mgtarget != null:
			Mgtarget.queue_free()
		if PlayerData.player_data["法宝"].size() != 0:
			addMagicWeapon()


func on_SZFBChange():
	if Global.should_change:
		if Mgtarget != null:
			Mgtarget.queue_free()
		if PlayerData.player_data["法宝"].size() != 0:
			addMagicWeapon()
		Global.should_change = false


func CheckRemoveOrAddFB():
	if PlayerData.player_data["法宝"].size() == 0:
		if Mgtarget != null:
			Mgtarget.queue_free()
	else:
		if Mgtarget == null:
			addMagicWeapon()


func _sync_main_sword_array_weapon() -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return
	if PlayerData.has_method("ensure_main_sword_array"):
		PlayerData.ensure_main_sword_array()
	var active := str(PlayerData.player_data.get("主线剑阵出战", ""))
	if (
		active != ""
		and PlayerData.has_method("can_main_sword_array_battle")
		and not PlayerData.can_main_sword_array_battle(active)
	):
		PlayerData.player_data["主线剑阵出战"] = ""
		active = ""
	if active == "":
		_last_main_sword_array_id = ""
		if is_instance_valid(MainSwordArrayTarget):
			MainSwordArrayTarget.queue_free()
		MainSwordArrayTarget = null
		return
	if is_instance_valid(MainSwordArrayTarget):
		if _last_main_sword_array_id != active:
			MainSwordArrayTarget.set_sword_id(active)
			_last_main_sword_array_id = active
		return
	var scene_parent := get_parent()
	if scene_parent == null or not is_instance_valid(scene_parent):
		return
	var parent := scene_parent.get_parent()
	if parent == null or not is_instance_valid(parent) or parent.is_queued_for_deletion():
		return
	var sword_array_scene := Global.load_scene_uncached(MAIN_SWORD_ARRAY_WEAPON_SCENE_PATH)
	if sword_array_scene == null:
		return
	MainSwordArrayTarget = sword_array_scene.instantiate()
	MainSwordArrayTarget.sword_id = active
	MainSwordArrayTarget.Player = self
	parent.add_child(MainSwordArrayTarget)
	MainSwordArrayTarget.position = position + (Vector2(-170, -190) if PlayerDir else Vector2(170, -190))
	_last_main_sword_array_id = active


func useFB():
	if Mgtarget == null or not is_instance_valid(Mgtarget) or Mgtarget.is_queued_for_deletion():
		return
	if not Mgtarget.has_method("EnoughMp"):
		return
	if bool(Mgtarget.call("EnoughMp")) and bool(Mgtarget.get("is_canuse")):
		Mgtarget.set("is_use", true)


func WSSkill() -> bool:
	var fashion_list: Variant = PlayerData.player_data.get("时装", [])
	if not fashion_list is Array or fashion_list.is_empty():
		return true
	var fashion: Variant = fashion_list[0]
	if not fashion is Dictionary:
		return true
	var fashion_id := str(fashion.get("名字", ""))
	var SZName: String = str(Global.GetName(fashion_id))
	var Pz := fashion_id.split(SZName)[0]
	if Pz == "putong":
		return true
	match SZName:
		"ttzssz":
			if not objattackDic.has("ttzs"):
				return true
			ADDTtzsEffect()
		"nmwsz":
			if not objattackDic.has("nmw"):
				return true
			ADDNMWEffect()
		"zlwsz":
			if not objattackDic.has("zlw"):
				return true
			ADDZLWEffect()
			if Pz == "shenqi":
				STARTZLWShenqiEffect()
		"smsrsz":
			if not objattackDic.has("smsr"):
				return true
			if smsrsz_timer == null:
				smsrsz_timer = Timer.new()
				add_child(smsrsz_timer)
				smsrsz_timer.timeout.connect(_on_smsrsz_timer_timeout)
			if Pz == "shenqi":
				ADDSMSRShenqiLightningRound()
			else:
				ADDSMSREffect()
			smsrsz_timer.start(1.0)

			if Pz == "shishi" or Pz == "xieling":
				Global.AddBuff(
					self.buff,
					{
						"Name": "NoDeBuff",
						"AddTime": 5.0,
						"ReduceInterval": 0,
						"value": 0,
						"AttackKind": "",
						"CanRemove": true,
						"DeBuff": false,
						"CanAdd": false
					}
				)
			elif Pz == "hunqi" or Pz == "chuanshuo":
				for child in self.buff.get_children():
					if child is BaseBuff and child.BuffInfo.get("DeBuff", false):
						child.queue_free()

				Global.AddBuff(
					self.buff,
					{
						"Name": "NoDeBuff",
						"AddTime": 5.0,
						"ReduceInterval": 0,
						"value": 0,
						"AttackKind": "",
						"CanRemove": true,
						"DeBuff": false,
						"CanAdd": false
					}
				)
		_:
			return true
	return true


func _on_smsrsz_timer_timeout():
	if not RoleProp.is_ws_state:
		smsrsz_timer.stop()
		return
	if has_smsrsz_fashion and current_fashion_quality == "shenqi":
		ADDSMSRShenqiLightningRound()
	else:
		ADDSMSREffect()


func _physics_process(delta: float) -> void:
	_sword_array_sync_elapsed += delta
	_auto_battle_target_search_elapsed += delta
	_auto_battle_jump_elapsed += delta
	jsfzsy()
	UseZhenFa()
	SetWingsOffset()
	ProcessSanXianHuTiEffect()

	if Islljy:
		velocity.x = 0

	if not SXYRCannotCure:
		if PlayerData.ChekEqzb("头衔", "sxyr"):
			SXYRCannotCure = true

	if not IsSanXianHuTiUsed and PlayerData.ChekEqzb("饰品", "huayan"):
		var hp_percent = float(RoleProp.roleprop.Hp) / float(RoleProp.roleprop.SHp) * 100

		if hp_percent <= 20.0:
			IsSanXianHuTiUsed = true

			var sxht_buff_info = {
				"Name": "SanXianHuTi",
				"value": 0.1,
				"AddTime": 20.0,
				"ReduceInterval": 1.0,
				"AttackKind": "cure",
				"CanRemove": true,
				"CanAdd": false,
				"DeBuff": false,
				"SpecialEffectAddInterval": 1.0
			}
			Global.AddBuff(self.buff, sxht_buff_info)

	for i in Role1SkillInter:
		if Role1SkillInter[i] > 0:
			Role1SkillInter[i] -= 0.1
	if MainSet.set_data["NotShowRoleBody"]:
		RoleBody.visible = false
		$Action/Wings.visible = false
		$Action/Wings.modulate = Color(1, 1, 1, 0)
	else:
		if not PlayerData.player_data["翅膀显示"]:
			$Action/Wings.visible = false
			$Action/Wings.modulate = Color(1, 1, 1, 0)

	if PlayerData.player_data["头衔显示"]:
		tx.visible = true
	else:
		tx.visible = false
	if MainSet.set_data["NotShowRoleEQ"]:
		role_equipment.visible = false
	if IsDeath:
		return
	_update_fashion_values_if_needed()
	_process_auto_battle(delta)
	AddTx()
	if RoleProp.ws_value >= RoleProp.max_ws_value:
		if Input.is_action_just_pressed("无双"):
			if not RoleProp.is_ws_state and WSSkill():
				RoleProp.is_ws_state = true
	if CureValue >= 4:
		CureValue = 4
	if is_on_floor():
		if not Onfloor:
			NewPosition = self.position.y
			OldIsCheck = false

		Onfloor = true
	if not is_on_floor():
		Onfloor = false
	if not OldIsCheck:
		if velocity.y > 0:
			OldPosition = self.position.y
			OldIsCheck = true
	if velocity.y <= 0:
		OldIsCheck = false
	ImproveSelfRecoveryWhenIdle()
	CheckAddBuff()

	if action.scale.x == -1:
		PlayerDir = true
	else:
		PlayerDir = false
	var archive_number := int(MemoryClass.get_cd_number())
	var archive_name: String
	if archive_number <= 6:
		archive_name = str(MainSet.set_data["name" + str(archive_number)])
	else:
		archive_name = str(MainSet.set_data["其他存档"][str(archive_number)]["name"])
	if archive_name != _last_archive_name:
		_last_archive_name = archive_name
		name_.text = archive_name

	selfProtect()
	RoleProp.Directon = PlayerDir
	NullSZFBCase()
	on_SZFBChange()
	CheckRemoveOrAddFB()
	if _sword_array_sync_elapsed >= 0.25:
		_sword_array_sync_elapsed = 0.0
		_sync_main_sword_array_weapon()

	if Mgtarget != null and "is_zcld" in Mgtarget and Mgtarget.is_zcld:
		zcld_level = Mgtarget.FB_Level
	else:
		zcld_level = 0

	if RoleProp.is_ws_state:
		if WSTimer.is_stopped():
			WSTimer.start(0.1)

	if (
		Input.is_action_just_pressed("down")
		and not has_meta("disable_down_drop")
		and not is_using_skills
		and not is_attacking
	):
		set_collision_mask_value(6, false)
		await get_tree().create_timer(0.5).timeout
		set_collision_mask_value(6, true)

		if not is_using_skills and not is_attacking and not IsDeath:
			get_action = "down"
	if death() and not IsDeath:
		IsDeath = true
		Global.RemoveAAllBuff()
		is_ice = false
		is_stun = false
		is_Immobilize = false
		IsScary = false
		velocity.x = 0
		velocity.y = 0
		get_action = "death"
		role_action_player.play("death")

		set_process_input(false)
		set_process_unhandled_input(false)
		await get_tree().create_timer(1.5).timeout
		Global.change_scene("res://Scene/Level/defeat.tscn")
		return
	RoleProp.up_level()
	RoleProp.role_pos_x = position.x
	RoleProp.role_pos_y = position.y
	RoleProp.role_pos = position
	remove_hit_data()
	if not is_on_floor():
		if self is role1:
			hit_count = 0
		elif self is role3:
			hit_count = 1
		elif self is role4:
			hit_count = 1
		elif self is role5:
			hit_count = 4
		velocity.y -= gravity * delta
	if is_on_floor() and velocity.y == 0:
		jump_count = 0
	if check_can_wait():
		_play_locomotion_animation(&"wait")
		get_action = "wait"

	if not NoLimitBuff() and not IsDeath:
		IsInSky = false
		if not IsTMc:
			if not IsScary:
				velocity.x = 0
				role_action_player.play("hurt")
			else:
				if IsScary:
					WhenScary()
	if Input.is_action_pressed("MagicWeapon"):
		if not get_parent().get_parent() is Level17 and not get_parent().get_parent() is Level22:
			if Mgtarget != null:
				if Mgtarget is GhostDoll:
					useFB()
				else:
					if NoLimitBuff():
						useFB()
	if is_Immobilize:
		velocity = Vector2(0, 0)
	if not NoLimitBuff():
		if has_method("_cancel_skill_for_control"):
			call("_cancel_skill_for_control")
		is_using_skills = false
	var mount_runtime := get_node_or_null("MountRuntime")
	if mount_runtime != null and bool(mount_runtime.call("process_mounted_control", delta)):
		pass
	elif NoLimitBuff():
		if IsTMc:
			if self is role3:
				if Input.is_action_pressed("slz"):
					get_skill("tmc2")
				if Input.is_action_pressed("lys"):
					get_skill("tmc2")
				if Input.is_action_pressed("lyfb"):
					get_skill("tmc2")
				if Input.is_action_pressed("hmz"):
					get_skill("tmc2")
				if Input.is_action_pressed("hytj"):
					get_skill("tmc2")
			else:
				if CanNormalControl():
					NoarmalControl()
		else:
			if CanNormalControl():
				NoarmalControl()

	if was_ws_state and not RoleProp.is_ws_state and smsrsz_timer != null:
		smsrsz_timer.stop()

	was_ws_state = RoleProp.is_ws_state

	Global.Player_dir = PlayerDir
	move_and_slide()


func _process(_delta: float) -> void:
	SetWingsOffset()


func ProcessSanXianHuTiEffect():
	if buff == null:
		return

	var sxht_buff = null

	var buff_child_count := buff.get_child_count()
	var buff_child_index := 0
	while buff_child_index < buff_child_count:
		var i = buff.get_child(buff_child_index)
		buff_child_index += 1
		if i != null and i is BaseBuff and i.BuffInfo["Name"] == "SanXianHuTi":
			sxht_buff = i
			break

	if sxht_buff == null:
		return

	var buff_data = sxht_buff.BuffInfo
	var heal_rate = buff_data.get("value", 0.05)

	var frame_heal_rate = heal_rate / 30.0

	var max_hp = RoleProp.roleprop.SHp
	var max_mp = RoleProp.roleprop.SMp

	var heal_hp = max(1, int(max_hp * frame_heal_rate))
	var heal_mp = max(1, int(max_mp * frame_heal_rate))

	cure_Hp(heal_hp)
	cure_Mp(heal_mp)

	if RoleProp.roleprop.Hp >= max_hp and RoleProp.roleprop.Mp >= max_mp:
		sxht_buff.queue_free()


func CanNormalControl():
	if not self is role5:
		if is_attacking == false and is_be_attacking == false and is_using_skills == false and not death():
			return true
	else:
		if CanMoveWhenUseSkill:
			if not death():
				return true
		else:
			if is_attacking == false and is_be_attacking == false and is_using_skills == false and not death():
				return true
	return false


func NoarmalControl():
	if IsUseSMB:
		return

	if MainSet.is_auto_battle_enabled() and not _is_auto_battle_skill_only():
		_process_auto_battle_movement()
		return

	if not Islljy:
		if not self is role5:
			NorMalMove()
		else:
			if CanMoveWhenUseSkill:
				var direction_ = Input.get_axis("move_left", "move_right")

				if IsReverseMove:
					direction_ = -direction_

				if direction_:
					velocity.x = direction_ * walk_speed * 0.7 * ReverseMoveSpeedMultiplier * mount_speed_multiplier
				else:
					velocity.x = move_toward(velocity.x, 0, walk_speed * 0.7 * ReverseMoveSpeedMultiplier)
			else:
				NorMalMove()

	if Input.is_action_just_pressed("jump"):
		if not is_Bound_to_the_ground:
			jump()
	if Input.is_action_pressed("slz") and not is_using_skills:
		var Skill_name = PlayerData.player_data["技能学习"]["技能键位"]["Y"]
		get_skill(Skill_name)
	if Input.is_action_pressed("lys") and not is_using_skills:
		var Skill_name = PlayerData.player_data["技能学习"]["技能键位"]["U"]
		get_skill(Skill_name)
	if Input.is_action_pressed("lyfb") and not is_using_skills:
		var Skill_name = PlayerData.player_data["技能学习"]["技能键位"]["I"]
		get_skill(Skill_name)
	if Input.is_action_pressed("hmz") and not is_using_skills:
		var Skill_name = PlayerData.player_data["技能学习"]["技能键位"]["O"]
		get_skill(Skill_name)
	if Input.is_action_pressed("hytj") and not is_using_skills:
		var Skill_name = PlayerData.player_data["技能学习"]["技能键位"]["L"]
		get_skill(Skill_name)


func _process_auto_battle(delta: float) -> void:
	if is_queued_for_deletion():
		return
	if not MainSet.is_auto_battle_enabled():
		_auto_battle_elapsed = 0.0
		_auto_battle_target = null
		_auto_battle_target_search_elapsed = 0.0
		_auto_battle_skill_cursor = 0
		_auto_battle_skill_cast_counts.clear()
		return
	if IsDeath:
		return
	_process_auto_battle_equipment()
	if _try_auto_battle_wushuang():
		return
	if is_silent or is_using_skills or is_attacking or is_be_attacking:
		return
	if is_stun or is_ice or is_Immobilize:
		return
	_auto_battle_elapsed += delta
	if _auto_battle_elapsed < AUTO_BATTLE_INTERVAL:
		return
	_auto_battle_elapsed = 0.0

	if not _is_auto_battle_skill_only():
		var target: Variant = _get_auto_battle_target()
		if target == null or not _is_auto_battle_target_in_attack_range(target):
			return

	var skill_entries := _get_auto_battle_skill_entries()
	if skill_entries.is_empty():
		_auto_battle_skill_cursor = 0
		_auto_battle_skill_cast_counts.clear()
		return
	if _auto_battle_skill_cursor >= skill_entries.size():
		_auto_battle_skill_cursor = 0
	var configured_ids: Array[String] = []
	for entry in skill_entries:
		configured_ids.append(str(entry.get("id", "")))
	for skill_id in _auto_battle_skill_cast_counts.keys():
		if str(skill_id) not in configured_ids:
			_auto_battle_skill_cast_counts.erase(skill_id)
	for offset in range(skill_entries.size()):
		var index := (_auto_battle_skill_cursor + offset) % skill_entries.size()
		var entry: Dictionary = skill_entries[index]
		var skill_id := str(entry.get("id", ""))
		if _is_auto_battle_skill_active(skill_id):
			_auto_battle_skill_cast_counts.erase(skill_id)
			_auto_battle_skill_cursor = (index + 1) % skill_entries.size()
			continue
		if not _can_auto_battle_use_skill(skill_id):
			continue
		var mp_before := int(RoleProp.roleprop.Mp)
		var cooldown_before := float(Role1SkillInter.get(skill_id, 0.0))
		var action_before: String = str(get_action)
		var using_skill_before := is_using_skills
		get_skill(skill_id)
		var cooldown_after := float(Role1SkillInter.get(skill_id, 0.0))
		var skill_cast_started := (
			cooldown_after > cooldown_before + 0.001
			or int(RoleProp.roleprop.Mp) < mp_before
			or is_using_skills != using_skill_before
			or get_action != action_before
		)
		if not skill_cast_started:
			continue
		var cast_count := int(_auto_battle_skill_cast_counts.get(skill_id, 0)) + 1
		var required_count := maxi(1, int(entry.get("count", 1)))
		if cast_count >= required_count:
			_auto_battle_skill_cast_counts.erase(skill_id)
			_auto_battle_skill_cursor = (index + 1) % skill_entries.size()
		else:
			_auto_battle_skill_cast_counts[skill_id] = cast_count
			_auto_battle_skill_cursor = index
		return


func _is_auto_battle_skill_only() -> bool:
	return bool(MainSet.set_data.get("AutoBattleSkillOnly", false))


func _process_auto_battle_equipment() -> void:
	if bool(MainSet.set_data.get("AutoBattleMagicWeapon", false)):
		_try_auto_battle_magic_weapon()
	if bool(MainSet.set_data.get("AutoBattleSwordArray", false)) and ZhenFaCd <= 0:
		_try_use_main_sword_array()


func _try_auto_battle_magic_weapon() -> bool:
	if Mgtarget == null or not is_instance_valid(Mgtarget) or Mgtarget.is_queued_for_deletion():
		return false
	if _is_magic_weapon_disabled_in_current_level():
		return false
	if bool(Mgtarget.get("is_use")) or not bool(Mgtarget.get("is_canuse")):
		return false
	if not Mgtarget is GhostDoll and not NoLimitBuff():
		return false
	useFB()
	return bool(Mgtarget.get("is_use"))


func _is_magic_weapon_disabled_in_current_level() -> bool:
	var scene_parent := get_parent()
	if scene_parent == null:
		return false
	var level := scene_parent.get_parent()
	return level is Level17 or level is Level22


func _try_auto_battle_wushuang() -> bool:
	if not bool(MainSet.set_data.get("AutoBattleWushuang", false)):
		return false
	if RoleProp.is_ws_state or RoleProp.ws_value < RoleProp.max_ws_value:
		return false
	if not WSSkill():
		return false
	RoleProp.is_ws_state = true
	return true


func _get_auto_battle_target() -> Variant:
	if (
		is_instance_valid(_auto_battle_target)
		and _is_auto_battle_target_valid(_auto_battle_target)
		and _auto_battle_target_search_elapsed < AUTO_BATTLE_TARGET_SEARCH_INTERVAL
	):
		return _auto_battle_target

	_auto_battle_target_search_elapsed = 0.0
	_auto_battle_target = null
	var candidates: Array = []
	var current_scene := get_tree().current_scene
	if current_scene != null and current_scene.has_method("get_active_monsters"):
		var active_monsters: Variant = current_scene.call("get_active_monsters")
		if active_monsters is Array:
			candidates = active_monsters
	if candidates.is_empty():
		candidates = get_tree().get_nodes_in_group("monsters")

	var best_target: Variant = null
	var best_score := INF
	for candidate in candidates:
		if not _is_auto_battle_target_valid(candidate):
			continue
		var monster := candidate as BaseMonster
		if monster == null:
			continue
		var horizontal_distance := absf(monster.global_position.x - global_position.x)
		var vertical_distance := absf(monster.global_position.y - global_position.y)
		if horizontal_distance > AUTO_BATTLE_TARGET_SEARCH_RANGE:
			continue
		var score := horizontal_distance + vertical_distance * 0.35
		if score < best_score:
			best_score = score
			best_target = monster
	_auto_battle_target = best_target
	return _auto_battle_target


func _is_auto_battle_target_valid(target: Variant) -> bool:
	if target == null or not is_instance_valid(target) or not target is BaseMonster:
		return false
	var monster := target as BaseMonster
	if not monster.is_inside_tree() or monster.is_queued_for_deletion():
		return false
	if monster.Hp <= 0 or monster.is_death or monster.NoTarget:
		return false
	if _is_summon_or_pet_target(monster):
		return false
	if monster.has_method("death") and bool(monster.call("death")):
		return false
	return true


func _get_auto_battle_attack_range() -> float:
	var range_value := AUTO_BATTLE_ATTACK_RANGE
	for skill_entry in _get_auto_battle_skill_entries():
		var skill_id := str(skill_entry.get("id", ""))
		if skill_id in ["hyjj", "hyjj_ws", "nz_yysj"]:
			range_value = maxf(range_value, 420.0)
		elif skill_id in ["lyfb", "hmz", "hmz_ws", "smb", "by", "cmly", "tllz", "ltjz"]:
			range_value = maxf(range_value, 320.0)
	return range_value


func _is_auto_battle_target_in_attack_range(target: Variant) -> bool:
	if not _is_auto_battle_target_valid(target):
		return false
	var monster := target as BaseMonster
	var horizontal_distance := absf(monster.global_position.x - global_position.x)
	var vertical_distance := absf(monster.global_position.y - global_position.y)
	return horizontal_distance <= _get_auto_battle_attack_range() and vertical_distance <= 220.0


func _process_auto_battle_movement() -> void:
	if not MainSet.is_auto_battle_enabled():
		return
	if _is_auto_battle_skill_only():
		_auto_battle_target = null
		velocity.x = 0.0
		_set_auto_battle_idle()
		return
	if IsDeath or is_silent or is_using_skills or is_attacking or is_be_attacking:
		velocity.x = 0.0
		return
	if not NoLimitBuff() or is_Bound_to_the_ground:
		velocity.x = 0.0
		return

	var target: Variant = _get_auto_battle_target()
	if not _is_auto_battle_target_valid(target):
		target = null
	var direction_ := 1.0
	if target != null and not _is_auto_battle_target_in_attack_range(target):
		var horizontal_delta: float = float((target as BaseMonster).global_position.x - global_position.x)
		if absf(horizontal_delta) > 12.0:
			direction_ = signf(horizontal_delta)
		elif target.global_position.y < global_position.y - 50.0:
			direction_ = 1.0 if PlayerDir else -1.0
		else:
			velocity.x = 0.0
			_set_auto_battle_idle()
			return
	elif target != null:
		var target_delta_x: float = float((target as BaseMonster).global_position.x - global_position.x)
		if absf(target_delta_x) > 8.0:
			_set_auto_battle_facing(signf(target_delta_x))
		velocity.x = 0.0
		_set_auto_battle_idle()
		return
	else:
		direction_ = 1.0

	_set_auto_battle_facing(direction_)
	if _auto_battle_is_blocked_ahead(direction_):
		_auto_battle_jump_if_blocked()
	if is_attacking or is_be_attacking or is_using_skills:
		velocity.x = 0.0
		return
	velocity.x = (
		direction_
		* walk_speed
		* RoleProp.ws_up_power
		* ReverseMoveSpeedMultiplier
		* AUTO_BATTLE_MOVE_SPEED_SCALE
		* mount_speed_multiplier
	)
	if is_on_floor():
		_play_locomotion_animation(&"run")
		get_action = "run"


func _set_auto_battle_facing(direction_: float) -> void:
	if direction_ > 0.0:
		action.scale.x = -1
		base_damagebox.scale.x = -1
		PlayerDir = true
	elif direction_ < 0.0:
		action.scale.x = 1
		base_damagebox.scale.x = 1
		PlayerDir = false


func _set_auto_battle_idle() -> void:
	if get_action == "run":
		get_action = ""
	if is_on_floor() and not is_attacking and not is_using_skills:
		_play_locomotion_animation(&"wait")


func _auto_battle_is_blocked_ahead(direction_: float) -> bool:
	if not is_on_floor() or direction_ == 0.0:
		return false
	var has_obstacle_collision := false
	var has_slide_collision := false
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		if collision == null:
			continue
		has_slide_collision = true
		var collider := collision.get_collider()
		if collider is Node and _find_auto_battle_monster(collider as Node) != null:
			continue
		var normal := collision.get_normal()
		if direction_ > 0.0 and normal.x < -0.25:
			has_obstacle_collision = true
		if direction_ < 0.0 and normal.x > 0.25:
			has_obstacle_collision = true
	if has_obstacle_collision or (not has_slide_collision and is_on_wall()):
		return true

	var space_state := get_world_2d().direct_space_state
	if space_state == null:
		return false
	var ray_start := global_position + Vector2(0.0, -28.0)
	var ray_end := ray_start + Vector2(direction_ * 36.0, 0.0)
	var query := PhysicsRayQueryParameters2D.create(ray_start, ray_end, collision_mask, [get_rid()])
	var hit := space_state.intersect_ray(query)
	if hit.is_empty():
		return false
	var collider: Variant = hit.get("collider")
	if collider is Node:
		var monster := _find_auto_battle_monster(collider as Node)
		if monster != null:
			return false
	return true


func _find_auto_battle_monster(node: Node) -> BaseMonster:
	var current := node
	var depth := 0
	while current != null and is_instance_valid(current) and depth < 8:
		if current is BaseMonster:
			return current as BaseMonster
		current = current.get_parent()
		depth += 1
	return null


func _auto_battle_jump_if_blocked() -> void:
	if _auto_battle_jump_elapsed < AUTO_BATTLE_JUMP_COOLDOWN:
		return
	if not is_on_floor() or is_Bound_to_the_ground or is_jump:
		return
	if is_attacking or is_be_attacking or is_using_skills:
		return
	_auto_battle_jump_elapsed = 0.0
	jump()


func _get_auto_battle_skills() -> Array:
	var result: Array = []
	for entry in _get_auto_battle_skill_entries():
		result.append(str(entry.get("id", "")))
	return result


func _get_auto_battle_skill_entries() -> Array[Dictionary]:
	var role_id := int(PlayerData.player_data.get("Myself", 1))
	if role_id < 1 or role_id > 6:
		role_id = 1
	var role_key := "角色" + str(role_id)
	var by_role_value: Variant = MainSet.set_data.get("AutoBattleSkillsByRole", {})
	if by_role_value is Dictionary and (by_role_value as Dictionary).has(role_key):
		var role_skills: Variant = (by_role_value as Dictionary).get(role_key, [])
		return _normalize_auto_battle_skill_entries(role_skills)
	var legacy_skills: Variant = MainSet.set_data.get("AutoBattleSkills", [])
	return _normalize_auto_battle_skill_entries(legacy_skills)


func _normalize_auto_battle_skill_entries(raw_value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not raw_value is Array:
		return result
	var seen: Dictionary = {}
	for value in raw_value:
		var skill_id := ""
		var count := 1
		if value is Dictionary:
			var entry: Dictionary = value
			skill_id = str(entry.get("id", entry.get("skill_id", "")))
			count = clampi(int(entry.get("count", 1)), 1, 99)
		else:
			skill_id = str(value)
		if skill_id == "" or seen.has(skill_id):
			continue
		seen[skill_id] = true
		(
			result
			. append(
				{
					"id": skill_id,
					"count": count,
				}
			)
		)
	return result


func _can_auto_battle_use_skill(skill_id: String) -> bool:
	if skill_id == "" or not Role1SkillInter.has(skill_id):
		return false
	if float(Role1SkillInter.get(skill_id, 0.0)) > 0.0:
		return false
	if not has_method("get_need_mp"):
		return false
	var need_mp := int(get_need_mp(skill_id, false))
	return int(RoleProp.roleprop.Mp) >= need_mp


func _is_auto_battle_skill_active(_skill_id: String) -> bool:
	return false


func NorMalMove():
	var direction_ = Input.get_axis("move_left", "move_right")

	if IsReverseMove:
		direction_ = -direction_

	if direction_ > 0:
		if check_on_floor() and is_attacking == false and is_be_attacking == false and is_using_skills == false:
			_play_locomotion_animation(&"run")
			get_action = "run"
		action.scale.x = -1
		base_damagebox.scale.x = -1
	elif direction_ < 0:
		if check_on_floor() and is_attacking == false and is_be_attacking == false and is_using_skills == false:
			_play_locomotion_animation(&"run")
			get_action = "run"
		action.scale.x = 1
		base_damagebox.scale.x = 1
	else:
		if get_action == "run":
			get_action = ""

	if direction_:
		velocity.x = (
			direction_ * walk_speed * RoleProp.ws_up_power * ReverseMoveSpeedMultiplier * mount_speed_multiplier
		)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * RoleProp.ws_up_power * ReverseMoveSpeedMultiplier)


func NoLimitBuff():
	return not is_ice and not is_stun and not is_EyeFix and not IsDeath and not is_Immobilize and not IsScary


func is_riding_mount() -> bool:
	var runtime := get_node_or_null("MountRuntime")
	return runtime != null and runtime.has_method("is_riding_mount") and bool(runtime.call("is_riding_mount"))


func turn_to_wait():
	if not is_on_floor():
		_play_locomotion_animation(&"wait")


func do_normalhit_1():
	pass


func do_normalhit_2():
	pass


func do_normalhit_3():
	pass


func do_normalhit_4():
	pass


func do_slz():
	pass


func do_zz():
	pass


func do_gsrs():
	pass


func do_lys():
	pass


func do_lyfb():
	pass


func do_hmz_pro():
	pass


func do_hytj():
	pass


func do_hyjj():
	pass


func do_jdy_2():
	pass


func do_jdy():
	pass


func do_qsez():
	pass


func Skill_Blb():
	pass


func Skill_Tjgl():
	pass


func Skill_XBZ():
	pass


func Skill_SHY():
	pass


func Skill_SMB():
	pass


func Skill_SMB2():
	pass


func Skill_BY():
	pass


func Skill_SGQ():
	pass


func Skill_MYHC():
	pass


func Skill_JGZ():
	pass


func Skill_JHSJ():
	pass


func Skill_SD():
	pass


func Skill_ZZNH():
	pass


func Skill_SSP():
	pass


func Skill_JSP():
	pass


func Skill_DGQ():
	pass


func Skill_XGQ():
	pass


func Skill_SYZQ():
	pass


func Skill_DJ():
	pass


func Skill_TMC2():
	pass


func Skill_TMC():
	pass


func Skill_BDQK():
	pass


func ShovelQLJ():
	pass


func ShovelDCJ():
	pass


func ShovelTKJ():
	pass


func ShovelMMW():
	pass


func ShovelZQ():
	pass


func ShovelWDWW():
	pass


func ShovelMBYJ():
	pass


func ShovelJDZ():
	pass


func ShovelWDZT():
	pass


func UseSLQ():
	pass


func UseCXQ():
	pass


func UseBLQ():
	pass


func UseXYQ():
	pass


func UseLLRD():
	pass


func UseLLJY():
	pass


func UseTLLZ():
	pass


func UseYGTH():
	pass


func UseFHF():
	pass


func is_can_move_attack_in_sky():
	if is_on_floor() and is_attacking:
		velocity.x = 0


func check_on_floor():
	return velocity.y == 0


func _play_locomotion_animation(animation_name: StringName) -> void:
	if role_action_player == null or role_action_player.current_animation == animation_name:
		return
	role_action_player.play(animation_name)


func check_can_wait():
	return (
		velocity.x == 0
		and not is_attacking
		and not is_be_attacking
		and velocity.y == 0
		and not death()
		and get_action != "run"
		and not IsTMc
	)


func checkCanuseSomeSkill():
	return not is_attacking and not is_be_attacking and velocity.y == 0 and not death()


func jump():
	is_jump = true
	if jump_count < 2 and is_attacking == false and is_be_attacking == false:
		velocity.y = jump_power
		if jump_count == 0:
			jump_count = 1
			role_action_player.play("jump1")
			get_action = "jump1"
			await role_action_player.animation_finished
			role_action_player.play("drop")
			await role_action_player.animation_finished
		else:
			jump_count = 2
			role_action_player.play("jump2")
			get_action = "jump2"
			await role_action_player.animation_finished
			role_action_player.play("drop")
			await role_action_player.animation_finished
	is_jump = false


func get_hit_data(hit_name_: String):
	HitDic = objattackDic[hit_name_]
	_hit_data_needs_reset = true


var _hit_data_needs_reset := false


func remove_hit_data():
	if not is_attacking and _hit_data_needs_reset:
		HitDic = {"power": 0, "hurtBack": [0, 0], "attackKind": "real"}
		_hit_data_needs_reset = false


func _prepare_hit_reaction() -> void:
	pass


func _skill_super_armor_active() -> bool:
	return false


func _get_hit_stiff_animation_duration() -> float:
	return -1.0


func _cancel_hit_reaction() -> void:
	_hit_reaction_generation += 1
	is_be_attacking = false


func state_behit():
	var stiff_seconds := -1.0
	if not _pending_hit_stiff_seconds.is_empty():
		stiff_seconds = _pending_hit_stiff_seconds.pop_front()
	if needProtect or is_knockback_immune():
		_cancel_hit_reaction()
		return
	if RoleProp.roleprop.Hp <= 0 or IsDeath:
		_cancel_hit_reaction()
		if RoleProp.roleprop.Hp <= 0 and not IsDeath:
			IsDeath = true
			Global.RemoveAAllBuff()
			velocity.x = 0
			velocity.y = 0
			get_action = "death"
			role_action_player.play("death")
			await get_tree().create_timer(1.5).timeout
			Global.change_scene("res://Scene/Level/defeat.tscn")
		return

	_prepare_hit_reaction()
	if needProtect:
		_cancel_hit_reaction()
		return

	_hit_reaction_generation += 1
	var reaction_generation := _hit_reaction_generation
	IsInSky = false
	is_be_attacking = true
	is_using_skills = false

	await get_tree().process_frame

	if not is_instance_valid(self) or not is_instance_valid(role_action_player):
		return
	if needProtect or reaction_generation != _hit_reaction_generation:
		return

	role_action_player.stop()
	role_action_player.play("hurt")
	get_action = "hurt"

	if stiff_seconds >= 0.0:
		await get_tree().create_timer(stiff_seconds, false).timeout
	else:
		var hurt_duration := _get_hit_stiff_animation_duration()
		if hurt_duration < 0.0:
			hurt_duration = role_action_player.current_animation_length
		var playback_speed := maxf(absf(role_action_player.speed_scale), 0.001)
		await get_tree().create_timer(maxf(hurt_duration / playback_speed, 1.0 / 30.0), false).timeout

	if is_instance_valid(self) and reaction_generation == _hit_reaction_generation:
		is_be_attacking = false


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if is_dikong_field_invincible() or IsDeath or needProtect:
		return
	IsInSky = false
	CUreCureCount = 0
	CureValue = 1
	IdleCount = 0

	Global.TotalHurtCount += 1
	var Target = area.get_parent().get_parent()
	var MonsterTarget: BaseMonster
	MonsterTarget = checkMonster(area)
	if Target == null or MonsterTarget == null:
		return
	if Target.objattackDic.size() == 0:
		return
	if str(Target.get("skill_name")) == "Monster118Bullet2":
		Global.AddBuff(
			self.buff,
			{
				"Name": "poision",
				"AddTime": 5,
				"CanAdd": true,
				"DeBuff": true,
				"CanRemove": false,
				"ReduceInterval": 1,
				"value": 900,
				"AttackKind": "magic"
			}
		)
	if MonsterTarget is Monster47:
		Global.PlayerBeHitCount += 1
	var last_hit = get_Monster_last_hurt(MonsterTarget, Target) * (1 - slzjs) * (1 - slzjs2)

	if MonsterTarget != null:
		if MonsterTarget.IsLpz:
			var Levellpz = PlayerData.player_data["落魄阵"]["Level"]
			MonsterTarget.lpzjs = Levellpz * 0.01
			last_hit *= (1 - MonsterTarget.lpzjs)

	var TotalCureMonster = int(MonsterTarget.ebol * last_hit)
	MonsterTarget.cure_hp(TotalCureMonster)
	if self is role3 and RoleProp.is_ws_state:
		last_hit = int(last_hit * 0.63)
	if MonsterTarget != null:
		MonsterTarget.total_hit += last_hit
		if MonsterTarget is Monster141:
			effect_reducehp(int(RoleProp.roleprop.SHp * 0.01), "real")
			Global.AddMonster141Aura(self.Bullet, self.position, MonsterTarget)
	Global.TotalRoleHurt += int(last_hit)
	if not is_miss:
		if self is role1:
			Global.addSound_(self, "res://Music/Hero/49_Role1_beAttack.mp3")
		elif self is role2:
			Global.addSound_(self, "res://Music/Hero/62_Role2_beAttack.mp3")
		elif self is role5:
			Global.addSound_(self, "res://Music/Hero/Role5/13_hurtStand.mp3")
		else:
			Global.addSound_(self, "res://Music/Hero/68_Role3_beAttack.mp3")
		_add_role_hit_effect_throttled()
		if not IsTMc:
			_add_role_protect(randi_range(3, 7))
	if self is role3:
		if randi_range(0, 100) <= 2 + PlayerData.player_data["技能学习"]["技能10"]["等级"] * 0.5:
			var Level = PlayerData.player_data["技能学习"]["技能10"]["等级"]
			if Level > 0:
				if not get_parent().get_parent() is Level17 and not get_parent().get_parent() is Level22:
					cure_Hp(RoleProp.roleprop.power * (0.5 + Level * 0.03))

	if self is role1 or self is role2 or self is role4 or self is NeZhaHero:
		if is_miss or RoleProp.is_ws_state or IsSuperArmor or needProtect or is_knockback_immune():
			is_be_attacking = false
		else:
			be_hit_back(MonsterTarget, Target)
			_queue_hit_stiff(MonsterTarget, Target)
			call_deferred("state_behit")
	elif self is role3:
		if is_miss or Is_sdBuff or IsTMc or IsSuperArmor or needProtect:
			is_be_attacking = false
		else:
			be_hit_back(MonsterTarget, Target)
			_queue_hit_stiff(MonsterTarget, Target)
			call_deferred("state_behit")
	elif self is role5:
		if is_miss or RoleProp.is_ws_state or IsSuperArmor or Role5Bt or needProtect:
			is_be_attacking = false
		else:
			be_hit_back(MonsterTarget, Target)
			_queue_hit_stiff(MonsterTarget, Target)
			call_deferred("state_behit")

	reduce_hp(last_hit, MonsterTarget, Target)


func reduce_hp(value: int, target_boss, target_obj):
	if is_dikong_field_invincible():
		return

	if is_miss:
		var miss_parent = get_parent().get_parent()
		var miss_position = Vector2(self.position.x, self.position.y - 110)
		Global.addMissEffect(miss_parent, miss_position)
		is_crit = false
		is_miss = false
		return

	if Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE):
		return

	var monster_damage_bonus: float = float(target_boss.damage_bonus) if target_boss is BaseMonster else 0.0
	value = _apply_damage_vs_reduction(value, monster_damage_bonus)

	if not canglongremove:
		if value >= RoleProp.roleprop.Hp:
			if PlayerData.ChekEqzb("饰品", "canglongjie"):
				(
					Global
					. AddBuff(
						self.buff,
						{
							"Name": "Indestructible",
							"AddTime": 3,
							"ReduceInterval": 0,
							"value": 0,
							"AttackKind": "",
							"CanRemove": false,
						}
					)
				)
				canglongremove = true
				return
	if RoleProp.roleprop.Hp <= 0:
		return
	if IsIndestructible or IsIndestructible1:
		if value >= RoleProp.roleprop.Hp:
			return

	CUreCureCount = 0
	CureValue = 1
	IdleCount = 0

	if target_boss == null or target_obj == null:
		return

	if self is role2 and hd > 0:
		var absorbed = min(hd, value)
		value -= absorbed
		hd -= absorbed
		print("[护盾·唐僧] 伤害吸收 %d，剩余护盾 %d" % [absorbed, hd])
		if value <= 0:
			return

	if value <= 0:
		return

	value = _apply_pet_turtle_damage_share(value)
	if value <= 0:
		return

	RoleProp.roleprop.Hp -= value

	var hit_name_value = target_obj.get("hit_name")
	if hit_name_value == null or typeof(target_boss.objattackDic) != TYPE_DICTIONARY:
		return
	var attack_data = target_boss.objattackDic.get(hit_name_value, {})
	if typeof(attack_data) != TYPE_DICTIONARY or not attack_data.has("attackKind"):
		return

	var ATKind = String(attack_data["attackKind"])
	if value > 0:
		var pp = get_parent().get_parent()
		var po = Vector2(self.position.x, self.position.y - 110)
		Global.addDamageText(pp, po, value, ATKind, is_crit, self)
	is_crit = false
	is_miss = false


func effect_reducehp(value, atkKind):
	if is_dikong_field_invincible():
		return

	if Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE):
		return

	if not canglongremove:
		if value >= RoleProp.roleprop.Hp:
			if PlayerData.ChekEqzb("饰品", "canglongjie"):
				(
					Global
					. AddBuff(
						self.buff,
						{
							"Name": "Indestructible",
							"AddTime": 3,
							"ReduceInterval": 0,
							"value": 0,
							"AttackKind": "",
							"CanRemove": false,
						}
					)
				)
				canglongremove = true
				return
	if RoleProp.roleprop.Hp <= 0:
		return
	if IsIndestructible or IsIndestructible1:
		if value >= RoleProp.roleprop.Hp:
			return

	CUreCureCount = 0
	CureValue = 1
	IdleCount = 0

	if self is role2 and hd > 0:
		var absorbed = min(hd, value)
		value -= absorbed
		hd -= absorbed
		print("[护盾·唐僧] 伤害吸收 %d，剩余护盾 %d" % [absorbed, hd])
		if value <= 0:
			return

	if value <= 0:
		return

	if atkKind == "physics":
		var reduce_rate = snapped(RoleProp.roleprop.Def / float(RoleProp.roleprop.Def + 250), 0.001)
		value = int(value * (1 - reduce_rate))
		Global.TotalPhyHurt += value
	elif atkKind == "magic":
		var reduce_rate = snapped(RoleProp.roleprop.Mdef / float(RoleProp.roleprop.Mdef + 250), 0.001)
		value = int(value * (1 - reduce_rate))
		Global.TotalMagHurt += value
	elif atkKind == "real":
		Global.TotalRealHurt += value

	value = _apply_damage_vs_reduction(value)

	value = _apply_pet_turtle_damage_share(value)
	if value <= 0:
		return

	RoleProp.roleprop.Hp -= value
	Global.TotalRoleHurt += int(value)

	if value > 0:
		var pp = get_parent().get_parent()
		var po = Vector2(self.position.x, self.position.y - 110)
		Global.addDamageText(pp, po, value, atkKind, false, self)


func get_Monster_last_hurt(target_boss, target_obj):
	is_crit = false
	is_miss = false
	if target_boss == null or target_obj == null:
		return 0
	var Target = checkMonster(target_boss) as BaseMonster
	if Target == null:
		return 0
	var hit_name_value = target_obj.get("hit_name")
	if hit_name_value == null or String(hit_name_value).is_empty():
		return 0
	var attack_dictionary: Dictionary = {}
	var source_attack_dictionary: Variant = target_obj.get("objattackDic")
	if source_attack_dictionary is Dictionary and (source_attack_dictionary as Dictionary).has(hit_name_value):
		attack_dictionary = source_attack_dictionary as Dictionary
	elif typeof(target_boss.objattackDic) == TYPE_DICTIONARY:
		attack_dictionary = target_boss.objattackDic
	if not attack_dictionary.has(hit_name_value):
		return 0
	var attack_data = attack_dictionary[hit_name_value]
	if typeof(attack_data) != TYPE_DICTIONARY:
		return 0
	if not attack_data.has("attackKind") or not attack_data.has("power"):
		return 0
	var LevelInter = abs(target_boss.level - RoleProp.baseroleprop.Level)

	var lx = String(attack_data["attackKind"])
	var Hurt = int(attack_data["power"])
	if bool(attack_data.get("stz_stack_bonus", false)) and buff != null:
		for buff_node in buff.get_children():
			if buff_node is BaseBuff and buff_node.IsSet:
				var buff_info: Dictionary = buff_node.BuffInfo
				if str(buff_info.get("Name", "")) == "monster137buff":
					Hurt += 100
	var Miss = RoleProp.roleprop.Miss - Target.Htarget
	var Crit = Target.crit - RoleProp.roleprop.CritReduce
	var Lucky = Target.lucky - RoleProp.roleprop.Toughness
	var last_def = RoleProp.roleprop.Def - Target.ar
	var last_mdef = RoleProp.roleprop.Mdef - Target.sp
	var crit_bl = LevelInter * 0.07
	var lucky_bl = LevelInter * 0.07
	var IniHurt = Hurt

	if Miss <= 0:
		Miss = 0
	if Crit <= 0:
		Crit = 0
	if last_def <= 0:
		last_def = 0
	if last_mdef <= 0:
		last_mdef = 0
	if IsDefeReduce:
		var defense_reduction := clampf(DefeReduce, 0.0, 1.0)
		last_def *= 1.0 - defense_reduction
		last_mdef *= 1.0 - defense_reduction
	if Lucky <= 0:
		Lucky = 0
	if crit_bl >= 1:
		crit_bl = 1
	if lucky_bl >= 0.7:
		lucky_bl = 0.7
	if target_boss.level - RoleProp.baseroleprop.Level < 0:
		Crit = Crit * (1 - crit_bl)
		Lucky = Lucky * (1 - lucky_bl)
		Hurt = int(Hurt * (1 - is_suppression_num(target_boss) * 0.05))
	else:
		Crit = Crit * (1 + crit_bl)
		Lucky = Lucky * (1 + lucky_bl)
		Hurt = int(Hurt * (1 + is_suppression_num(target_boss) * 0.05))
	var bl
	Crit = snapped(Crit / float(Crit + 100), 0.001)
	Miss = snapped(Miss / float(Miss + 100), 0.001)
	randomize()
	if randf_range(0, 1) <= Miss:
		Global.TotalMissCount += 1
		is_miss = true
		return 0
	if randf_range(0, 1) <= Crit:
		bl = 2 + snapped(Lucky / float(Lucky + 50), 0.001) - tszbsjm
		Hurt = Hurt * bl
		is_crit = true
	if lx == "physics":
		var 减伤率 = snapped(last_def / float(last_def + 250), 0.001)
		Hurt = int(Hurt * (1 - 减伤率))
		Global.TotalPhyHurt += Hurt
	elif lx == "magic":
		var 减伤率 = snapped(last_mdef / float(last_mdef + 250), 0.001)
		Hurt = int(Hurt * (1 - 减伤率))
		Global.TotalMagHurt += Hurt
	elif lx == "real":
		Global.TotalRealHurt += Hurt

	if IsIndestructible or IsIndestructible1:
		if Hurt >= RoleProp.roleprop.Hp:
			return 0
	if self is role3:
		if IsTMc:
			if Hurt > 0:
				if target_boss != null:
					if target_boss is BaseMonster:
						var Level = PlayerData.player_data["技能学习"]["技能5"]["等级"] + 1
						var LastHurt = int(IniHurt * (2 + Level * 0.2))
						target_boss.receive_reflected_damage(LastHurt, "magic", int(RoleProp.roleprop.sp))
	return Hurt


func get_total_damage_reduction() -> float:
	var permanent_reduction := maxf(0.0, float(RoleProp.roleprop.get("damage_reduction", 0.0)))
	return permanent_reduction + maxf(0.0, wdsl_damage_reduction)


func add_dikong_field_invincibility() -> void:
	dikong_field_invincible_count += 1


func remove_dikong_field_invincibility() -> void:
	dikong_field_invincible_count = maxi(0, dikong_field_invincible_count - 1)


func is_dikong_field_invincible() -> bool:
	return dikong_field_invincible_count > 0


func _apply_damage_vs_reduction(value: int, attacker_damage_bonus: float = 0.0) -> int:
	if value <= 0:
		return value
	var multiplier := maxf(0.0, 1.0 + maxf(0.0, attacker_damage_bonus) - get_total_damage_reduction())
	return int(float(value) * multiplier)


func Level_suppression(target):
	return target.level - RoleProp.baseroleprop.Level > 0


func is_suppression_num(target):
	var num: int = abs(target.level - RoleProp.baseroleprop.Level)
	if num > 5:
		num = 5
	return num


func not_suppression_num(target):
	var num: int
	if RoleProp.baseroleprop.Level - target.level > 2:
		num = 2
	else:
		num = RoleProp.baseroleprop.Level - target.level
	return num


func be_hit_back(target_boss, target_obj):
	if is_knockback_immune():
		return
	if not target_boss is BaseMonster:
		return
	if target_boss.has_method("get_knockback_velocity_for_target"):
		var custom_velocity: Variant = target_boss.call("get_knockback_velocity_for_target", target_obj, self)
		if custom_velocity is Vector2:
			var now_msec := Time.get_ticks_msec()
			var blocked_until: int = (
				int(get_meta("eight_immortals_knockback_until")) if has_meta("eight_immortals_knockback_until") else 0
			)
			if now_msec >= blocked_until:
				velocity = custom_velocity as Vector2
				set_meta("eight_immortals_knockback_until", now_msec + 120)
			return
	if target_boss.has_method("get_knockback_direction_for_target"):
		var custom_direction: Variant = target_boss.call("get_knockback_direction_for_target", target_obj, self)
		if custom_direction is int and int(custom_direction) != 0:
			if int(custom_direction) > 0:
				attack_to_right(target_boss, target_obj)
			else:
				attack_to_left(target_boss, target_obj)
			return
	if target_boss.MonsterDirection:
		attack_to_right(target_boss, target_obj)
	else:
		attack_to_left(target_boss, target_obj)


func is_knockback_immune() -> bool:
	return false


func _get_monster_hurt_back(target_boss, target_obj) -> Array:
	if target_boss == null or target_obj == null:
		return []
	var hit_name_value = target_obj.get("hit_name")
	if hit_name_value == null or typeof(target_boss.objattackDic) != TYPE_DICTIONARY:
		return []
	var attack_data = target_boss.objattackDic.get(hit_name_value, {})
	if typeof(attack_data) != TYPE_DICTIONARY or not attack_data.has("hurtBack"):
		return []
	var hurt_back = attack_data["hurtBack"]
	if typeof(hurt_back) != TYPE_ARRAY or hurt_back.size() < 2:
		return []
	return hurt_back


func _get_source_target_move(target_boss, target_obj) -> Array:
	if target_boss == null or target_obj == null:
		return []
	var hit_name_value = target_obj.get("hit_name")
	if hit_name_value == null or typeof(target_boss.objattackDic) != TYPE_DICTIONARY:
		return []
	var attack_data = target_boss.objattackDic.get(hit_name_value, {})
	if typeof(attack_data) != TYPE_DICTIONARY:
		return []
	var source_move: Variant = attack_data.get("sourceTargetMove", null)
	if source_move is Vector2:
		return [source_move.x, source_move.y]
	if source_move is Array and source_move.size() >= 2:
		return [source_move[0], source_move[1]]
	return []


func _queue_hit_stiff(target_boss, target_obj) -> void:
	var stiff_seconds := -1.0
	if target_boss != null and target_obj != null:
		var hit_name_value = target_obj.get("hit_name")
		if hit_name_value != null and typeof(target_boss.objattackDic) == TYPE_DICTIONARY:
			var attack_data = target_boss.objattackDic.get(hit_name_value, {})
			if typeof(attack_data) == TYPE_DICTIONARY and attack_data.has("sourceStiffSeconds"):
				stiff_seconds = maxf(float(attack_data["sourceStiffSeconds"]), 0.0)
	_pending_hit_stiff_seconds.append(stiff_seconds)


func attack_to_right(target_boss, target_obj):
	var source_move := _get_source_target_move(target_boss, target_obj)
	if source_move.size() >= 2:
		self.velocity.x = absf(float(source_move[0]))
		self.velocity.y = -absf(float(source_move[1]))
		return
	var hurt_back := _get_monster_hurt_back(target_boss, target_obj)
	if hurt_back.is_empty():
		return
	self.velocity.x = -float(hurt_back[0]) * 25
	self.velocity.y = float(hurt_back[1]) * 15


func attack_to_left(target_boss, target_obj):
	var source_move := _get_source_target_move(target_boss, target_obj)
	if source_move.size() >= 2:
		self.velocity.x = -absf(float(source_move[0]))
		self.velocity.y = -absf(float(source_move[1]))
		return
	var hurt_back := _get_monster_hurt_back(target_boss, target_obj)
	if hurt_back.is_empty():
		return
	self.velocity.x = float(hurt_back[0]) * 25
	self.velocity.y = float(hurt_back[1]) * 15


func _on_skill_in_timeout() -> void:
	pass


func cure_Mp(value: int = 0):
	if RoleProp.roleprop.Mp + value >= RoleProp.roleprop.SMp:
		value = RoleProp.roleprop.SMp - RoleProp.roleprop.Mp
	RoleProp.roleprop.Mp += value
	if value > 0:
		var pp = get_parent().get_parent()
		var po: Vector2
		if PlayerDir:
			po = Vector2(self.position.x - 50, self.position.y - 140)
		else:
			po = Vector2(self.position.x + 30, self.position.y - 140)
		Global.addDamageText(pp, po, value, "CureMp", false, self)


func reduce_Mp(value: int = 0):
	RoleProp.roleprop.Mp -= value
	if value > 0:
		var pp = get_parent().get_parent()
		var po: Vector2
		if PlayerDir:
			po = Vector2(self.position.x - 50, self.position.y - 140)
		else:
			po = Vector2(self.position.x + 30, self.position.y - 140)
		Global.addDamageText(pp, po, value, "ReduceMp", false, self)


func cure_Hp(value: int = 0):
	if SXYRCannotCure:
		return 0
	if RoleProp.roleprop.Hp <= 0:
		return 0
	if get_parent().get_parent() is Level17 or get_parent().get_parent() is Level22 or BloodFix or LifeManaLock:
		return 0

	var max_hp = RoleProp.roleprop.SHp
	var old_hp = RoleProp.roleprop.Hp
	var effective = min(value, max_hp - old_hp)
	var excess = value - effective

	RoleProp.roleprop.Hp += effective
	_apply_pet_turtle_link_heal(int(effective))
	is_CureHp = true
	CureHpValue = int(effective)
	Global.TotalCureHp += int(effective)

	var le = get_parent().get_parent() as BaseLevel
	for i in le.get_node("Monster").get_children():
		if i != null and i is Monster37:
			i.cure_hp(effective * 8)

	if effective > 0:
		var pp = get_parent().get_parent()
		var po: Vector2
		if PlayerDir:
			po = Vector2(self.position.x - 50, self.position.y - 140)
		else:
			po = Vector2(self.position.x + 30, self.position.y - 140)
		Global.addDamageText(pp, po, effective, "cure", is_crit, self)

	return effective


func _pet_turtle_link_unit() -> Node:
	if not has_meta("pet_turtle_link_unit_ref"):
		return null
	var unit_ref = get_meta("pet_turtle_link_unit_ref")
	if not (unit_ref is WeakRef):
		return null
	var until_msec: int = int(get_meta("pet_turtle_link_until_msec")) if has_meta("pet_turtle_link_until_msec") else 0
	if Time.get_ticks_msec() >= until_msec:
		_clear_pet_turtle_link_meta()
		return null
	var unit_value = unit_ref.get_ref()
	if typeof(unit_value) != TYPE_OBJECT or not is_instance_valid(unit_value):
		_clear_pet_turtle_link_meta()
		return null
	var unit := unit_value as Node
	if unit == null or unit.is_queued_for_deletion():
		_clear_pet_turtle_link_meta()
		return null
	var unit_hp = unit.get("Hp")
	if unit_hp == null or int(unit_hp) <= 0:
		_clear_pet_turtle_link_meta()
		return null
	return unit


func _apply_pet_turtle_damage_share(value: int) -> int:
	if value <= 0:
		return value
	var unit := _pet_turtle_link_unit()
	if unit == null or not unit.has_method("receive_linked_damage"):
		return value
	if not has_meta("pet_turtle_link_percent"):
		return value
	var percent := clampi(int(get_meta("pet_turtle_link_percent")), 0, 100)
	if percent <= 0:
		return value
	var requested_share := clampi(int(round(float(value) * float(percent) / 100.0)), 0, value)
	if requested_share <= 0:
		return value
	var actual_share := clampi(int(unit.call("receive_linked_damage", requested_share)), 0, requested_share)
	return maxi(0, value - actual_share)


func _apply_pet_turtle_link_heal(value: int) -> void:
	var skip_heal: bool = (
		bool(get_meta("pet_turtle_skip_link_heal")) if has_meta("pet_turtle_skip_link_heal") else false
	)
	if value <= 0 or skip_heal:
		return
	var unit := _pet_turtle_link_unit()
	if unit != null and unit.has_method("receive_linked_heal"):
		unit.call("receive_linked_heal", value)


func _clear_pet_turtle_link_meta() -> void:
	for key in ["pet_turtle_link_unit_ref", "pet_turtle_link_percent", "pet_turtle_link_until_msec"]:
		if has_meta(key):
			remove_meta(key)


func FBcureHp(value: int):
	if SXYRCannotCure:
		return
	if get_parent().get_parent() is Level17 or get_parent().get_parent() is Level22:
		return
	if RoleProp.roleprop.Hp + value >= RoleProp.roleprop.SHp:
		value = RoleProp.roleprop.SHp - RoleProp.roleprop.Hp
	RoleProp.roleprop.Hp += value
	if value > 0:
		var pp = get_parent().get_parent()
		var po: Vector2
		if PlayerDir:
			po = Vector2(self.position.x - 50, self.position.y - 140)
		else:
			po = Vector2(self.position.x + 30, self.position.y - 140)
		Global.addDamageText(pp, po, value, "cure", is_crit, self)


func _on_spontaneous_recovery_timeout() -> void:
	ran_num = randi_range(0, 100)
	if RoleProp.roleprop.Hp <= 0:
		return
	if get_parent().get_parent() is Level17 or get_parent().get_parent() is Level22 or BloodFix or LifeManaLock:
		return
	if CureValue >= 4:
		CureValue = 4

	if RoleProp.roleprop.Hp < RoleProp.roleprop.SHp and RoleProp.roleprop.Hp > 0:
		if not SXYRCannotCure:
			Global.TotalCureHp += int(RoleProp.roleprop.R_hp * CureValue)
			RoleProp.roleprop.Hp += int(RoleProp.roleprop.R_hp * CureValue)

	if RoleProp.roleprop.Mp < RoleProp.roleprop.SMp:
		var has_magic_drain_buff = false
		if self.buff != null:
			for i in self.buff.get_children():
				if i != null and i.BuffInfo["Name"] == "MagicDrain":
					has_magic_drain_buff = true
					break

		if has_magic_drain_buff:
			pass
		else:
			RoleProp.roleprop.Mp += RoleProp.roleprop.R_mp

			IsMagicDrain = false


func get_need_mp(skill_name, bool_):
	if not bool_:
		match skill_name:
			"slz":
				return 10 + ((3 + 2 * (get_SkillLevel(1) - 1)) * (get_SkillLevel(1) - 1))
			"hytj":
				return 8 + ((3 + 2 * (get_SkillLevel(2) - 1)) * (get_SkillLevel(2) - 1))
			"lys":
				return 12 + ((4 + 2 * (get_SkillLevel(3) - 1)) * (get_SkillLevel(3) - 1))
			"lyfb":
				return 35 + ((6 + 2 * (get_SkillLevel(4) - 1)) * (get_SkillLevel(4) - 1))
			"hmz":
				return 35 + ((3 + 3 * (get_SkillLevel(5) - 1)) * (get_SkillLevel(5) - 1))
			"hmz_ws":
				return 35 + ((3 + 3 * (get_SkillLevel(12) - 1)) * (get_SkillLevel(12) - 1))
			"hyjj_ws":
				return 45 + ((4 + 3 * (get_SkillLevel(13) - 1)) * (get_SkillLevel(13) - 1))
			"zz":
				return 12 + ((4 + 2 * (get_SkillLevel(6) - 1)) * (get_SkillLevel(6) - 1))
			"gsrs":
				return 12 + ((4 + 2 * (get_SkillLevel(11) - 1)) * (get_SkillLevel(11) - 1))
			"qsez":
				return 10 + ((8 + 2 * (get_SkillLevel(7) - 1)) * (get_SkillLevel(7) - 1))
			"jdy":
				return 10 + ((8 + 2 * (get_SkillLevel(8) - 1)) * (get_SkillLevel(8) - 1))
			"hyjj":
				return 22 + ((8 + 2 * (get_SkillLevel(9) - 1)) * (get_SkillLevel(9) - 1))
			"blb":
				return 15 + ((3 + 2 * (get_SkillLevel(1) - 1)) * (get_SkillLevel(1) - 1))
			"xbz":
				return 25 + ((3 + 2 * (get_SkillLevel(2) - 1)) * (get_SkillLevel(2) - 1))
			"tjgl":
				return 35 + ((3 + 2 * (get_SkillLevel(4) - 1)) * (get_SkillLevel(4) - 1))
			"shy":
				return 30 + ((3 + 2 * (get_SkillLevel(3) - 1)) * (get_SkillLevel(3) - 1))
			"smb":
				return 60 + ((3 + 3 * (get_SkillLevel(5) - 1)) * (get_SkillLevel(5) - 1))
			"myhc":
				return 35 + ((3 + 2 * (get_SkillLevel(7) - 1)) * (get_SkillLevel(7) - 1))
			"sgq":
				return 40 + ((3 + 3 * (get_SkillLevel(6) - 1)) * (get_SkillLevel(6) - 1))
			"jgz":
				return 40 + ((3 + 3 * (get_SkillLevel(8) - 1)) * (get_SkillLevel(8) - 1))
			"jhsj":
				return 60 + ((3 + 3 * (get_SkillLevel(9) - 1)) * (get_SkillLevel(9) - 1))
			"by":
				return 55 + ((3 + 3 * (get_SkillLevel(11) - 1)) * (get_SkillLevel(11) - 1))
			"zfjg":
				return 80 + ((3 + 3 * (get_SkillLevel(12) - 1)) * (get_SkillLevel(12) - 1))
			"ssp":
				return 10 + ((2 + 2 * (get_SkillLevel(1) - 1)) * (get_SkillLevel(1) - 1))
			"dj":
				return 10 + ((3 + 2 * (get_SkillLevel(2) - 1)) * (get_SkillLevel(2) - 1))
			"dgq":
				return 15 + ((3 + 2 * (get_SkillLevel(3) - 1)) * (get_SkillLevel(3) - 1))
			"zznh":
				return 10 + ((3 + 2 * (get_SkillLevel(4) - 1)) * (get_SkillLevel(4) - 1))
			"tmc":
				return 40 + ((3 + 2 * (get_SkillLevel(5) - 1)) * (get_SkillLevel(5) - 1))
			"sd":
				return 10 + ((3 + 2 * (get_SkillLevel(6) - 1)) * (get_SkillLevel(6) - 1))
			"jsp":
				return 20 + ((3 + 2 * (get_SkillLevel(7) - 1)) * (get_SkillLevel(7) - 1))
			"xgq":
				return 20 + ((3 + 2 * (get_SkillLevel(8) - 1)) * (get_SkillLevel(8) - 1))
			"syzq":
				return 20 + ((3 + 2 * (get_SkillLevel(9) - 1)) * (get_SkillLevel(9) - 1))
			"bdqk":
				return 50 + ((3 + 3 * (get_SkillLevel(12) - 1)) * (get_SkillLevel(12) - 1))

			"qlj":
				return 15 + ((2 + 2 * (get_SkillLevel(1) - 1)) * (get_SkillLevel(1) - 1))
			"dcj":
				return 15 + ((3 + 2 * (get_SkillLevel(2) - 1)) * (get_SkillLevel(2) - 1))
			"wdzt":
				return 15 + ((3 + 2 * (get_SkillLevel(3) - 1)) * (get_SkillLevel(3) - 1))
			"tkj":
				return 15 + ((3 + 2 * (get_SkillLevel(4) - 1)) * (get_SkillLevel(4) - 1))
			"mmw":
				return 25 + ((3 + 2 * (get_SkillLevel(5) - 1)) * (get_SkillLevel(5) - 1))
			"jdz":
				return 20 + ((3 + 2 * (get_SkillLevel(6) - 1)) * (get_SkillLevel(6) - 1))
			"lhsq":
				return 20 + ((3 + 2 * (get_SkillLevel(7) - 1)) * (get_SkillLevel(7) - 1))
			"zq":
				return 20 + ((3 + 2 * (get_SkillLevel(8) - 1)) * (get_SkillLevel(8) - 1))
			"wdww":
				return 10 + ((3 + 2 * (get_SkillLevel(9) - 1)) * (get_SkillLevel(9) - 1))
			"bylt":
				return 55 + ((3 + 3 * (get_SkillLevel(11) - 1)) * (get_SkillLevel(11) - 1))
			"cmly":
				return 55 + ((3 + 3 * (get_SkillLevel(12) - 1)) * (get_SkillLevel(12) - 1))

			"xyq":
				return 15 + ((2 + 2 * (get_SkillLevel(1) - 1)) * (get_SkillLevel(1) - 1))
			"slq":
				return 20 + ((3 + 2 * (get_SkillLevel(2) - 1)) * (get_SkillLevel(2) - 1))
			"blq":
				return 20 + ((3 + 2 * (get_SkillLevel(3) - 1)) * (get_SkillLevel(3) - 1))
			"fhf":
				return 20 + ((3 + 2 * (get_SkillLevel(4) - 1)) * (get_SkillLevel(4) - 1))
			"ltjz":
				return 50 + ((3 + 3 * (get_SkillLevel(11) - 1)) * (get_SkillLevel(11) - 1))
			"cxq":
				return 25 + ((3 + 2 * (get_SkillLevel(5) - 1)) * (get_SkillLevel(5) - 1))
			"llrd":
				return 30 + ((3 + 2 * (get_SkillLevel(6) - 1)) * (get_SkillLevel(6) - 1))
			"lljy":
				return 40 + ((3 + 2 * (get_SkillLevel(7) - 1)) * (get_SkillLevel(7) - 1))
			"ygth":
				return 40 + ((3 + 2 * (get_SkillLevel(8) - 1)) * (get_SkillLevel(8) - 1))
			"tllz":
				return 40 + ((3 + 2 * (get_SkillLevel(9) - 1)) * (get_SkillLevel(9) - 1))
			"":
				return 0
	else:
		match skill_name:
			"slz":
				return 10 + ((3 + 2 * (get_SkillLevel(1))) * (get_SkillLevel(1)))
			"hytj":
				return 8 + ((3 + 2 * (get_SkillLevel(2))) * (get_SkillLevel(2)))
			"lys":
				return 12 + ((4 + 2 * (get_SkillLevel(3))) * (get_SkillLevel(3)))
			"lyfb":
				return 35 + ((6 + 2 * (get_SkillLevel(4))) * (get_SkillLevel(4)))
			"hmz":
				return 35 + ((3 + 3 * (get_SkillLevel(5))) * (get_SkillLevel(5)))
			"hmz_ws":
				return 35 + ((3 + 3 * (get_SkillLevel(12))) * (get_SkillLevel(12)))
			"hyjj_ws":
				return 45 + ((4 + 3 * (get_SkillLevel(13))) * (get_SkillLevel(13)))
			"zz":
				return 12 + ((4 + 2 * (get_SkillLevel(6))) * (get_SkillLevel(6)))
			"gsrs":
				return 12 + ((4 + 2 * (get_SkillLevel(11))) * (get_SkillLevel(11)))
			"qsez":
				return 10 + ((8 + 2 * (get_SkillLevel(7))) * (get_SkillLevel(7)))
			"jdy":
				return 10 + ((8 + 2 * (get_SkillLevel(8))) * (get_SkillLevel(8)))
			"hyjj":
				return 22 + ((8 + 2 * (get_SkillLevel(9))) * (get_SkillLevel(9)))
			"blb":
				return 15 + ((3 + 2 * (get_SkillLevel(1))) * (get_SkillLevel(1)))
			"xbz":
				return 25 + ((3 + 2 * (get_SkillLevel(2))) * (get_SkillLevel(2)))
			"tjgl":
				return 35 + ((3 + 2 * (get_SkillLevel(4))) * (get_SkillLevel(4)))
			"shy":
				return 30 + ((3 + 2 * (get_SkillLevel(3))) * (get_SkillLevel(3)))
			"smb":
				return 60 + ((3 + 3 * (get_SkillLevel(5))) * (get_SkillLevel(5)))
			"myhc":
				return 35 + ((3 + 2 * (get_SkillLevel(7))) * (get_SkillLevel(7)))
			"sgq":
				return 40 + ((3 + 3 * (get_SkillLevel(6))) * (get_SkillLevel(6)))
			"jgz":
				return 40 + ((3 + 3 * (get_SkillLevel(8))) * (get_SkillLevel(8)))
			"jhsj":
				return 60 + ((3 + 3 * (get_SkillLevel(9))) * (get_SkillLevel(9)))
			"by":
				return 55 + ((3 + 3 * (get_SkillLevel(11))) * (get_SkillLevel(11)))
			"zfjg":
				return 80 + ((3 + 3 * (get_SkillLevel(12))) * (get_SkillLevel(12)))
			"ssp":
				return 10 + ((2 + 2 * (get_SkillLevel(1))) * (get_SkillLevel(1)))
			"dj":
				return 10 + ((3 + 2 * (get_SkillLevel(2))) * (get_SkillLevel(2)))
			"dgq":
				return 15 + ((3 + 2 * (get_SkillLevel(3))) * (get_SkillLevel(3)))
			"zznh":
				return 10 + ((3 + 2 * (get_SkillLevel(4))) * (get_SkillLevel(4)))
			"tmc":
				return 40 + ((3 + 2 * (get_SkillLevel(5))) * (get_SkillLevel(5)))
			"sd":
				return 10 + ((3 + 2 * (get_SkillLevel(6))) * (get_SkillLevel(6)))
			"jsp":
				return 20 + ((3 + 2 * (get_SkillLevel(7))) * (get_SkillLevel(7)))
			"xgq":
				return 20 + ((3 + 2 * (get_SkillLevel(8))) * (get_SkillLevel(8)))
			"syzq":
				return 20 + ((3 + 2 * (get_SkillLevel(9))) * (get_SkillLevel(9)))
			"bdqk":
				return 50 + ((3 + 3 * (get_SkillLevel(12))) * (get_SkillLevel(12)))

			"qlj":
				return 15 + ((2 + 2 * (get_SkillLevel(1))) * (get_SkillLevel(1)))
			"dcj":
				return 15 + ((3 + 2 * (get_SkillLevel(2))) * (get_SkillLevel(2)))
			"wdzt":
				return 15 + ((3 + 2 * (get_SkillLevel(3))) * (get_SkillLevel(3)))
			"tkj":
				return 15 + ((3 + 2 * (get_SkillLevel(4))) * (get_SkillLevel(4)))
			"mmw":
				return 25 + ((3 + 2 * (get_SkillLevel(5))) * (get_SkillLevel(5)))
			"jdz":
				return 20 + ((3 + 2 * (get_SkillLevel(6))) * (get_SkillLevel(6)))
			"lhsq":
				return 20 + ((3 + 2 * (get_SkillLevel(7))) * (get_SkillLevel(7)))
			"zq":
				return 20 + ((3 + 2 * (get_SkillLevel(8))) * (get_SkillLevel(8)))
			"wdww":
				return 10 + ((3 + 2 * (get_SkillLevel(9))) * (get_SkillLevel(9)))
			"bylt":
				return 55 + ((3 + 3 * (get_SkillLevel(11))) * (get_SkillLevel(11)))
			"cmly":
				return 55 + ((3 + 3 * (get_SkillLevel(12))) * (get_SkillLevel(12)))

			"xyq":
				return 15 + ((2 + 2 * (get_SkillLevel(1))) * (get_SkillLevel(1)))
			"slq":
				return 20 + ((3 + 2 * (get_SkillLevel(2))) * (get_SkillLevel(2)))
			"blq":
				return 20 + ((3 + 2 * (get_SkillLevel(3))) * (get_SkillLevel(3)))
			"fhf":
				return 20 + ((3 + 2 * (get_SkillLevel(4))) * (get_SkillLevel(4)))
			"ltjz":
				return 50 + ((3 + 3 * (get_SkillLevel(11))) * (get_SkillLevel(11)))
			"cxq":
				return 25 + ((3 + 2 * (get_SkillLevel(5))) * (get_SkillLevel(5)))
			"llrd":
				return 30 + ((3 + 2 * (get_SkillLevel(6))) * (get_SkillLevel(6)))
			"lljy":
				return 40 + ((3 + 2 * (get_SkillLevel(7))) * (get_SkillLevel(7)))
			"ygth":
				return 40 + ((3 + 2 * (get_SkillLevel(8))) * (get_SkillLevel(8)))
			"tllz":
				return 40 + ((3 + 2 * (get_SkillLevel(9))) * (get_SkillLevel(9)))
			"":
				return 0
	return 0


func get_SkillLevel(num):
	return PlayerData.player_data["技能学习"]["技能" + str(num)]["等级"]


func death():
	return RoleProp.roleprop.Hp <= 0


func addMagicWeapon():
	if is_instance_valid(Mgtarget) and not Mgtarget.is_queued_for_deletion():
		return
	Mgtarget = null
	if str(PlayerData.player_data.get("实战法宝", "")) in PlayerData.RETIRED_WUDU_MAGIC_WEAPONS:
		PlayerData.player_data["实战法宝"] = ""
	if PlayerData.player_data["法宝"].size() != 0:
		var name1 = PlayerData.player_data["实战法宝"]
		if name1 != "":
			var parent = get_parent().get_parent()
			Mgtarget = Global.addMagicWeapon(parent, name1, Vector2(0, 0))
			if Mgtarget != null and Mgtarget.has_method("set_magic_weapon_player"):
				Mgtarget.set_magic_weapon_player(self)
			else:
				if Mgtarget != null:
					Mgtarget.queue_free()
				Mgtarget = null
		else:
			PlayerData.player_data["实战法宝"] = PlayerData.player_data["法宝"][0]["名字"]
			var parent = get_parent().get_parent()
			Mgtarget = Global.addMagicWeapon(parent, PlayerData.player_data["实战法宝"], Vector2(0, 0))
			if Mgtarget != null and Mgtarget.has_method("set_magic_weapon_player"):
				Mgtarget.set_magic_weapon_player(self)
			else:
				if Mgtarget != null:
					Mgtarget.queue_free()
				Mgtarget = null
	else:
		if Mgtarget != null:
			Mgtarget.queue_free()


func add_WSEffect():
	spawn_ws_effect(action, get_parent())


func _on_ws_timer_timeout() -> void:
	add_WSEffect()


func _add_role_protect(value: float) -> bool:
	if value <= 0.0 or IsDeath or needProtect:
		return needProtect
	CurrentProtect = clampf(CurrentProtect + value, 0.0, MaxProtect)
	if CurrentProtect >= MaxProtect:
		_activate_role_protect()
	return needProtect


func _activate_role_protect() -> void:
	if IsDeath or needProtect:
		return
	CurrentProtect = MaxProtect
	needProtect = true
	need_removeProtect = true
	_cancel_hit_reaction()
	_set_protect_visual(true)
	$Protect.start(3.0)


func _clear_role_protect() -> void:
	needProtect = false
	need_removeProtect = false
	CurrentProtect = 0.0
	_set_protect_visual(false)


func selfProtect():
	CurrentProtect = clampf(CurrentProtect, 0.0, MaxProtect)
	if not needProtect and CurrentProtect >= MaxProtect:
		_activate_role_protect()
		return
	if needProtect:
		_set_protect_visual(true)
		if $Protect.is_stopped():
			_clear_role_protect()
			return
		CurrentProtect = maxf(0.0, CurrentProtect - 1.0)
	else:
		CurrentProtect = maxf(0.0, CurrentProtect - 0.05)


func _on_protect_timeout() -> void:
	_clear_role_protect()


var _protect_visual_active := false


func _set_protect_visual(active: bool) -> void:
	if is_instance_valid(MyHurtBox):
		MyHurtBox.set_deferred("disabled", active)
	_protect_visual_active = active
	var alpha := 0.5 if active else 1.0
	if is_instance_valid(RoleBody):
		RoleBody.self_modulate = Color(1, 1, 1, alpha)
	if is_instance_valid(RoleEq):
		RoleEq.self_modulate = Color(1, 1, 1, alpha)


func onEqchange():
	var WQ: String
	var Fj: String
	if PlayerData.player_data["幻化列表"]["武器"] == "":
		if PlayerData.player_data["武器"].size() == 0:
			WQ = "Empty"
		else:
			WQ = str(PlayerData.player_data["武器"][0]["名字"])
	else:
		WQ = str(PlayerData.player_data["幻化列表"]["武器"])
	ChangeEq(WQ)
	if PlayerData.player_data["幻化列表"]["防具"] == "":
		if PlayerData.player_data["时装"].size() == 0:
			if PlayerData.player_data["防具"].size() == 0:
				Fj = "Empty"
			else:
				Fj = str(PlayerData.player_data["防具"][0]["名字"])
		else:
			Fj = str(PlayerData.player_data["时装"][0]["名字"])
	else:
		Fj = str(PlayerData.player_data["幻化列表"]["防具"])
	Fj = Global.GetName(Fj)

	ChangeBody(Fj)
	var mount_runtime := get_node_or_null("MountRuntime")
	if mount_runtime != null and mount_runtime.has_method("refresh_rider_appearance"):
		mount_runtime.call("refresh_rider_appearance")
	AddSpecialEffectClothes(WQ, Fj)
	var WingsList
	if PlayerData.player_data["幻化列表"]["翅膀"] == "":
		if PlayerData.player_data["翅膀"].size() == 0:
			wings.visible = false
			WingsList = "empty"
		else:
			WingsList = PlayerData.player_data["翅膀"][0]["名字"]
	else:
		WingsList = PlayerData.player_data["幻化列表"]["翅膀"]
	var show_wings: bool = (
		WingsList != "empty"
		and bool(PlayerData.player_data.get("翅膀显示", true))
		and not bool(MainSet.set_data.get("NotShowRoleBody", false))
	)
	wings.visible = show_wings
	wings.modulate = Color.WHITE if show_wings else Color(1, 1, 1, 0)
	if not show_wings:
		wings.stop()
		return
	if WingsList == "xyzy":
		_ensure_xianyu_wing_animation()
	elif WingsList == "hhyq":
		_ensure_huahao_wing_animation()

	_set_xianyu_wing_flip_tracks(false)
	_set_static_wing_animation_tracks(WingsList == "hhyq" or WingsList == "xyzy")
	wings.flip_h = WingsList == "xyzy" or WingsList == "hhyq"
	wings.z_index = 0
	wings.play(WingsList)
	_last_wings_name = ""
	SetWingsOffset()


func _capture_wings_base_transform() -> void:
	if wings == null or _wings_base_transform_initialized:
		return
	_wings_base_position = wings.position
	_wings_base_offset = wings.offset
	_wings_base_rotation = wings.rotation
	_wings_base_scale = wings.scale
	_wings_base_flip_h = wings.flip_h
	_wings_base_transform_initialized = true


func _scan_late_static_wing_tracks() -> void:
	if not is_inside_tree():
		return
	var current_wings_name := ""
	var transmog_data: Variant = PlayerData.player_data.get("幻化列表", {})
	var transmog_wings := str(transmog_data.get("翅膀", "")) if transmog_data is Dictionary else ""
	if transmog_wings != "":
		current_wings_name = transmog_wings
	elif PlayerData.player_data.get("翅膀", []).size() > 0:
		current_wings_name = str(PlayerData.player_data["翅膀"][0].get("名字", ""))
	_set_static_wing_animation_tracks(current_wings_name == "hhyq" or current_wings_name == "xyzy")


func _reset_wings_base_transform() -> void:
	_capture_wings_base_transform()
	wings.position = _wings_base_position
	wings.offset = _wings_base_offset
	wings.rotation = _wings_base_rotation
	wings.scale = _wings_base_scale
	wings.flip_h = _wings_base_flip_h


func _set_static_wing_animation_tracks(disabled: bool) -> void:
	if role_action_player == null:
		return
	if disabled == _static_wing_tracks_disabled:
		if not disabled:
			return

		for library_name in role_action_player.get_animation_library_list():
			var library: AnimationLibrary = role_action_player.get_animation_library(library_name)
			if library == null:
				continue
			for animation_name in library.get_animation_list():
				var animation: Animation = library.get_animation(animation_name)
				if animation == null:
					continue
				for track_index in animation.get_track_count():
					var track_path := str(animation.track_get_path(track_index))
					if not _is_wing_transform_track(track_path) or not animation.track_is_enabled(track_index):
						continue
					var known_track := false
					for state in _static_wing_track_states:
						if state.get("animation") == animation and int(state.get("track_index", -1)) == track_index:
							known_track = true
							break
					if known_track:
						continue
					(
						_static_wing_track_states
						. append(
							{
								"animation": animation,
								"track_index": track_index,
								"enabled": true,
							}
						)
					)
					animation.track_set_enabled(track_index, false)
		return
	if disabled:
		_static_wing_track_states.clear()
		for library_name in role_action_player.get_animation_library_list():
			var library: AnimationLibrary = role_action_player.get_animation_library(library_name)
			if library == null:
				continue
			for animation_name in library.get_animation_list():
				var animation: Animation = library.get_animation(animation_name)
				if animation == null:
					continue
				for track_index in animation.get_track_count():
					var track_path := str(animation.track_get_path(track_index))
					if _is_wing_transform_track(track_path):
						(
							_static_wing_track_states
							. append(
								{
									"animation": animation,
									"track_index": track_index,
									"enabled": animation.track_is_enabled(track_index),
								}
							)
						)
						animation.track_set_enabled(track_index, false)
		_static_wing_tracks_disabled = true
		return
	for state in _static_wing_track_states:
		var animation: Animation = state.get("animation")
		if animation != null:
			animation.track_set_enabled(int(state.get("track_index", -1)), bool(state.get("enabled", true)))
	_static_wing_track_states.clear()
	_static_wing_tracks_disabled = false


func _is_wing_transform_track(track_path: String) -> bool:
	return (
		track_path.ends_with("Action/Wings:position")
		or track_path.ends_with("Action/Wings:offset")
		or track_path.ends_with("Action/Wings:rotation")
		or track_path.ends_with("Action/Wings:flip_h")
	)


func _set_xianyu_wing_flip_tracks(disabled: bool) -> void:
	if role_action_player == null or disabled == _xyzy_wing_flip_tracks_disabled:
		return
	if disabled:
		_xyzy_wing_flip_track_states.clear()
		for library_name in role_action_player.get_animation_library_list():
			var library: AnimationLibrary = role_action_player.get_animation_library(library_name)
			if library == null:
				continue
			for animation_name in library.get_animation_list():
				var animation: Animation = library.get_animation(animation_name)
				if animation == null:
					continue
				for track_index in animation.get_track_count():
					var track_path := str(animation.track_get_path(track_index))
					if not track_path.ends_with("Action/Wings:flip_h"):
						continue
					(
						_xyzy_wing_flip_track_states
						. append(
							{
								"animation": animation,
								"track_index": track_index,
								"enabled": animation.track_is_enabled(track_index),
							}
						)
					)
					animation.track_set_enabled(track_index, false)
		_xyzy_wing_flip_tracks_disabled = true
		return
	for state in _xyzy_wing_flip_track_states:
		var animation: Animation = state.get("animation")
		if animation != null:
			animation.track_set_enabled(int(state.get("track_index", -1)), bool(state.get("enabled", true)))
	_xyzy_wing_flip_track_states.clear()
	_xyzy_wing_flip_tracks_disabled = false


func _ensure_xianyu_wing_animation() -> void:
	if wings == null or wings.sprite_frames == null or wings.sprite_frames.has_animation(&"xyzy"):
		return
	var role_script := get_script() as Script
	var role_script_path := role_script.resource_path if role_script != null else ""
	var wing_path := str(XIANYU_WING_PATHS.get(role_script_path, ""))
	var source_frames := load(wing_path) as SpriteFrames if wing_path != "" else null
	if source_frames == null or not source_frames.has_animation(&"xyzy"):
		return
	var target_frames := wings.sprite_frames
	target_frames.add_animation(&"xyzy")
	target_frames.set_animation_loop(&"xyzy", source_frames.get_animation_loop(&"xyzy"))
	target_frames.set_animation_speed(&"xyzy", source_frames.get_animation_speed(&"xyzy"))
	for frame_index in source_frames.get_frame_count(&"xyzy"):
		target_frames.add_frame(
			&"xyzy",
			source_frames.get_frame_texture(&"xyzy", frame_index),
			source_frames.get_frame_duration(&"xyzy", frame_index)
		)


func _ensure_huahao_wing_animation() -> void:
	if wings == null or wings.sprite_frames == null or wings.sprite_frames.has_animation(&"hhyq"):
		return
	var target_frames := wings.sprite_frames
	target_frames.add_animation(&"hhyq")
	target_frames.set_animation_loop(&"hhyq", true)
	target_frames.set_animation_speed(&"hhyq", 30.0)
	for frame_index in range(1, 41):
		var texture := load("%s/%d.png" % [HUAHAO_WING_FRAME_DIR, frame_index]) as Texture2D
		if texture != null:
			target_frames.add_frame(&"hhyq", texture)


func ChangeBody(name1):
	self.RoleBody.texture = Global.LoadRole1Body(name1)
	preload("res://Script/Hero/MoonPalaceClothesEffect.gd").sync(RoleBody, str(name1), true)


func ChangeEq(name1):
	self.RoleEq.texture = Global.LoadRole1EQ(name1)


func AddSpecialEffectClothes(EqName, ClothesName):
	var Lastname = EqName + ClothesName
	var BodyList = [toukui, jianjia, huwan, shenti, yaodai, xiabai]
	match Lastname:
		"zxstgzxstj":
			for i in BodyList:
				if i != null:
					i.play("zxstj")
					i.offset = Vector2(0, 0)
			wuqi.play("zxstg")
			wuqi.offset = Vector2(0, 0)
			wuqi.scale = Vector2(0.87, 0.87)
			return
		"pftygpftyj":
			for i in BodyList:
				if i != null:
					i.play("pftyj")
					match str(i.name):
						"toukui":
							i.offset = Vector2(3, -15)
							continue
						"jianjia":
							i.offset = Vector2(15, 0)
							continue
						"shenti":
							i.offset = Vector2(-25, -20)
							continue
					i.offset = Vector2(0, 0)

			wuqi.play("pftyg")
			wuqi.offset = Vector2(3, 0)
			wuqi.scale = Vector2(0.87, 0.87)
			return
		"slshgslshj":
			for i in BodyList:
				if i != null:
					i.play("slshj")
					match str(i.name):
						"toukui":
							i.offset = Vector2(3, -15)
							continue
						"jianjia":
							i.offset = Vector2(15, 10)
							continue
						"xiabai":
							i.offset = Vector2(0, -10)
							continue
					i.offset = Vector2(0, 0)

			wuqi.play("slshg")
			wuqi.offset = Vector2(0, 0)
			wuqi.scale = Vector2(1, 1)
			return
	for i in effect_body.get_children():
		if i != null:
			i.play("Empty")


func _on_hit_box_area_entered(area: Area2D) -> void:
	if objattackDic.has(get_action):
		if objattackDic[get_action].has("addeffect"):
			var Monster = area.get_parent().get_parent()
			if Monster != null:
				if Monster is BaseMonster and not _is_summon_or_pet_target(Monster):
					if self is role4:
						if objattackDic[get_action]["addeffect"]["Name"] == "Voodoo":
							if Global.CheckWD(Monster) < 10:
								Global.AddBuff(Monster.buff, objattackDic[get_action]["addeffect"])
						else:
							Global.AddBuff(Monster.buff, objattackDic[get_action]["addeffect"])
					else:
						Global.AddBuff(Monster.buff, objattackDic[get_action]["addeffect"])
	if self is role1:
		if get_action == "qsez":
			velocity.x = 0
			Global.addSound_(self, "res://Music/Hero/27_Role1_hit13_2.mp3")
			if not is_call:
				is_call = true
				var pp = [
					Vector2(self.position.x, self.position.y),
					Vector2(self.position.x - 30, self.position.y),
					Vector2(self.position.x, self.position.y + 30),
					Vector2(self.position.x + 30, self.position.y),
					Vector2(self.position.x, self.position.y - 30)
				]
				for i in range(5):
					if randi_range(0, 100) < 50:
						Global.addRoleBullet_1_safe(self.Bullet, pp[i], "qsez", self.objattackDic["qsez"])
					else:
						Global.addRoleBullet_1_safe(self.Bullet, pp[i], "qsez_1", self.objattackDic["qsez"])
					await get_tree().create_timer(0.08, false).timeout


func _is_summon_or_pet_target(target: Node) -> bool:
	if target == null or not is_instance_valid(target):
		return true
	var is_tiger: bool = bool(target.get_meta("pet_tiger_unit")) if target.has_meta("pet_tiger_unit") else false
	var is_sum: bool = bool(target.get_meta("is_summon")) if target.has_meta("is_summon") else false
	if is_tiger or is_sum:
		return true
	if target.has_method("get") and target.get("is_summon") == true:
		return true
	return false


func checkMonster(get_tt):
	if not is_instance_valid(get_tt):
		return null

	var node = get_tt
	var depth := 0
	while node != null and is_instance_valid(node) and depth < 10:
		if node is BaseMonster:
			return null if _is_summon_or_pet_target(node) else node
		node = node.get_parent()
		depth += 1

	return null


func get_RealTarget(get_tt):
	return get_tt.get_parent().get_parent()


func CheckAddBuff():
	var not_SanXianHuTi = true
	var not_ReverseMove = true
	var not_magic_drain = true
	var not_yxbuff = true
	var not_lljy = true
	var not_ice = true
	var not_dl = true
	var not_eyefix = true
	var not_stun = true
	var not_sppeddown = true
	var not_silent = true
	var not_BoundFloor = true
	var not_Immobilize = true
	var not_BloodFix = true
	var not_LifeManaLock = true
	var not_DefeReduce = true
	var not_Scary = true
	var not_SuperArmor = true
	var not_Indestructible = true
	var not_Indestructible1 = true
	var not_DoubleFallPro = true
	var not_IsWDZT = true
	var not_slz = true
	var not_tsz = true
	var not_NoDeBuff = true
	var not_Xr = true
	if self.buff == null:
		return

	var buff_child_count := self.buff.get_child_count()
	var buff_child_index := 0
	while buff_child_index < buff_child_count:
		var i = self.buff.get_child(buff_child_index)
		buff_child_index += 1
		if i != null:
			var buff_info: Dictionary = i.BuffInfo
			match str(buff_info["Name"]):
				"SanXianHuTi":
					not_SanXianHuTi = false
				"ReverseMove":
					IsReverseMove = true
					ReverseMoveSpeedMultiplier = 2.0
					not_ReverseMove = false
				"yxbuff":
					IsYxBuff = true
					var bonus_rate = buff_info.get("value", 0.5)
					YxBuffPowerRate = bonus_rate
					YxBuffCritRate = bonus_rate
					YxBuffLuckyRate = bonus_rate
					not_yxbuff = false
				"MagicDrain":
					IsMagicDrain = true
					StoredMP = buff_info.get("stored_mp", 0)
					not_magic_drain = false
				"lljybuff":
					Islljy = true
					not_lljy = false
				"NoDeBuff":
					NoDeBuff = true
					not_NoDeBuff = false
				"lpzbuff":
					IsXr = true
					not_Xr = false
				"tszbuff":
					Istsz = true
					not_tsz = false
				"slzbuff":
					Isslz = true
					not_slz = false
				"Ice":
					is_ice = true
					not_ice = false
				"PoisionBody":
					IsWDZT = true
					not_IsWDZT = false
				"SuperArmor":
					IsSuperArmor = true
					not_SuperArmor = false
				"DoubleFallPro":
					IsDoubleFallPro = true
					not_DoubleFallPro = false
				"DefeReduce":
					IsDefeReduce = true
					not_DefeReduce = false
				"Indestructible":
					IsIndestructible = true
					not_Indestructible = false
				"Indestructible1":
					IsIndestructible1 = true
					not_Indestructible1 = false
				"DeadLink":
					is_DeadLink = true
					not_dl = false
				"EyeFix":
					is_EyeFix = true
					not_eyefix = false
				"Immobilize":
					is_Immobilize = true
					not_Immobilize = false
				"stun":
					is_stun = true
					not_stun = false
				"speed_down":
					is_speedDown = true
					not_sppeddown = false
				"BloodFix":
					BloodFix = true
					not_BloodFix = false
				"LifeManaLock":
					LifeManaLock = true
					not_LifeManaLock = false
				"silent":
					is_silent = true
					not_silent = false
				"Boundground":
					is_Bound_to_the_ground = true
					not_BoundFloor = false
				"Scary":
					IsScary = true
					not_Scary = false

	if not_ReverseMove:
		IsReverseMove = false
		ReverseMoveSpeedMultiplier = 1.0

	if not_magic_drain:
		IsMagicDrain = false
		StoredMP = 0

	if not_yxbuff:
		IsYxBuff = false
		YxBuffPowerRate = 0.0
		YxBuffCritRate = 0.0
		YxBuffLuckyRate = 0.0

	if not_lljy:
		Islljy = false

	if not_Xr:
		IsXr = false
		xrbl = 0
	if not_NoDeBuff:
		NoDeBuff = false
	if not_tsz:
		Istsz = false
		tszzs = 0
	if not_slz:
		Isslz = false
		slzjs2 = 0
	if not_IsWDZT:
		IsWDZT = false
	if not_DoubleFallPro:
		IsDoubleFallPro = false
	if not_Indestructible:
		IsIndestructible = false
	if not_Indestructible1:
		IsIndestructible1 = false
	if not_SuperArmor:
		IsSuperArmor = _skill_super_armor_active()
	if not_DefeReduce:
		IsDefeReduce = false
		DefeReduce = 0
	if not_Scary:
		IsScary = false
	if not_BloodFix:
		BloodFix = false
	if not_LifeManaLock:
		LifeManaLock = false
	if not_BoundFloor:
		is_Bound_to_the_ground = false
	if not_silent:
		is_silent = false
	if not_ice:
		is_ice = false
	if not_dl:
		is_DeadLink = false
	if not_eyefix:
		is_EyeFix = false
	if not_stun:
		is_stun = false
	if not_Immobilize:
		is_Immobilize = false
	if not_sppeddown:
		is_speedDown = false
		walk_speed = _fabao_jiasu_base_speed * 2 if is_fabao_jiasu else 240
	if buff.get_child_count() == 0:
		is_speedDown = false
		walk_speed = _fabao_jiasu_base_speed * 2 if is_fabao_jiasu else 240
		is_stun = false
		is_EyeFix = false
		is_ice = false
		is_DeadLink = false
		is_silent = false
		is_Bound_to_the_ground = false
		IsReverseMove = false


func get_skill(name1):
	name1 = str(name1)
	var raw_skill_name = name1
	if is_silent or not is_inside_tree() or is_queued_for_deletion():
		return
	var scene_parent := get_parent()
	if scene_parent == null or not is_instance_valid(scene_parent):
		return
	var level := scene_parent.get_parent()
	if level == null or not is_instance_valid(level) or level.is_queued_for_deletion():
		return
	if level is Level17 or level is Level22:
		return
	if name1 == "":
		return
	var cooldown_key: String = name1
	if name1 == "jdy2":
		cooldown_key = "jdy"
	elif name1 == "tmc2":
		cooldown_key = "tmc"
	if not Role1SkillInter.has(cooldown_key):
		push_warning("忽略未知角色技能：%s" % raw_skill_name)
		return
	if self is role1:
		var IsCanUseSlz = false
		if name1 == "slz":
			for i in PlayerData.player_data["技能学习"]["技能键位"]:
				if str(PlayerData.player_data["技能学习"]["技能键位"][i]) == "slz":
					IsCanUseSlz = true
			if not IsCanUseSlz:
				return
		if name1 == "hyjj":
			if not checkCanuseSomeSkill():
				return
		if RoleProp.roleprop.Mp >= get_need_mp(name1, false) and Role1SkillInter[cooldown_key] <= 0:
			RoleProp.roleprop.Mp -= get_need_mp(name1, false)
		else:
			return
		match name1:
			"slz":
				if Role1SkillInter["slz"] <= 0:
					do_slz()
			"zz":
				do_zz()
			"gsrs":
				do_gsrs()
			"lys":
				if Role1SkillInter["lys"] <= 0:
					do_lys()
			"lyfb":
				if Role1SkillInter["lyfb"] <= 0:
					do_lyfb()
			"hmz":
				if has_method("set_hmz_version"):
					call("set_hmz_version", false)
				if has_method("set_hmz_cooldown_key"):
					call("set_hmz_cooldown_key", "hmz")
				if has_method("set_hmz_damage_level"):
					call("set_hmz_damage_level", get_SkillLevel(5) + 1, "hmz")
				do_hmz_pro()
			"hmz_ws":
				if has_method("set_hmz_version"):
					call("set_hmz_version", true)
				if has_method("set_hmz_cooldown_key"):
					call("set_hmz_cooldown_key", "hmz_ws")
				if has_method("set_hmz_damage_level"):
					call("set_hmz_damage_level", get_SkillLevel(12) + 1, "hmz_ws")
				do_hmz_pro()
			"hyjj_ws":
				if has_method("do_wushuang_huoyan_jinjing"):
					call("do_wushuang_huoyan_jinjing")
			"hytj":
				if Role1SkillInter["hytj"] <= 0:
					do_hytj()
			"hyjj":
				if Role1SkillInter["hyjj"] <= 0:
					do_hyjj()
			"jdy":
				if Role1SkillInter["jdy"] <= 0:
					do_jdy()
			"jdy2":
				if Role1SkillInter["jdy"] <= 0:
					do_jdy_2()
			"qsez":
				if Role1SkillInter["qsez"] <= 0:
					do_qsez()
			"":
				return
	elif self is role2:
		if not is_on_floor():
			if name1 == "smb":
				return
		if SMB1 == null:
			if RoleProp.roleprop.Mp < get_need_mp(name1, false) or Role1SkillInter[cooldown_key] > 0:
				return
		match name1:
			"blb":
				if Role1SkillInter["blb"] <= 0:
					Skill_Blb()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"tjgl":
				if Role1SkillInter["tjgl"] <= 0:
					Skill_Tjgl()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"xbz":
				if Role1SkillInter["xbz"] <= 0:
					Skill_XBZ()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"shy":
				if Role1SkillInter["shy"] <= 0:
					Skill_SHY()
					if MyShallow == null:
						RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"sgq":
				if Role1SkillInter["sgq"] <= 0:
					Skill_SGQ()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"myhc":
				if Role1SkillInter["myhc"] <= 0:
					Skill_MYHC()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"jgz":
				if Role1SkillInter["jgz"] <= 0:
					Skill_JGZ()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"jhsj":
				if Role1SkillInter["jhsj"] <= 0:
					Skill_JHSJ()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"smb":
				if Role1SkillInter["smb"] <= 0:
					Skill_SMB()
					if SMB1 == null:
						RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"by":
				if Role1SkillInter["by"] <= 0:
					Skill_BY()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"zfjg":
				if Role1SkillInter["zfjg"] <= 0:
					call("Skill_Zfjg")
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
	elif self is role3:
		if name1 == "tmc2":
			if Role1SkillInter["tmc"] <= 0:
				Skill_TMC2()
				return
			return
		if RoleProp.roleprop.Mp >= get_need_mp(name1, false) and Role1SkillInter[cooldown_key] <= 0:
			RoleProp.roleprop.Mp -= get_need_mp(name1, false)
		else:
			return
		match name1:
			"sd":
				if Role1SkillInter["sd"] <= 0:
					Skill_SD()
			"ssp":
				if Role1SkillInter["ssp"] <= 0:
					Skill_SSP()
			"jsp":
				if Role1SkillInter["jsp"] <= 0:
					Skill_JSP()
			"zznh":
				if Role1SkillInter["zznh"] <= 0:
					Skill_ZZNH()
			"dj":
				if Role1SkillInter["dj"] <= 0:
					Skill_DJ()
			"dgq":
				if Role1SkillInter["dgq"] <= 0:
					Skill_DGQ()
			"xgq":
				if Role1SkillInter["xgq"] <= 0:
					Skill_XGQ()
			"syzq":
				if Role1SkillInter["syzq"] <= 0:
					Skill_SYZQ()
			"tmc":
				if Role1SkillInter["tmc"] <= 0:
					Skill_TMC()
			"bdqk":
				if Role1SkillInter["bdqk"] <= 0:
					call("Skill_BDQK")
	elif self is role4:
		if RoleProp.roleprop.Mp >= get_need_mp(name1, false) and Role1SkillInter[cooldown_key] <= 0:
			RoleProp.roleprop.Mp -= get_need_mp(name1, false)
		else:
			return
		match name1:
			"qlj":
				if Role1SkillInter["qlj"] <= 0:
					ShovelQLJ()
			"dcj":
				if Role1SkillInter["dcj"] <= 0:
					ShovelDCJ()
			"wdzt":
				if Role1SkillInter["wdzt"] <= 0:
					ShovelWDZT()
			"tkj":
				if Role1SkillInter["tkj"] <= 0:
					ShovelTKJ()
			"mmw":
				if Role1SkillInter["mmw"] <= 0:
					ShovelMMW()
			"zq":
				if Role1SkillInter["zq"] <= 0:
					ShovelZQ()
			"wdww":
				if Role1SkillInter["wdww"] <= 0:
					ShovelWDWW()
			"bylt":
				if Role1SkillInter["bylt"] <= 0:
					call("ShovelBYLT")
			"cmly":
				if Role1SkillInter["cmly"] <= 0:
					call("ShovelCMLY")
			"lhsq":
				if Role1SkillInter["lhsq"] <= 0:
					ShovelMBYJ()
			"jdz":
				if Role1SkillInter["jdz"] <= 0:
					ShovelJDZ()
	elif self is role5:
		if RoleProp.roleprop.Mp >= get_need_mp(name1, false) and Role1SkillInter[cooldown_key] <= 0:
			RoleProp.roleprop.Mp -= get_need_mp(name1, false)
		else:
			return
		match name1:
			"slq":
				if Role1SkillInter["slq"] <= 0:
					UseSLQ()
			"cxq":
				if Role1SkillInter["cxq"] <= 0:
					UseCXQ()
			"blq":
				if Role1SkillInter["blq"] <= 0:
					UseBLQ()
			"xyq":
				if Role1SkillInter["xyq"] <= 0:
					UseXYQ()
			"llrd":
				if Role1SkillInter["llrd"] <= 0:
					UseLLRD()
			"lljy":
				if Role1SkillInter["lljy"] <= 0:
					UseLLJY()
			"tllz":
				if Role1SkillInter["tllz"] <= 0:
					UseTLLZ()
			"ygth":
				if Role1SkillInter["ygth"] <= 0:
					UseYGTH()
			"fhf":
				if Role1SkillInter["fhf"] <= 0:
					UseFHF()
			"ltjz":
				if Role1SkillInter["ltjz"] <= 0:
					call("UseLTJZ")


func ImproveSelfRecoveryWhenIdle():
	if is_be_attacking:
		CUreCureCount = 0
		CureValue = 1
	else:
		CUreCureCount += 1
	if CUreCureCount % 180 == 0 and CUreCureCount != 0:
		CureValue += 0.5
	if velocity.x == 0:
		IdleCount += 1
	else:
		IdleCount = 0
	if IdleCount % 120 == 0 and IdleCount != 0:
		CureValue += 0.5


func ResetInsky():
	IsInSky = false


func SetInsky():
	IsInSky = true


func _prewarm_heavy_skill_resources() -> void:
	SMSR_SHENQI_LIGHTNING_EFFECT.prewarm_frames()
	if zlwsz_shenqi_gear_scene == null:
		zlwsz_shenqi_gear_scene = load("res://Scene/Hero/ZLWShenqiGearBullet.tscn")


func ADDSMSRShenqiLightningRound() -> void:
	if not RoleProp.is_ws_state or not has_smsrsz_fashion or current_fashion_quality != "shenqi":
		return
	if not objattackDic.has("smsr"):
		return
	var effect := SMSR_SHENQI_LIGHTNING_EFFECT.new()
	effect.setup(self, objattackDic["smsr"])
	var level := get_parent().get_parent()
	if level != null:
		level.add_child(effect)
	else:
		add_child(effect)


func ADDSMSREffect():
	var dic = objattackDic["smsr"].duplicate(true)
	if PlayerDir:
		dic["hurtBack"] = [-20, -1]
	else:
		dic["hurtBack"] = [20, -1]

	Global.addRoleBullet_(self, Vector2(0, 20), false, "SMSRBullet", dic)


func ADDZLWEffect():
	Global.addRoleBullet_(self, Vector2(0, 0), false, "ZLWBullet", objattackDic["zlw"])


func STARTZLWShenqiEffect():
	ADDZLWShenqiWheelEffect()
	if zlwsz_shenqi_timer == null:
		zlwsz_shenqi_timer = Timer.new()
		add_child(zlwsz_shenqi_timer)
		zlwsz_shenqi_timer.timeout.connect(_on_zlwsz_shenqi_timer_timeout)
	zlwsz_shenqi_timer.start(3.0)


func _on_zlwsz_shenqi_timer_timeout():
	if RoleProp.is_ws_state:
		ADDZLWShenqiWheelEffect()
	else:
		zlwsz_shenqi_timer.stop()


func ADDZLWShenqiWheelEffect():
	if not objattackDic.has("zlw_shenqi_ws"):
		return
	if zlwsz_shenqi_gear_scene == null:
		zlwsz_shenqi_gear_scene = load("res://Scene/Hero/ZLWShenqiGearBullet.tscn")
	var bullet_parent = get_tree().current_scene
	if bullet_parent == null:
		bullet_parent = self.Bullet
	for i in range(3):
		var gear = zlwsz_shenqi_gear_scene.instantiate()
		gear.follow_target = self
		gear.initial_angle = TAU / 3.0 * i
		gear.HitDic = objattackDic["zlw_shenqi_ws"]
		bullet_parent.add_child(gear)
		gear.global_position = self.global_position


func ADDTtzsEffect():
	Global.addRoleBullet_(self, Vector2(0, 0), false, "TtzsszBullet", objattackDic["ttzs"])


func ADDNMWEffect():
	var PositionList_1 = [Vector2(-65, 500), Vector2(65, 500)]
	var PositionList_2 = [Vector2(-175, 500), Vector2(175, 500)]
	var PositionList_3 = [Vector2(-285, 500), Vector2(285, 500)]
	var PositionList = {
		"1": [Vector2(-185, 500), Vector2(65, 500), Vector2(-65, 500), Vector2(185, 500)],
		"2":
		[
			Vector2(-285, 500),
			Vector2(-185, 500),
			Vector2(65, 500),
			Vector2(-65, 500),
			Vector2(185, 500),
			Vector2(285, 500)
		],
		"3":
		[
			Vector2(-385, 500),
			Vector2(-285, 500),
			Vector2(-185, 500),
			Vector2(65, 500),
			Vector2(-65, 500),
			Vector2(185, 500),
			Vector2(285, 500),
			Vector2(385, 500)
		],
	}
	var SZName = Global.GetName(PlayerData.player_data["时装"][0]["名字"])
	var Pz = str(PlayerData.player_data["时装"][0]["名字"]).split(SZName)[0]
	var Count: int = 1
	match Pz:
		"youxiu":
			Count = 1
		"jingliang":
			Count = 2
		"shishi":
			Count = 3
	for i in PositionList[str(Count)]:
		Global.addRoleBullet_(self.Bullet, Vector2(i.x + position.x, 500), false, "NMWBullet2", objattackDic["nmw"])


func SetSZValue():
	has_smsrsz_fashion = false
	current_fashion_quality = ""
	if PlayerData.player_data["时装"].size() <= 0:
		return
	var SZName = Global.GetName(PlayerData.player_data["时装"][0]["名字"])
	var Pz = str(PlayerData.player_data["时装"][0]["名字"]).split(SZName)[0]
	var Bl = 1
	match SZName:
		"ttzssz":
			var Power: int
			var Pj: float
			var Time_: float
			match Pz:
				"youxiu":
					Power = RoleProp.roleprop.power * 1
					Pj = 0.15
					Time_ = 4
				"jingliang":
					Power = RoleProp.roleprop.power * 1.5
					Pj = 0.25
					Time_ = 6
				"shishi":
					Power = RoleProp.roleprop.power * 2
					Pj = 0.35
					Time_ = 8
				"xieling":
					Power = RoleProp.roleprop.power * 2.5
					Pj = 0.4
					Time_ = 10
				"hunqi":
					Power = RoleProp.roleprop.power * 3
					Pj = 0.45
					Time_ = 12
				"chuanshuo":
					Power = RoleProp.roleprop.power * 3.5
					Pj = 0.5
					Time_ = 14
				"shenqi":
					Power = RoleProp.roleprop.power * 4
					Pj = 0.4
					Time_ = 16
			objattackDic["ttzs"] = {
				"power": int(Power),
				"hurtBack": [1, -1],
				"attackKind": "magic",
				"addeffect":
				{
					"Name": "DefeReduce",
					"AddTime": Time_,
					"ReduceInterval": 0,
					"value": Pj,
					"AttackKind": "",
					"CanRemove": true,
					"CanAdd": false,
					"DeBuff": true
				}
			}
		"nmwsz":
			var max_hp = RoleProp.roleprop.SHp
			var Power: int
			var Pj: float
			var Time_: float
			match Pz:
				"youxiu":
					Power = max_hp * 0.3
					Pj = max_hp * 0.05
					Time_ = 2
				"jingliang":
					Power = max_hp * 0.5
					Pj = max_hp * 0.07
					Time_ = 3
				"shishi":
					Power = max_hp * 0.7
					Pj = max_hp * 0.09
					Time_ = 5
				"xieling":
					Power = max_hp * 0.9
					Pj = max_hp * 0.11
					Time_ = 7
				"hunqi":
					Power = max_hp * 1.1
					Pj = max_hp * 0.13
					Time_ = 9
				"chuanshuo":
					Power = max_hp * 1.3
					Pj = max_hp * 0.15
					Time_ = 11
				"shenqi":
					Power = max_hp * 1.5
					Pj = max_hp * 0.17
					Time_ = 13
			objattackDic["nmw"] = {
				"power": int(Power),
				"hurtBack": [1, -1],
				"attackKind": "magic",
				"addeffect":
				{
					"Name": "Fire",
					"AddTime": Time_,
					"ReduceInterval": 1,
					"value": int(Pj),
					"AttackKind": "real",
					"CanRemove": true,
					"CanAdd": false,
					"DeBuff": true,
				}
			}
		"zlwsz":
			var Power: int
			var Time_: float
			match Pz:
				"youxiu":
					Power = RoleProp.roleprop.power * 3
					Time_ = 2
				"jingliang":
					Power = RoleProp.roleprop.power * 4
					Time_ = 3
				"shishi":
					Power = RoleProp.roleprop.power * 5
					Time_ = 4
				"xieling":
					Power = RoleProp.roleprop.power * 6
					Time_ = 5
				"hunqi":
					Power = RoleProp.roleprop.power * 7
					Time_ = 6
				"chuanshuo":
					Power = RoleProp.roleprop.power * 8
					Time_ = 7
				"shenqi":
					Power = RoleProp.roleprop.power * 9
					Time_ = 8
			objattackDic["zlw"] = {
				"power": int(Power),
				"hurtBack": [1, -1],
				"attackKind": "magic",
				"addeffect":
				{
					"Name": "stun",
					"AddTime": Time_,
					"ReduceInterval": 0,
					"value": 0,
					"AttackKind": "",
					"CanRemove": true,
					"CanAdd": false,
					"DeBuff": true
				}
			}
			if Pz == "shenqi":
				objattackDic["zlw_shenqi_ws"] = {
					"power": int(RoleProp.roleprop.power * 2.5),
					"hurtBack": [0, 0],
					"attackKind": "magic",
					"stun_chance": 40,
					"addeffect":
					{
						"Name": "stun",
						"AddTime": 1,
						"ReduceInterval": 0,
						"value": 0,
						"AttackKind": "",
						"CanRemove": true,
						"CanAdd": false,
						"DeBuff": true
					}
				}

		"smsrsz":
			has_smsrsz_fashion = true
			current_fashion_quality = Pz
			var Power: int
			match Pz:
				"youxiu":
					Power = RoleProp.roleprop.power * 3
				"jingliang":
					Power = RoleProp.roleprop.power * 3
				"shishi":
					Power = RoleProp.roleprop.power * 3
				"xieling":
					Power = RoleProp.roleprop.power * 3
				"hunqi":
					Power = RoleProp.roleprop.power * 3
				"chuanshuo":
					Power = RoleProp.roleprop.power * 3
				"shenqi":
					Power = RoleProp.roleprop.power * 3
			objattackDic["smsr"] = {
				"power": int(Power),
				"hurtBack": [0, 0],
				"attackKind": "magic",
			}


func _update_fashion_values_if_needed() -> void:
	var fashion_name := ""
	if not PlayerData.player_data["时装"].is_empty():
		fashion_name = str(PlayerData.player_data["时装"][0].get("名字", ""))
	var current_power := int(RoleProp.roleprop.power)
	var current_max_hp := int(RoleProp.roleprop.SHp)
	if (
		_fashion_values_initialized
		and fashion_name == _last_fashion_name
		and current_power == _last_fashion_power
		and current_max_hp == _last_fashion_max_hp
	):
		return
	_fashion_values_initialized = true
	_last_fashion_name = fashion_name
	_last_fashion_power = current_power
	_last_fashion_max_hp = current_max_hp
	SetSZValue()


func WhenScary():
	if not IsScary or is_be_attacking:
		return
	if ran_num <= 20:
		_play_locomotion_animation(&"wait")
		velocity.x = 0
	elif ran_num > 20 and ran_num <= 60:
		_play_locomotion_animation(&"run")
		get_action = "run"
		action.scale.x = 1
		base_damagebox.scale.x = 1
		velocity.x = -walk_speed * RoleProp.ws_up_power * 0.5
	else:
		_play_locomotion_animation(&"run")
		get_action = "run"
		action.scale.x = -1
		base_damagebox.scale.x = -1
		velocity.x = walk_speed * RoleProp.ws_up_power * 0.5
	pass


func AddTx():
	var title_name := "Empty"
	if PlayerData.player_data["幻化列表"].has("头衔"):
		if PlayerData.player_data["幻化列表"]["头衔"] == "":
			if PlayerData.player_data["头衔"].size() == 0:
				title_name = "Empty"
			else:
				title_name = str(PlayerData.player_data["头衔"][0]["名字"])
		else:
			title_name = str(PlayerData.player_data["幻化列表"]["头衔"])
	if title_name == _last_title_name:
		return
	_last_title_name = title_name
	_play_title(title_name)


func _play_title(title_name: String) -> void:
	tx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if title_name == "htd":
		_ensure_title_animation(title_name, "res://Art/AllTX/htd.png")
	elif title_name == "ymqzq":
		_ensure_title_animation(title_name, "res://Art/AllTX/ymqzq.png")
	tx.play(title_name)
	var title_scale := 0.85
	if title_name == "zmcq":
		title_scale = 0.75
	tx.scale = Vector2(title_scale, title_scale)


func _ensure_title_animation(title_name: String, texture_path: String) -> void:
	if tx.sprite_frames == null or tx.sprite_frames.has_animation(StringName(title_name)):
		return
	var title_texture := load(texture_path) as Texture2D
	if title_texture == null:
		return
	var animation_name := StringName(title_name)
	tx.sprite_frames.add_animation(animation_name)
	tx.sprite_frames.set_animation_loop(animation_name, true)
	tx.sprite_frames.set_animation_speed(animation_name, 15.0)
	for row in range(4):
		for column in range(4):
			var frame_texture := AtlasTexture.new()
			frame_texture.atlas = title_texture
			frame_texture.region = Rect2(column * 208, row * 124, 208, 124)
			tx.sprite_frames.add_frame(animation_name, frame_texture)


func jsfzsy():
	var formation_name := str(PlayerData.player_data["已佩戴阵法"])
	var formation_level := 0
	if formation_name == "slz":
		formation_level = int(PlayerData.player_data["森罗阵"]["Level"])
	elif formation_name == "tsz":
		formation_level = int(PlayerData.player_data["腾蛇阵"]["Level"])
	if formation_name == _last_hero_formation and formation_level == _last_hero_formation_level:
		return
	_last_hero_formation = formation_name
	_last_hero_formation_level = formation_level
	if formation_name == "slz":
		var Levelslz = formation_level
		slzjs = Levelslz * 0.01
	else:
		slzjs = 0
	if formation_name == "tsz":
		var Leveltsz = formation_level
		tszbsjm = Leveltsz * 0.01
	else:
		tszbsjm = 0


func UseZhenFa():
	if Input.is_action_just_pressed("阵法") or Input.is_action_just_pressed("MDS"):
		if _try_use_main_sword_array():
			return
		if PlayerData.player_data["已佩戴阵法"] == "" or PlayerData.player_data["已佩戴阵法"] == null:
			return
		match PlayerData.player_data["已佩戴阵法"]:
			"slz":
				if ZhenFaCd <= 0:
					self.objattackDic["slz"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic", "WSValue": 0}
					Global.addRoleBullet_(self, Vector2(0, 30), false, "SLZBullet", objattackDic["slz"])
					_start_zhen_fa_cd(30)
			"lpz":
				if ZhenFaCd <= 0:
					self.objattackDic["lpz"] = {
						"power": int(RoleProp.roleprop.power * 1),
						"hurtBack": [0, 0],
						"attackKind": "magic",
						"WSValue": 0
					}
					Global.addRoleBullet_(
						self.Bullet, position + Vector2(0, 40), false, "LPZBullet", objattackDic["lpz"]
					)
					_start_zhen_fa_cd(30)
			"tsz":
				if ZhenFaCd <= 0:
					self.objattackDic["tsz"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic", "WSValue": 0}
					Global.addRoleBullet_(self, Vector2(0, 30), false, "TSZBullet", objattackDic["tsz"])
					_start_zhen_fa_cd(30)
			"tqz":
				if not is_on_floor():
					return
				if ZhenFaCd <= 0:
					self.objattackDic["tqz"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic", "WSValue": 0}
					Global.addRoleBullet_(
						self.Bullet, position + Vector2(0, 40), false, "TQZBullet", objattackDic["tqz"]
					)
					_start_zhen_fa_cd(35)


func _try_use_main_sword_array() -> bool:
	if PlayerData.has_method("ensure_main_sword_array"):
		PlayerData.ensure_main_sword_array()
	var active := str(PlayerData.player_data.get("主线剑阵出战", ""))
	if active == "":
		return false
	if PlayerData.has_method("can_main_sword_array_battle") and not PlayerData.can_main_sword_array_battle(active):
		PlayerData.player_data["主线剑阵出战"] = ""
		return false
	if ZhenFaCd > 0:
		return true
	_sync_main_sword_array_weapon()
	if is_instance_valid(MainSwordArrayTarget) and MainSwordArrayTarget.has_method("cast_skill"):
		MainSwordArrayTarget.cast_skill()
		_set_main_sword_array_cooldown_visible(false)
		_start_zhen_fa_cd(30)
		return true
	return false


func _start_zhen_fa_cd(cd_time: float) -> void:
	ZhenFaCd = cd_time
	if is_instance_valid(Global.zhen_fa):
		Global.zhen_fa.MaxTime = ZhenFaCd
	if is_instance_valid(zhen_fa):
		zhen_fa.start(ZhenFaCd)


func _on_zhen_fa_timeout() -> void:
	ZhenFaCd = 0
	_set_main_sword_array_cooldown_visible(true)


func _set_main_sword_array_cooldown_visible(value: bool) -> void:
	var active := str(PlayerData.player_data.get("主线剑阵出战", ""))
	if active == "":
		return
	if is_instance_valid(MainSwordArrayTarget):
		MainSwordArrayTarget.visible = value


func _on_hit_box_body_entered(body: Node2D) -> void:
	pass


func SetWingsOffset():
	var CurrentWingsName: String
	if PlayerData.player_data["幻化列表"]["翅膀"] == "":
		if PlayerData.player_data["翅膀"].size() == 0:
			CurrentWingsName = "empty"
		else:
			CurrentWingsName = PlayerData.player_data["翅膀"][0]["名字"]
	else:
		CurrentWingsName = PlayerData.player_data["幻化列表"]["翅膀"]
	var special_wing_position := Vector2(41, -4) if self is role1 else _wings_base_position
	var special_wing_offset_y := 0.0 if self is role1 or self is role4 or self is role5 or self is NeZhaHero else -25.0
	if CurrentWingsName == _last_wings_name:
		if CurrentWingsName == "xyzy":
			wings.position = special_wing_position
			wings.offset = Vector2(0, special_wing_offset_y)
			wings.rotation = 0.0
			wings.scale = Vector2.ONE
			return
		if CurrentWingsName == "hhyq":
			wings.position = special_wing_position
			wings.offset = Vector2(60, special_wing_offset_y)
			wings.rotation = 0.0
			wings.scale = Vector2.ONE
			return
		return
	_last_wings_name = CurrentWingsName
	_reset_wings_base_transform()
	wings.flip_h = CurrentWingsName == "xyzy" or CurrentWingsName == "hhyq"
	match CurrentWingsName:
		"xtzy", "ttzy":
			if self is role2 or self is role3:
				wings.position = Vector2(0, 0)
			else:
				wings.offset = Vector2(0, 0)
			wings.scale = Vector2(1.4, 1.4)
		"xqzy":
			if self is role2 or self is role3:
				wings.position = Vector2(14, 10)
			else:
				wings.offset = Vector2(5, 10)
			wings.scale = Vector2(1.2, 1.2)
		"jmzy":
			if self is role2 or self is role3:
				wings.position = Vector2(45, 15)
			else:
				wings.offset = Vector2(25, 15)
			wings.scale = Vector2(1.1, 1.1)
		"xmzy":
			if self is role2 or self is role3:
				wings.position = Vector2(40, -25)
			else:
				wings.offset = Vector2(30, -15)
			wings.scale = Vector2(1, 1)
		"bszy":
			if self is role2 or self is role3:
				wings.position = Vector2(30, 0)
			else:
				wings.offset = Vector2(20, 10)
			wings.scale = Vector2(1, 1)
		"wyzy":
			if self is role2 or self is role3:
				wings.position = Vector2(30, 0)
			else:
				wings.offset = Vector2(15, 15)
			wings.scale = Vector2(1, 1)
		"ryzy":
			if self is role2:
				wings.position = Vector2(30, 0)
			elif self is role3:
				wings.position = Vector2(45, -20)
				wings.scale = Vector2(1.1, 1.1)
			else:
				wings.offset = Vector2(25, 0)
		"xyzy":
			wings.position = special_wing_position
			wings.offset = Vector2(0, special_wing_offset_y)
			wings.scale = Vector2.ONE
			wings.rotation = 0.0
		"hhyq":
			wings.position = special_wing_position
			wings.offset = Vector2(60, special_wing_offset_y)
			wings.rotation = 0.0
			wings.scale = Vector2.ONE


func ResetSanXianHuTi():
	IsSanXianHuTiUsed = false
