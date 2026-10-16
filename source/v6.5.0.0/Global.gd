extends Node
const DataKeys := preload("res://Script/Base/DataKeys.gd")

signal combo_milestone_reached(milestone: int)
signal sound_settings_changed

const TARGET_MAX_FPS := 150
const SHOW_DEBUG_PERF_OVERLAY := true
const DuplicateTextureAliases = preload("res://Script/Monster/DuplicateTextureAliases.gd")
const WUSHUANG_HUOYAN_EFFECT_SCRIPT = preload("res://Script/Hero/WuShuangHuoYanJinJingEffect.gd")
const BING_YU_EFFECT_SCRIPT = preload("res://Script/Hero/BingYuEffect.gd")
const BA_DI_QIAN_KUN_EFFECT_SCRIPT = preload("res://Script/Hero/BaDiQianKunEffect.gd")
const BI_LUO_TIAN_EFFECT_SCRIPT = preload("res://Script/Hero/BiLuoTianEffect.gd")
const LEI_TING_JIE_ZHEN_EFFECT_SCRIPT = preload("res://Script/Hero/LeiTingJieZhenEffect.gd")
const SMSR_SHENQI_LIGHTNING_EFFECT_SCRIPT = preload("res://Script/Hero/SMSRShenqiLightningEffect.gd")
const HMZ_AWAKEN_EFFECT_SCRIPT = preload("res://Script/Hero/HmzAwakenEffect.gd")
const LYFB_AWAKEN_EFFECT_SCRIPT = preload("res://Script/Hero/LyfbAwakenEffect.gd")
const JHSJ_AWAKEN_EFFECT_SCRIPT = preload("res://Script/Hero/JHSJAwakenEffect.gd")
const CANG_MU_LONG_YUN_EFFECT_SCRIPT = preload("res://Script/Hero/CangMuLongYunEffect.gd")
const ROLE4_POISON_ARRAY_AWAKEN_EFFECT_SCRIPT = preload("res://Script/Hero/Role4PoisonArrayAwakenEffect.gd")
const STREAMING_ROLE_BULLET_SCRIPT = preload("res://Script/Hero/StreamingRoleBullet.gd")
const MIRROR_SCRIPT = preload("res://Script/MagicWeapon/Mirror.gd")
const PET_TURTLE_BULLET_SCRIPT = preload("res://Script/Pet/PetTurtleBullet.gd")
const PET_RABBIT_BULLET_SCRIPT = preload("res://Script/Pet/PetRabbitBullet.gd")
const PET_MOUSE_BULLET_SCRIPT = preload("res://Script/Pet/PetMouseBullet.gd")
const PET_NEAT_BULLET_SCRIPT = preload("res://Script/Pet/PetNeatBullet.gd")
const MONSTER_CONTROL_BUFF_NAMES := [
	"Ice",
	"stun",
	"EyeFix",
	"DeadLink",
	"Boundground",
	"silent",
	"Immobilize",
	"BloodFix",
	"LifeManaLock",
	"Scary",
	"speed_down",
	"lljybuff",
	"ReverseMove",
]

var cloud_save_user_id := ""
var cloud_save_access_token := ""
var cloud_save_uid_md5 := ""
var cloud_save_account := ""
var cloud_auth_cooldown_until_msec := 0

const HIDDEN_FEATURE_INVINCIBLE := "invincible"
const HIDDEN_FEATURE_INSTANT_KILL := "instant_kill"
const HIDDEN_FEATURE_ALL_MAPS := "all_maps"
const HIDDEN_FEATURE_FREE_SHOP := "free_shop"
const HIDDEN_FEATURE_ALL_SHOP_ITEMS := "all_shop_items"

var _hidden_feature_flags: Dictionary = {
	HIDDEN_FEATURE_INVINCIBLE: false,
	HIDDEN_FEATURE_INSTANT_KILL: false,
	HIDDEN_FEATURE_ALL_MAPS: false,
	HIDDEN_FEATURE_FREE_SHOP: false,
	HIDDEN_FEATURE_ALL_SHOP_ITEMS: false,
}


func set_hidden_feature_enabled(feature_name: String, enabled: bool) -> void:
	if _hidden_feature_flags.has(feature_name):
		_hidden_feature_flags[feature_name] = enabled


func is_hidden_feature_enabled(feature_name: String) -> bool:
	return bool(_hidden_feature_flags.get(feature_name, false))


var AllBuffList = [
	"speed_down",
	"DefeReduce",
	"nlls",
	"Ice",
	"stun",
	"EyeFix",
	"DeadLink",
	"Boundground",
	"silent",
	"Immobilize",
	"BloodFix",
	"LifeManaLock",
	"Bleed",
	"poision",
	"Fire",
	"Scary",
	"SuperArmor",
	"Indestructible",
	"Indestructible1",
	"DoubleFallPro",
	"Voodoo",
	"PoisionBody",
	"slzbuff",
	"lpzbuff",
	"yxbuff",
	"tszbuff",
	"lljybuff",
	"NoDeBuff",
	"flls",
	"MagicDrain",
	"ReverseMove",
	"SanXianHuTi",
	"jgz",
	"zznh",
	"SMSRSZ_CD"
]
var BuffList = []
var _ui_popup_layer
var _active_hover_popup

var _pool_data = {"root": null, "damage_text": [], "mr_hurt": [], "role_be_hit": [], "sound_player": []}
const DAMAGE_TEXT_POOL_LIMIT := 80
const MR_HURT_POOL_LIMIT := 32
const ROLE_BE_HIT_POOL_LIMIT := 24
const SOUND_PLAYER_POOL_LIMIT := 32
const COMBAT_HIT_DAMAGE_POOL_SIZE := 12
const COMBAT_HIT_EFFECT_POOL_SIZE := 16
const COMBAT_HIT_SOUND_POOL_SIZE := 6
var ChooseList = []
var ChooseMs: bool
var buff_box
var MgCdPic
var zhen_fa
var LHHJBossList = {}

const BASIC_AR_BUTTON_PATH := "res://Scene/other_scene/BacisArButton.tscn"
const ADD_WEAPON_BULLET_PATHS := {
	"CloudSwordBullet": "res://Scene/MagicWeapon/HitBulletLazy/CloudSwordBullet.tscn",
	"CucurFire_1": "res://Scene/MagicWeapon/HitBulletLazy/CucurFire_1.tscn",
	"CucurFire_2": "res://Scene/MagicWeapon/HitBulletLazy/CucurFire_2.tscn",
	"GhostDollBullet_1": "res://Scene/MagicWeapon/HitBulletLazy/GhostDollBullet_1.tscn",
	"GhostDollBullet_2": "res://Scene/MagicWeapon/HitBulletLazy/GhostDollBullet_2.tscn",
	"GhostDollBullet_3": "res://Scene/MagicWeapon/HitBulletLazy/GhostDollBullet_3.tscn",
	"MagicUmbrellaBullet": "res://Scene/MagicWeapon/HitBulletLazy/MagicUmbrellaBullet.tscn",
	"PurpleGlodCucurbitBullet": "res://Scene/MagicWeapon/HitBulletLazy/PurpleGlodCucurbitBullet.tscn",
	"SwordBullet": "res://Scene/MagicWeapon/HitBulletLazy/SwordBullet.tscn",
	"wdsfBullet1": "res://Scene/MagicWeapon/HitBulletLazy/wdsfBullet1.tscn",
	"wdsfBullet2": "res://Scene/MagicWeapon/HitBulletLazy/wdsfBullet2.tscn",
	"wdsfBullet3": "res://Scene/MagicWeapon/HitBulletLazy/wdsfBullet3.tscn",
	"wdshBullet1": "res://Scene/MagicWeapon/HitBulletLazy/wdshBullet1.tscn",
	"wdshBullet2": "res://Scene/MagicWeapon/HitBulletLazy/wdshBullet2.tscn",
	"wdshBullet2_1": "res://Scene/MagicWeapon/HitBulletLazy/wdshBullet2_1.tscn",
	"wdslBullet1": "res://Scene/MagicWeapon/HitBulletLazy/wdslBullet1.tscn",
	"wdslBullet2": "res://Scene/MagicWeapon/HitBulletLazy/wdslBullet2.tscn",
	"wdstBullet1": "res://Scene/MagicWeapon/HitBulletLazy/wdstBullet1.tscn",
	"wdstBullet2": "res://Scene/MagicWeapon/HitBulletLazy/wdstBullet2.tscn",
	"wdstBullet3": "res://Scene/MagicWeapon/HitBulletLazy/wdstBullet3.tscn",
}
const MAGIC_WEAPON_SCENE_PATHS := {
	"zcld": "res://Scene/MagicWeapon/zcld.tscn",
	"dshl": "res://Scene/MagicWeapon/Cucurbit.tscn",
	"dhqf": "res://Scene/MagicWeapon/dhqf.tscn",
	"tsgj": "res://Scene/MagicWeapon/Sword.tscn",
	"bsyj": "res://Scene/MagicWeapon/Mirror.tscn",
	"lsys": "res://Scene/MagicWeapon/MagicUmbrella.tscn",
	"xhmt": "res://Scene/MagicWeapon/GhostDoll.tscn",
	"xhhl": "res://Scene/MagicWeapon/Cucurbit2.tscn",
	"kyl": "res://Scene/MagicWeapon/Hybrofoline.tscn",
	"qyj": "res://Scene/MagicWeapon/CloudSword.tscn",
	"zjfyd": "res://Scene/MagicWeapon/PurpleGoldBell.tscn",
	"zjhl": "res://Scene/MagicWeapon/PurpleGlodCucurbit.tscn",
	"yjp": "res://Scene/MagicWeapon/Yujingping.tscn",
	"zlwdah": "res://Scene/MagicWeapon/zlwdah.tscn",
	"sqzlw": "res://Scene/MagicWeapon/sqzlw.tscn",
	"nmwdnh": "res://Scene/MagicWeapon/Nmwdnh.tscn",
	"sqnmwdnh": "res://Scene/MagicWeapon/Nmwdnh.tscn",
	"xianyjp": "res://Scene/MagicWeapon/XianYujingping.tscn",
	"yx": "res://Scene/MagicWeapon/yx.tscn",
	"qlsword": "res://Scene/MagicWeapon/qlsword.tscn",
	"dzyl": "res://Scene/MagicWeapon/QingLian.tscn",
	"469000004": "res://Scene/MagicWeapon/ZhenLeiTianChui.tscn",
	"469000011": "res://Scene/MagicWeapon/DiKongYuMoQuan.tscn",
	"yyzlj": "res://Scene/MagicWeapon/EightImmortal_yyzlj.tscn",
	"ywhl": "res://Scene/MagicWeapon/EightImmortal_ywhl.tscn",
	"zhyx": "res://Scene/MagicWeapon/EightImmortal_zhyx.tscn",
	"bjs": "res://Scene/MagicWeapon/EightImmortal_bjs.tscn",
	"sxyg": "res://Scene/MagicWeapon/EightImmortal_sxyg.tscn",
	"dkhl": "res://Scene/MagicWeapon/EightImmortal_dkhl.tscn",
	"yyb": "res://Scene/MagicWeapon/EightImmortal_yyb.tscn",
	"hehua": "res://Scene/MagicWeapon/EightImmortal_hehua.tscn",
}
const HIT_TEXT_PATH := "res://Scene/Hittext/HitText.tscn"
const DAMAGE_TEXT_PATH := "res://Scene/Hittext/DamageText.tscn"
const MONSTER_BLOOD_PATH := "res://Scene/MonsterBlood/monster_blood_bar.tscn"
const BOSS_BLOOD_PATH := "res://Scene/MonsterBlood/BossBlood.tscn"
const MONSTER_BE_HIT_PATH := "res://Scene/MonsterDamage/monster_be_hit.tscn"
const SPECIAL_AFFECT_SLIM_DIR := "res://Scene/Base/SpecialAffectSlim"
const ROLE_BE_HIT_EFFECT_PATH := "res://Scene/Base/RoleBeHitEffect.tscn"
const AURA_PATH := "res://Scene/other_scene/Auras.tscn"
const BUFF_ICON_PATH := "res://Scene/other_scene/BuffIcon.tscn"
const DAMAGE_NUMBER_PATH := "res://Scene/Hittext/DamageNumber.tscn"
const MISS_EFFECT_PATH := "res://Scene/Hittext/miss_effect.tscn"
const COMBO_PATH := "res://Scene/show_text/combo.tscn"
const COMBO_NUM_PATH := "res://Scene/show_text/combo_num.tscn"
const LIJI_PATH := "res://Scene/show_text/liji.tscn"
const MOMENT_TEXT_PATH := "res://Scene/show_text/MomentText.tscn"
const MESSAGE_SHOW_PATH := "res://Scene/show_text/Message_show.tscn"
const BASE_BUFF_PATH := "res://Scene/Base/BaseBuff.tscn"
const ROLE_BULLET_SLIM_DIR := "res://Scene/Hero/RoleBulletSlim"
const STREAMING_ROLE_BULLET_PATH := "res://Scene/Hero/StreamingRoleBullet.tscn"
const ROLE3_BULLET3_SLIM_PATH := "res://Scene/Hero/Role3Bullet3Slim.tscn"
const ROLE3_SD_SLIM_PATH := "res://Scene/Hero/Role3SdSlim.tscn"
const ROLE3_ZZNH_SLIM_PATH := "res://Scene/Hero/Role3ZznhSlim.tscn"
const ROLE_SPECIAL_EFFECT_SLIM_DIR := "res://Scene/Hero/RoleSpecialEffectSlim"
const TTZSSZ_BULLET_SLIM_PATH := "res://Scene/Hero/TtzsszBulletSlim.tscn"
const MONSTER_BULLET_SLIM_DIR := "res://Scene/Monster/MonsterBulletSlim"
const MONSTER_BULLET_PATH := "res://Scene/Monster/MonsterBullet.tscn"
const FLY_BULLET_PATH := "res://Scene/Bullet/Fly_bullet.tscn"
const FLY_BULLET_SLIM_DIR := "res://Scene/Bullet/FlyBulletSlim"
const CHASE_BULLET_PATH := "res://Scene/Bullet/Chase_bullet.tscn"
const STREAMED_PNG_EFFECT_SCRIPT = preload("res://Script/Monster/StreamedPngEffect.gd")
const MONSTER_212_BULLET_SCRIPTS := [
	preload("res://Script/Monster/Monster212Bullet1.gd"),
	preload("res://Script/Monster/Monster212Bullet2.gd"),
	preload("res://Script/Monster/Monster212Bullet3.gd"),
	preload("res://Script/Monster/Monster212Bullet4.gd"),
]
const MONSTER_SCENE_ALIASES := {
	3043: 3031,
	3044: 3030,
	3045: 3032,
	3046: 3028,
	3053: 3047,
	3054: 3038,
	3055: 3036,
	3064: 3039,
	3072: 3065,
	3073: 3067,
	3074: 3068,
	3075: 3066,
	3178: 3159,
	3183: 3177,
	3126: 3119,
	3145: 3121,
	3146: 3122,
	3221: 3199,
	3226: 3198,
	3274: 3222,
	3275: 3198,
	3321: 3308,
	3322: 3309,
	3340: 3320,
	3341: 3308,
	3342: 3309,
}
const DYNAMIC_MONSTER_TEXTURE_PATHS := {
	150:
	[
		"res://Art/Monster/QiongQi/Monster42FramesCenteredCropped",
		"res://Art/Monster/QiongQi/Effects/BuffGreen.png",
		"res://Art/Monster/QiongQi/Effects/BuffBlue.png",
	],
	151: ["res://Art/Monster/TaoWu/Monster47FramesCenteredCropped"],
	152: ["res://Art/Monster/HunDun/Monster60FramesCenteredCropped"],
	153: ["res://Art/Monster/TaoTie/Monster115FramesCenteredCropped"],
	1460: ["res://Art/Monster/Tongtian3057"],
	212:
	[
		"res://Art/Monster/Game3Monster/Monster_212/DefineSprite_44_Monster212",
		"res://Art/Monster/Game3Monster/Monster_212/DefineSprite_92_Monster212Bullet1_Cropped",
		"res://Art/Monster/Game3Monster/Monster_212/DefineSprite_88_Monster212Bullet2",
		"res://Art/Monster/Game3Monster/Monster_212/DefineSprite_71_Monster212Bullet3",
		"res://Art/Monster/Game3Monster/Monster_212/DefineSprite_49_Monster212Bullet4_2_Cropped",
	],
	163: ["res://Art/Monster/Game3Monster/Monster_163/body", "res://Art/Monster/Game3Monster/Monster_163/body_actions"],
	164: ["res://Art/Monster/Game3Monster/Monster_164/body", "res://Art/Monster/Game3Monster/Monster_164/body_actions"],
	165: ["res://Art/Monster/Game3Monster/Monster_165/body", "res://Art/Monster/Game3Monster/Monster_165/body_actions"],
	166: ["res://Art/Monster/Game3Monster/Monster_166/body", "res://Art/Monster/Game3Monster/Monster_166/body_actions"],
	168: ["res://Art/Monster/Game3Monster/Monster_168/body", "res://Art/Monster/Game3Monster/Monster_168/body_actions"],
	169: ["res://Art/Monster/Game3Monster/Monster_169/body", "res://Art/Monster/Game3Monster/Monster_169/body_actions"],
	174: ["res://Art/Monster/Game3Monster/Monster_174/body", "res://Art/Monster/Game3Monster/Monster_174/body_actions"],
	175: ["res://Art/Monster/Game3Monster/Monster_175/body", "res://Art/Monster/Game3Monster/Monster_175/body_actions"],
	1501:
	[
		"res://Art/Monster/PetTigerBoss/model/frames/stage1",
		"res://Art/Monster/PetTigerBoss/effects",
	],
	1502:
	[
		"res://Art/Monster/PetTigerBoss/model/frames/stage2",
		"res://Art/Monster/PetTigerBoss/effects",
	],
	1503:
	[
		"res://Art/Monster/PetTigerBoss/model/frames/stage3",
		"res://Art/Monster/PetTigerBoss/effects",
	],
	1504:
	[
		"res://Art/Monster/PetTigerBoss/model/frames/stage4",
		"res://Art/Monster/PetTigerBoss/effects",
	],
	4401: ["res://Art/Monster/Game3Monster/ThreePrince/nezha"],
	4402:
	[
		"res://Art/Monster/Game3Monster/ThreePrince/muzha",
		"res://Art/HeroPicture/Role3/BaDiQianKunSmooth",
	],
	4403: ["res://Art/Monster/Game3Monster/ThreePrince/jinzha"],
}
const DYNAMIC_MONSTER_STREAM_EFFECT_ROOTS := {
	150: ["res://Art/Monster/QiongQi/Effects"],
	151: ["res://Art/Monster/TaoWu/Effects"],
	152: ["res://Art/Monster/HunDun/Effects"],
	153: ["res://Art/Monster/TaoTie/Effects"],
	163:
	[
		"res://Art/Monster/Game3Monster/Monster_163/hit1",
		"res://Art/Monster/Game3Monster/Monster_163/hit2",
		"res://Art/Monster/Game3Monster/Monster_163/hit3"
	],
	164:
	[
		"res://Art/Monster/Game3Monster/Monster_164/hit1",
		"res://Art/Monster/Game3Monster/Monster_164/hit2",
		"res://Art/Monster/Game3Monster/Monster_164/hit3"
	],
	165:
	[
		"res://Art/Monster/Game3Monster/Monster_165/hit1",
		"res://Art/Monster/Game3Monster/Monster_165/hit2",
		"res://Art/Monster/Game3Monster/Monster_165/hit3"
	],
	166:
	[
		"res://Art/Monster/Game3Monster/Monster_166/hit1",
		"res://Art/Monster/Game3Monster/Monster_166/hit2",
		"res://Art/Monster/Game3Monster/Monster_166/hit3"
	],
	168:
	[
		"res://Art/Monster/Game3Monster/Monster_168/hit1",
		"res://Art/Monster/Game3Monster/Monster_168/hit2",
		"res://Art/Monster/Game3Monster/Monster_168/hit3"
	],
	169: ["res://Art/Monster/Game3Monster/Monster_169/hit1", "res://Art/Monster/Game3Monster/Monster_169/hit3"],
	174:
	[
		"res://Art/Monster/Game3Monster/Monster_174/hit1",
		"res://Art/Monster/Game3Monster/Monster_174/hit2",
		"res://Art/Monster/Game3Monster/Monster_174/hit3"
	],
	175: ["res://Art/Monster/Game3Monster/Monster_175/hit1", "res://Art/Monster/Game3Monster/Monster_175/hit3"],
}
const DYNAMIC_MONSTER_SCENE_PATHS := {
	114: ["res://Scene/Monster/MonsterBulletSlim/Monster114Bullet2.tscn"],
	137: ["res://Scene/Monster/MonsterBulletSlim/Monster137Bullet2.tscn"],
	1460:
	[
		"res://Scene/Monster/MonsterBulletSlim/Tongtian3057Projectile.tscn",
		"res://Scene/Monster/MonsterBulletSlim/Tongtian3057Beam.tscn",
	],
	3002: ["res://Scene/Monster/MonsterBulletSlim/ZhuqueTigerArrow.tscn"],
	3004: ["res://Scene/Monster/MonsterBulletSlim/XuanwuGateArrow.tscn"],
	3007:
	[
		"res://Scene/Monster/MonsterBulletSlim/WeiyangBossBullet1.tscn",
		"res://Scene/Monster/MonsterBulletSlim/WeiyangBossBullet2.tscn",
		"res://Scene/Monster/MonsterBulletSlim/WeiyangBossBullet3.tscn",
	],
	3012: [],
	3009: ["res://Scene/Monster/MonsterBulletSlim/JiuhuaPineArrow.tscn"],
	3020:
	[
		"res://Scene/Monster/MonsterBulletSlim/ShuangxiBossArrow1.tscn",
		"res://Scene/Monster/MonsterBulletSlim/ShuangxiBossArrow2.tscn",
	],
	212:
	[
		"res://Scene/Monster/MonsterBulletSlim/Monster212Bullet1.tscn",
		"res://Scene/Monster/MonsterBulletSlim/Monster212Bullet2.tscn",
		"res://Scene/Monster/MonsterBulletSlim/Monster212Bullet3.tscn",
		"res://Scene/Monster/MonsterBulletSlim/Monster212Bullet4.tscn",
	],
	1501:
	[
		"res://Scene/Monster/MonsterBulletSlim/PetTiger1Bullet1.tscn",
		"res://Scene/Monster/MonsterBulletSlim/PetTiger1Bullet2.tscn",
	],
	1502:
	[
		"res://Scene/Monster/MonsterBulletSlim/PetTiger2Bullet1.tscn",
		"res://Scene/Monster/MonsterBulletSlim/PetTiger1Bullet2.tscn",
		"res://Scene/Monster/MonsterBulletSlim/PetTiger2Bullet3_1.tscn",
		"res://Scene/Monster/MonsterBulletSlim/PetTiger2Bullet3_2.tscn",
	],
	1503:
	[
		"res://Scene/Monster/MonsterBulletSlim/PetTiger2Bullet1.tscn",
		"res://Scene/Monster/MonsterBulletSlim/PetTiger1Bullet2.tscn",
		"res://Scene/Monster/MonsterBulletSlim/PetTiger2Bullet3_1.tscn",
		"res://Scene/Monster/MonsterBulletSlim/PetTiger2Bullet3_2.tscn",
		"res://Scene/Monster/MonsterBulletSlim/PetTiger3Bullet4_1.tscn",
		"res://Scene/Monster/MonsterBulletSlim/PetTiger3Bullet4_2.tscn",
	],
	1504:
	[
		"res://Scene/Monster/MonsterBulletSlim/PetTiger2Bullet1.tscn",
		"res://Scene/Monster/MonsterBulletSlim/PetTiger1Bullet2.tscn",
		"res://Scene/Monster/MonsterBulletSlim/PetTiger2Bullet3_1.tscn",
		"res://Scene/Monster/MonsterBulletSlim/PetTiger2Bullet3_2.tscn",
		"res://Scene/Monster/MonsterBulletSlim/PetTiger3Bullet4_1.tscn",
		"res://Scene/Monster/MonsterBulletSlim/PetTiger3Bullet4_2.tscn",
	],
	4401: ["res://Scene/Monster/MonsterBulletSlim/ThreePrinceBullet.tscn"],
	4402: ["res://Scene/Monster/MonsterBulletSlim/ThreePrinceBullet.tscn"],
	4403: ["res://Scene/Monster/MonsterBulletSlim/ThreePrinceBullet.tscn"],
}

var BasicArButton = null
var addWeaponBullet = null
var bullet = null
var hit_text = null
var damage_text = null
var monster_blood = null
var monster_be_hit = null
var SpecialAffect = null
var Aura_ = null
var BuffIcon_ = null
var DamageNumber = null
var MissEffect = null
var Combo = null
var ComboNum = null
var lj = null
var moment_texxt = null
var MessageShow = null
var BaseBuff_ = null
var RoleBullet_ = null
var FlyBullet = null
var ChaseBullet_ = null


func _ready() -> void:
	if MainSet != null and MainSet.has_method("apply_frame_rate"):
		MainSet.apply_frame_rate()
	else:
		Engine.max_fps = TARGET_MAX_FPS
	if SHOW_DEBUG_PERF_OVERLAY:
		_create_debug_perf_overlay()
	call_deferred("prewarm_permanent_small_ui_scenes")


var CloudSword_ = null
var PurpleGoldBell_ = null
var Zcld_ = null
var Cucurbit_ = null
var Sword_ = null
var Mirror_ = null
var GhostDoll_ = null
var Dhqf_ = null
var MagicUmbrella_ = null
var PurpleGlodCucurbit_ = null
var Hybrofoline_ = null
var Yujingping_ = null
var Zlwdah_ = null
var Sqzlw_ = null
var Nmwdnh_ = null
var XianYujingping_ = null
var Yx_ = null
var Qlsword_ = null
var Cucurbit2_ = null

var _monster_scene_cache = {}
var _monster_script_bullet_scene_cache: Dictionary = {}
var _last_full_monster_bullet_name := ""
var _level_resource_preload_signature := ""
var _last_combo_value: int = 0
var IsFrist: bool
var Is_Show: bool
var CollectNum: int = 0
var PlayerBeHitCount: int = 0
var GameOver: int = 1
var LLBTWXMS: bool = false
var LLBTCGMS: bool = true
var LLBTBOSSMS: bool
var BoxCount: int = 0
var LLBTLevel: int = 1

var InfiniteLevelMultiplier: float = 0.0
var CurrentLevel: String
var SelectedThreePrinceId: int = 0
var SelectedEightImmortalId: int = 0
var SelectedConstellationLevel: int = 1
var ConstellationBestTier: Dictionary = {}
var LevelDropProData = {}
var LevelBeginTime = ""
var LevelEndTime = ""
var MostLianji: int = 0
var LastPropHp: float
var TotalRoleHurt: int
var LastLevelPath: String
var cd_path: String = ""

var TotalRoleHit: int
var TotalCureHp: int
var TotalPhyHit: int
var TotalMagHit: int
var TotalRealHit: int
var TotalPhyHurt: int
var TotalMagHurt: int
var TotalRealHurt: int
var TotalHurtCount: int
var TotalHitCount: int
var TotalCritCount: int
var TotalMissCount: int
var Windows_
var FileNum = 1.201
var Mytime
var Player_pos_x
var zb_packisfull = false
var dj_packisfull = false
var xhp_packisfull = false
var should_change: bool
var Forge_
var FB_CD: int
var is_in_ldl
var get_target
var is_Mpo
var is_ice
var is_poision
var is_Fire
var is_speed_down
var is_stun
var is_Bleed
var is_EyeFix
var is_DeadLink
var LJ_times: int
var lj_count: int

var Player_dir_
var remove_jq
var wait_time: float = 0.8
var get_player
var NeedChangeItem: bool = true
var Player_dir

var _resource_cache = {}
var _audio_cache = {}
var _texture_cache = {}
var _current_role_body_texture_path: String = ""
var _current_role_equipment_texture_path: String = ""
var _all_hero_skill_resources_preloaded: bool = false
var _prewarmed_role_id: int = 0
var archive_session_active: bool = false
var archive_session_role_id: int = 0
var _archive_session_prewarm_in_progress: bool = false
var _archive_session_generation: int = 0
var _ui_runtime_instance_paths: Dictionary = {}
var _ui_runtime_instance_counts: Dictionary = {}
const PERMANENT_SMALL_UI_SCENE_PATHS := [
	"res://Scene/BackPack/BackPack.tscn",
	"res://Scene/Skill/Learn_skill.tscn",
	"res://Scene/Pet/PetInterface.tscn",
	"res://Scene/BackPack/Magic_weapon_infor.tscn",
]
var _permanent_small_ui_scene_cache: Dictionary = {}
var _permanent_ui_prewarm_in_progress := false
var _permanent_ui_prewarmed := false
var _prewarmed_pet_signature: String = ""
var _level_resource_cache_paths: Dictionary = {}
var _level_runtime_warmed_scene_paths: Dictionary = {}
var _level_runtime_prewarmed_monster_ids: Dictionary = {}
var _level_preload_generation: int = 0
var _last_sound_play_msec = {}
var _active_sound_players: Dictionary = {}
var _last_sfx_enabled := true
var _last_sfx_volume := INF
const MOBILE_SFX_VOICE_LIMIT := 24
const DESKTOP_SFX_VOICE_LIMIT := 48
const MOBILE_SFX_PER_SOUND_LIMIT := 4
const DESKTOP_SFX_PER_SOUND_LIMIT := 8
var _last_mr_hurt_msec = {}
var _pending_combo_milestones = {}
var _debug_perf_layer: CanvasLayer = null
var _debug_perf_label: Label = null
var _debug_perf_elapsed: float = 0.0
var _debug_perf_last_ticks_msec: int = 0
var _debug_perf_max_frame_ms: float = 0.0
var _sword_damage_text_frame: int = -1
var _sword_damage_text_count: int = 0
var _sword_hit_effect_frame: int = -1
var _sword_hit_effect_count: int = 0
var current_magic_summon: Node = null


func _get_pool_root() -> Node:
	var root = _pool_data.get("root")
	if root != null and is_instance_valid(root):
		return root
	root = Node.new()
	root.name = "RuntimePool"
	add_child(root)
	_pool_data["root"] = root
	return root


func _take_pooled_node(pool, scene_path: String) -> Node:
	while pool.size() > 0:
		var node = pool.pop_back()
		if is_instance_valid(node):
			return node
	var scene = preload_scene_path(scene_path)
	if scene == null:
		return null
	return scene.instantiate()


func _attach_pooled_node(node: Node, parent: Node) -> void:
	if node == null or parent == null:
		return
	var old_parent = node.get_parent()
	if old_parent != null:
		old_parent.remove_child(node)
	parent.add_child(node)


func _store_pooled_node(node: Node, pool: Array, max_size: int) -> void:
	var old_parent = node.get_parent()
	if old_parent != null:
		old_parent.remove_child(node)
	if pool.size() >= max_size:
		node.queue_free()
		return
	_get_pool_root().add_child(node)
	pool.append(node)


func recycle_damage_text(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	_release_damage_text_count(node)
	_store_pooled_node(node, _pool_data["damage_text"], DAMAGE_TEXT_POOL_LIMIT)


func _release_damage_text_count(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	_active_damage_texts.erase(node.get_instance_id())
	if bool(node.get_meta("damage_text_active", false)):
		node.set_meta("damage_text_active", false)
		_on_damage_text_freed()


func _on_damage_text_tree_exited(node: Node) -> void:
	_release_damage_text_count(node)


func recycle_mr_hurt(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	_store_pooled_node(node, _pool_data["mr_hurt"], MR_HURT_POOL_LIMIT)


func recycle_role_be_hit(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	_store_pooled_node(node, _pool_data["role_be_hit"], ROLE_BE_HIT_POOL_LIMIT)


func recycle_sound_player(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	_active_sound_players.erase(node.get_instance_id())
	if not _pool_data["sound_player"].has(node):
		_store_pooled_node(node, _pool_data["sound_player"], SOUND_PLAYER_POOL_LIMIT)


func _on_sound_player_tree_exiting(instance_id: int) -> void:
	_active_sound_players.erase(instance_id)


func _reserve_sound_voice(sound_key: String, priority: int) -> bool:
	var same_count := 0
	var total_victim: AudioStreamPlayer
	var same_victim: AudioStreamPlayer
	var total_priority := priority
	var same_priority := priority
	for id_value in _active_sound_players.keys():
		var entry: Dictionary = _active_sound_players[id_value]
		var node: Variant = entry.get("node")
		if not is_instance_valid(node) or not node.is_inside_tree() or node.is_queued_for_deletion():
			_active_sound_players.erase(id_value)
			continue
		var node_priority := int(entry["priority"])
		if node_priority < total_priority:
			total_priority = node_priority
			total_victim = node as AudioStreamPlayer
		if str(entry["key"]) == sound_key:
			same_count += 1
			if node_priority < same_priority:
				same_priority = node_priority
				same_victim = node as AudioStreamPlayer
	var mobile := OS.has_feature("mobile")
	var same_limit := MOBILE_SFX_PER_SOUND_LIMIT if mobile else DESKTOP_SFX_PER_SOUND_LIMIT
	var total_limit := MOBILE_SFX_VOICE_LIMIT if mobile else DESKTOP_SFX_VOICE_LIMIT
	var victim: AudioStreamPlayer
	if same_count >= same_limit:
		victim = same_victim
	elif _active_sound_players.size() >= total_limit:
		victim = total_victim
	else:
		return true
	if victim == null:
		return false
	victim.call("_on_finished")
	return true


func _create_debug_perf_overlay() -> void:
	if _debug_perf_layer != null and is_instance_valid(_debug_perf_layer):
		return
	_debug_perf_layer = CanvasLayer.new()
	_debug_perf_layer.name = "DebugPerfOverlay"
	_debug_perf_layer.layer = 4096
	add_child(_debug_perf_layer)
	_debug_perf_label = Label.new()
	_debug_perf_label.name = "DebugPerfLabel"
	_debug_perf_label.position = Vector2(8, 6)
	_debug_perf_label.z_index = 4096
	_debug_perf_label.add_theme_font_size_override("font_size", 12)
	_debug_perf_label.add_theme_color_override("font_color", Color(0.1, 1.0, 0.25, 1.0))
	_debug_perf_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_debug_perf_label.add_theme_constant_override("outline_size", 1)
	_debug_perf_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	_debug_perf_label.add_theme_constant_override("shadow_offset_x", 0)
	_debug_perf_label.add_theme_constant_override("shadow_offset_y", 0)
	_debug_perf_layer.add_child(_debug_perf_label)
	_debug_perf_last_ticks_msec = Time.get_ticks_msec()
	_update_debug_perf_overlay()


func _format_debug_memory(bytes_value: int) -> String:
	var mb := float(bytes_value) / 1024.0 / 1024.0
	return str(snapped(mb, 0.1)) + " MB"


func _get_process_memory_from_proc_status() -> Dictionary:
	var result := {"rss": -1, "peak": -1, "source": ""}
	var file := FileAccess.open("/proc/self/status", FileAccess.READ)
	if file == null:
		file = FileAccess.open("/proc/" + str(OS.get_process_id()) + "/status", FileAccess.READ)
	if file == null:
		result["rss"] = OS.get_static_memory_usage()
		result["peak"] = OS.get_static_memory_peak_usage()
		result["source"] = "Godot"
		return result
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.begins_with("VmRSS:"):
			result["rss"] = _parse_proc_status_kb_line(line)
		elif line.begins_with("VmHWM:"):
			result["peak"] = _parse_proc_status_kb_line(line)
	if int(result["rss"]) >= 0:
		result["source"] = "真实"
	else:
		result["rss"] = OS.get_static_memory_usage()
		result["peak"] = OS.get_static_memory_peak_usage()
		result["source"] = "Godot"
	return result


func _parse_proc_status_kb_line(line: String) -> int:
	var parts := line.split(" ", false)
	for part in parts:
		if part.is_valid_int():
			return int(part) * 1024
	return -1


func _update_debug_perf_overlay() -> void:
	if _debug_perf_label == null or not is_instance_valid(_debug_perf_label):
		return
	var fps := Engine.get_frames_per_second()
	var render_total_mem := int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))
	_debug_perf_label.text = "FPS: " + str(fps) + "\n显存: " + _format_debug_memory(render_total_mem)
	_debug_perf_max_frame_ms = 0.0


func _debug_count_live_monsters() -> int:
	var tree := get_tree()
	if tree == null or tree.current_scene == null:
		return 0
	var root := tree.current_scene
	var monster_root := root.get_node_or_null("Monster")
	if monster_root == null:
		return 0
	var count := 0
	for child in monster_root.get_children():
		if child is BaseMonster and not child.death():
			count += 1
	return count


func can_show_sword_damage_text() -> bool:
	var frame := int(Engine.get_process_frames())
	if _sword_damage_text_frame != frame:
		_sword_damage_text_frame = frame
		_sword_damage_text_count = 0
	var limit := 3 if OS.has_feature("mobile") else 6
	if _sword_damage_text_count >= limit:
		return false
	_sword_damage_text_count += 1
	return true


func can_show_sword_hit_effect() -> bool:
	var frame := int(Engine.get_process_frames())
	if _sword_hit_effect_frame != frame:
		_sword_hit_effect_frame = frame
		_sword_hit_effect_count = 0
	var limit := 2 if OS.has_feature("mobile") else 4
	if _sword_hit_effect_count >= limit:
		return false
	_sword_hit_effect_count += 1
	return true


func _load_scene(path: String) -> PackedScene:
	if _permanent_small_ui_scene_cache.has(path):
		var permanent_scene: Variant = _permanent_small_ui_scene_cache[path]
		if _is_valid_packed_scene(permanent_scene):
			return permanent_scene
		_permanent_small_ui_scene_cache.erase(path)
	if _resource_cache.has(path) and not _is_valid_packed_scene(_resource_cache[path]):
		_resource_cache.erase(path)
	if not _resource_cache.has(path):
		if _is_runtime_ui_scene_path(path):
			_resource_cache[path] = ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
		else:
			_resource_cache[path] = load(path)
	var cached_scene: Variant = _resource_cache.get(path)
	if path in PERMANENT_SMALL_UI_SCENE_PATHS and _is_valid_packed_scene(cached_scene):
		_permanent_small_ui_scene_cache[path] = cached_scene
	return _resource_cache[path]


func _is_valid_packed_scene(value: Variant) -> bool:
	if not is_instance_valid(value):
		return false
	return value is PackedScene


func load_ui_scene(path: String) -> PackedScene:
	if not _is_runtime_ui_scene_path(path):
		return load(path) as PackedScene
	return _load_scene(path) as PackedScene


func prewarm_permanent_small_ui_scenes() -> void:
	if _permanent_ui_prewarm_in_progress or _permanent_ui_prewarmed:
		return
	_permanent_ui_prewarm_in_progress = true
	for scene_path in PERMANENT_SMALL_UI_SCENE_PATHS:
		if not _permanent_small_ui_scene_cache.has(scene_path):
			_load_scene(scene_path)
		await get_tree().process_frame
	_permanent_ui_prewarm_in_progress = false
	_permanent_ui_prewarmed = true


func get_level_info_monster_ids(level_name: String) -> Array:
	if level_name == "":
		return []
	var level_info_scene: PackedScene = LevelInfo as PackedScene
	if level_info_scene == null:
		level_info_scene = _load_scene("res://Scene/other_scene/LevelInfo.tscn") as PackedScene
	if level_info_scene == null:
		return []
	var probe := level_info_scene.instantiate()
	if probe == null:
		return []
	var all_info: Variant = probe.get("LevelInfo")
	if not all_info is Dictionary:
		probe.free()
		return []
	var level_info: Variant = (all_info as Dictionary).get(level_name, {})
	if not level_info is Dictionary:
		probe.free()
		return []
	var result: Array = []
	var monster_list: Variant = (level_info as Dictionary).get("MonsterList", [])
	if monster_list is Array:
		for monster_entry_value in monster_list:
			if not monster_entry_value is Dictionary:
				continue
			var monster_entry: Dictionary = monster_entry_value
			var monster_id := int(monster_entry.get("ConfigId", 0))
			if monster_id <= 0:
				var scene_path := str(monster_entry.get("ScenePath", ""))
				var monster_file := scene_path.get_file().get_basename()
				if monster_file.begins_with("Monster_"):
					var monster_id_text := monster_file.trim_prefix("Monster_")
					if monster_id_text.is_valid_int():
						monster_id = int(monster_id_text)
			if monster_id > 0 and not result.has(monster_id):
				result.append(monster_id)
	probe.free()
	return result


func get_cached_audio(path: String) -> AudioStream:
	var resolved_path := path
	if path.ends_with("/effect4.mp3"):
		resolved_path = path.replace("effect4.mp3", "effect3.mp3")
	if path == "":
		return null
	if not _audio_cache.has(path):
		_audio_cache[path] = load(resolved_path)
	return _audio_cache[path] as AudioStream


func get_cached_texture(path: String) -> Texture2D:
	var resolved_path := path
	if path.ends_with("/mp_poision.png"):
		resolved_path = path.replace("mp_poision.png", "poision.png")
	resolved_path = DuplicateTextureAliases.resolve(resolved_path)
	if path == "":
		return null
	if not _texture_cache.has(path) or _texture_cache[path] == null:
		var texture := MonsterAtlasSequence.texture_for_source_path(resolved_path)
		if texture == null:
			texture = load(resolved_path) as Texture2D
		if texture != null:
			_texture_cache[path] = texture
		else:
			_texture_cache.erase(path)
		return texture
	return _texture_cache[path] as Texture2D


func release_cached_texture(path: String) -> void:
	if path == "":
		return
	_texture_cache.erase(path)
	var resolved_path := DuplicateTextureAliases.resolve(path)
	if resolved_path != path:
		_texture_cache.erase(resolved_path)


func preload_scene_path(path: String) -> PackedScene:
	return _load_scene(path) as PackedScene


func prewarm_skill_page_resources() -> void:
	var paths: Array = [
		"res://Scene/Skill/Learn_skill.tscn",
		"res://Scene/Skill/zd_skill.tscn",
		"res://Scene/Skill/bd_skill.tscn",
	]
	var role_id := clampi(int(PlayerData.player_data.get("Myself", 1)), 1, 6)
	var role_skill_icons := {
		1: ["slz", "hytj", "lys", "lyfb", "hmz", "hmz_ws", "zz", "qsez", "jdy", "hyjj", "sx", "gsrs", "hyjj_ws"],
		2: ["blb", "xbz", "shy", "tjgl", "smb", "sgq", "myhc", "jgz", "jhsj", "sjt", "by", "zfjg"],
		3: ["ssp", "dj", "dgq", "zznh", "tmc", "sd", "jsp", "xgq", "syzq", "rj", "bdqk"],
		4: ["qlj", "dcj", "wdzt", "tkj", "mmw", "jdz", "lhsq", "zq", "wdww", "mds", "bylt", "cmly"],
		5: ["xyq", "slq", "blq", "fhf", "cxq", "llrd", "lljy", "ygth", "tllz", "yyb", "ltjz"],
		6: ["nz_jlsh", "nz_fhcc", "nz_hlqg", "nz_hlhs", "nz_lblc"],
	}
	for icon_name in role_skill_icons[role_id]:
		paths.append("res://Art/Skill/SkillIcon/%s.png" % icon_name)
	await _preload_paths_threaded(paths)
	Skill_learn = _resource_cache.get("res://Scene/Skill/Learn_skill.tscn") as PackedScene
	zd_skill = _resource_cache.get("res://Scene/Skill/zd_skill.tscn") as PackedScene
	bd_skill = _resource_cache.get("res://Scene/Skill/bd_skill.tscn") as PackedScene


func load_scene_uncached(path: String) -> PackedScene:
	if path == "":
		return null
	if _resource_cache.has(path):
		return _resource_cache[path] as PackedScene
	var scene := ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
	if scene != null:
		_resource_cache[path] = scene
		_track_level_resource(path)
	return scene


func load_level_monster_scene(path: String) -> PackedScene:
	if path == "":
		return null
	if _monster_scene_cache.has(path):
		return _monster_scene_cache[path] as PackedScene
	var scene := _load_scene(path) as PackedScene
	if scene != null:
		_monster_scene_cache[path] = scene
		_track_level_resource(path)
	return scene


func _canonical_monster_scene_id(monster_id: int) -> int:
	return int(MONSTER_SCENE_ALIASES.get(monster_id, monster_id))


func _monster_scene_path(monster_id: int) -> String:
	return "res://Scene/Monster/Monster_%d.tscn" % _canonical_monster_scene_id(monster_id)


func preload_level_monster_scenes(monster_ids: Array) -> void:
	var scene_paths: Array = []
	var seen_ids := {}
	for monster_id_value in monster_ids:
		var monster_id := _canonical_monster_scene_id(int(monster_id_value))
		if monster_id <= 0 or seen_ids.has(monster_id):
			continue
		seen_ids[monster_id] = true
		scene_paths.append(_monster_scene_path(monster_id))
	if scene_paths.is_empty():
		return
	_track_level_scene_dependencies(scene_paths)
	await _preload_paths_threaded(scene_paths)
	for path_value in scene_paths:
		var path := str(path_value)
		var scene = _resource_cache.get(path)
		if scene is PackedScene:
			_monster_scene_cache[path] = scene


func prewarm_monster_scene_paths(scene_paths: Array) -> void:
	var pending_paths: Array[String] = []
	for path_value in scene_paths:
		var path := str(path_value)
		if path == "" or _level_runtime_warmed_scene_paths.has(path) or pending_paths.has(path):
			continue
		pending_paths.append(path)
	if pending_paths.is_empty():
		return
	_track_level_scene_dependencies(pending_paths)
	await _preload_paths_threaded(pending_paths)
	await _warm_scene_paths_over_frames(pending_paths, 1)
	for path in pending_paths:
		var scene = _resource_cache.get(path)
		if scene is PackedScene:
			_monster_scene_cache[path] = scene
			_level_runtime_warmed_scene_paths[path] = true


func preload_level_monster_runtime_resources(monster_ids: Array) -> void:
	var requested_monster_ids: Array = monster_ids.duplicate()

	var unique_monster_ids: Array = []
	var seen_monster_ids: Dictionary = {}
	for monster_id_value in requested_monster_ids:
		var monster_id := int(monster_id_value)
		if monster_id <= 0 or seen_monster_ids.has(monster_id) or _level_runtime_prewarmed_monster_ids.has(monster_id):
			continue
		seen_monster_ids[monster_id] = true
		unique_monster_ids.append(monster_id)
	if unique_monster_ids.is_empty():
		return

	var texture_paths: Array = []

	for monster_id in unique_monster_ids:
		var manifest_path := MonsterAtlasSequence.manifest_for_model(monster_id)
		if monster_id in [3323, 3343]:
			manifest_path = "res://Art/Monster/PalaceBoss/%d/manifest.json" % monster_id
		elif monster_id == 3352:
			manifest_path = "res://Art/Monster/CloudBoss/3352/manifest.json"
		elif not NorthOriginalData.monster_record(monster_id).is_empty():
			manifest_path = NorthOriginalData.manifest(monster_id)
		if manifest_path.is_empty():
			continue
		var manifest := MonsterAtlasSequence.manifest_data(manifest_path)
		for page_value in manifest.get("pages", []):
			if page_value is Dictionary:
				_append_unique_preload_path(texture_paths, str((page_value as Dictionary).get("path", "")))
	_append_dynamic_monster_textures(texture_paths, unique_monster_ids)
	if not texture_paths.is_empty():
		var textures_per_frame := 2 if OS.has_feature("mobile") else 5
		if seen_monster_ids.has(3343):
			textures_per_frame = 1
		await preload_level_texture_paths(texture_paths, textures_per_frame)

	var streamed_effect_roots: Array = []
	_append_dynamic_monster_stream_effect_roots(streamed_effect_roots, unique_monster_ids)
	if not streamed_effect_roots.is_empty():
		await STREAMED_PNG_EFFECT_SCRIPT.prewarm_effect_roots(streamed_effect_roots, 3)

	if seen_monster_ids.has(5):
		await MonsterBullet.warm_monster5_stream_images()
	if seen_monster_ids.has(212):
		for bullet_script in MONSTER_212_BULLET_SCRIPTS:
			bullet_script.prewarm_frames()
			await get_tree().process_frame

	var tiger_stage := 0
	for monster_id in unique_monster_ids:
		if monster_id >= 1501 and monster_id <= 1504:
			tiger_stage = maxi(tiger_stage, monster_id - 1500)
	if tiger_stage > 0:
		await MonsterBullet.prewarm_pet_tiger_runtime(tiger_stage)

	var monster_scene_paths: Array[String] = []
	for monster_id in unique_monster_ids:
		var scene_path := _monster_scene_path(monster_id)
		if ResourceLoader.exists(scene_path) and not monster_scene_paths.has(scene_path):
			monster_scene_paths.append(scene_path)
	var bullet_scene_paths := _collect_monster_script_bullet_scene_paths(monster_scene_paths)
	_append_dynamic_monster_scene_paths(bullet_scene_paths, unique_monster_ids)
	await prewarm_monster_bullet_scene_paths(bullet_scene_paths)
	await prewarm_monster_scene_paths(monster_scene_paths)

	for monster_id in unique_monster_ids:
		_level_runtime_prewarmed_monster_ids[monster_id] = true


func preload_level_texture_paths(texture_paths: Array, textures_per_frame: int = 5) -> void:
	var unique_paths: Array = []
	for path_value in texture_paths:
		var path := str(path_value)
		if path == "" or unique_paths.has(path):
			continue
		unique_paths.append(path)
		_track_level_resource(path)
	if unique_paths.is_empty():
		return
	await _preload_paths_threaded(unique_paths)
	await _warm_texture_rids_over_frames(unique_paths, maxi(1, textures_per_frame))


func load_monster_bullet_scene(bullet_name: String) -> PackedScene:
	var slim_path := MONSTER_BULLET_SLIM_DIR.path_join(bullet_name + ".tscn")
	if ResourceLoader.exists(slim_path):
		return load_scene_uncached(slim_path)
	_last_full_monster_bullet_name = bullet_name

	var fallback := load_scene_uncached(MONSTER_BULLET_PATH)
	if fallback != null:
		return fallback
	push_error("Missing MonsterBullet scene: %s" % bullet_name)
	return null


func load_fly_bullet_scene(bullet_name: String) -> PackedScene:
	var slim_path := FLY_BULLET_SLIM_DIR.path_join(bullet_name + ".tscn")
	if ResourceLoader.exists(slim_path):
		return load_scene_uncached(slim_path)
	return _cached_scene(&"FlyBullet", FLY_BULLET_PATH)


func _cache_threaded_resource(path: String, resource: Resource) -> void:
	if resource == null:
		return
	if resource is PackedScene or path.ends_with(".tscn"):
		_resource_cache[path] = resource
	elif resource is AudioStream:
		_audio_cache[path] = resource
	elif resource is Texture2D:
		_texture_cache[path] = resource
	else:
		_resource_cache[path] = resource


func _preload_paths_threaded(paths: Array) -> void:
	var request_paths: Array[String] = []
	var seen_paths: Dictionary = {}
	for path_value in paths:
		var path := str(path_value)
		if path == "":
			continue
		if _resource_cache.has(path) or _audio_cache.has(path) or _texture_cache.has(path):
			continue
		if seen_paths.has(path):
			continue
		seen_paths[path] = true
		request_paths.append(path)

	var batch_size := _get_threaded_preload_batch_size(request_paths.size())
	var batch_start := 0
	while batch_start < request_paths.size():
		var pending: Array[String] = []
		var batch_end := mini(batch_start + batch_size, request_paths.size())
		for index in range(batch_start, batch_end):
			var path := request_paths[index]
			var err = ResourceLoader.load_threaded_request(path)
			if err == OK or err == ERR_BUSY:
				pending.append(path)
			else:
				var resource = load(path)
				_cache_threaded_resource(path, resource)
		while not pending.is_empty():
			var i := pending.size() - 1
			while i >= 0:
				var path := pending[i]
				var status = ResourceLoader.load_threaded_get_status(path)
				if status == ResourceLoader.THREAD_LOAD_LOADED:
					var resource = ResourceLoader.load_threaded_get(path)
					_cache_threaded_resource(path, resource)
					pending.remove_at(i)
				elif (
					status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
				):
					pending.remove_at(i)
				i -= 1
			if not pending.is_empty():
				await get_tree().process_frame
		batch_start = batch_end


func _get_threaded_preload_batch_size(request_count: int) -> int:
	if request_count <= 0:
		return 1
	return mini(request_count, 2 if OS.has_feature("mobile") else 4)


func _warm_scene_paths_over_frames(paths: Array, per_frame: int = 2) -> void:
	var warmed_this_frame := 0
	for path in paths:
		var scene = preload_scene_path(str(path))
		if scene != null:
			_warm_scene_instance(scene)
			warmed_this_frame += 1
			if warmed_this_frame >= per_frame:
				warmed_this_frame = 0
				await get_tree().process_frame


func _release_warm_audio_players(players: Array[AudioStreamPlayer]) -> void:
	for player in players:
		if player == null or not is_instance_valid(player):
			continue
		player.stop()
		player.stream = null
		player.free()
	players.clear()


func _warm_audio_streams_over_frames(paths: Array, per_frame: int = 2) -> void:
	var players: Array[AudioStreamPlayer] = []
	var batch_size := maxi(1, per_frame)
	for path_value in paths:
		var stream := get_cached_audio(str(path_value))
		if stream == null:
			continue
		var player := AudioStreamPlayer.new()
		player.volume_db = -80.0
		player.stream = stream
		add_child(player)
		player.play()
		players.append(player)
		if players.size() >= batch_size:
			await get_tree().process_frame
			_release_warm_audio_players(players)
	if not players.is_empty():
		await get_tree().process_frame
		_release_warm_audio_players(players)


func _warm_texture_rids_over_frames(paths: Array, per_frame: int = 6) -> void:
	var warmed_this_frame := 0
	for path in paths:
		var texture := get_cached_texture(str(path))
		if texture == null:
			continue
		texture.get_rid()
		warmed_this_frame += 1
		if warmed_this_frame >= per_frame:
			warmed_this_frame = 0
			if DisplayServer.get_name() == "headless":
				await get_tree().process_frame
			else:
				await RenderingServer.frame_post_draw


func _get_damage_number_texture_paths() -> Array:
	var result: Array = []
	var number_dirs: Array[String] = [
		"res://Art/AllNumber/cure/cure_",
		"res://Art/AllNumber/CureMp/CureMp_",
		"res://Art/AllNumber/ReduceMp/ReduceMp_",
		"res://Art/AllNumber/Physics/physics_",
		"res://Art/AllNumber/physicscrit/physics_",
		"res://Art/AllNumber/magic/magic_",
		"res://Art/AllNumber/magic/physics_",
		"res://Art/AllNumber/magiccrit/magic_",
		"res://Art/AllNumber/real/real_",
		"res://Art/AllNumber/realcrit/real_",
		"res://Art/AllNumber/LJ/lj_",
		"res://Art/AllNumber/monster/physics/physics_",
		"res://Art/AllNumber/monster/magic/magic_",
	]
	for prefix in number_dirs:
		for i in range(10):
			result.append(prefix + str(i) + ".png")
	return result


func preload_combat_hit_resources() -> void:
	preload_damage_number_textures()
	_cached_scene(&"hit_text", HIT_TEXT_PATH)
	var damage_scene := _cached_scene(&"damage_text", DAMAGE_TEXT_PATH)
	_cached_scene(&"DamageNumber", DAMAGE_NUMBER_PATH)
	_cached_scene(&"MissEffect", MISS_EFFECT_PATH)
	var role_be_hit_scene := preload_scene_path(ROLE_BE_HIT_EFFECT_PATH)
	var monster_hit_scene := _cached_scene(&"monster_be_hit", MONSTER_BE_HIT_PATH)
	var monster_blood_scene := _cached_scene(&"monster_blood", MONSTER_BLOOD_PATH)
	var sound_scene := preload_scene_path("res://Scene/AllSound/monster_be_hit.tscn")
	get_cached_audio("res://Music/MonsterHurt/6_BeattackByRole1.mp3")
	get_cached_audio("res://Music/Hero/9_BeattackByRole2.mp3")
	get_cached_audio("res://Music/Hero/49_Role1_beAttack.mp3")
	get_cached_audio("res://Music/Hero/62_Role2_beAttack.mp3")
	get_cached_audio("res://Music/Hero/68_Role3_beAttack.mp3")
	_seed_runtime_pool("damage_text", damage_scene, COMBAT_HIT_DAMAGE_POOL_SIZE, &"prepare_for_pool")
	_seed_runtime_pool("mr_hurt", monster_hit_scene, COMBAT_HIT_EFFECT_POOL_SIZE)
	_seed_runtime_pool("role_be_hit", role_be_hit_scene, COMBAT_HIT_EFFECT_POOL_SIZE)
	_seed_runtime_pool("sound_player", sound_scene, COMBAT_HIT_SOUND_POOL_SIZE)
	await _prewarm_combat_hit_rendering(monster_blood_scene)


func _seed_runtime_pool(
	pool_name: String, scene: PackedScene, target_size: int, prepare_method: StringName = &""
) -> void:
	if scene == null:
		return
	var pool: Array = _pool_data[pool_name]
	while pool.size() < target_size:
		var node := scene.instantiate()
		if node == null:
			return
		_get_pool_root().add_child(node)
		if prepare_method != &"" and node.has_method(prepare_method):
			node.call(prepare_method)
		if node is CanvasItem:
			(node as CanvasItem).visible = false
		if node is AudioStreamPlayer:
			node.set_physics_process(false)
		pool.append(node)


func _prewarm_combat_hit_rendering(monster_blood_scene: PackedScene) -> void:
	var tree := get_tree()
	if tree == null:
		return
	var warm_root := Node2D.new()
	warm_root.name = "CombatHitPrewarm"
	warm_root.z_index = -4096
	warm_root.position = get_viewport().get_visible_rect().get_center()
	add_child(warm_root)

	var role_hit = _take_pooled_node(_pool_data["role_be_hit"], ROLE_BE_HIT_EFFECT_PATH)
	if role_hit != null:
		_attach_pooled_node(role_hit, warm_root)
		role_hit.setup(Vector2.ONE, false, 1.0)
		role_hit.modulate.a = 0.001

	var damage_sample = _take_pooled_node(_pool_data["damage_text"], DAMAGE_TEXT_PATH)
	if damage_sample != null:
		_attach_pooled_node(damage_sample, warm_root)
		damage_sample.setup(88888888, "physics", false, null)
		damage_sample.modulate.a = 0.001
		var damage_player := damage_sample.get_node_or_null("ShowPlayer") as AnimationPlayer
		if damage_player != null and damage_player.has_animation(&"physics"):
			damage_player.play(&"physics")

	var monster_hits: Array[Node] = []
	for animation_name in [&"hurt_1", &"hurt_2"]:
		var monster_hit = _take_pooled_node(_pool_data["mr_hurt"], MONSTER_BE_HIT_PATH)
		if monster_hit == null:
			continue
		_attach_pooled_node(monster_hit, warm_root)
		monster_hit.visible = true
		monster_hit.modulate.a = 0.001
		var animation_player := monster_hit.get_node_or_null("AnimationPlayer") as AnimationPlayer
		if animation_player != null and animation_player.has_animation(animation_name):
			animation_player.play(animation_name)
		monster_hits.append(monster_hit)

	if monster_blood_scene != null:
		var blood_bar := monster_blood_scene.instantiate() as Node2D
		if blood_bar != null:
			blood_bar.process_mode = Node.PROCESS_MODE_DISABLED
			blood_bar.modulate.a = 0.001
			warm_root.add_child(blood_bar)
			var progress_bar := blood_bar.get_node_or_null("blood_bar") as TextureProgressBar
			var blood_label := blood_bar.get_node_or_null("blood_bar/blood_text") as Label
			if progress_bar != null:
				progress_bar.value = 0.75
			if blood_label != null:
				blood_label.text = "123456"

	for texture_path in [
		"res://Art/AllNumber/magic/physics_8.png",
		"res://Art/AllNumber/magic/magic_8.png",
		"res://Art/AllNumber/real/real_8.png",
	]:
		var digit_sprite := Sprite2D.new()
		digit_sprite.texture = get_cached_texture(texture_path)
		digit_sprite.modulate.a = 0.001
		warm_root.add_child(digit_sprite)

	var sound_players: Array[AudioStreamPlayer] = []
	for sound_path in [
		"res://Music/MonsterHurt/6_BeattackByRole1.mp3",
		"res://Music/Hero/9_BeattackByRole2.mp3",
	]:
		var sound_player = (
			_take_pooled_node(_pool_data["sound_player"], "res://Scene/AllSound/monster_be_hit.tscn")
			as AudioStreamPlayer
		)
		if sound_player == null:
			continue
		_attach_pooled_node(sound_player, warm_root)
		sound_player.set_physics_process(false)
		sound_player.volume_db = -80.0
		sound_player.stream = get_cached_audio(sound_path)
		sound_player.play()
		sound_players.append(sound_player)

	await tree.process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw

	if role_hit != null and is_instance_valid(role_hit):
		role_hit.modulate = Color.WHITE
		role_hit.recycle()
	if damage_sample != null and is_instance_valid(damage_sample):
		damage_sample.modulate = Color.WHITE
		damage_sample.recycle()
	for monster_hit in monster_hits:
		if monster_hit != null and is_instance_valid(monster_hit):
			monster_hit.modulate = Color.WHITE
			monster_hit.recycle()
	for sound_player in sound_players:
		if sound_player == null or not is_instance_valid(sound_player):
			continue
		sound_player.stop()
		sound_player.stream = null
		sound_player.set_physics_process(false)
		if not _pool_data["sound_player"].has(sound_player):
			recycle_sound_player(sound_player)
	if is_instance_valid(warm_root):
		warm_root.free()


func _warm_scene_instance(scene: PackedScene) -> void:
	if scene == null:
		return
	var node := scene.instantiate()
	if node != null:
		node.free()


func clear_level_resource_cache() -> void:
	_level_preload_generation += 1
	_level_resource_preload_signature = ""
	STREAMED_PNG_EFFECT_SCRIPT.clear_prewarmed_images()
	MonsterAtlasSequence.clear_cache()
	for bullet_script in MONSTER_212_BULLET_SCRIPTS:
		bullet_script.clear_cached_frames()
	for path_value in _level_resource_cache_paths.keys():
		var path := str(path_value)
		_resource_cache.erase(path)
		_texture_cache.erase(path)
		_audio_cache.erase(path)
	_level_resource_cache_paths.clear()
	_level_runtime_warmed_scene_paths.clear()
	_level_runtime_prewarmed_monster_ids.clear()
	_monster_scene_cache.clear()


func release_map_visual_resources(root: Node) -> void:
	if root == null or not is_instance_valid(root):
		return
	for child in root.get_children():
		release_map_visual_resources(child)
	var sprite := root as Sprite2D
	if sprite != null:
		sprite.texture = null
	var texture_rect := root as TextureRect
	if texture_rect != null:
		texture_rect.texture = null
	var texture_button := root as TextureButton
	if texture_button != null:
		texture_button.texture_normal = null
		texture_button.texture_pressed = null
		texture_button.texture_hover = null
		texture_button.texture_disabled = null
		texture_button.texture_focused = null
	var progress_bar := root as TextureProgressBar
	if progress_bar != null:
		progress_bar.texture_under = null
		progress_bar.texture_progress = null
		progress_bar.texture_over = null
	var animated_sprite := root as AnimatedSprite2D
	if animated_sprite != null:
		animated_sprite.sprite_frames = null
	var nine_patch := root as NinePatchRect
	if nine_patch != null:
		nine_patch.texture = null


func clear_combat_runtime_cache() -> void:
	clear_level_resource_cache()
	_clear_runtime_pools()
	NeZhaEquipmentVisuals.clear_cached_frames()
	_prewarmed_role_id = 0
	_prewarmed_pet_signature = ""
	_current_role_body_texture_path = ""
	_current_role_equipment_texture_path = ""
	var combat_prefixes := [
		"res://Art/HeroPicture/",
		"res://Art/Monster/",
		"res://Art/Level/",
		"res://Art/Pet/",
		"res://Art/MagicWeapon/",
		"res://Art/zhuxianjianzhen/",
		"res://Art/AddEffect/",
		"res://Art/AllNumber/",
		"res://Scene/Hero/",
		"res://Scene/Monster/",
		"res://Scene/MagicWeapon/",
		"res://Scene/Pet/",
	]
	_erase_cached_paths_by_prefix(_resource_cache, combat_prefixes)
	_erase_cached_paths_by_prefix(_texture_cache, combat_prefixes)
	_erase_cached_paths_by_prefix(
		_audio_cache,
		[
			"res://Music/Hero/",
			"res://Music/MonsterHurt/",
			"res://Music/level/",
		]
	)

	hit_text = null
	damage_text = null
	monster_blood = null
	monster_be_hit = null
	SpecialAffect = null
	DamageNumber = null
	MissEffect = null
	RoleBullet_ = null
	FlyBullet = null
	ChaseBullet_ = null
	SpecialEffectBullet = null
	Role4Bullet_ = null
	RoleBullet_1 = null
	Role1Shallow = null
	Monster65Bullet = null
	RoleSpecialEffect_ = null
	Role2Shallow = null
	SMBEffect = null
	NewBullet = null
	BossBlood_ = null
	_all_hero_skill_resources_preloaded = false
	if current_magic_summon != null and is_instance_valid(current_magic_summon):
		current_magic_summon.queue_free()
	current_magic_summon = null


func is_archive_exit_scene(scene_path: String) -> bool:
	return (
		scene_path
		in [
			"res://Scene/main_menu/Main_Menu.tscn",
			"res://Scene/main_menu/ChoosePlayer.tscn",
		]
	)


func begin_archive_session() -> void:
	var role_id := _current_role_id()
	if archive_session_active and archive_session_role_id == role_id:
		return
	if archive_session_active and archive_session_role_id != role_id:
		release_role_runtime_resources()
	archive_session_active = true
	archive_session_role_id = role_id
	_archive_session_generation += 1
	if _archive_session_prewarm_in_progress:
		call_deferred("begin_archive_session")
		return
	_archive_session_prewarm_in_progress = true
	var generation := _archive_session_generation
	await prewarm_permanent_small_ui_scenes()
	if generation != _archive_session_generation or not archive_session_active:
		_archive_session_prewarm_in_progress = false
		return
	await prewarm_skill_page_resources()
	if generation != _archive_session_generation or not archive_session_active:
		_archive_session_prewarm_in_progress = false
		return
	await _prewarm_archive_role_resources(role_id)
	if generation != _archive_session_generation or not archive_session_active:
		_archive_session_prewarm_in_progress = false
		return
	_archive_session_prewarm_in_progress = false


func _prewarm_archive_role_resources(role_id: int) -> void:
	var role_paths: Array[String] = []
	role_paths.append_array(get_current_role_equipment_preload_paths(role_id))
	await _preload_paths_threaded(role_paths)
	await prewarm_current_role_runtime_resources(role_id)


func _role_scene_path(role_id: int) -> String:
	return (
		{
			1: "res://Scene/Hero/Role_1/Role1.tscn",
			2: "res://Scene/Hero/Role_2/Role_2.tscn",
			3: "res://Scene/Hero/Role_3/Role_3.tscn",
			4: "res://Scene/Hero/Role_4/Role_4.tscn",
			5: "res://Scene/Hero/Role_5/Role_5.tscn",
			6: "res://Scene/Hero/Role_6/Role_6.tscn",
		}
		. get(role_id, "")
	)


func _current_visual_equipment_names() -> Dictionary:
	var weapon_name := "Empty"
	var body_name := "Empty"
	var transmog: Variant = PlayerData.player_data.get(DataKeys.TRANSMOG_LIST, {})
	var weapon_transmog := str(transmog.get(DataKeys.WEAPON, "")) if transmog is Dictionary else ""
	var body_transmog := str(transmog.get(DataKeys.ARMOR, "")) if transmog is Dictionary else ""
	var weapons: Variant = PlayerData.player_data.get(DataKeys.WEAPON, [])
	var fashions: Variant = PlayerData.player_data.get(DataKeys.FASHION, [])
	var armors: Variant = PlayerData.player_data.get(DataKeys.ARMOR, [])
	if weapon_transmog != "":
		weapon_name = weapon_transmog
	elif weapons is Array and not weapons.is_empty() and weapons[0] is Dictionary:
		weapon_name = str((weapons[0] as Dictionary).get(DataKeys.NAME, "Empty"))
	if body_transmog != "":
		body_name = body_transmog
	elif fashions is Array and not fashions.is_empty() and fashions[0] is Dictionary:
		body_name = str((fashions[0] as Dictionary).get(DataKeys.NAME, "Empty"))
	elif armors is Array and not armors.is_empty() and armors[0] is Dictionary:
		body_name = str((armors[0] as Dictionary).get(DataKeys.NAME, "Empty"))
	return {"weapon": weapon_name, "body": body_name}


func get_current_role_equipment_preload_paths(role_id: int = 0) -> Array[String]:
	if role_id <= 0:
		role_id = _current_role_id()
	var names := _current_visual_equipment_names()
	var paths: Array[String] = []
	if role_id == 6:
		NeZhaEquipmentVisuals.get_body_frames(str(names.get("body", "Empty")))
		NeZhaEquipmentVisuals.get_body_front_frames(str(names.get("body", "Empty")))
		NeZhaEquipmentVisuals.get_weapon_frames(str(names.get("weapon", "Empty")))
		return paths
	var body_name: String = str(get_clean_name(str(names.get("body", "Empty"))))
	var weapon_name: String = str(names.get("weapon", "Empty"))
	var body_path := "res://Art/HeroPicture/Role%dAllEquipment/Role_%d_Body_%s.png" % [role_id, role_id, body_name]
	var weapon_path := "res://Art/HeroPicture/Role%dAllEquipment/Role_%d_Eq_%s.png" % [role_id, role_id, weapon_name]
	if ResourceLoader.exists(body_path):
		paths.append(body_path)
	if ResourceLoader.exists(weapon_path):
		paths.append(weapon_path)
	return paths


func end_archive_session() -> void:
	if not archive_session_active and archive_session_role_id == 0:
		return
	_archive_session_generation += 1
	clear_combat_runtime_cache()

	HMZ_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	LYFB_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	JHSJ_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	CANG_MU_LONG_YUN_EFFECT_SCRIPT.clear_cached_data()
	ROLE4_POISON_ARRAY_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	STREAMING_ROLE_BULLET_SCRIPT.clear_cached_frames()
	MIRROR_SCRIPT.clear_cached_frames()
	archive_session_active = false
	archive_session_role_id = 0
	_archive_session_prewarm_in_progress = false


func _clear_runtime_pools() -> void:
	for pool_name in ["damage_text", "mr_hurt", "role_be_hit", "sound_player"]:
		var pool: Array = _pool_data[pool_name]
		for node_value in pool:
			var node := node_value as Node
			if node == null or not is_instance_valid(node):
				continue
			if node is AudioStreamPlayer:
				(node as AudioStreamPlayer).stop()
				(node as AudioStreamPlayer).stream = null
			node.queue_free()
		pool.clear()
	var pool_root := _pool_data.get("root") as Node
	if pool_root != null and is_instance_valid(pool_root):
		pool_root.queue_free()
	_pool_data["root"] = null
	_active_damage_texts.clear()
	_damage_text_count = 0


func release_role_runtime_resources() -> void:
	_prewarmed_role_id = 0
	_current_role_body_texture_path = ""
	_current_role_equipment_texture_path = ""
	NeZhaEquipmentVisuals.clear_cached_frames()
	WUSHUANG_HUOYAN_EFFECT_SCRIPT.clear_cached_frames()
	BING_YU_EFFECT_SCRIPT.clear_cached_data()
	BA_DI_QIAN_KUN_EFFECT_SCRIPT.clear_cached_frames()
	BI_LUO_TIAN_EFFECT_SCRIPT.clear_cached_frames()
	LEI_TING_JIE_ZHEN_EFFECT_SCRIPT.clear_cached_frames()
	SMSR_SHENQI_LIGHTNING_EFFECT_SCRIPT.clear_cached_frames()
	HMZ_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	LYFB_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	JHSJ_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	CANG_MU_LONG_YUN_EFFECT_SCRIPT.clear_cached_data()
	ROLE4_POISON_ARRAY_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	STREAMING_ROLE_BULLET_SCRIPT.clear_cached_frames()
	_erase_cached_paths_by_prefix(_resource_cache, ["res://Art/HeroPicture/", "res://Scene/Hero/"])
	_erase_cached_paths_by_prefix(_texture_cache, ["res://Art/HeroPicture/"])
	_erase_cached_paths_by_prefix(_audio_cache, ["res://Music/Hero/"])
	SpecialEffectBullet = null
	RoleBullet_ = null
	FlyBullet = null
	ChaseBullet_ = null
	Role4Bullet_ = null
	RoleBullet_1 = null
	Role1Shallow = null
	RoleSpecialEffect_ = null
	Role2Shallow = null
	SMBEffect = null
	NewBullet = null


func _erase_cached_paths_by_prefix(cache: Dictionary, prefixes: Array) -> void:
	for path_value in cache.keys():
		var path := str(path_value)
		for prefix in prefixes:
			if path.begins_with(str(prefix)):
				cache.erase(path)
				break


func _track_level_resource(path: String) -> void:
	if path != "":
		_level_resource_cache_paths[path] = true


func _dependency_resource_path(dependency: String) -> String:
	var resource_path_start := dependency.find("res://")
	if resource_path_start >= 0:
		return dependency.substr(resource_path_start)
	return dependency


func _track_level_scene_dependencies(scene_paths: Array) -> void:
	for scene_path_value in scene_paths:
		var scene_path := str(scene_path_value)
		_track_level_resource(scene_path)
		for dependency in ResourceLoader.get_dependencies(scene_path):
			var dependency_path := _dependency_resource_path(str(dependency))
			_track_level_resource(dependency_path)


func _append_png_files_recursive(paths: Array, root_path: String) -> void:
	var added_before := paths.size()
	var directories := DirAccess.get_directories_at(root_path)
	for file_name in DirAccess.get_files_at(root_path):
		if file_name.get_extension().to_lower() == "png":
			var path := root_path.path_join(file_name)
			if not paths.has(path):
				paths.append(path)
	for directory_name in directories:
		_append_png_files_recursive(paths, root_path.path_join(directory_name))
	if paths.size() == added_before and directories.is_empty():
		_append_numbered_png_files(paths, root_path)


func _append_numbered_png_files(paths: Array, root_path: String) -> void:
	var missing_streak := 0
	var found_any := false
	for index in range(601):
		var path := root_path.path_join(str(index) + ".png")
		if ResourceLoader.exists(path):
			if not paths.has(path):
				paths.append(path)
			found_any = true
			missing_streak = 0
		elif found_any:
			missing_streak += 1
			if missing_streak >= 30:
				break


func _append_unique_preload_path(paths: Array, path: String) -> void:
	if path != "" and not paths.has(path):
		paths.append(path)


func _collect_scene_texture_dependencies(scene_paths: Array) -> Array:
	var texture_paths: Array = []
	var visited: Dictionary = {}
	for scene_path_value in scene_paths:
		_collect_texture_dependencies_recursive(str(scene_path_value), texture_paths, visited)
	return texture_paths


func _collect_texture_dependencies_recursive(resource_path: String, texture_paths: Array, visited: Dictionary) -> void:
	if resource_path == "" or visited.has(resource_path) or not ResourceLoader.exists(resource_path):
		return
	visited[resource_path] = true
	for dependency in ResourceLoader.get_dependencies(resource_path):
		var dependency_path := _dependency_resource_path(str(dependency))
		var extension := dependency_path.get_extension().to_lower()
		if extension in ["png", "jpg", "jpeg", "webp", "svg"]:
			_append_unique_preload_path(texture_paths, dependency_path)
		elif extension in ["tscn", "tres", "res"]:
			_collect_texture_dependencies_recursive(dependency_path, texture_paths, visited)


func _append_dynamic_monster_textures(texture_paths: Array, monster_ids: Array) -> void:
	for monster_id_value in monster_ids:
		var monster_id := _canonical_monster_scene_id(int(monster_id_value))
		var atlas_manifest := MonsterAtlasSequence.manifest_for_model(monster_id)
		if not atlas_manifest.is_empty():
			continue
		var dynamic_paths: Variant = DYNAMIC_MONSTER_TEXTURE_PATHS.get(monster_id, [])
		if not dynamic_paths is Array:
			continue
		for path_value in dynamic_paths:
			var path := str(path_value)
			if path.get_extension().to_lower() == "png":
				if ResourceLoader.exists(path):
					_append_unique_preload_path(texture_paths, path)
			else:
				if DirAccess.open(path) == null:
					continue
				_append_png_files_recursive(texture_paths, path)


func _append_dynamic_monster_stream_effect_roots(effect_roots: Array, monster_ids: Array) -> void:
	for monster_id_value in monster_ids:
		var monster_id := int(monster_id_value)
		var root_paths: Variant = DYNAMIC_MONSTER_STREAM_EFFECT_ROOTS.get(monster_id, [])
		if not root_paths is Array:
			continue
		for root_path_value in root_paths:
			_append_unique_preload_path(effect_roots, str(root_path_value))


func _append_dynamic_monster_scene_paths(scene_paths: Array, monster_ids: Array) -> void:
	for monster_id_value in monster_ids:
		var monster_id := int(monster_id_value)
		var dynamic_scene_paths: Variant = DYNAMIC_MONSTER_SCENE_PATHS.get(monster_id, [])
		if not dynamic_scene_paths is Array:
			continue
		for scene_path_value in dynamic_scene_paths:
			_append_unique_preload_path(scene_paths, str(scene_path_value))


func _collect_monster_script_bullet_scene_paths(monster_scene_paths: Array) -> Array:
	var result: Array = []
	for monster_scene_path_value in monster_scene_paths:
		var monster_scene_path := str(monster_scene_path_value)
		if _monster_script_bullet_scene_cache.has(monster_scene_path):
			for cached_path in _monster_script_bullet_scene_cache[monster_scene_path]:
				_append_unique_preload_path(result, str(cached_path))
			continue
		var scene_result: Array = []
		var visited_scripts: Dictionary = {}
		for dependency in ResourceLoader.get_dependencies(monster_scene_path):
			var dependency_path := _dependency_resource_path(str(dependency))
			if dependency_path.get_extension().to_lower() == "gd":
				_collect_bullet_scene_paths_from_script(dependency_path, scene_result, visited_scripts)
		_monster_script_bullet_scene_cache[monster_scene_path] = scene_result.duplicate()
		for scene_path in scene_result:
			_append_unique_preload_path(result, str(scene_path))
	return result


func _collect_bullet_scene_paths_from_script(
	script_path: String, scene_paths: Array, visited_scripts: Dictionary
) -> void:
	if script_path == "" or visited_scripts.has(script_path):
		return
	visited_scripts[script_path] = true
	var file := FileAccess.open(script_path, FileAccess.READ)
	if file == null:
		return
	var source := file.get_as_text()
	var string_regex := RegEx.new()
	if string_regex.compile('"([^"]+)"') == OK:
		for match_result in string_regex.search_all(source):
			var bullet_name := match_result.get_string(1)
			if bullet_name == "" or bullet_name.find("/") != -1:
				continue
			var bullet_scene_path := MONSTER_BULLET_SLIM_DIR.path_join(bullet_name + ".tscn")
			if ResourceLoader.exists(bullet_scene_path):
				_append_unique_preload_path(scene_paths, bullet_scene_path)
	var extends_regex := RegEx.new()
	if extends_regex.compile('extends\\s+"([^"]+\\.gd)"') == OK:
		var extends_match := extends_regex.search(source)
		if extends_match != null:
			_collect_bullet_scene_paths_from_script(extends_match.get_string(1), scene_paths, visited_scripts)


func prewarm_monster_bullet_scene_paths(scene_paths: Array) -> void:
	var pending_paths: Array[String] = []
	for path_value in scene_paths:
		var path := str(path_value)
		if path == "" or _level_runtime_warmed_scene_paths.has(path) or pending_paths.has(path):
			continue
		pending_paths.append(path)
	if pending_paths.is_empty():
		return
	_track_level_scene_dependencies(pending_paths)
	await _preload_paths_threaded(pending_paths)
	var texture_paths: Array = []
	var priority_texture_paths: Array = []
	for scene_path in pending_paths:
		var scene_texture_paths := _collect_scene_texture_dependencies([scene_path])
		for texture_path in scene_texture_paths:
			_append_unique_preload_path(texture_paths, str(texture_path))
			_track_level_resource(str(texture_path))
		for index in range(mini(4, scene_texture_paths.size())):
			_append_unique_preload_path(priority_texture_paths, str(scene_texture_paths[index]))
	await _preload_paths_threaded(texture_paths)
	var textures_per_frame := 2 if OS.has_feature("mobile") else 5
	await _warm_texture_rids_over_frames(priority_texture_paths, textures_per_frame)
	await _warm_scene_paths_over_frames(pending_paths, 1)
	for path in pending_paths:
		var scene = _resource_cache.get(path)
		if scene is PackedScene:
			_level_runtime_warmed_scene_paths[path] = true


func _level_monster_group_signature(monster_group: Dictionary) -> String:
	var parts := PackedStringArray()
	for stage_key in ["stage_1", "stage_2", "stage_3", "stage_4"]:
		var values := PackedStringArray()
		var stage_list = monster_group.get(stage_key, [])
		if stage_list is Array:
			for monster_id_value in stage_list:
				values.append(str(int(monster_id_value)))
		parts.append(stage_key + ":" + ",".join(values))
	return "|".join(parts)


func _preload_level_background_resources(scene_paths: Array, monster_ids: Array, generation: int) -> void:
	if scene_paths.is_empty():
		return
	await get_tree().process_frame
	if generation != _level_preload_generation:
		return
	_track_level_scene_dependencies(scene_paths)
	await _preload_paths_threaded(scene_paths)
	if generation != _level_preload_generation:
		return
	var texture_paths := _collect_scene_texture_dependencies(scene_paths)
	_append_dynamic_monster_textures(texture_paths, monster_ids)
	await _preload_paths_threaded(texture_paths)
	if generation != _level_preload_generation:
		return
	var textures_per_frame := 2 if OS.has_feature("mobile") else 5
	await _warm_texture_rids_over_frames(texture_paths, textures_per_frame)
	if generation != _level_preload_generation:
		return
	await _warm_scene_paths_over_frames(scene_paths, 1)


func preload_level_monster_resources(monster_group: Dictionary) -> void:
	return
	var preload_signature := _level_monster_group_signature(monster_group)
	if preload_signature != "" and preload_signature == _level_resource_preload_signature:
		return
	clear_level_resource_cache()
	var priority_scene_paths: Array = []
	var background_scene_paths: Array = []
	var seen_monster_ids := {}
	var priority_monster_ids: Array = []
	var background_monster_ids: Array = []
	for stage_key in ["stage_1", "stage_2", "stage_3", "stage_4"]:
		var stage_list = monster_group.get(stage_key, [])
		if not stage_list is Array:
			continue
		for monster_id_value in stage_list:
			var monster_id := int(monster_id_value)
			if seen_monster_ids.has(monster_id):
				continue
			seen_monster_ids[monster_id] = true
			var scene_path := "res://Scene/Monster/Monster_" + str(monster_id) + ".tscn"
			if stage_key == "stage_1" or stage_key == "stage_2":
				_append_unique_preload_path(priority_scene_paths, scene_path)
				priority_monster_ids.append(monster_id)
			else:
				_append_unique_preload_path(background_scene_paths, scene_path)
				background_monster_ids.append(monster_id)

	var actual_level_scene_paths: Array = []
	actual_level_scene_paths.append_array(priority_scene_paths)
	actual_level_scene_paths.append_array(background_scene_paths)
	_track_level_scene_dependencies(actual_level_scene_paths)

	var blocking_scene_paths := priority_scene_paths.duplicate()
	if blocking_scene_paths.is_empty():
		blocking_scene_paths.append_array(background_scene_paths)
		priority_monster_ids.append_array(background_monster_ids)
		background_scene_paths.clear()
		background_monster_ids.clear()
	await _preload_paths_threaded(blocking_scene_paths)
	var priority_texture_paths := _collect_scene_texture_dependencies(blocking_scene_paths)
	_append_dynamic_monster_textures(priority_texture_paths, priority_monster_ids)
	await _preload_paths_threaded(priority_texture_paths)

	call_deferred("_preload_level_background_resources", [], [], _level_preload_generation)

	var texture_paths: Array = _get_damage_number_texture_paths()
	(
		texture_paths
		. append_array(
			[
				"res://Art/AddEffect/Buff_icon/poision.png",
				"res://Art/AddEffect/Buff_icon/mp_poision.png",
				"res://Art/AddEffect/Buff_icon/Ice.png",
				"res://Art/AddEffect/Buff_icon/Fire.png",
				"res://Art/AddEffect/Buff_icon/speed_down.png",
				"res://Art/AddEffect/Buff_icon/stun.png",
				"res://Art/AddEffect/Buff_icon/htsf.png",
				"res://Art/AddEffect/Buff_icon/Bleed.png",
				"res://Art/AddEffect/Buff_icon/yxbuff.png",
				"res://Art/ItemIcon/zxbx_3.png",
				"res://Art/ItemIcon/peach.png",
				"res://Art/ItemIcon/Bble.png",
				"res://Art/ItemIcon/radish.png",
				"res://Art/ItemIcon/qhsbx.png",
				"res://Art/BackPack/AllItems/empty.png",
			]
		)
	)
	var audio_paths: Array = [
		"res://Music/MonsterHurt/6_BeattackByRole1.mp3",
		"res://Music/Hero/9_BeattackByRole2.mp3",
		"res://Music/Hero/49_Role1_beAttack.mp3",
		"res://Music/Hero/62_Role2_beAttack.mp3",
		"res://Music/Hero/68_Role3_beAttack.mp3",
		"res://Music/Hero/Role5/13_hurtStand.mp3",
	]

	_level_resource_preload_signature = preload_signature


func preload_combat_misc_resources() -> void:
	var texture_paths: Array[String] = [
		"res://Art/AddEffect/Buff_icon/poision.png",
		"res://Art/AddEffect/Buff_icon/mp_poision.png",
		"res://Art/AddEffect/Buff_icon/Ice.png",
		"res://Art/AddEffect/Buff_icon/Fire.png",
		"res://Art/AddEffect/Buff_icon/speed_down.png",
		"res://Art/AddEffect/Buff_icon/stun.png",
		"res://Art/AddEffect/Buff_icon/htsf.png",
		"res://Art/AddEffect/Buff_icon/Bleed.png",
		"res://Art/AddEffect/Buff_icon/yxbuff.png",
	]
	for path in texture_paths:
		get_cached_texture(path)
	var scene_paths: Array[String] = [
		"res://Scene/Monster/Monster_zhw/Monster_141_zhw.tscn",
		"res://Scene/Monster/Monster_zhw/Monster_142_sqzlw.tscn",
		"res://Scene/Monster/Monster_zhw/Monster_142_zhw.tscn",
		"res://Scene/Monster/Monster_14501.tscn",
		"res://Scene/Monster/Monster_14501_wdww.tscn",
		"res://Scene/Monster/Monster_146.tscn",
		"res://Scene/Monster/Monster_63.tscn",
	]


func preload_common_drop_textures() -> void:
	var drop_paths: Array[String] = [
		"res://Art/ItemIcon/zxbx_3.png",
		"res://Art/ItemIcon/peach.png",
		"res://Art/ItemIcon/Bble.png",
		"res://Art/ItemIcon/radish.png",
		"res://Art/ItemIcon/qhsbx.png",
		"res://Art/BackPack/AllItems/empty.png",
	]
	for path in drop_paths:
		get_cached_texture(path)


func preload_damage_number_textures() -> void:
	var number_dirs: Array[String] = [
		"res://Art/AllNumber/cure/cure_",
		"res://Art/AllNumber/CureMp/CureMp_",
		"res://Art/AllNumber/ReduceMp/ReduceMp_",
		"res://Art/AllNumber/Physics/physics_",
		"res://Art/AllNumber/physicscrit/physics_",
		"res://Art/AllNumber/magic/magic_",
		"res://Art/AllNumber/magic/physics_",
		"res://Art/AllNumber/magiccrit/magic_",
		"res://Art/AllNumber/real/real_",
		"res://Art/AllNumber/realcrit/real_",
		"res://Art/AllNumber/LJ/lj_",
		"res://Art/AllNumber/monster/physics/physics_",
		"res://Art/AllNumber/monster/magic/magic_",
	]
	for prefix in number_dirs:
		for i in range(10):
			get_cached_texture(prefix + str(i) + ".png")


func preload_all_hero_skill_resources() -> void:
	if _all_hero_skill_resources_preloaded:
		return
	_all_hero_skill_resources_preloaded = true
	var scene_paths: Array[String] = [
		"res://Scene/Hero/RoleBullet_1.tscn",
		"res://Scene/Hero/Role1SHallow.tscn",
		"res://Scene/Hero/Role_1/hmz_effect/SpecialEffectBullet.tscn",
		"res://Scene/Hero/Role_1/hmz_effect/SpecialEffectBullet-1.tscn",
		"res://Scene/Hero/Role_1/WS_Effect.tscn",
		"res://Scene/Hero/Role_2/smb_effect.tscn",
		"res://Scene/Hero/Role_4/Role4Bullet.tscn",
		"res://Scene/Bullet/Fly_bullet.tscn",
		"res://Scene/Bullet/Chase_bullet.tscn",
	]
	for scene_path in scene_paths:
		var scene := preload_scene_path(scene_path)
		_warm_scene_instance(scene)
	var audio_paths: Array[String] = [
		"res://Music/Hero/00_Role1_gsrs.mp3",
		"res://Music/Hero/1_Role1_hit9.mp3",
		"res://Music/Hero/11_Role1_hit7.mp3",
		"res://Music/Hero/11_Role2_hit4.mp3",
		"res://Music/Hero/17_Role1_hit6.mp3",
		"res://Music/Hero/18_Role1_hit14.mp3",
		"res://Music/Hero/26_Role1_hit13_1.mp3",
		"res://Music/Hero/27_Role1_hit13_2.mp3",
		"res://Music/Hero/32_Role2_hit6.mp3",
		"res://Music/Hero/35_Role1_hit10_1.mp3",
		"res://Music/Hero/36_Role1_hit10_2.mp3",
		"res://Music/Hero/37_Role1_hit10_4.mp3",
		"res://Music/Hero/38_Role1_hit5.mp3",
		"res://Music/Hero/39_Role1_hit3AndHit4.mp3",
		"res://Music/Hero/39_Role2_hit9.mp3",
		"res://Music/Hero/40_Role1_hit1AndHit2.mp3",
		"res://Music/Hero/40_Role2_hit7.mp3",
		"res://Music/Hero/42_Role1_hit11.mp3",
		"res://Music/Hero/44_Role1_hit12_2.mp3",
		"res://Music/Hero/45_Role1_hit12_1.mp3",
		"res://Music/Hero/49_Role1_beAttack.mp3",
		"res://Music/Hero/51_Role2_hit10.mp3",
		"res://Music/Hero/57_Role2_hit8.mp3",
		"res://Music/Hero/58_Role2_hit1.mp3",
		"res://Music/Hero/59_Role1_dead.mp3",
		"res://Music/Hero/59_Role2_hit2.mp3",
		"res://Music/Hero/60_Role2_hit3.mp3",
		"res://Music/Hero/62_Role2_beAttack.mp3",
		"res://Music/Hero/68_Role3_beAttack.mp3",
		"res://Music/Hero/69_Role3_hit3.mp3",
		"res://Music/Hero/70_Role3_hit2.mp3",
		"res://Music/Hero/71_Role3_hit1.mp3",
		"res://Music/Hero/72_Role3_dead.mp3",
		"res://Music/Hero/75_Role2_dead.mp3",
		"res://Music/Hero/8_Role1_hit6.mp3",
		"res://Music/Hero/9_BeattackByRole2.mp3",
		"res://Music/Hero/effect8.mp3",
		"res://Music/Hero/Role3/10_Role3_hit8.mp3",
		"res://Music/Hero/Role3/14_Role3_hit7.mp3",
		"res://Music/Hero/Role3/16_Role3_hit5.mp3",
		"res://Music/Hero/Role3/31_Role3_hit6.mp3",
		"res://Music/Hero/Role3/38_Role3_hit9.mp3",
		"res://Music/Hero/Role3/52_Role3_hit12_2.mp3",
		"res://Music/Hero/Role3/53_Role3_hit4.mp3",
		"res://Music/Hero/Role3/56_Role3_hit10.mp3",
		"res://Music/Hero/Role3/67_Role3_hit11.mp3",
		"res://Music/Hero/Role3/74_Role3_hit12_1.mp3",
		"res://Music/Hero/Role3/Role3_skill_11.wav",
		"res://Music/Hero/Role4/Arrowdcj.mp3",
		"res://Music/Hero/Role4/ArrowHit1.mp3",
		"res://Music/Hero/Role4/ArrowHit2.mp3",
		"res://Music/Hero/Role4/Arrowmmw.mp3",
		"res://Music/Hero/Role4/Arrowqlj.mp3",
		"res://Music/Hero/Role4/Arrowtkj.mp3",
		"res://Music/Hero/Role4/Arrowzq.mp3",
		"res://Music/Hero/Role4/effect6_repeat.mp3",
		"res://Music/Hero/Role4/jdz.mp3",
		"res://Music/Hero/Role4/lhsq.mp3",
		"res://Music/Hero/Role4/mds.mp3",
		"res://Music/Hero/Role4/Shoveldcj.mp3",
		"res://Music/Hero/Role4/ShovelHit1.mp3",
		"res://Music/Hero/Role4/ShovelHit2.mp3",
		"res://Music/Hero/Role4/ShovelHit3.mp3",
		"res://Music/Hero/Role4/Shovelmmw.mp3",
		"res://Music/Hero/Role4/Shovelqlj.mp3",
		"res://Music/Hero/Role4/Shovelzq.mp3",
		"res://Music/Hero/Role4/wdww.mp3",
		"res://Music/Hero/Role5/13_hurtStand.mp3",
		"res://Music/Hero/Role5/attack.mp3",
		"res://Music/Hero/Role5/attack_repeat.mp3",
		"res://Music/Hero/Role5/attack1.mp3",
		"res://Music/Hero/Role5/attack2.mp3",
		"res://Music/Hero/Role5/attack3.mp3",
		"res://Music/Hero/Role5/attack4.mp3",
		"res://Music/Hero/Role5/effect1_1.mp3",
		"res://Music/Hero/Role5/effect1_2.mp3",
		"res://Music/Hero/Role5/effect2.mp3",
		"res://Music/Hero/Role5/effect3.mp3",
		"res://Music/Hero/Role5/effect4.mp3",
		"res://Music/Hero/Role5/effect6.mp3",
		"res://Music/Hero/Role5/effect7_1.mp3",
		"res://Music/Hero/Role5/effect7_2.mp3",
		"res://Music/Hero/Role5/effect8_1.mp3",
		"res://Music/Hero/Role5/effect8_2.mp3",
		"res://Music/Hero/Role5/effect9_1.mp3",
		"res://Music/Hero/Role5/effect9_2.mp3",
		"res://Music/Hero/Role5/jumpAttack.mp3",
		"res://Music/Hero/smsrsz_bullet_xc.mp3",
	]
	for audio_path in audio_paths:
		get_cached_audio(audio_path)


func _equipped_role_skill_names() -> Array:
	var skill_data: Variant = PlayerData.player_data.get(DataKeys.SKILL_LEARNED, {})
	var skill_keys: Variant = skill_data.get("技能键位", {}) if skill_data is Dictionary else {}
	return skill_keys.values() if skill_keys is Dictionary else []


func _role_skill_scene_paths(role_id: int) -> Array[String]:
	var paths: Array[String] = []
	var equipped_skills := _equipped_role_skill_names()

	if _is_zlwsz_shenqi_equipped():
		paths.append("res://Scene/Hero/ZLWShenqiGearBullet.tscn")
	match role_id:
		1:
			if equipped_skills.has("qsez") or equipped_skills.has("hyjj"):
				paths.append("res://Scene/Hero/RoleBullet_1.tscn")
			if (
				equipped_skills.has("qsez")
				or equipped_skills.has("zz")
				or equipped_skills.has("lyfb")
				or equipped_skills.has("hmz")
				or equipped_skills.has("hmz_ws")
			):
				paths.append("res://Scene/Hero/Role1SHallow.tscn")
			if equipped_skills.has("hmz") or equipped_skills.has("hmz_ws"):
				paths.append("res://Scene/Hero/Role_1/hmz_effect/SpecialEffectBullet.tscn")
		2:
			(
				paths
				. append_array(
					[
						"res://Scene/Base/Role2shallow.tscn",
						"res://Scene/Hero/Role_2/smb_effect.tscn",
						"res://Scene/Hero/RoleBulletSlim/Role2Bullet1.tscn",
						"res://Scene/Hero/RoleBulletSlim/Role2Bullet2.tscn",
						"res://Scene/Hero/RoleBulletSlim/Role2Bullet3.tscn",
						"res://Scene/Hero/RoleBulletSlim/Role2Bullet4.tscn",
						"res://Scene/Hero/RoleBulletSlim/Role2Bullet5.tscn",
						"res://Scene/Hero/RoleBulletSlim/Role2Bullet5_1.tscn",
						"res://Scene/Hero/RoleBulletSlim/Role2Bullet6.tscn",
						"res://Scene/Hero/RoleSpecialEffectSlim/zfjg_zh.tscn",
						"res://Scene/Hero/RoleSpecialEffectSlim/tjgl.tscn",
						"res://Scene/Hero/RoleSpecialEffectSlim/tjgl_hd.tscn",
						"res://Scene/Hero/RoleSpecialEffectSlim/myhc.tscn",
						"res://Scene/Hero/RoleSpecialEffectSlim/jgz.tscn",
						"res://Scene/Hero/RoleSpecialEffectSlim/jhsj.tscn",
					]
				)
			)
		3:
			(
				paths
				. append_array(
					[
						STREAMING_ROLE_BULLET_PATH,
						"res://Scene/Hero/RoleBulletSlim/Role3Bullet1.tscn",
						ROLE3_BULLET3_SLIM_PATH,
						ROLE3_SD_SLIM_PATH,
						ROLE3_ZZNH_SLIM_PATH,
					]
				)
			)
		4:
			(
				paths
				. append_array(
					[
						"res://Scene/Hero/Role_4/Role4Bullet.tscn",
						"res://Scene/Hero/RoleBulletSlim/Role4Bullet3.tscn",
						"res://Scene/Hero/RoleBulletSlim/Role4Bullet6.tscn",
					]
				)
			)
			if equipped_skills.has("wdww"):
				paths.append("res://Scene/Monster/Monster_138.tscn")
		5:
			(
				paths
				. append_array(
					[
						"res://Scene/Hero/RoleBulletSlim/Role5Bullet1.tscn",
						"res://Scene/Hero/RoleBulletSlim/Role5Bullet2.tscn",
						"res://Scene/Hero/RoleBulletSlim/Role5Bullet3.tscn",
						"res://Scene/Hero/RoleBulletSlim/Role5Bullet4.tscn",
						"res://Scene/Hero/RoleBulletSlim/Role5Bullet5.tscn",
						"res://Scene/Hero/RoleBulletSlim/Role5Bullet6.tscn",
					]
				)
			)
		6:
			(
				paths
				. append_array(
					[
						"res://Art/HeroPicture/Role6/equipment_atlas/default_body/default_body.tres",
						"res://Art/HeroPicture/Role6/equipment_atlas/default_body_front/default_body_front.tres",
						"res://Art/HeroPicture/Role6/equipment_atlas/default_weapon/default_weapon.tres",
						"res://Scene/Hero/Role_6/NeZhaSkillEffect.tscn",
					]
				)
			)
			if equipped_skills.has("nz_yysj"):
				paths.append("res://Scene/Hero/Role_6/NeZhaYinYangEffect.tscn")
	return paths


func _is_zlwsz_shenqi_equipped() -> bool:
	var fashions: Variant = PlayerData.player_data.get(DataKeys.FASHION, [])
	if not fashions is Array or (fashions as Array).is_empty():
		return false
	var fashion: Variant = (fashions as Array)[0]
	if not fashion is Dictionary:
		return false
	var fashion_name := str((fashion as Dictionary).get(DataKeys.NAME, ""))
	var base_name: String = str(get_clean_name(fashion_name))
	return base_name == "zlwsz" and fashion_name.begins_with("shenqi")


func _role_skill_sound_paths(role_id: int) -> Array[String]:
	match role_id:
		1:
			return [
				"res://Music/Hero/17_Role1_hit6.mp3",
				"res://Music/Hero/8_Role1_hit6.mp3",
				"res://Music/Hero/11_Role1_hit7.mp3",
				"res://Music/Hero/1_Role1_hit9.mp3",
				"res://Music/Hero/00_Role1_gsrs.mp3",
				"res://Music/Hero/36_Role1_hit10_2.mp3",
				"res://Music/Hero/37_Role1_hit10_4.mp3",
				"res://Music/Hero/35_Role1_hit10_1.mp3",
				"res://Music/Hero/44_Role1_hit12_2.mp3",
				"res://Music/Hero/40_Role1_hit1AndHit2.mp3",
				"res://Music/Hero/39_Role1_hit3AndHit4.mp3",
				"res://Music/Hero/38_Role1_hit5.mp3",
				"res://Music/Hero/18_Role1_hit14.mp3",
				"res://Music/Hero/45_Role1_hit12_1.mp3",
				"res://Music/Hero/42_Role1_hit11.mp3",
				"res://Music/Hero/26_Role1_hit13_1.mp3",
			]
		2:
			return [
				"res://Music/Hero/58_Role2_hit1.mp3",
				"res://Music/Hero/59_Role2_hit2.mp3",
				"res://Music/Hero/57_Role2_hit8.mp3",
				"res://Music/Hero/60_Role2_hit3.mp3",
				"res://Music/Hero/51_Role2_hit10.mp3",
				"res://Music/Hero/11_Role2_hit4.mp3",
				"res://Music/Hero/32_Role2_hit6.mp3",
				"res://Music/Hero/40_Role2_hit7.mp3",
				"res://Music/Hero/39_Role2_hit9.mp3",
			]
		3:
			return [
				"res://Music/Hero/71_Role3_hit1.mp3",
				"res://Music/Hero/70_Role3_hit2.mp3",
				"res://Music/Hero/69_Role3_hit3.mp3",
				"res://Music/Hero/Role3/16_Role3_hit5.mp3",
				"res://Music/Hero/Role3/10_Role3_hit8.mp3",
				"res://Music/Hero/Role3/14_Role3_hit7.mp3",
				"res://Music/Hero/Role3/31_Role3_hit6.mp3",
				"res://Music/Hero/Role3/38_Role3_hit9.mp3",
				"res://Music/Hero/Role3/53_Role3_hit4.mp3",
				"res://Music/Hero/Role3/56_Role3_hit10.mp3",
				"res://Music/Hero/Role3/67_Role3_hit11.mp3",
				"res://Music/Hero/Role3/74_Role3_hit12_1.mp3",
				"res://Music/Hero/Role3/52_Role3_hit12_2.mp3",
				"res://Music/Hero/Role3/Role3_skill_11.wav",
			]
		4:
			return [
				"res://Music/Hero/Role4/ShovelHit1.mp3",
				"res://Music/Hero/Role4/ShovelHit2.mp3",
				"res://Music/Hero/Role4/ShovelHit3.mp3",
				"res://Music/Hero/Role4/ArrowHit1.mp3",
				"res://Music/Hero/Role4/ArrowHit2.mp3",
				"res://Music/Hero/Role4/Shovelqlj.mp3",
				"res://Music/Hero/Role4/Arrowqlj.mp3",
				"res://Music/Hero/Role4/Shoveldcj.mp3",
				"res://Music/Hero/Role4/Arrowdcj.mp3",
				"res://Music/Hero/Role4/Shovelmmw.mp3",
				"res://Music/Hero/Role4/Arrowmmw.mp3",
				"res://Music/Hero/Role4/Shovelzq.mp3",
				"res://Music/Hero/Role4/Arrowzq.mp3",
				"res://Music/Hero/Role4/Arrowtkj.mp3",
				"res://Music/Hero/Role4/jdz.mp3",
				"res://Music/Hero/Role4/lhsq.mp3",
				"res://Music/Hero/Role4/mds.mp3",
				"res://Music/Hero/Role4/wdww.mp3",
				"res://Music/Hero/Role4/effect6_repeat.mp3",
			]
		5:
			return [
				"res://Music/Hero/Role5/attack1.mp3",
				"res://Music/Hero/Role5/attack2.mp3",
				"res://Music/Hero/Role5/attack3.mp3",
				"res://Music/Hero/Role5/attack4.mp3",
				"res://Music/Hero/Role5/jumpAttack.mp3",
				"res://Music/Hero/Role5/effect3.mp3",
				"res://Music/Hero/Role5/effect4.mp3",
				"res://Music/Hero/Role5/effect2.mp3",
				"res://Music/Hero/Role5/effect1_1.mp3",
				"res://Music/Hero/Role5/effect1_2.mp3",
				"res://Music/Hero/Role5/effect6.mp3",
				"res://Music/Hero/Role5/effect8_1.mp3",
				"res://Music/Hero/Role5/effect8_2.mp3",
				"res://Music/Hero/Role5/effect9_1.mp3",
				"res://Music/Hero/Role5/effect9_2.mp3",
				"res://Music/Hero/Role5/effect7_1.mp3",
				"res://Music/Hero/Role5/effect7_2.mp3",
				"res://Music/Hero/Role5/attack.mp3",
			]
	return []


func _append_numbered_resource_paths(
	paths: Array[String], path_format: String, count: int, start: int = 0, step: int = 1
) -> void:
	var index := start
	for unused in range(count):
		var path := path_format % index
		if ResourceLoader.exists(path):
			paths.append(path)
		index += step


func _role_heavy_effect_paths(role_id: int) -> Array[String]:
	var equipped_skills := _equipped_role_skill_names()
	var paths: Array[String] = []
	if role_id == 4 and equipped_skills.has("bylt"):
		_append_numbered_resource_paths(paths, "res://Art/HeroPicture/Role4/BiLuoTian/cast/cast_%02d.png", 51)
		_append_numbered_resource_paths(paths, "res://Art/HeroPicture/Role4/BiLuoTian/hit/hit_%02d.png", 11)
	elif role_id == 5 and equipped_skills.has("ltjz"):
		_append_numbered_resource_paths(
			paths, "res://Art/HeroPicture/Role5/LeiTingJieZhen/formation_spine/formation_%02d.png", 66
		)
		_append_numbered_resource_paths(
			paths, "res://Art/HeroPicture/Role5/LeiTingJieZhen/lightning_spine/lightning_%02d.png", 47
		)
	return paths


func get_current_role_heavy_effect_paths() -> Array[String]:
	var paths := _role_heavy_effect_paths(_current_role_id())
	var fashions: Variant = PlayerData.player_data.get(DataKeys.FASHION, [])
	if fashions is Array and not fashions.is_empty() and str(fashions[0].get(DataKeys.NAME, "")) == "shenqismsrsz":
		_append_numbered_resource_paths(paths, "res://Art/HeroPicture/SMSRShenqiLightning/lightning/d_%05d.png", 9)
		_append_numbered_resource_paths(
			paths, "res://Art/HeroPicture/SMSRShenqiLightning/hit_mesh/hit_%05d.png", 10, 0, 2
		)
	return paths


func get_current_role_preload_paths() -> Array[String]:
	var role_id := _current_role_id()
	var paths := _role_skill_scene_paths(role_id)
	paths.append_array(_role_skill_sound_paths(role_id))
	paths.append_array(_role_heavy_effect_paths(role_id))
	return paths


func prewarm_current_role_runtime_resources(role_id: int = 0) -> void:
	if role_id <= 0:
		role_id = _current_role_id()
	if _prewarmed_role_id == role_id:
		return
	if _prewarmed_role_id > 0:
		release_role_runtime_resources()
	var scene_paths := _role_skill_scene_paths(role_id)
	var equipped_skills := _equipped_role_skill_names()
	var sound_paths := _role_skill_sound_paths(role_id)
	var preload_paths := scene_paths.duplicate()
	preload_paths.append_array(sound_paths)
	preload_paths.append_array(_role_heavy_effect_paths(role_id))
	await _preload_paths_threaded(preload_paths)
	await _warm_scene_paths_over_frames(scene_paths, 1)
	await _warm_audio_streams_over_frames(sound_paths, 2)
	if role_id == 2 and _equipped_role_skill_names().has("by"):
		BING_YU_EFFECT_SCRIPT.prewarm_frames()
		await get_tree().process_frame
	if role_id == 1 and (equipped_skills.has("hmz") or equipped_skills.has("hmz_ws")) and not SpecialEffectBullet:
		SpecialEffectBullet = _load_scene("res://Scene/Hero/Role_1/hmz_effect/SpecialEffectBullet.tscn")
	_prewarmed_role_id = role_id


func preload_current_role_skill_resources(role: Variant) -> void:
	var role_id := _role_id_from_runtime_node(role)
	await prewarm_current_role_runtime_resources(role_id)


func _role_id_from_runtime_node(role: Variant) -> int:
	if is_instance_valid(role) and role is Node:
		var role_script := (role as Node).get_script() as Script
		var script_path := role_script.resource_path if role_script != null else ""
		match script_path:
			"res://Script/Hero/Role1.gd":
				return 1
			"res://Script/Hero/Role_2.gd":
				return 2
			"res://Script/Hero/Role_3.gd":
				return 3
			"res://Script/Hero/Role_4.gd":
				return 4
			"res://Script/Hero/Role_5.gd":
				return 5
			"res://Script/Hero/NeZhaHero.gd":
				return 6
	return clampi(int(PlayerData.player_data.get("Myself", 1)), 1, 6)


func _legacy_preload_current_role_skill_resources(role: Variant) -> void:
	var role_id := _role_id_from_runtime_node(role)
	var role_scene_paths: Array[String] = []
	if role_id == 1:
		role_scene_paths = [
			"res://Scene/Hero/Role1SHallow.tscn",
			"res://Scene/Hero/Role_1/hmz_effect/SpecialEffectBullet.tscn",
			"res://Scene/Hero/Role_1/WS_Effect.tscn",
		]
	elif role_id == 2:
		role_scene_paths = ["res://Scene/Hero/Role_2/smb_effect.tscn"]
	elif role_id == 4:
		role_scene_paths = ["res://Scene/Hero/Role_4/Role4Bullet.tscn"]
	for scene_path in role_scene_paths:
		_warm_scene_instance(preload_scene_path(scene_path))
	if role_id == 1 and not SpecialEffectBullet:
		SpecialEffectBullet = _load_scene("res://Scene/Hero/Role_1/hmz_effect/SpecialEffectBullet.tscn")
	var sounds: Array[String] = []
	if role_id == 1:
		sounds = [
			"res://Music/Hero/17_Role1_hit6.mp3",
			"res://Music/Hero/8_Role1_hit6.mp3",
			"res://Music/Hero/11_Role1_hit7.mp3",
			"res://Music/Hero/1_Role1_hit9.mp3",
			"res://Music/Hero/00_Role1_gsrs.mp3",
			"res://Music/Hero/36_Role1_hit10_2.mp3",
			"res://Music/Hero/37_Role1_hit10_4.mp3",
			"res://Music/Hero/35_Role1_hit10_1.mp3",
			"res://Music/Hero/44_Role1_hit12_2.mp3"
		]
	elif role_id == 2:
		sounds = [
			"res://Music/Hero/58_Role2_hit1.mp3",
			"res://Music/Hero/59_Role2_hit2.mp3",
			"res://Music/Hero/57_Role2_hit8.mp3",
			"res://Music/Hero/60_Role2_hit3.mp3",
			"res://Music/Hero/51_Role2_hit10.mp3",
			"res://Music/Hero/11_Role2_hit4.mp3",
			"res://Music/Hero/32_Role2_hit6.mp3",
			"res://Music/Hero/40_Role2_hit7.mp3",
			"res://Music/Hero/39_Role2_hit9.mp3"
		]
	elif role_id == 3:
		sounds = [
			"res://Music/Hero/71_Role3_hit1.mp3",
			"res://Music/Hero/70_Role3_hit2.mp3",
			"res://Music/Hero/69_Role3_hit3.mp3",
			"res://Music/Hero/Role3/16_Role3_hit5.mp3",
			"res://Music/Hero/Role3/10_Role3_hit8.mp3",
			"res://Music/Hero/Role3/14_Role3_hit7.mp3",
			"res://Music/Hero/Role3/31_Role3_hit6.mp3",
			"res://Music/Hero/Role3/38_Role3_hit9.mp3",
			"res://Music/Hero/Role3/53_Role3_hit4.mp3",
			"res://Music/Hero/Role3/56_Role3_hit10.mp3",
			"res://Music/Hero/Role3/67_Role3_hit11.mp3",
			"res://Music/Hero/Role3/74_Role3_hit12_1.mp3",
			"res://Music/Hero/Role3/52_Role3_hit12_2.mp3",
			"res://Music/Hero/Role3/Role3_skill_11.wav"
		]
	elif role_id == 4:
		sounds = [
			"res://Music/Hero/Role4/ShovelHit1.mp3",
			"res://Music/Hero/Role4/ShovelHit2.mp3",
			"res://Music/Hero/Role4/ShovelHit3.mp3",
			"res://Music/Hero/Role4/ArrowHit1.mp3",
			"res://Music/Hero/Role4/ArrowHit2.mp3",
			"res://Music/Hero/Role4/Shovelqlj.mp3",
			"res://Music/Hero/Role4/Arrowqlj.mp3",
			"res://Music/Hero/Role4/Shoveldcj.mp3",
			"res://Music/Hero/Role4/Arrowdcj.mp3",
			"res://Music/Hero/Role4/Shovelmmw.mp3",
			"res://Music/Hero/Role4/Arrowmmw.mp3",
			"res://Music/Hero/Role4/Shovelzq.mp3",
			"res://Music/Hero/Role4/Arrowzq.mp3",
			"res://Music/Hero/Role4/Arrowtkj.mp3",
			"res://Music/Hero/Role4/jdz.mp3",
			"res://Music/Hero/Role4/lhsq.mp3",
			"res://Music/Hero/Role4/mds.mp3",
			"res://Music/Hero/Role4/wdww.mp3",
			"res://Music/Hero/Role4/effect6_repeat.mp3"
		]
	elif role_id == 5:
		sounds = [
			"res://Music/Hero/Role5/attack1.mp3",
			"res://Music/Hero/Role5/attack2.mp3",
			"res://Music/Hero/Role5/attack3.mp3",
			"res://Music/Hero/Role5/attack4.mp3",
			"res://Music/Hero/Role5/jumpAttack.mp3",
			"res://Music/Hero/Role5/effect3.mp3",
			"res://Music/Hero/Role5/effect4.mp3",
			"res://Music/Hero/Role5/effect2.mp3",
			"res://Music/Hero/Role5/effect1_1.mp3",
			"res://Music/Hero/Role5/effect1_2.mp3",
			"res://Music/Hero/Role5/effect6.mp3",
			"res://Music/Hero/Role5/effect8_1.mp3",
			"res://Music/Hero/Role5/effect8_2.mp3",
			"res://Music/Hero/Role5/effect9_1.mp3",
			"res://Music/Hero/Role5/effect9_2.mp3",
			"res://Music/Hero/Role5/effect7_1.mp3",
			"res://Music/Hero/Role5/effect7_2.mp3",
			"res://Music/Hero/Role5/attack.mp3"
		]
	for sound_path in sounds:
		get_cached_audio(sound_path)


func _cached_scene(property_name: StringName, path: String) -> PackedScene:
	var scene = get(property_name) as PackedScene
	if scene == null:
		scene = _load_scene(path) as PackedScene
		set(property_name, scene)
	return scene


var lhhjbutton = null
var MosaicHelp = null
var back_pack = null
var touch_text = null
var cd_jm = null
var set_menu = null

var mycamera = null
var music_set = null
var target_scene: String = ""
var FourSwordsEndlessMode: bool = false
var SSSLendlessMode: bool = false
var ConstellationEndlessMode: bool = false
var ThreePrinceEndlessMode: bool = false

var _preloaded_scene: PackedScene = null
var _preloading_path: String = ""


func preload_next(path: String):
	"Start preloading a scene for instant transition later."
	if path == "" or _preloading_path == path:
		return
	if _resource_cache.has(path):
		_preloaded_scene = _resource_cache[path] as PackedScene
		_preloading_path = path
		return
	_preloading_path = path
	ResourceLoader.load_threaded_request(path)


func _get_preloaded(path: String) -> PackedScene:
	"Check if a preloaded scene is ready, return it or null."
	if _preloaded_scene != null and _preloaded_scene.resource_path == path:
		var ps = _preloaded_scene
		_preloaded_scene = null
		_preloading_path = ""
		return ps
	if _preloading_path == path:
		var status = ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var ps = ResourceLoader.load_threaded_get(path) as PackedScene
			_preloaded_scene = null
			_preloading_path = ""
			return ps
	return null


var main_backpack = null
var sell_or_equ = null
var equ_propeties_box = null
var dj_sell = null
var dj_infor = null
var fall_equ = null
var pl_sell = null
var ldl = null
var Game_information = null
var zd_skill = null
var Skill_learn = null
var role_information = null
var SpecialEffectBullet = null
var choose_text = null
var zztwtrap = null
var BuffIcon = null
var Trap_ = null
var bd_skill = null
var nmw_hands = null
var qh_jm = null
var change_background = null
var synthesis = null
var magp_infor = null
var shop_ttems = null
var SHop = null
var ldl_help = null
var Choose_Item = null
var WS_Effect = null

var SkillSelect = null
var UseMagicWeapon = null
var MagicHelp = null

var Sound_ = null
var Mosaic_ = null
var BGM_ = null
var Role4Bullet_ = null
var GameSet_ = null
var SkillKeySet = null
var RoleBullet_1 = null
var Role1Shallow = null
var ChangeClothesJm = null
var HHjm = null
var ZLw_stage = null
var AfterLevelEnd = null
var Buffinfor = null
var Monster65Bullet = null
var ChoosePlayer = null
var RoleSpecialEffect_ = null
var Role2Shallow = null
var SMBEffect = null
var NewBullet = null
var RoleMagicNeed = null
var GameNeedKnow = null
var MonsterHead = null
var LevelFallBox = null
var LevelInfo = null
var Pj = null
var HelpThing = null
var Hc_Help = null
var BossBlood_ = null
var Stage = null
var Decompose_ = null
var Decompose_Help = null
var RewardBox = null
var RewardInfo = null
var TaskTitle = null
var BasicTask_ = null
var TaskReward = null
var ADDFont = null
var GameAnnouncement = null
var BasicPellet_ = null
var TransBox = null
var llbtChallenge = null
var Forges = null
var ForgeBox = null
var ForgeHelp = null
var BasicMonmentInfo = null
var MonsterInfo = null
var HDZM = null
var LSH = null
var LXDY = null
var DsgChoose = null
var Line = null
var MysteryShop = null
var CureTimesBox = null
var LetterForPlayer = null
var SomeMonsterHelp = null
var Lhhj_ = null
var listbutton = null
var lhhjhelp = null
var Monster141Aura = null
var ReturnBackMap = null
var Zhenfalxbutton = null
var ZhenFaInfo = null
var ZhenFaUi = null
var _28Ui = null
var zhenyanbutton = null
var ZhenYanCureLevel = null
var ZhenFaTuPo = null
var ZhenFaHelp = null
var RoleButton = null
var Star = null


func add_star(parent, Type):
	if not Star:
		Star = _load_scene("res://Scene/other_scene/star.tscn")
	var target = instance_scene(Star, parent)
	target.Type = Type
	return target


func add_role_button(parent, MyName, MyFather):
	if not RoleButton:
		RoleButton = _load_scene("res://Scene/other_scene/role_button.tscn")
	var target = instance_scene(RoleButton, parent)
	target.MyName = MyName
	target.MyFather = MyFather
	return target


func add_basic_ar_button(parent, Num):
	var target = instance_scene(_cached_scene(&"BasicArButton", BASIC_AR_BUTTON_PATH), parent)
	if target == null:
		return null
	target.MyNum = Num
	return target


func add_zhen_fa_help(parent, position):
	if not ZhenFaHelp:
		ZhenFaHelp = _load_scene("res://Scene/other_scene/ZhenFaHelp.tscn")
	var target = instance_scene(ZhenFaHelp, parent)
	target.position = position
	return target


func add_zhen_fa_tu_po(parent, position, Father):
	if not ZhenFaTuPo:
		ZhenFaTuPo = _load_scene("res://Scene/other_scene/ZhenFaTuPo.tscn")
	var target = instance_scene(ZhenFaTuPo, parent)
	target.position = position
	target.Father = Father
	return target


func add_zhen_yan_cure_level(parent, position, Father):
	if not ZhenYanCureLevel:
		ZhenYanCureLevel = _load_scene("res://Scene/other_scene/ZhenYanCureLevel.tscn")
	var target = instance_scene(ZhenYanCureLevel, parent)
	target.position = position
	target.Father = Father
	return target


func addzhenyanbutton(parent, position, LocNum, Father):
	if not zhenyanbutton:
		zhenyanbutton = _load_scene("res://Scene/other_scene/zhenyanbutton.tscn")
	var target = instance_scene(zhenyanbutton, parent)
	target.position = position
	target.LocNum = LocNum
	target.Father = Father
	return target


func add_28_ui(parent, position):
	if not _28Ui:
		_28Ui = _load_scene("res://Scene/other_scene/TwentyEightConstellations.tscn")
	var target = instance_scene(_28Ui, parent)
	target.position = position
	return target


func add_zhen_fa_ui(parent, position):
	if not ZhenFaUi:
		ZhenFaUi = _load_scene("res://Scene/other_scene/ZhenFaUi.tscn")
	var target = instance_scene(ZhenFaUi, parent)
	target.position = position
	return target


func add_zhen_fa_info(parent, position, Father):
	if not ZhenFaInfo:
		ZhenFaInfo = _load_scene("res://Scene/other_scene/zhenfainfo.tscn")
	var target = instance_scene(ZhenFaInfo, parent)
	target.position = position
	target.Father = Father
	return target


func add_zhenfalxbutton(parent, zhenfaName, Father):
	if not Zhenfalxbutton:
		Zhenfalxbutton = _load_scene("res://Scene/other_scene/zhenfalxbutton.tscn")
	var target = instance_scene(Zhenfalxbutton, parent)
	target.zhenfaName = zhenfaName
	target.Father = Father
	return target


func addhdgqmap(parent, position):
	if not ReturnBackMap:
		ReturnBackMap = _load_scene("res://Scene/other_scene/ReturnBackMap.tscn")
	var target = instance_scene(ReturnBackMap, parent)
	target.position = position
	return target


func add_monster141_aura(parent, position_, TargetMonster):
	if not Monster141Aura:
		Monster141Aura = _load_scene("res://Scene/other_scene/NMWAura.tscn")
	var target = instance_scene(Monster141Aura, parent)
	target.TargetMonster = TargetMonster
	target.position = position_
	return target


func addlhhjhelp(parent, position):
	if not lhhjhelp:
		lhhjhelp = _load_scene("res://Scene/other_scene/lhhj_help.tscn")
	var target = instance_scene(lhhjhelp, parent)
	target.position = position
	return target


func addlistbutton(parent, selfName, Father, Num):
	if not listbutton:
		listbutton = _load_scene("res://Scene/other_scene/list_button.tscn")
	var target = instance_scene(listbutton, parent)
	target.selfName = selfName
	target.Father = Father
	target.Num = Num
	return target


func addlhhj(parent, position):
	if not Lhhj_:
		Lhhj_ = _load_scene("res://Scene/other_scene/lhhj.tscn")
	var target = instance_scene(Lhhj_, parent)
	target.scale = Vector2.ONE
	if position == Vector2.ZERO or position == Vector2(0, 0):
		target.position = viewport_center_for_parent(parent) - Vector2(461, 282)
	else:
		target.position = position
	return target


func addlhhjbutton(parent, selfName, Father):
	if not lhhjbutton:
		lhhjbutton = _load_scene("res://Scene/other_scene/lhhj_button.tscn")
	var target = instance_scene(lhhjbutton, parent)
	target.selfName = selfName
	target.Father = Father
	return target


func add_some_monster_help(parent, position):
	if not SomeMonsterHelp:
		SomeMonsterHelp = _load_scene("res://Scene/Monster/SomeMonsterHelp.tscn")
	var target = instance_scene(SomeMonsterHelp, parent)
	target.position = position
	return target


func add_mosaic_help(parent, position):
	if not MosaicHelp:
		MosaicHelp = _load_scene("res://Scene/LDL/MosaicHelp.tscn")
	var target = instance_scene(MosaicHelp, parent)
	target.position = position
	return target


func add_letter_for_player(parent, position):
	if not LetterForPlayer:
		LetterForPlayer = _load_scene("res://Scene/other_scene/ALetterForAllPlayers.tscn")
	var target = instance_scene(LetterForPlayer, parent)
	target.position = position
	return target


func add_cure_times_box(parent, position):
	if not CureTimesBox:
		CureTimesBox = _load_scene("res://Scene/Shop/CureTimesBox.tscn")
	var target = instance_scene(CureTimesBox, parent)
	target.position = position
	return target


func add_mystery_shop(parent, position):
	if not MysteryShop:
		MysteryShop = _load_scene("res://Scene/Shop/MysteryShop.tscn")
	var target = instance_scene(MysteryShop, parent)
	if position == Vector2.ZERO or position == Vector2(0, 0):
		target.position = viewport_center_for_parent(parent) - Vector2(458, 293)
	else:
		target.position = position
	return target


func add_trans_box(parent, name_, Transmogrified_):
	if not TransBox:
		TransBox = _load_scene("res://Scene/other_scene/TransmogtifiedBox.tscn")
	var target = instance_scene(TransBox, parent)
	target.SelfName_ = name_
	target.Transmogrified_ = Transmogrified_
	return target


func add_role4_bullet(parent, Player, position: Vector2):
	if not Role4Bullet_:
		Role4Bullet_ = _load_scene("res://Scene/Hero/Role_4/Role4Bullet.tscn")
	var target = instance_scene(Role4Bullet_, parent)
	target.Player = Player
	target.position = position
	return target


func add_line(parent, Monster, Type):
	if not Line:
		Line = _load_scene("res://Scene/Level/LineEffect.tscn")
	var target = instance_scene(Line, parent)
	target.position = Vector2(0, 0)
	target.Type = Type
	target.Monster = Monster
	return target


func add_dsg_choose(parent):
	if not DsgChoose:
		DsgChoose = _load_scene("res://Scene/Level/DsgChoose.tscn")
	var target = instance_scene(DsgChoose, parent)
	target.position = Vector2(0, 0)
	return target


func add_hdzm(parent, Parent):
	if not HDZM:
		HDZM = _load_scene("res://Scene/Level/HDZM.tscn")
	var target = instance_scene(HDZM, parent)
	target.scale = Vector2.ONE
	target.position = viewport_center_for_parent(parent) - Vector2(493, 260)
	target.Parent = Parent
	var guard_script = load("res://Script/Level/HDZMWindowGuard.gd")
	if guard_script != null:
		var guard = guard_script.new()
		get_tree().root.add_child(guard)
		guard.setup(target)
	return target


func add_lsh(parent, Parent):
	if not LSH:
		LSH = _load_scene("res://Scene/other_scene/lsh.tscn")
	var target = instance_scene(LSH, parent)
	target.scale = Vector2.ONE
	target.position = viewport_center_for_parent(parent) - Vector2(492, 254)
	return target


func add_lxdy(parent, Parent):
	if not LXDY:
		LXDY = _load_scene("res://Scene/other_scene/lxdy.tscn")
	var target = instance_scene(LXDY, parent)
	target.scale = Vector2.ONE
	target.position = viewport_center_for_parent(parent) - Vector2(461, 282)
	return target


func add_monster_info(parent, MonsterName, position):
	if not MonsterInfo:
		MonsterInfo = _load_scene("res://Scene/Monster/BossInfo.tscn")
	var target = instance_scene(MonsterInfo, parent)
	target.MonsterName = MonsterName
	target.position = position
	return target


func add_basic_monment_info(parent, ShowText, position):
	if not BasicMonmentInfo:
		BasicMonmentInfo = _load_scene("res://Scene/other_scene/BasicMonmentInfo.tscn")
	var target = instance_scene(BasicMonmentInfo, parent)
	target.ShowText = ShowText
	target.position = position
	return target


func add_forge_help(parent, position):
	if not ForgeHelp:
		ForgeHelp = _load_scene("res://Scene/LDL/ForgeHelp.tscn")
	var target = instance_scene(ForgeHelp, parent)
	target.position = position
	return target


func add_forge_box(parent, Name, Num):
	if not ForgeBox:
		ForgeBox = _load_scene("res://Scene/LDL/ForgeMaterialBox.tscn")
	var target = instance_scene(ForgeBox, parent)
	target.ItemName = Name
	target.NeedNum = Num
	return target


func add_forges(parent, position):
	if not Forges:
		Forges = _load_scene("res://Scene/LDL/Forge.tscn")
	var target = instance_scene(Forges, parent)
	target.position = position
	return target


func addllbt_challenge(parent, position):
	if not llbtChallenge:
		llbtChallenge = _load_scene("res://Scene/Level/llbt_challenge.tscn")
	var target = instance_scene(llbtChallenge, parent)
	target.position = position
	return target


func add_basic_pellet(parent, position):
	if not BasicPellet_:
		BasicPellet_ = _load_scene("res://Scene/Pellet/BasicPellet.tscn")
	var target = instance_scene(BasicPellet_, parent)
	target.position = position
	return target


func add_game_announcement(parent, position):
	if not GameAnnouncement:
		GameAnnouncement = _load_scene("res://Scene/main_menu/GameAnnouncement.tscn")
	var target = instance_scene(GameAnnouncement, parent)
	if target is CanvasLayer:
		target.offset = position
	elif target is Node2D or target is Control:
		target.position = position
	return target


func add_font_(parent, ShowText, Font_, FontSize, FontColor, OutLineSize, OutLineColor):
	if not ADDFont:
		ADDFont = _load_scene("res://Scene/show_text/MessageInfo.tscn")
	var target = instance_scene(ADDFont, parent)
	if Font_ == null:
		target.Font_ = null
	else:
		target.Font_ = load(Font_)
	target.ShowText = ShowText
	target.FontColor = FontColor
	target.OutLineSize = OutLineSize
	target.OutLineColor = OutLineColor
	target.FontSize = FontSize
	return target


func add_task_reward(parent, ItemName, TotalNum):
	if not TaskReward:
		TaskReward = _load_scene("res://Scene/Task/TaskReward.tscn")
	var target = instance_scene(TaskReward, parent)
	target.ItemName = ItemName
	target.TotalNum = TotalNum
	target.z_index = 99
	return target


func add_basic_task(parent, position):
	if not BasicTask_:
		BasicTask_ = _load_scene("res://Scene/Task/BasicTask.tscn")
	var target = instance_scene(BasicTask_, parent)
	if position == Vector2.ZERO or position == Vector2(0, 0):
		target.position = viewport_center_for_parent(parent) - Vector2(470, 295)
	else:
		target.position = position
	return target


func add_task_title(parent, TaskType, TaskName, MyFather):
	if not TaskTitle:
		TaskTitle = _load_scene("res://Scene/Task/TaskTitle.tscn")
	var target = instance_scene(TaskTitle, parent)
	target.TaskName = TaskName
	target.TaskType = TaskType
	target.MyFather = MyFather
	target.z_index = 99
	return target


func get_ui_popup_layer() -> CanvasLayer:
	if _ui_popup_layer != null and is_instance_valid(_ui_popup_layer):
		return _ui_popup_layer
	_ui_popup_layer = CanvasLayer.new()
	_ui_popup_layer.name = "GlobalUiPopupLayer"
	_ui_popup_layer.layer = 4096
	get_tree().root.add_child(_ui_popup_layer)
	return _ui_popup_layer


func clear_hover_popup() -> void:
	if _active_hover_popup != null and is_instance_valid(_active_hover_popup):
		_active_hover_popup.queue_free()
	_active_hover_popup = null


func _cleanup_transient_ui_under(root: Node, names: Array) -> void:
	if root == null:
		return
	for child in root.get_children():
		if child == null or not is_instance_valid(child):
			continue
		_cleanup_transient_ui_under(child, names)
		if child.name in names:
			if child is CanvasItem:
				(child as CanvasItem).visible = false
			var child_parent := child.get_parent()
			if child_parent != null:
				child_parent.remove_child(child)
			child.queue_free()


func cleanup_transient_ui() -> void:
	clear_hover_popup()
	if _ui_popup_layer != null and is_instance_valid(_ui_popup_layer):
		for child in _ui_popup_layer.get_children():
			if child != null and is_instance_valid(child):
				child.queue_free()
	var names = [
		"MapShadowTop",
		"MapShadowBottom",
		"MapShadowLeft",
		"MapShadowRight",
		"ShopShadowTop",
		"ShopShadowBottom",
		"ShopShadowLeft",
		"ShopShadowRight",
		"LevelInfo",
		"BasicTask",
		"Shop",
		"MysteryShop",
		"LDL",
		"ldl",
		"lxdy",
		"lsh",
		"lhhj",
		"LXDY",
		"LSH",
		"LHHJ",
		"Learn_skill",
		"HDZM",
		"ReturnBackMap",
		"GameAnnouncement",
		"GameSet",
		"RewardInterface",
		"Choose_item",
		"choose_scene",
		"MessageShow",
		"TwentyEightConstellations"
	]
	var scene_root = get_tree().current_scene
	if scene_root != null:
		_cleanup_transient_ui_under(scene_root, names)
	_cleanup_transient_ui_under(get_tree().root, names)


func register_ui_runtime_instance(node: Node, scene_path: String) -> void:
	if node == null or not is_instance_valid(node) or not _is_runtime_ui_scene_path(scene_path):
		return
	var instance_id := node.get_instance_id()
	if _ui_runtime_instance_paths.has(instance_id):
		return
	_ui_runtime_instance_paths[instance_id] = scene_path
	_ui_runtime_instance_counts[scene_path] = int(_ui_runtime_instance_counts.get(scene_path, 0)) + 1
	node.tree_exited.connect(_on_ui_runtime_instance_exited.bind(instance_id), CONNECT_ONE_SHOT)


func configure_backpack_role_preview(page: Node, player: Variant = null) -> void:
	if page == null or not is_instance_valid(page):
		return
	var valid_player: Variant = player if is_instance_valid(player) else null
	var role_id := _role_id_from_runtime_node(valid_player)
	var role_body := page.get_node_or_null("background/RoleBody") as Sprite2D
	var role_equipment := page.get_node_or_null("background/RoleEquipment") as Sprite2D
	if role_body != null:
		role_body.texture = (
			ResourceLoader.load(
				"res://Art/HeroPicture/Role%dAllEquipment/Role_%d_Body_Empty.png" % [role_id, role_id],
				"Texture2D",
				ResourceLoader.CACHE_MODE_IGNORE
			)
			as Texture2D
		)
	if role_equipment != null:
		role_equipment.texture = (
			ResourceLoader.load(
				"res://Art/HeroPicture/Role%dAllEquipment/Role_%d_Eq_Empty.png" % [role_id, role_id],
				"Texture2D",
				ResourceLoader.CACHE_MODE_IGNORE
			)
			as Texture2D
		)


func _on_ui_runtime_instance_exited(instance_id: int) -> void:
	if not _ui_runtime_instance_paths.has(instance_id):
		return
	var scene_path := str(_ui_runtime_instance_paths[instance_id])
	_ui_runtime_instance_paths.erase(instance_id)
	var remaining := maxi(0, int(_ui_runtime_instance_counts.get(scene_path, 1)) - 1)
	if remaining > 0:
		_ui_runtime_instance_counts[scene_path] = remaining
		return
	_ui_runtime_instance_counts.erase(scene_path)
	call_deferred("_release_ui_scene_cache_if_unused", scene_path)


func _release_ui_scene_cache_if_unused(scene_path: String) -> void:
	if int(_ui_runtime_instance_counts.get(scene_path, 0)) > 0:
		return
	if scene_path in PERMANENT_SMALL_UI_SCENE_PATHS:
		return
	_resource_cache.erase(scene_path)
	_clear_packed_scene_members_for_path(scene_path)
	_erase_cached_paths_by_prefix(_texture_cache, _ui_art_prefixes_for_scene(scene_path))


func release_ui_runtime_cache(release_permanent: bool = false) -> void:
	_ui_runtime_instance_paths.clear()
	_ui_runtime_instance_counts.clear()
	for path_value in _resource_cache.keys():
		var scene_path := str(path_value)
		if (
			_is_runtime_ui_scene_path(scene_path)
			and (release_permanent or scene_path not in PERMANENT_SMALL_UI_SCENE_PATHS)
		):
			_resource_cache.erase(scene_path)
	for property_info in get_property_list():
		var property_name := StringName(property_info.get("name", ""))
		var value: Variant = get(property_name)
		if (
			_is_valid_packed_scene(value)
			and _is_runtime_ui_scene_path((value as PackedScene).resource_path)
			and (release_permanent or (value as PackedScene).resource_path not in PERMANENT_SMALL_UI_SCENE_PATHS)
		):
			set(property_name, null)
	if release_permanent or not archive_session_active:
		_erase_cached_paths_by_prefix(
			_texture_cache,
			[
				"res://Art/BackPack/",
				"res://Art/Skill/",
				"res://Art/Shop/",
				"res://Art/LDL/",
				"res://Art/Pet/PetPageResources/",
				"res://Art/Main_menu/BodyTraining/",
				"res://Art/lianti/",
				"res://Art/zhenyaota/",
			]
		)
	if release_permanent:
		_permanent_small_ui_scene_cache.clear()
		_permanent_ui_prewarmed = false


func _clear_packed_scene_members_for_path(scene_path: String) -> void:
	for property_info in get_property_list():
		var property_name := StringName(property_info.get("name", ""))
		var value: Variant = get(property_name)
		if _is_valid_packed_scene(value) and (value as PackedScene).resource_path == scene_path:
			set(property_name, null)


func _is_runtime_ui_scene_path(scene_path: String) -> bool:
	if scene_path == "res://Scene/set_menu.tscn" or scene_path == "res://Scene/Pet/PetInterface.tscn":
		return true
	for prefix in [
		"res://Scene/BackPack/",
		"res://Scene/Skill/",
		"res://Scene/Shop/",
		"res://Scene/LDL/",
		"res://Scene/Task/",
		"res://Scene/Pellet/",
		"res://Scene/ArchiveInterface/",
	]:
		if scene_path.begins_with(prefix):
			return true
	return (
		scene_path
		in [
			"res://Scene/main_menu/BodyTraining.tscn",
			"res://Scene/main_menu/BodyTrainingDetail.tscn",
			"res://Scene/main_menu/ZhuXianSwordPage.tscn",
			"res://Scene/main_menu/ZhenYaoTower.tscn",
			"res://Scene/main_menu/GameSet.tscn",
			"res://Scene/main_menu/GameAnnouncement.tscn",
			"res://Scene/main_menu/Game_information.tscn",
			"res://Scene/other_scene/choose_music.tscn",
			"res://Scene/other_scene/TwentyEightConstellations.tscn",
			"res://Scene/other_scene/ZhenFaUi.tscn",
			"res://Scene/other_scene/TransmogtifiedBox.tscn",
			"res://Scene/other_scene/Transmogrified.tscn",
			"res://Scene/other_scene/change_back_ground.tscn",
			"res://Scene/MagicWeapon/Magic_help.tscn",
		]
	)


func _ui_art_prefixes_for_scene(scene_path: String) -> Array:
	if scene_path.begins_with("res://Scene/Skill/"):
		return ["res://Art/Skill/"]
	if scene_path.begins_with("res://Scene/BackPack/"):
		return ["res://Art/BackPack/"]
	if scene_path == "res://Scene/Pet/PetInterface.tscn":
		return ["res://Art/Pet/PetPageResources/"]
	if scene_path.begins_with("res://Scene/LDL/"):
		return ["res://Art/LDL/"]
	if (
		scene_path == "res://Scene/main_menu/BodyTraining.tscn"
		or scene_path == "res://Scene/main_menu/BodyTrainingDetail.tscn"
	):
		return ["res://Art/lianti/"]
	if scene_path == "res://Scene/main_menu/ZhenYaoTower.tscn":
		return ["res://Art/zhenyaota/"]
	return []


func register_hover_popup(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		clear_hover_popup()
		return
	if _active_hover_popup == node:
		return
	clear_hover_popup()
	_active_hover_popup = node


func screen_popup_position(offset := Vector2(25, 20)) -> Vector2:
	return get_viewport().get_mouse_position() + offset


func center_node_on_screen(node: Node, fallback_size := Vector2(940, 590)) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var size = fallback_size
	if node.has_method("get_rect"):
		size = node.get_rect().size
	if node is Node2D:
		(node as Node2D).position = (viewport_size - size) * 0.5


func popup_ui_scale() -> float:
	var viewport_size = get_viewport().get_visible_rect().size
	return min(viewport_size.x / 940.0, viewport_size.y / 590.0)


func apply_popup_screen_layout(node: Node, position: Vector2, estimated_size := Vector2(240, 240)) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var final_pos = position
	if final_pos.x + estimated_size.x > viewport_size.x:
		final_pos.x = position.x - estimated_size.x - 50.0
	if final_pos.x < 0.0:
		final_pos.x = 8.0
	if final_pos.y < 0.0:
		final_pos.y = 8.0
	if node is Node2D:
		(node as Node2D).position = final_pos
	elif node is Control:
		(node as Control).position = final_pos


func popup_position_for_parent(parent_node: Node, offset := Vector2(25, 20)) -> Vector2:
	var mouse_pos = get_tree().get_root().get_mouse_position() + offset
	if parent_node is CanvasItem:
		return (parent_node as CanvasItem).get_global_transform().affine_inverse() * mouse_pos
	return mouse_pos


func viewport_center_for_parent(parent_node: Node) -> Vector2:
	var center = get_viewport().get_visible_rect().size * 0.5
	if parent_node is CanvasItem:
		return (parent_node as CanvasItem).get_global_transform().affine_inverse() * center
	return center


func add_reward_info(parent, position, List, UseItemName, UseNum):
	if not RewardInfo:
		RewardInfo = _load_scene("res://Scene/other_scene/RewardInterface.tscn")
	var target = instance_scene(RewardInfo, parent)
	if position == Vector2.ZERO:
		target.position = viewport_center_for_parent(parent) - Vector2(478, 210)
	else:
		target.position = position
	target.UseNum = UseNum
	target.UseItemName = UseItemName
	target.ItemList_ = List
	target.z_index = 99
	return target


func add_reward_box(parent, item_id, Num):
	if not RewardBox:
		RewardBox = _load_scene("res://Scene/other_scene/reward_box_2.tscn")
	var target = instance_scene(RewardBox, parent)
	target.item_id = item_id
	target.Name = item_id
	target.Num = Num
	return target


func add_decompose_help(parent, position):
	if not Decompose_Help:
		Decompose_Help = _load_scene("res://Scene/LDL/DecomposeHelp.tscn")
	var target = instance_scene(Decompose_Help, parent)
	target.position = position
	return target


func add_decompose_(parent, position):
	if not Decompose_:
		Decompose_ = _load_scene("res://Scene/LDL/Decompose.tscn")
	var target = instance_scene(Decompose_, parent)
	target.position = position
	return target


func add_zztw_trap(parent, Name, position):
	if not zztwtrap:
		zztwtrap = _load_scene("res://Scene/Level/zztw_trap.tscn")
	var target = instance_scene(zztwtrap, parent)
	target.MyName = Name
	target.position = position
	return target


func add_stage(parent, Obj, position):
	if not Stage:
		Stage = _load_scene("res://Scene/Level/jctfloor_1.tscn")
	var target = instance_scene(Stage, parent)
	target.Type = Obj
	target.position = position
	return target


func add_boss_blood_(parent, Obj):
	if not BossBlood_:
		BossBlood_ = _load_scene(BOSS_BLOOD_PATH)
	var target = instance_scene(BossBlood_, parent)
	target.GetObj = Obj
	return target


func add_hc_help(parent, position):
	if not Hc_Help:
		Hc_Help = _load_scene("res://Scene/other_scene/hc_help.tscn")
	var target = instance_scene(Hc_Help, parent)
	target.position = position
	return target


func add_help_thing(parent, position, ItemInfo):
	if not HelpThing:
		HelpThing = _load_scene("res://Scene/other_scene/help_things.tscn")
	var target = instance_scene(HelpThing, parent)
	target.ItemInfo = ItemInfo
	target.position = position
	return target


func add_pj(parent, position, Num):
	if not Pj:
		Pj = _load_scene("res://Scene/other_scene/ping_jia.tscn")
	var target = instance_scene(Pj, parent)
	target.Num = Num
	target.position = position
	return target


func get_current_level_fall_pro(default_pro: float) -> float:
	if LevelDropProData.is_empty():
		var level_info_scene = _load_scene("res://Scene/other_scene/LevelInfo.tscn")
		if level_info_scene != null:
			var probe = level_info_scene.instantiate()
			if probe != null:
				sync_level_drop_pro_data(probe.LevelInfo)
				probe.queue_free()
	var level_name = str(CurrentLevel)
	var base_pro = -1.0
	if level_name != "" and LevelDropProData.has(level_name):
		base_pro = float(LevelDropProData[level_name])
	var effective_pro = default_pro
	if base_pro >= 0.0:
		var diff = int(MainSet.set_data.get("Difficult", 0))
		var multipliers = [1.0, 2.0, 3.0, 3.0]
		diff = clampi(diff, 0, multipliers.size() - 1)
		effective_pro = base_pro * multipliers[diff] / 100.0
	if RoleProp.SourcePlayer != null and RoleProp.SourcePlayer.IsDoubleFallPro:
		effective_pro *= 2.0
	return clampf(effective_pro, 0.0, 1.0)


func sync_level_drop_pro_data(level_info: Dictionary) -> void:
	LevelDropProData.clear()
	for level_name in level_info.keys():
		LevelDropProData[level_name] = level_info[level_name].get("fall_pro", 0)


func _enter_level_without_info(parent, path):
	if path == "res://Scene/Level/Level_llbt.tscn":
		return addllbt_challenge(parent, Vector2(0, 0))
	if not str(path).begins_with("res://"):
		return add_dsg_choose(parent)
	change_scene(path)
	return null


func add_level_info(parent, Name, position, path):
	CurrentLevel = Name
	var show_level_info := bool(MainSet.set_data.get("LevelInfo", false))
	if (
		str(path)
		in [
			"res://Scene/Level/Level_stz.tscn",
			"res://Scene/Level/Level_esbxx.tscn",
			"res://Scene/Level/Level_tzsijian.tscn",
			"res://Scene/Level/Level_sssl.tscn",
			"res://Scene/Level/Level_bxgh.tscn"
		]
	):
		show_level_info = true
	if str(path) == "res://Scene/Level/Level_tzsijian.tscn":
		FourSwordsEndlessMode = false
	if str(path) == "res://Scene/Level/Level_stz.tscn":
		ThreePrinceEndlessMode = false
	if str(path) == "res://Scene/Level/Level_sssl.tscn":
		SSSLendlessMode = false
	if str(path) == "res://Scene/Level/Level_esbxx.tscn":
		ConstellationEndlessMode = false
	if str(path) == "res://Scene/Level/Level_bxgh.tscn":
		SelectedEightImmortalId = 0
	if not LevelInfo:
		LevelInfo = _load_scene("res://Scene/other_scene/LevelInfo.tscn")
	if not show_level_info:
		var probe = LevelInfo.instantiate()
		if probe != null:
			probe.LevelName = Name
			probe.TargetStagePath = path
			sync_level_drop_pro_data(probe.LevelInfo)
			var nightmare_block_message := ""
			if probe.has_method("_get_nightmare_entry_block_message"):
				nightmare_block_message = str(probe.call("_get_nightmare_entry_block_message"))
			probe.free()
			if nightmare_block_message != "":
				add_message_show(parent, nightmare_block_message, 1.5, Vector2(470, 300))
				return null
		return _enter_level_without_info(parent, path)
	var target = instance_scene(LevelInfo, parent)
	if target == null:
		return null
	sync_level_drop_pro_data(target.LevelInfo)
	target.LevelName = Name
	target.TargetStagePath = path
	if position == Vector2.ZERO or position == Vector2(0, 0):
		target.position = viewport_center_for_parent(parent) - Vector2(470, 295)
	else:
		target.position = position
	return target


func add_monster_head(parent, Name, IsBoss, ScenePath := ""):
	if not MonsterHead:
		MonsterHead = _load_scene("res://Scene/other_scene/MonsterHeadInfo.tscn")
	var target = instance_scene(MonsterHead, parent)
	target.MonsterName = Name
	target.IsBoss = IsBoss
	target.MonsterScenePath = ScenePath
	return target


func add_level_fall_box(parent, Inldl, Inhhgz, Name, qh_level, wx, EqProp):
	if not LevelFallBox:
		LevelFallBox = _load_scene("res://Scene/BackPack/Box_1.tscn")
	var target = instance_scene(LevelFallBox, parent)
	target.is_in_ldl_gz = Inldl
	target.is_in_hhgz = Inhhgz
	target.qh_level = qh_level
	target.wx = wx
	target.EQ_prop = EqProp
	target.get_item_name = Name
	target.set_meta("item_name", Name)
	target.set_meta("level_fall_box", true)
	return target


func add_item_box(parent, Inldl, Inhhgz, Name, qh_level, num, wx, EqProp):
	if not LevelFallBox:
		LevelFallBox = _load_scene("res://Scene/BackPack/Box_1.tscn")
	var target = instance_scene(LevelFallBox, parent)
	target.is_in_ldl_gz = Inldl
	target.is_in_hhgz = Inhhgz
	target.qh_level = qh_level
	target.total_number = num
	target.wx = wx
	target.EQ_prop = EqProp
	target.get_item_name = Name
	target.set_meta("item_name", Name)
	return target


func add_game_need_know(parent, position):
	if not GameNeedKnow:
		GameNeedKnow = _load_scene("res://Scene/other_scene/GameNeedKnow.tscn")
	var target = instance_scene(GameNeedKnow, parent)
	target.position = position
	return target


func add_role_magic_need(parent, position, name_, Old, New):
	if not RoleMagicNeed:
		RoleMagicNeed = _load_scene("res://Scene/Skill/RoleMagicNeed.tscn")
	var target = instance_scene(RoleMagicNeed, parent)
	target.position = position
	target.Skill_name = name_
	target.CurrentNeed = Old
	target.NextNeed = New
	return target


func add_new_bullet(parent, position, Dir, name_, Dic):
	if not NewBullet:
		NewBullet = _load_scene("res://Scene/Hero/BulletBullet.tscn")
	var target = instance_scene(NewBullet, parent)
	target.position = position
	target.name_ = name_
	target.HitDic = Dic
	target.Direction = Dir
	return target


func add_smb_effect(parent, position, Dir):
	if not SMBEffect:
		SMBEffect = _load_scene("res://Scene/Hero/Role_2/smb_effect.tscn")
	var target = instance_scene(SMBEffect, parent)
	target.position = position
	target.Dir = Dir
	return target


func add_role2_shallow(parent, position, Dir):
	if not Role2Shallow:
		Role2Shallow = _load_scene("res://Scene/Base/Role2shallow.tscn")
	var target = instance_scene(Role2Shallow, parent)
	target.position = position
	target.Dir = Dir
	return target


func add_role_special_effect(parent, position, Dir, name_):
	var effect_name := str(name_)
	var scene = null
	if effect_name in ["sd", "sd2"]:
		scene = load_scene_uncached(ROLE3_SD_SLIM_PATH)
	elif effect_name == "zznh":
		scene = load_scene_uncached(ROLE3_ZZNH_SLIM_PATH)
	else:
		var slim_path := ROLE_SPECIAL_EFFECT_SLIM_DIR.path_join(effect_name + ".tscn")
		scene = load_scene_uncached(slim_path) if ResourceLoader.exists(slim_path) else null
	if scene == null:
		if not RoleSpecialEffect_:
			RoleSpecialEffect_ = _load_scene("res://Scene/Hero/RoleSpecialEffect.tscn")
		scene = RoleSpecialEffect_
	var target = instance_scene(scene, parent)
	target.position = position
	target.SpecialEffectName = name_
	target.Dir = Dir
	return target


func add_role_bullet(parent, position, Dir, name_, Dic):
	var bullet_name := str(name_)
	var scene = null
	if bullet_name in ["Role3Bullet2", "TtzsszBullet"]:
		scene = load_scene_uncached(STREAMING_ROLE_BULLET_PATH)
	elif bullet_name == "Role3Bullet3":
		scene = load_scene_uncached(ROLE3_BULLET3_SLIM_PATH)
	else:
		var slim_path := ROLE_BULLET_SLIM_DIR.path_join(bullet_name + ".tscn")
		if not ResourceLoader.exists(slim_path):
			push_error("Missing slim role bullet scene: " + slim_path)
			return null
		scene = load_scene_uncached(slim_path)
	var target = instance_scene(scene, parent)
	if target == null:
		return
	target.position = position
	target.name_ = name_
	target.HitDic = Dic
	target.Direction = Dir
	return target


func add_choose_player(parent, position_):
	if not ChoosePlayer:
		ChoosePlayer = _load_scene("res://Scene/main_menu/ChoosePlayer.tscn")
	var target = instance_scene(ChoosePlayer, parent)
	target.position = position_
	return target


func add_monster65_bullet(parent, position_):
	if not Monster65Bullet:
		Monster65Bullet = _load_scene("res://Scene/Monster/Monster65bullet.tscn")
	var target = instance_scene(Monster65Bullet, parent)
	target.position = position_
	return target


func add_aura(parent, position_, Value, color_type = 0):
	var target = instance_scene(_cached_scene(&"Aura_", AURA_PATH), parent)
	if target == null:
		return null
	target.Value = PaSkill.apply_soul_gain_bonus(int(Value))
	target.color_type = color_type
	target.position = position_
	return target


func add_buffinfor(parent, position_, Data):
	if not Buffinfor:
		Buffinfor = _load_scene("res://Scene/other_scene/buff_information.tscn")
	var target = instance_scene(Buffinfor, parent)
	target.DataList = Data
	apply_popup_screen_layout(target, position_, Vector2(320, 120))
	prepare_hover_info_popup(target, true)
	return target


func add_buff_icon(parent, Data):
	if parent == null or not is_instance_valid(parent) or parent.is_queued_for_deletion():
		return null
	var buff_scene := _cached_scene(&"BuffIcon_", BUFF_ICON_PATH)
	if buff_scene == null:
		return null
	var target = buff_scene.instantiate()
	if target == null:
		return null
	parent.add_child(target)
	target.DataList = Data
	var buff_name := str(Data.get("Name", "")) if Data is Dictionary else ""
	if not buff_name.is_empty():
		target.name = buff_name
		target.BuffName = buff_name
	return target


func is_monster_control_buff(buff_name: Variant) -> bool:
	return str(buff_name) in MONSTER_CONTROL_BUFF_NAMES


func add_buff(parent, BuffInfo):
	if parent == null or not (BuffInfo is Dictionary):
		return null
	var Target = parent.get_parent()
	if Target != null and Target.get("NoDeBuff") != null:
		if Target.get("NoDeBuff"):
			if (
				BuffInfo.has("DeBuff")
				and BuffInfo["DeBuff"]
				and BuffInfo["Name"] != "jgz"
				and BuffInfo["Name"] != "zznh"
			):
				return null
	var new_name := str(BuffInfo.get("Name", ""))
	if new_name == "":
		return null
	if Target is BaseMonster and Target.is_control_immune() and is_monster_control_buff(new_name):
		return null
	var unique_buff_names := [
		"Ice",
		"stun",
		"EyeFix",
		"DeadLink",
		"Boundground",
		"silent",
		"Immobilize",
		"BloodFix",
		"LifeManaLock",
		"Scary",
		"SuperArmor",
		"DoubleFallPro",
		"PoisionBody",
		"NoDeBuff",
		"yxbuff",
		"HealOverTime",
		"MagicDrain",
		"ReverseMove",
		"jgz",
		"zznh",
		"speed_down",
		"DefeReduce",
		"nlls",
		"slzbuff",
		"lpzbuff",
		"tszbuff",
		"lljybuff",
		"PetLifeBonus",
		"PetAttackBonus",
		"PetDefenseBonus",
		"PetManaBonus"
	]
	var can_add := bool(BuffInfo.get("CanAdd", false)) and new_name != "speed_down"
	if not can_add and new_name in unique_buff_names:
		for child in parent.get_children():
			var child_buff = child.get("BuffInfo")
			if child_buff is Dictionary and str(child_buff.get("Name", "")) == new_name:
				if child.get("BuffTime") != null:
					child.BuffInfo = BuffInfo.duplicate(true)
					child.LastValue = float(BuffInfo.get("value", 0.0))
					if new_name == "speed_down" and child.has_method("apply_slow_speed"):
						child.apply_slow_speed()
					child.LastTime = float(BuffInfo.get("AddTime", 0.0))
					if child.BuffTime != null:
						child.BuffTime.start(float(BuffInfo.get("AddTime", 0.0)))
					if (
						new_name in ["PetLifeBonus", "PetAttackBonus", "PetDefenseBonus", "PetManaBonus"]
						and child.has_method("refresh_pet_owner_bonus")
					):
						child.refresh_pet_owner_bonus(maxi(0, int(BuffInfo.get("value", 0))))
					if (
						Target is BaseMonster
						and not Target.is_control_immune()
						and new_name in ["Ice", "stun", "EyeFix", "Immobilize", "lljybuff"]
					):
						Target.interrupt_movement_for_control()
					return child
				return null
	var node_instance = instance_scene(_cached_scene(&"BaseBuff_", BASE_BUFF_PATH), parent)
	if node_instance == null:
		return null
	if node_instance.has_method("start_buff"):
		var buff_instance = node_instance
		buff_instance.BuffInfo = BuffInfo.duplicate(true)
		if (
			Target is BaseMonster
			and not Target.is_control_immune()
			and new_name in ["Ice", "stun", "EyeFix", "Immobilize", "lljybuff"]
		):
			Target.interrupt_movement_for_control()
		return buff_instance
	else:
		print("Invalid BaseBuff instance")
		node_instance.queue_free()
		return null


func add_after_level_end(parent, position):
	if not AfterLevelEnd:
		AfterLevelEnd = _load_scene("res://Scene/other_scene/AfterLevelEnd.tscn")
	var target = instance_scene(AfterLevelEnd, parent)
	target.z_index = 9999
	target.top_level = true
	if position != Vector2.ZERO and position != Vector2(0, 0):
		target.position = position
	return target


func add_combo(parent, ComboNum_, position):
	for child in parent.get_children():
		if child is Node2D and child.has_method(&"set_combo_num"):
			child.set_combo_num(ComboNum_)
			child.position = position
			return child
	var combo_scene = _cached_scene(&"Combo", COMBO_PATH)
	if combo_scene == null:
		return null
	var target = combo_scene.instantiate()
	if target == null:
		return null
	parent.add_child(target)
	target.position = position
	if target.has_method(&"set_combo_num"):
		target.set_combo_num(ComboNum_)
	else:
		target.ComboNum = ComboNum_
	return target


func add_combo_num(parent, ComboNum_):
	var target = instance_scene(_cached_scene(&"ComboNum", COMBO_NUM_PATH), parent)
	if target == null:
		return null
	target.ComboNum = ComboNum_
	return target


func add_z_lw_stage(parent, position, Speed, Dir, Max, PD):
	if not ZLw_stage:
		ZLw_stage = _load_scene("res://Scene/Level/zlw_fly_floor.tscn")
	var target = instance_scene(ZLw_stage, parent)
	target.position = position
	target.Direction = Dir
	target.Speed = Speed
	target.MaxPosition_x = Max
	target.PD = PD
	return target


func add_h_hjm(parent, position):
	if not HHjm:
		HHjm = _load_scene("res://Scene/other_scene/Transmogrified.tscn")
	var target = instance_scene(HHjm, parent)
	target.position = position
	return target


func add_change_clothes_jm(parent, position, name_, Transmogrified_):
	if not ChangeClothesJm:
		ChangeClothesJm = _load_scene("res://Scene/other_scene/c_hange_clothes_jm.tscn")
	var target = instance_scene(ChangeClothesJm, parent)
	target.position = position
	target.SelfName_ = name_
	target.Transmogrified_ = Transmogrified_
	return target


func add_miss_effect(parent, position):
	var target = instance_scene(_cached_scene(&"MissEffect", MISS_EFFECT_PATH), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_damage_number(parent, value, Type, is_crit, tar):
	if not bool(MainSet.set_data.get("ShowDamageText", true)):
		return null

	var target = instance_scene(_cached_scene(&"DamageNumber", DAMAGE_NUMBER_PATH), parent)
	if target == null:
		return null
	if is_instance_valid(tar):
		target.target = tar
	else:
		target.target = null
	target.is_crit = is_crit
	target.Type = Type
	target.need_number = value
	return target


func set_damage_text_enabled(enabled: bool) -> void:
	MainSet.set_data["ShowDamageText"] = enabled
	if enabled:
		return
	var active_nodes: Array = _active_damage_texts.values()
	for node_value in active_nodes:
		if not is_instance_valid(node_value):
			continue
		var node: Node = node_value as Node
		if node == null:
			continue
		if node.has_method("recycle"):
			node.call("recycle")
		else:
			_release_damage_text_count(node)
			node.queue_free()


var _damage_text_count: int = 0
var _active_damage_texts: Dictionary = {}


func add_damage_text(parent, position, value, Type, is_crit, tar):
	if not bool(MainSet.set_data.get("ShowDamageText", true)):
		return null
	if _damage_text_count >= 80:
		_recount_active_damage_texts()
		if _damage_text_count >= 80:
			return null
	_damage_text_count += 1
	var target = _take_pooled_node(_pool_data["damage_text"], DAMAGE_TEXT_PATH)
	if target == null:
		_on_damage_text_freed()
		return null
	_attach_pooled_node(target, parent)
	target.set_meta("damage_text_active", true)
	_active_damage_texts[target.get_instance_id()] = target
	var exit_callback := _on_damage_text_tree_exited.bind(target)
	if not target.tree_exited.is_connected(exit_callback):
		target.tree_exited.connect(exit_callback)
	target.position = position
	if target.has_method("setup"):
		target.setup(value, Type, is_crit, tar)
	else:
		target.target = tar
		target.Type = Type
		target.Number = value
		target.is_crit = is_crit
	return target


func _recount_active_damage_texts() -> void:
	for instance_id in _active_damage_texts.keys():
		var node = _active_damage_texts[instance_id]
		if node == null or not is_instance_valid(node) or not bool(node.get_meta("damage_text_active", false)):
			_active_damage_texts.erase(instance_id)
	_damage_text_count = _active_damage_texts.size()


func _on_damage_text_freed():
	_damage_text_count -= 1
	if _damage_text_count < 0:
		_damage_text_count = 0


func add_role1_shallow(parent, position, dir, int_action):
	if not Role1Shallow:
		Role1Shallow = _load_scene("res://Scene/Hero/Role1SHallow.tscn")
	var target = instance_scene(Role1Shallow, parent)
	target.position = position
	target.iniaction = int_action
	target.direction = dir
	return target


func add_role_bullet_1(parent, position, name_, Dic):
	if not RoleBullet_1:
		RoleBullet_1 = _load_scene("res://Scene/Hero/RoleBullet_1.tscn")
	var target = instance_scene(RoleBullet_1, parent)
	target.position = position
	target.name_ = name_
	target.HitDic = Dic
	return target


func add_skill_key_set(parent, position, name_):
	if not SkillKeySet:
		SkillKeySet = _load_scene("res://Scene/Skill/SkillKeySet.tscn")
	var target = instance_scene(SkillKeySet, parent)
	target.position = position
	target.need_name = name_
	return target


func add_game_set(parent, position):
	if not GameSet_:
		GameSet_ = _load_scene("res://Scene/main_menu/GameSet.tscn")
	var target = instance_scene(GameSet_, parent)
	if target == null:
		return null
	var design_size := Vector2(942, 589)
	var viewport_size = get_viewport().get_visible_rect().size
	var fit_scale = min(viewport_size.x / design_size.x, viewport_size.y / design_size.y)
	if target is Node2D:
		target.scale = Vector2(fit_scale, fit_scale)
		target.position = viewport_center_for_parent(parent) - design_size * fit_scale * 0.5
	else:
		target.position = position
	return target


func add_bgm(parent, target_):
	if not BGM_:
		BGM_ = _load_scene("res://Scene/AllSound/bgm.tscn")
	var target = instance_scene(BGM_, parent)
	target.target = target_
	return target


func add_mosaic_(parent, position):
	if not Mosaic_:
		Mosaic_ = _load_scene("res://Scene/LDL/Mosaic.tscn")
	var target = instance_scene(Mosaic_, parent)
	target.position = position
	return target


func add_sound(parent, target_, priority: int = 0):
	if not is_instance_valid(parent) or parent.is_queued_for_deletion():
		return null
	if not bool(MainSet.set_data.get("RoleOrMonsterHit", true)):
		return null
	var now_msec := Time.get_ticks_msec()
	var sound_key := str(target_)
	var last_msec := int(_last_sound_play_msec.get(sound_key, -45))
	if now_msec - last_msec < 45:
		return null
	if not _reserve_sound_voice(sound_key, priority):
		return null
	if get_cached_audio(sound_key) == null:
		return null
	var target = _take_pooled_node(_pool_data["sound_player"], "res://Scene/AllSound/monster_be_hit.tscn")
	if target == null:
		return null
	_last_sound_play_msec[sound_key] = now_msec
	_attach_pooled_node(target, parent)
	var instance_id: int = target.get_instance_id()
	var exit_callback := _on_sound_player_tree_exiting.bind(instance_id)
	if not target.tree_exiting.is_connected(exit_callback):
		target.tree_exiting.connect(exit_callback)
	_active_sound_players[instance_id] = {"node": target, "key": sound_key, "priority": priority}
	if target.has_method("setup"):
		target.setup(target_)
	else:
		target.target = target_
	return target


func add_magic_help(parent, position):
	if not MagicHelp:
		MagicHelp = _load_scene("res://Scene/MagicWeapon/Magic_help.tscn")
	var target = instance_scene(MagicHelp, parent)
	target.z_index = 99
	target.position = position
	return target


func _get_viewport_center_position() -> Vector2:
	return get_viewport().get_visible_rect().size * 0.5


func add_use_magic_weapon(parent, position):
	if not UseMagicWeapon:
		UseMagicWeapon = _load_scene("res://Scene/BackPack/Use_magic_weapon.tscn")
	var target = instance_scene(UseMagicWeapon, parent)
	target.z_index = 99
	target.position = position
	return target


func add_skill_select(parent, position, name_):
	if not SkillSelect:
		SkillSelect = _load_scene("res://Scene/BackPack/skill_select.tscn")
	var target = instance_scene(SkillSelect, parent)
	target.wp_name = name_
	target.position = position
	return target


func add_weapon_bullet(parent, position, name_, List, dir, Rand):
	var scene_path := str(ADD_WEAPON_BULLET_PATHS.get(str(name_), ""))
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		push_error("Missing lazy weapon bullet scene for: " + str(name_))
		return null
	var cache_key := StringName("add_weapon_bullet_" + str(name_))
	var target = instance_scene(_cached_scene(cache_key, scene_path), parent)
	if target == null:
		return null
	target.objattackDic = List
	target.Rnd = Rand
	target.name_ = name_
	target.dir = dir
	target.position = position
	return target


func get_active_pet_preload_data() -> Dictionary:
	if PlayerData.has_method("ensure_pet_dragon"):
		PlayerData.ensure_pet_dragon()
	if PlayerData.has_method("ensure_pet_phoenix"):
		PlayerData.ensure_pet_phoenix()
	if PlayerData.has_method("ensure_pet_turtle"):
		PlayerData.ensure_pet_turtle()
	if PlayerData.has_method("ensure_pet_rabbit"):
		PlayerData.ensure_pet_rabbit()
	if PlayerData.has_method("ensure_pet_mouse"):
		PlayerData.ensure_pet_mouse()
	if PlayerData.has_method("ensure_pet_neat"):
		PlayerData.ensure_pet_neat()
	var pets: Variant = PlayerData.player_data.get(PlayerData.PET_LIST_KEY, [])
	if not (pets is Array):
		return {}
	var active_name := str(PlayerData.player_data.get(PlayerData.ACTIVE_PET_KEY, ""))
	var selected_pet: Dictionary = {}
	var selected_type := ""
	for pet in pets:
		if not (pet is Dictionary) or not bool(pet.get(DataKeys.DEPLOYED, false)):
			continue
		var type_name := str(pet.get(DataKeys.TYPE, ""))
		var pet_name := str(pet.get(DataKeys.ALT_NAME, ""))
		var is_dragon := (
			type_name == "PetDragon" or pet_name.begins_with("辰龙") or pet_name in ["龙仔", "绿英龙", "青龙将军", "青龙妖圣"]
		)
		var is_tiger := type_name == "PetTiger" or pet_name in ["虎丸", "白灵虎", "白虎将军", "白虎战神", "白虎"]
		var is_phoenix := (
			type_name == "PetPhoenix"
			or pet_name.begins_with("朱雀")
			or pet_name in ["雀蛋", "炎皇雀", "朱雀将军", "朱雀女皇", "朱雀幼灵", "赤羽朱雀", "朱雀神君"]
		)
		var is_turtle := (
			type_name == "PetTurtle" or pet_name.begins_with("玄武") or pet_name in ["龟布", "墨玄龟", "玄武将军", "玄武大帝"]
		)
		var is_rabbit := type_name == "PetRabbit" or pet_name in ["月兔", "疾风兔", "寒冰玉兔", "冰霜月神"]
		var is_mouse := type_name == "PetMouse" or pet_name.begins_with("子鼠") or pet_name in ["子鼠元帅", "子鼠大元帅"]
		var is_neat := type_name == "PetNeat" or pet_name in ["丑牛", "丑牛元帅", "丑牛大元帅"]
		if (
			not is_dragon
			and not is_tiger
			and not is_phoenix
			and not is_turtle
			and not is_rabbit
			and not is_mouse
			and not is_neat
		):
			continue
		var pet_type := (
			"PetNeat"
			if is_neat
			else (
				"PetMouse"
				if is_mouse
				else (
					"PetRabbit"
					if is_rabbit
					else (
						"PetTurtle"
						if is_turtle
						else "PetPhoenix" if is_phoenix else "PetDragon" if is_dragon else "PetTiger"
					)
				)
			)
		)
		if selected_pet.is_empty():
			selected_pet = pet
			selected_type = pet_type
		if active_name == "" or active_name == pet_type or active_name == pet_name:
			selected_pet = pet
			selected_type = pet_type
			break
	if selected_pet.is_empty():
		return {}
	var stage := int(selected_pet.get("阶段", 0))
	var pet_level := int(selected_pet.get(DataKeys.LEVEL, 1))
	if selected_type == "PetMouse":
		stage = 2 if pet_level >= 50 else 1
	elif stage <= 0:
		stage = 4 if pet_level >= 50 else 3 if pet_level >= 30 else 2 if pet_level >= 15 else 1
	return {
		"type": selected_type,
		"stage": clampi(stage, 1, 2) if selected_type == "PetMouse" else clampi(stage, 1, 4),
		"level": pet_level,
	}


func get_active_pet_preload_paths() -> Array[String]:
	var pet_info := get_active_pet_preload_data()
	var pet_type := str(pet_info.get("type", ""))
	if pet_type == "":
		return []
	var stage := (
		clampi(int(pet_info.get("stage", 1)), 1, 2)
		if pet_type == "PetMouse"
		else clampi(int(pet_info.get("stage", 1)), 1, 4)
	)
	var pet_level := int(pet_info.get("level", 1))
	if pet_type == "PetNeat":
		return (
			[
				"res://Scene/Pet/PetNeatSummon_%d.tscn" % stage,
				"res://Art/Pet/PetNeat/model/pet_neat_stage%d_frames.tres" % stage,
				"res://Scene/Pet/PetNeatBullet.tscn",
				"res://Art/Pet/PetNeat/model/actions/stage%d/wait/头像.png" % stage,
				"res://Art/Pet/skillicon/mncz.png",
			]
			+ (["res://Art/Pet/skillicon/mljt.png"] if stage >= 3 else [])
			+ (["res://Art/Pet/skillicon/cnaoyi.png"] if stage >= 4 else [])
		)
	if pet_type == "PetMouse":
		var mouse_paths: Array[String] = [
			"res://Scene/Pet/PetMouseSummon_%d.tscn" % stage,
			"res://Art/Pet/PetMouse/model/pet_mouse_stage%d_frames.tres" % stage,
			"res://Scene/Pet/PetMouseBullet.tscn",
			"res://Art/Pet/PetMouse/model/actions/stage%d/wait/head.png" % stage,
			"res://Art/Pet/skillicon/sc.png",
		]
		if pet_level >= 30:
			mouse_paths.append("res://Art/Pet/skillicon/hxfb.png")
		if pet_level >= 50:
			mouse_paths.append("res://Art/Pet/skillicon/aoyi.png")
		return mouse_paths
	if pet_type == "PetTiger":
		var tiger_paths: Array[String] = [
			"res://Scene/Pet/PetTigerSummon_%d.tscn" % stage,
			"res://Art/Pet/PetTiger/model/pet_tiger_stage%d_frames.tres" % stage,
			"res://Scene/Pet/PetTigerBullet.tscn",
			"res://Art/Pet/PetTiger/model/actions/stage%d/wait/icon.png" % stage,
			"res://Art/Pet/skillicon/hy.png",
		]
		if stage >= 2:
			tiger_paths.append("res://Art/Pet/skillicon/sxhz.png")
		if stage >= 3:
			tiger_paths.append("res://Art/Pet/skillicon/hsqj.png")
		if stage >= 4:
			tiger_paths.append("res://Art/Pet/skillicon/aoyi.png")
		return tiger_paths
	if pet_type == "PetPhoenix":
		var phoenix_paths: Array[String] = [
			"res://Scene/Pet/PetPhoenixSummon_%d.tscn" % stage,
			"res://Art/Pet/PetPhoenix/model/pet_phoenix_stage%d_frames.tres" % stage,
			"res://Art/Pet/PetPhoenix/model/actions/stage%d/wait/头像.png" % stage,
			"res://Art/Pet/skillicon/np.png",
		]
		if stage >= 2:
			phoenix_paths.append("res://Art/Pet/skillicon/bshn.png")
		if stage >= 3:
			phoenix_paths.append("res://Art/Pet/skillicon/dhly.png")
		if stage >= 4:
			phoenix_paths.append("res://Art/Pet/skillicon/aoyi.png")
		return phoenix_paths
	if pet_type == "PetTurtle":
		var turtle_paths: Array[String] = [
			"res://Scene/Pet/PetTurtleSummon_%d.tscn" % stage,
			"res://Art/Pet/PetTurtle/model/pet_turtle_stage%d_frames.tres" % stage,
			"res://Scene/Pet/PetTurtleBullet.tscn",
			"res://Art/Pet/PetTurtle/model/actions/stage%d/wait/头像.png" % stage,
			"res://Art/Pet/skillicon/sld.png",
		]
		if stage >= 2:
			turtle_paths.append("res://Art/Pet/skillicon/txlj.png")
		if stage >= 3:
			turtle_paths.append("res://Art/Pet/skillicon/sybh.png")
		if stage >= 4:
			turtle_paths.append("res://Art/Pet/skillicon/aoyi.png")
		return turtle_paths
	if pet_type == "PetRabbit":
		var rabbit_paths: Array[String] = [
			"res://Scene/Pet/PetRabbitSummon_%d.tscn" % stage,
			"res://Art/Pet/PetRabbit/model/pet_rabbit_stage%d_frames.tres" % stage,
			"res://Scene/Pet/PetRabbitBullet.tscn",
			"res://Art/Pet/PetRabbit/model/actions/stage%d/wait/头像.png" % stage,
			"res://Art/Pet/skillicon/yg.png",
		]
		if stage >= 2:
			rabbit_paths.append("res://Art/Pet/skillicon/jf.png")
		if stage >= 3:
			rabbit_paths.append("res://Art/Pet/skillicon/bs.png")
		if stage >= 4:
			rabbit_paths.append("res://Art/Pet/skillicon/aoyi.png")
		return rabbit_paths
	var paths: Array[String] = [
		"res://Scene/Pet/PetDragonSummon_%d.tscn" % stage,
		"res://Art/Pet/PetDragon/model/pet_dragon_stage%d_frames.tres" % stage,
		"res://Scene/Pet/PetDragonBullet.tscn",
		"res://Art/Pet/PetDragon/model/actions/stage%d/wait/头像.png" % stage,
		"res://Art/Pet/skillicon/fs.png",
	]
	if stage >= 2:
		paths.append("res://Art/Pet/skillicon/sdcc.png")
	if stage >= 3:
		paths.append("res://Art/Pet/skillicon/ltwj.png")
	if stage >= 4:
		paths.append("res://Art/Pet/skillicon/aoyi.png")
	return paths


func _preload_sprite_frames_resource(path: String) -> void:
	var frames := _resource_cache.get(path) as SpriteFrames
	if frames == null:
		frames = ResourceLoader.load(path, "SpriteFrames", ResourceLoader.CACHE_MODE_REUSE) as SpriteFrames
		if frames != null:
			_resource_cache[path] = frames


func prewarm_active_pet_runtime_resources() -> void:
	var pet_info := get_active_pet_preload_data()
	var pet_type := str(pet_info.get("type", ""))
	if pet_type == "":
		return
	var stage := (
		clampi(int(pet_info.get("stage", 1)), 1, 2)
		if pet_type == "PetMouse"
		else clampi(int(pet_info.get("stage", 1)), 1, 4)
	)
	var pet_level := int(pet_info.get("level", 1))
	var mouse_skill_tier := 50 if pet_level >= 50 else 30 if pet_level >= 30 else 1
	var pet_signature := (
		"%s:%d:%d" % [pet_type, stage, mouse_skill_tier] if pet_type == "PetMouse" else "%s:%d" % [pet_type, stage]
	)
	if pet_signature == _prewarmed_pet_signature:
		return
	var scene_path := ""
	var frames_path := ""
	var bullet_scene_path := ""
	if pet_type == "PetNeat":
		scene_path = "res://Scene/Pet/PetNeatSummon_%d.tscn" % stage
		frames_path = "res://Art/Pet/PetNeat/model/pet_neat_stage%d_frames.tres" % stage
		bullet_scene_path = "res://Scene/Pet/PetNeatBullet.tscn"
	elif pet_type == "PetMouse":
		scene_path = "res://Scene/Pet/PetMouseSummon_%d.tscn" % stage
		frames_path = "res://Art/Pet/PetMouse/model/pet_mouse_stage%d_frames.tres" % stage
		bullet_scene_path = "res://Scene/Pet/PetMouseBullet.tscn"
	elif pet_type == "PetTiger":
		scene_path = "res://Scene/Pet/PetTigerSummon_%d.tscn" % stage
		frames_path = "res://Art/Pet/PetTiger/model/pet_tiger_stage%d_frames.tres" % stage
		bullet_scene_path = "res://Scene/Pet/PetTigerBullet.tscn"
	elif pet_type == "PetPhoenix":
		scene_path = "res://Scene/Pet/PetPhoenixSummon_%d.tscn" % stage
		frames_path = "res://Art/Pet/PetPhoenix/model/pet_phoenix_stage%d_frames.tres" % stage
		bullet_scene_path = "res://Scene/Pet/PetTigerBullet.tscn"
	elif pet_type == "PetTurtle":
		scene_path = "res://Scene/Pet/PetTurtleSummon_%d.tscn" % stage
		frames_path = "res://Art/Pet/PetTurtle/model/pet_turtle_stage%d_frames.tres" % stage
		bullet_scene_path = "res://Scene/Pet/PetTurtleBullet.tscn"
	elif pet_type == "PetRabbit":
		scene_path = "res://Scene/Pet/PetRabbitSummon_%d.tscn" % stage
		frames_path = "res://Art/Pet/PetRabbit/model/pet_rabbit_stage%d_frames.tres" % stage
		bullet_scene_path = "res://Scene/Pet/PetRabbitBullet.tscn"
	else:
		scene_path = "res://Scene/Pet/PetDragonSummon_%d.tscn" % stage
		frames_path = "res://Art/Pet/PetDragon/model/pet_dragon_stage%d_frames.tres" % stage
		bullet_scene_path = "res://Scene/Pet/PetDragonBullet.tscn"
	_warm_scene_instance(preload_scene_path(scene_path))
	var bullet_scene := preload_scene_path(bullet_scene_path)
	_warm_scene_instance(bullet_scene)
	_preload_sprite_frames_resource(frames_path)
	if pet_type == "PetNeat":
		PET_NEAT_BULLET_SCRIPT.warm_pet_neat_frames(stage)
	elif pet_type == "PetMouse":
		PET_MOUSE_BULLET_SCRIPT.warm_pet_mouse_frames(pet_level)
	elif pet_type == "PetTiger":
		await MonsterBullet.prewarm_pet_tiger_runtime(stage, bullet_scene)
	elif pet_type == "PetPhoenix":
		await MonsterBullet.prewarm_pet_phoenix_runtime(stage, bullet_scene)
	elif pet_type == "PetTurtle":
		await PET_TURTLE_BULLET_SCRIPT.prewarm_pet_turtle_runtime(stage, bullet_scene)
	elif pet_type == "PetRabbit":
		PET_RABBIT_BULLET_SCRIPT.warm_pet_rabbit_frames(stage)
	else:
		await MonsterBullet.prewarm_pet_dragon_runtime(stage, bullet_scene)
	_prewarmed_pet_signature = pet_signature


func get_magic_weapon_preload_paths(name_) -> Array[String]:
	var weapon_name := str(name_)
	var paths: Array[String] = []
	var scene_path := str(MAGIC_WEAPON_SCENE_PATHS.get(weapon_name, ""))
	if scene_path != "":
		paths.append(scene_path)
	if weapon_name == "xianyjp":
		(
			paths
			. append_array(
				[
					"res://Scene/Monster/Monster_zhw/GuanyinSummon.tscn",
					"res://Art/Monster/GuanyinSpine/skeleton.atlas",
					"res://Art/Monster/GuanyinSpine/guanyin.spine-json",
				]
			)
		)
	return paths


func prewarm_magic_weapon_runtime_resources(name_) -> void:
	if str(name_) != "xianyjp":
		return
	GuanyinSummon.preload_spine_data()


func prepare_magic_weapon_resources(name_) -> void:
	var scene_path := str(MAGIC_WEAPON_SCENE_PATHS.get(str(name_), ""))
	if scene_path == "" or _resource_cache.has(scene_path):
		return
	await _preload_paths_threaded([scene_path])


func add_magic_weapon(parent, name_, position):
	var weapon_name := str(name_)
	if weapon_name in PlayerData.RETIRED_WUDU_MAGIC_WEAPONS:
		return null

	if current_magic_summon and is_instance_valid(current_magic_summon):
		current_magic_summon.queue_free()
		current_magic_summon = null

	var scene_path := str(MAGIC_WEAPON_SCENE_PATHS.get(weapon_name, ""))
	if scene_path == "":
		return null
	var scene := load_scene_uncached(scene_path)
	if scene == null:
		return null
	var target = instance_scene(scene, parent)
	if target:
		target.position = position
		if target.has_method("set_magic_weapon_name"):
			target.set_magic_weapon_name(weapon_name)
	return target


func add_message_show(Parent, NeedText: String, Time_: float, Position: Vector2):
	var target = instance_scene(_cached_scene(&"MessageShow", MESSAGE_SHOW_PATH), Parent)
	if target == null:
		return null
	target.z_index = 999
	if Position == Vector2.ZERO or Position == Vector2(470, 300):
		target.position = viewport_center_for_parent(Parent)
	else:
		target.position = Position
	target.ShowText = NeedText
	target.LastTime = Time_
	center_popup_texts(target)
	return target


func add_ws_effect(parent):
	if not WS_Effect:
		WS_Effect = _load_scene("res://Scene/Hero/Role_1/WS_Effect.tscn")
	var target = instance_scene(WS_Effect, parent)
	return target


func add_choose_item(parent, position, List, name_, page):
	if not Choose_Item:
		Choose_Item = _load_scene("res://Scene/Shop/Choose_item.tscn")
	var target = instance_scene(Choose_Item, parent)
	target.name_ = name_
	target.page_ = page
	target.list_ = List
	target.z_index = 99
	if position == Vector2.ZERO or position == Vector2(460, 260):
		target.position = viewport_center_for_parent(parent)
	else:
		target.position = position
	return target


func add_s_y_n_help(parent, position):
	if not ldl_help:
		ldl_help = _load_scene("res://Scene/LDL/s_yn_help.tscn")
	var target = instance_scene(ldl_help, parent)
	target.z_index = 99
	target.position = position
	return target


func add_shop(parent, position):
	if not SHop:
		SHop = _load_scene("res://Scene/Shop/SHOP.tscn")
	var target = instance_scene(SHop, parent)
	target.z_index = 99
	target.position = position
	return target


func add_shop_items(parent, position, name_: String, need_):
	if not shop_ttems:
		shop_ttems = _load_scene("res://Scene/Shop/Shop_item.tscn")
	var target = instance_scene(shop_ttems, parent)
	target.position = position
	target.item_name_ = name_
	target.need_lh = int(need_)
	return target


func add_magp_infor(parent, position):
	if not magp_infor:
		magp_infor = _load_scene("res://Scene/BackPack/Magic_weapon_infor.tscn")
	var target = instance_scene(magp_infor, parent)
	target.position = position
	return target


func add_synthesis(parent, position):
	if not synthesis:
		synthesis = _load_scene("res://Scene/LDL/Synthesis.tscn")
	var target = instance_scene(synthesis, parent)
	target.position = position
	return target


func add_change_bg(parent, position):
	if not change_background:
		change_background = _load_scene("res://Scene/other_scene/change_back_ground.tscn")
	var target = instance_scene(change_background, parent)
	if target is CanvasLayer:
		target.offset = position
	elif target != null:
		target.position = position
	return target


func add_strength(parent, position):
	if not qh_jm:
		qh_jm = _load_scene("res://Scene/LDL/strength.tscn")
	var target = instance_scene(qh_jm, parent)
	target.position = position
	return target


func create_hands(parent, direction, position):
	if not nmw_hands:
		nmw_hands = _load_scene("res://Scene/Monster/Monster_25.tscn")
	var target = instance_scene(nmw_hands, parent)
	if target == null:
		return null
	target.position = position
	var mr_ani_node = target.get_node_or_null("MonsterDir/mr_ani")
	if mr_ani_node:
		mr_ani_node.flip_h = direction
	return target


func call_chase_bullet(parent, name_, speed, time: float, dir, position, hit_name, dic):
	var target = instance_scene(_cached_scene(&"ChaseBullet_", CHASE_BULLET_PATH), parent)
	if target == null:
		print("Error: failed to instantiate ChaseBullet_, check resource path")
		return null
	if target.has_node("Chaseani"):
		target.chase_ani = target.get_node("Chaseani")
	elif target.has_node("ChaseAni"):
		target.chase_ani = target.get_node("ChaseAni")
	if target.chase_ani:
		target.chase_ani.flip_h = dir
	else:
		print("警告: ChaseBullet 场景缺少 chase_ani 节点")
	target.name_ = name_
	target.speed_ = speed
	target.time_ = time
	target.position = position
	target.AttList = dic
	target.hit_name = hit_name
	return target


func call_fly_bullet(parent, name_, dir, position, distance, speed, hit_name, dic):
	var target = instance_scene(load_fly_bullet_scene(str(name_)), parent)
	if target == null:
		return null
	target.name_ = name_
	target.speed_ = speed
	target.direction_ = dir
	target.distance = distance
	target.position = position
	target.AttList = dic
	target.hit_name = hit_name
	return target


func add_lj(parent, position_):
	var target = instance_scene(_cached_scene(&"lj", LIJI_PATH), parent)
	if target == null:
		return null
	target.z_index = 99
	target.position = position_
	return target


func add_trap(parent, position_, name_):
	if not Trap_:
		Trap_ = _load_scene("res://Scene/Level/trap.tscn")
	var target = instance_scene(Trap_, parent)
	target.z_index = 99
	target.get_name_ = name_
	target.position = position_
	return target


func add_buff_icon_text(parent, text_):
	if not BuffIcon:
		BuffIcon = _load_scene("res://Scene/BackPack/buff.tscn")
	var target = instance_scene(BuffIcon, parent)
	target.z_index = 99
	target.texture_ = text_
	return target


func add_special_effect(parent, position_, name_, scale_, direction, speed_):
	if str(name_) == "RoleBeHit":
		var role_hit = _take_pooled_node(_pool_data["role_be_hit"], ROLE_BE_HIT_EFFECT_PATH)
		if role_hit == null:
			return null
		_attach_pooled_node(role_hit, parent)
		role_hit.z_index = 99
		role_hit.position = position_
		role_hit.setup(scale_, direction, speed_)
		return role_hit
	var effect_name := str(name_)
	var scene_path := SPECIAL_AFFECT_SLIM_DIR.path_join(effect_name + ".tscn")
	if not ResourceLoader.exists(scene_path):
		push_error("Missing slim special effect scene: " + scene_path)
		return null
	var target = instance_scene(_cached_scene(StringName("SpecialAffect_" + effect_name), scene_path), parent)
	if target == null:
		return null
	target.z_index = 99
	target.Effect_name = name_
	target.scale_ = scale_
	target.Effect_speed = speed_
	target.Effect_dir = direction
	target.position = position_
	return target


func add_choose_text(parent, position_, text_, calm_time):
	if not choose_text:
		choose_text = _load_scene("res://Scene/show_text/choose_scene.tscn")
	var target = instance_scene(choose_text, parent)
	target.z_index = 99
	target.position = position_
	target.my_text = text_
	target.calm_time = calm_time
	return target


func add_special_effect_bullet(parent, position_, scale_, name_, dir):
	if not SpecialEffectBullet:
		SpecialEffectBullet = _load_scene("res://Scene/Hero/Role_1/hmz_effect/SpecialEffectBullet.tscn")
	var target = instance_scene(SpecialEffectBullet, parent)
	target.z_index = 99
	target.position = position_
	target.scale_ = scale_
	target.dire = dir
	target.action_name = name_
	return target


func add_role_information(parent, position):
	if not role_information:
		role_information = _load_scene("res://Scene/Level/Role_information.tscn")
	if role_information == null or parent == null or not is_instance_valid(parent):
		return null
	var target = role_information.instantiate()
	if target == null:
		return null
	parent.add_child(target)
	target.z_index = 99
	target.position = position
	buff_box = target.buff_box
	return target


func add_learn_skill(parent, position):
	if not Skill_learn:
		Skill_learn = _load_scene("res://Scene/Skill/Learn_skill.tscn")
	var target = instance_scene(Skill_learn, parent)
	target.z_index = 99
	target.position = position
	return target


func add_zd_skillscene(parent, position):
	if not zd_skill:
		zd_skill = _load_scene("res://Scene/Skill/zd_skill.tscn")
	var target = instance_scene(zd_skill, parent)
	target.z_index = 99
	target.position = position
	return target


func add_bd_skillscene(parent, position):
	if not bd_skill:
		bd_skill = _load_scene("res://Scene/Skill/bd_skill.tscn")
	var target = instance_scene(bd_skill, parent)
	target.z_index = 99
	target.position = position
	return target


func add_gm_infor(parent, position):
	if not Game_information:
		Game_information = _load_scene("res://Scene/main_menu/Game_information.tscn")
	var target = instance_scene(Game_information, parent)
	target.z_index = 99
	target.position = position
	return target


func add_ldl(parent, position):
	if not ldl:
		ldl = _load_scene("res://Scene/LDL/ldl.tscn")
	var target = instance_scene(ldl, parent)
	target.z_index = 99
	target.position = position
	return target


func add_pl_sell(parent, position):
	if not pl_sell:
		pl_sell = _load_scene("res://Scene/BackPack/pl_sell.tscn")
	var target = instance_scene(pl_sell, parent)
	target.z_index = 99
	target.position = position
	return target


func fall_item(parent, position, name_, value_):
	if not fall_equ:
		fall_equ = _load_scene("res://Scene/BackPack/equipment_fall.tscn")
	var target = instance_scene(fall_equ, parent)
	target.position = position
	target.item_name = name_
	target.num_ = value_
	return target


func add_dj_infor(parent, position, name_):
	if not dj_infor:
		dj_infor = _load_scene("res://Scene/BackPack/dj_information.tscn")
	var target = instance_scene(dj_infor, parent)
	target.my_name = name_
	target.z_index = 99
	target.position = position
	left_align_popup_texts(target)
	return target


func close_backpack_click_menus(parent: Node = null) -> void:
	var roots := []
	if parent != null:
		roots.append(parent)
	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene != parent:
		roots.append(current_scene)
	if get_tree().root != null:
		roots.append(get_tree().root)
	for root in roots:
		_close_backpack_click_menus_in(root)


func _close_backpack_click_menus_in(root: Node) -> void:
	if root == null:
		return
	for child in root.get_children():
		if child == null:
			continue
		if child.name == "dj_sell" or child.name == "sell_or_equ":
			child.free()
			continue
		_close_backpack_click_menus_in(child)


func add_dj_sell(parent, position, name_, page_):
	close_backpack_click_menus(parent)
	if not dj_sell:
		dj_sell = _load_scene("res://Scene/BackPack/dj_sell.tscn")
	var target = instance_scene(dj_sell, parent)
	target.my_page = page_
	target.my_name = name_
	target.z_index = 99
	target.position = position
	return target


func get_parent_(self_, times):
	var i = 0
	while i < times:
		self_ = self_.get_parent()
		i = i + 1
	return self_


func add_equ_propeties_box(parent, position, name_, qh_level, wx, Data):
	if not equ_propeties_box:
		equ_propeties_box = _load_scene("res://Scene/BackPack/equipment_properies.tscn")
	var target = instance_scene(equ_propeties_box, parent)
	target.z_index = 199
	var item_data: Dictionary = Data.duplicate(true) if Data is Dictionary else {}
	var template: Dictionary = AE.AllEquipment_.get(str(name_), {})
	if item_data.is_empty() and str(template.get("所属", "")) == "宠物装备":
		item_data = template.duplicate(true)
	var item_type := str(item_data.get(DataKeys.TYPE, template.get(DataKeys.TYPE, "")))
	var belongs_to := str(item_data.get("所属", template.get("所属", "")))
	if (item_type == "宠物装备" or belongs_to == "宠物装备") and target.has_method("setup_pet_equipment"):
		var slot_type := str(item_data.get("装备类型", template.get("装备类型", ""))).strip_edges()
		var pet_instance := {
			"名字": str(item_data.get(DataKeys.NAME, template.get(DataKeys.NAME, name_))),
			"强化等级": int(qh_level),
			"类型": slot_type,
			"装备类型": slot_type,
			"Data": item_data,
		}
		if item_data.has("随机属性") and item_data["随机属性"] is Array:
			pet_instance["随机属性"] = (item_data["随机属性"] as Array).duplicate(true)
		target.call("setup_pet_equipment", pet_instance, maxi(0, int(item_data.get("售价", template.get("售价", 0)))))
	else:
		target.qh_level = qh_level
		target.nam = name_
		target.wx = wx
		target.EQ_prop = Data
	target.position = position
	left_align_popup_texts(target)
	return target


func add_se_eq_jm(parent, position, name_, page_, number_):
	close_backpack_click_menus(parent)
	if not sell_or_equ:
		sell_or_equ = _load_scene("res://Scene/BackPack/sell_or_equ.tscn")
	var target = instance_scene(sell_or_equ, parent)
	target.page = page_
	target.number = number_
	target.get_name_ = name_
	target.z_index = 99
	target.position = position
	return target


func add_main_backpack(parent, position):
	if not main_backpack:
		main_backpack = _load_scene("res://Scene/BackPack/Main_Backpack.tscn")
	var target = instance_scene(main_backpack, parent)
	target.position = position
	return target


func change_scene(target, force_loading_screen: bool = false):
	var target_path := str(target)
	var exiting_archive := is_archive_exit_scene(target_path)
	if exiting_archive:
		end_archive_session()
	cleanup_transient_ui()
	release_ui_runtime_cache(exiting_archive)

	clear_level_resource_cache()

	var cached = _get_preloaded(target_path)

	if (
		not force_loading_screen
		and cached != null
		and target_path.begins_with("res://Scene/Level/")
		and target_path != "res://Scene/Level/Level_hdzm.tscn"
	):
		get_tree().change_scene_to_packed(cached)
		return

	target_scene = target_path
	get_tree().change_scene_to_file("res://Scene/other_scene/load_scene.tscn")


func _deferred_change_scene():
	get_tree().change_scene_to_file(target_scene)


func add_music_set(parent, position):
	if not music_set:
		music_set = _load_scene("res://Scene/other_scene/choose_music.tscn")
	var target = instance_scene(music_set, parent)
	target.position = position
	return target


func add_camera(parent, position, right):
	if not mycamera:
		mycamera = _load_scene("res://Scene/Level/camera.tscn")
	var target = instance_scene(mycamera, parent)
	target.position = position
	target.max_right = right
	return target


func call_hero(who: String, parent, position: Vector2, _dir: bool):
	var clean_who = who.replace(".0", "").replace(".", "")
	var scene_paths = {
		"role_1": "res://Scene/Hero/Role_1/Role1.tscn",
		"role_2": "res://Scene/Hero/Role_2/Role_2.tscn",
		"role_3": "res://Scene/Hero/Role_3/Role_3.tscn",
		"role_4": "res://Scene/Hero/Role_4/Role_4.tscn",
		"role_5": "res://Scene/Hero/Role_5/Role_5.tscn",
		"role_6": "res://Scene/Hero/Role_6/Role_6.tscn"
	}
	if not scene_paths.has(clean_who):
		push_error("Unknown hero type: " + who + " (cleaned to: " + clean_who + ")")
		return null
	var scene_resource = load(scene_paths[clean_who])
	if scene_resource:
		var target = scene_resource.instantiate()
		if target:
			parent.add_child(target)
			target.position = position
			get_player = target
			return target
	push_error("Failed to create hero: " + clean_who)
	return null


func add_set_menu(parent, position):
	if not set_menu:
		set_menu = _load_scene("res://Scene/set_menu.tscn")
	var target = instance_scene(set_menu, parent)
	target.position = position
	return target


func add_cd_jm(parent, position):
	if not cd_jm:
		cd_jm = _load_scene("res://Scene/ArchiveInterface/read_archive_interface.tscn")
	var target = instance_scene(cd_jm, parent)
	target.position = position
	return target


func add_moment_text(parent, position, text, last_time):
	var target = instance_scene(_cached_scene(&"moment_texxt", MOMENT_TEXT_PATH), parent)
	if target == null:
		return null
	target.position = position
	target.show_text = text
	target.last_time = last_time
	target.z_index = 99
	return target


func add_touch_text(parent, position, text):
	if not touch_text:
		touch_text = _load_scene("res://Scene/show_text/touch_text.tscn")
	var target = instance_scene(touch_text, parent)
	target.position = position
	target.z_index = 99
	target.tt = text
	return target


func add_back_pack(parent, position):
	if not back_pack:
		back_pack = _load_scene("res://Scene/BackPack/BackPack.tscn")
	var target = instance_scene(back_pack, parent)
	configure_backpack_role_preview(target)
	target.position = position - Vector2(481, 297)
	target.z_index = 10
	return target


func create_monster(M_id: int, parent, position_: Vector2) -> BaseMonster:
	var scene_id := _canonical_monster_scene_id(M_id)
	var path := _monster_scene_path(scene_id)
	var scene = load_level_monster_scene(path)
	if scene:
		var target := instance_scene(scene, parent) as BaseMonster
		if target == null:
			return null
		if scene_id != M_id:
			target.name = "Monster_%d" % M_id

			target.set_meta("source_monster_id", M_id)
		target.position = position_
		return target
	return null


func add_hit_text(parent, position_, value, lx, crit, miss):
	var target = instance_scene(_cached_scene(&"hit_text", HIT_TEXT_PATH), parent)
	if target == null:
		return null
	target.show_lx = str(lx)
	target.is_crit = crit
	target.is_miss = miss
	target.show_text = value
	target.position = position_
	return target


func add_monster_blood(parent, position_, value, text):
	var target = instance_scene(_cached_scene(&"monster_blood", MONSTER_BLOOD_PATH), parent)
	if target == null:
		return null
	target.bar_value = value
	target.bar_text = text
	target.position = position_
	return target


func add_mr_hurt(parent, position_):
	if parent == null:
		return null
	var now_msec := Time.get_ticks_msec()
	var key := str(parent.get_instance_id())
	var last_msec := int(_last_mr_hurt_msec.get(key, 0))
	if now_msec - last_msec < 55:
		return null
	_last_mr_hurt_msec[key] = now_msec
	var target = _take_pooled_node(_pool_data["mr_hurt"], MONSTER_BE_HIT_PATH)
	if target == null:
		return null
	_attach_pooled_node(target, parent)
	target.modulate = Color.WHITE
	target.position = position_
	if target.has_method("do_"):
		target.do_()
	return target


func promote_popup_without_moving(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	var in_popup_layer := node.get_parent() == get_ui_popup_layer()
	if node is Control:
		var control := node as Control
		var old_position := control.global_position
		control.z_index = 9999
		control.z_as_relative = false
		control.top_level = not in_popup_layer
		control.global_position = old_position
	elif node is Node2D:
		var node_2d := node as Node2D
		var old_transform: Transform2D = node_2d.global_transform
		node_2d.z_index = 9999
		node_2d.z_as_relative = false
		node_2d.top_level = not in_popup_layer
		node_2d.global_transform = old_transform
	elif node is CanvasItem:
		var canvas_item := node as CanvasItem
		canvas_item.z_index = 9999
		canvas_item.z_as_relative = false
		canvas_item.top_level = not in_popup_layer


func set_popup_screen_position(node: Node, screen_position: Vector2) -> void:
	if node == null or not is_instance_valid(node):
		return
	if node is Control:
		(node as Control).global_position = screen_position
	elif node is Node2D:
		(node as Node2D).global_position = screen_position
	elif node is CanvasItem:
		(node as CanvasItem).global_transform.origin = screen_position


func promote_popup_to_global_layer_without_moving(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	var popup_layer := get_ui_popup_layer()
	if popup_layer == null or not is_instance_valid(popup_layer):
		promote_popup_without_moving(node)
		return
	var screen_pos := Vector2.ZERO
	if node is Control:
		screen_pos = (node as Control).global_position
	elif node is Node2D:
		screen_pos = (node as Node2D).global_position
	elif node is CanvasItem:
		screen_pos = (node as CanvasItem).get_global_transform().origin
	var old_parent := node.get_parent()
	if old_parent != popup_layer:
		if old_parent != null:
			old_parent.remove_child(node)
		popup_layer.add_child(node)
	set_popup_screen_position(node, screen_pos)
	promote_popup_without_moving(node)
	if node is CanvasItem:
		(node as CanvasItem).visible = true


func left_align_popup_texts(root: Node) -> void:
	if root == null:
		return
	if root is Label:
		var label := root as Label
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	elif root is Button:
		var button := root as Button
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	for child in root.get_children():
		left_align_popup_texts(child)


func prepare_hover_info_popup(target: Node, use_top_level := false) -> void:
	if target == null:
		return
	target.z_index = 4095
	if target is CanvasItem:
		(target as CanvasItem).z_as_relative = false
	if use_top_level and target is CanvasItem:
		(target as CanvasItem).top_level = target.get_parent() != get_ui_popup_layer()
	if target is Control:
		(target as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_align_popup_texts(target)
	if use_top_level:
		register_hover_popup(target)


func center_popup_texts(root: Node) -> void:
	if root == null:
		return
	if root is Label:
		var label := root as Label
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	elif root is Button:
		var button := root as Button
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	for child in root.get_children():
		center_popup_texts(child)


func instance_scene_safe(target_scene_, parent):
	var target = target_scene_.instantiate()
	parent.call_deferred("add_child", target)
	center_popup_texts(target)
	return target


func add_role_bullet_1_safe(parent, position, name_, Dic):
	if not RoleBullet_1:
		RoleBullet_1 = _load_scene("res://Scene/Hero/RoleBullet_1.tscn")
	var target = RoleBullet_1.instantiate()
	target.position = position
	target.name_ = name_
	target.HitDic = Dic
	parent.call_deferred("add_child", target)
	return target


func add_bullet_safe(bullet_name, parent, direction, show_speed, position, hit_name_, list):
	var bullet_scene = load_monster_bullet_scene(str(bullet_name))
	if bullet_scene == null:
		return null
	var target = bullet_scene.instantiate()
	target.AttList = list
	target.hit_name = hit_name_
	if str(hit_name_) != "" and list is Dictionary:
		target.objattackDic[hit_name_] = list
	target.position = position
	target.dir = direction
	target.skill_name = bullet_name
	target.speed = show_speed
	parent.call_deferred("add_child", target)
	return target


func instance_scene(target_scene_, parent):
	if target_scene_ == null:
		push_error("instance_scene got null scene")
		return null
	if parent == null or not is_instance_valid(parent):
		push_error("instance_scene got null or invalid parent for scene: %s" % target_scene_.resource_path)
		return null
	if parent.is_queued_for_deletion():
		push_error("instance_scene parent is queued for deletion for scene: %s" % target_scene_.resource_path)
		return null
	var target = target_scene_.instantiate()
	if target == null:
		return null
	register_ui_runtime_instance(target, str(target_scene_.resource_path))
	parent.call_deferred("add_child", target)
	center_popup_texts(target)
	return target


func add_bullet(bullet_name: String, parent, direction: bool, show_speed, position, hit_name_, list):
	var target = instance_scene(load_monster_bullet_scene(bullet_name), parent)
	if target == null:
		return null
	target.AttList = list
	target.hit_name = hit_name_
	target.position = position
	target.dir = direction
	target.skill_name = bullet_name
	target.speed = show_speed
	return target


func main_remove_child(parent, node_name):
	parent.remove_child(get_node(node_name))


func _physics_process(_delta: float) -> void:
	var sfx_enabled := bool(MainSet.set_data.get("RoleOrMonsterHit", true))
	var sfx_volume := float(MainSet.set_data.get("MusicFB_2", 0.0))
	if sfx_enabled != _last_sfx_enabled or not is_equal_approx(sfx_volume, _last_sfx_volume):
		_last_sfx_enabled = sfx_enabled
		_last_sfx_volume = sfx_volume
		sound_settings_changed.emit()
	if _debug_perf_label != null and is_instance_valid(_debug_perf_label):
		var now_msec := Time.get_ticks_msec()
		if _debug_perf_last_ticks_msec > 0:
			_debug_perf_max_frame_ms = maxf(_debug_perf_max_frame_ms, float(now_msec - _debug_perf_last_ticks_msec))
		_debug_perf_last_ticks_msec = now_msec
		_debug_perf_elapsed += _delta
		if _debug_perf_elapsed >= 1.0:
			_debug_perf_elapsed = 0.0
			_update_debug_perf_overlay()
	if MainSet.set_data.has("FileValue"):
		if float(MainSet.set_data["FileValue"]) < float(FileNum):
			MainSet.set_data["FileValue"] = FileNum
	if BoxCount > 0:
		BoxCount -= 1
	lj_count += 1
	if lj_count > 100:
		lj_count = 0
		LJ_times = 0
		check_combo_milestone(LJ_times)


func check_combo_milestone(current_combo: int):
	if current_combo == 0:
		_last_combo_value = 0
		_pending_combo_milestones.clear()
		return
	if current_combo % 40 == 0 and _last_combo_value % 40 != 0:
		if not _pending_combo_milestones.has(current_combo):
			_pending_combo_milestones[current_combo] = true
			call_deferred("_emit_combo_milestone_deferred", current_combo)
	_last_combo_value = current_combo


func _emit_combo_milestone_deferred(current_combo: int) -> void:
	await get_tree().process_frame
	_pending_combo_milestones.erase(current_combo)
	combo_milestone_reached.emit(current_combo)


func get_position_between(Ob_1, Ob_2):
	if Ob_1 == null or Ob_2 == null:
		return Vector2(0, 0)
	var pp_1 = Ob_2.position.x - Ob_1.position.x
	var pp_2 = Ob_2.position.y - Ob_1.position.y
	if pp_1 == 0 or pp_2 == 0:
		return Vector2(0, 0)
	var pp_3 = sqrt(pp_1 * pp_1 + pp_2 * pp_2)
	var pp_4: Vector2 = Vector2(pp_1 / pp_3, pp_2 / pp_3)
	return pp_4


func get_dis_betweem(Ob_1, Ob_2):
	if Ob_1 == null or Ob_2 == null:
		return 0
	var pp_1 = Ob_2.position.x - Ob_1.position.x
	var pp_2 = Ob_2.position.y - Ob_1.position.y
	var pp_3 = sqrt(pp_1 * pp_1 + pp_2 * pp_2)
	return pp_3


func load_role1_body(name_):
	var role_id := _current_role_id()
	var path := (
		"res://Art/HeroPicture/Role"
		+ str(role_id)
		+ "AllEquipment/Role_"
		+ str(role_id)
		+ "_Body_"
		+ str(name_)
		+ ".png"
	)
	var texture := _load_current_role_texture(path, true)
	if texture == null:
		push_warning("角色身体贴图加载失败: " + path)
	return texture


func load_role1_eq(name_):
	var role_id := _current_role_id()
	var path := (
		"res://Art/HeroPicture/Role" + str(role_id) + "AllEquipment/Role_" + str(role_id) + "_Eq_" + str(name_) + ".png"
	)
	var texture := _load_current_role_texture(path, false)
	if texture == null:
		push_warning("角色装备贴图加载失败: " + path)
	return texture


func _load_current_role_texture(path: String, is_body: bool) -> Texture2D:
	var texture := get_cached_texture(path)
	if texture == null:
		return null
	var previous_path := _current_role_body_texture_path if is_body else _current_role_equipment_texture_path
	if previous_path != "" and previous_path != path:
		_texture_cache.erase(previous_path)
	if is_body:
		_current_role_body_texture_path = path
	else:
		_current_role_equipment_texture_path = path
	return texture


func _current_role_id() -> int:
	var role_id := int(PlayerData.player_data.get("Myself", 1))
	if role_id < 1 or role_id > 6:
		return 1
	return role_id


func get_wx(num):
	var all_wx = ["金", "木", "水", "火", "土"]
	match num:
		0:
			var rr = randi_range(0, 100)
			if rr <= 4:
				return get_random_wx(3, all_wx)
			elif rr > 4 and rr < 10:
				return get_random_wx(2, all_wx)
			else:
				return get_random_wx(1, all_wx)
		1:
			return get_random_wx(1, all_wx)
		2:
			return get_random_wx(2, all_wx)
		3:
			return get_random_wx(3, all_wx)
		4:
			var temp_list = all_wx.duplicate()
			var remove_index = randi_range(0, temp_list.size() - 1)
			temp_list.remove_at(remove_index)
			return temp_list
		5:
			return all_wx
		_:
			return []


func get_random_wx(count, source_list):
	var result = []
	var temp_list = source_list.duplicate()
	for i in range(count):
		if temp_list.size() == 0:
			break
		var random_index = randi_range(0, temp_list.size() - 1)
		result.append(temp_list[random_index])
		temp_list.remove_at(random_index)
	return result


func check_dir_between_two_obj(Player, Monster):
	if Player.position.x >= Monster.position.x:
		if not Player.PlayerDir:
			return true
	elif Player.position.x < Monster.position.x:
		if Player.PlayerDir:
			return true
	return false


func remove_all_buff():
	Global.is_Mpo = false
	Global.is_ice = false
	Global.is_poision = false
	Global.is_Fire = false
	Global.is_speed_down = false
	Global.is_stun = false
	Global.is_Bleed = false
	Global.is_EyeFix = false
	Global.is_DeadLink = false
	RoleProp.ws_value = 0


func load_(name_):
	var abc = load("res://Art/BackPack/AllItems/" + str(name_) + ".png")
	return abc


func add_all_item_num(List, Num, NumRange):
	randomize()
	var Dic = {}
	for i in List:
		Dic[i] = {"Name": i, "Num": 0}
	for i in range(Num):
		var item_name = List[randi_range(0, List.size() - 1)]
		Dic[item_name]["Num"] += NumRange
	var List_ = []
	for i in Dic:
		if int(Dic[i]["Num"]) == 0:
			List_.push_back(i)
	for i in List_:
		Dic.erase(i)
	for i in Dic:
		var num = Dic[i]["Num"]
		PlayerData.add_dj(i, num)
	return Dic


func get_all_item_num(List, Num, NumRange):
	randomize()
	var Dic = {}
	for i in List:
		Dic[i] = {"Name": i, "Num": 0}
	for i in range(Num):
		var item_name = List[randi_range(0, List.size() - 1)]
		Dic[item_name]["Num"] += NumRange
	var List_ = []
	for i in Dic:
		if int(Dic[i]["Num"]) == 0:
			List_.push_back(i)
	for i in List_:
		Dic.erase(i)
	for i in Dic:
		var item_name = i
		var Num_ = Dic[i]["Num"]
		Dic[i] = {"Name": item_name, "Value": Num_, "Prop": {}, "WX": [], "StrengthValue": 0}
	var ll = []
	for i in Dic:
		ll.push_back(Dic[i])
	return ll


func remove_all_active_buffs():
	for i in RoleProp.SourcePlayer.buff.get_children():
		if i != null:
			if i.BuffInfo["AddTime"] < 999:
				if i.BuffInfo.has("CanRemove"):
					if i.BuffInfo["CanRemove"]:
						i.queue_free()
				else:
					i.queue_free()


func remove_a_all_buff():
	for i in RoleProp.SourcePlayer.buff.get_children():
		if i != null:
			match i.BuffInfo["Name"]:
				"DoubleFallPro":
					continue
			i.queue_free()


func on_fresh():
	var Dic = Time.get_datetime_dict_from_system()
	var MyDic = PlayerData.player_data["MyTime"]
	if MyDic == {}:
		return
	if int(Dic["year"]) < int(MyDic["year"]):
		return false
	elif int(Dic["year"]) > int(MyDic["year"]):
		return true
	else:
		if int(Dic["month"]) < int(MyDic["month"]):
			return false
		elif int(Dic["month"]) > int(MyDic["month"]):
			return true
		else:
			if int(Dic["day"]) < int(MyDic["day"]):
				return false
			elif int(Dic["day"]) > int(MyDic["day"]):
				return true
			else:
				return false


func check_wd(OBJ):
	var Count: int = 0
	for i in OBJ.buff.get_children():
		if i != null:
			if i.BuffInfo["Name"] == "Voodoo":
				Count += 1
	return Count


func remove_wd(OBJ):
	for i in OBJ.buff.get_children():
		if i != null:
			if i.BuffInfo["Name"] == "Voodoo":
				i.queue_free()


func get_clean_name(Name: String):
	var xianyu_body_name_map := {
		"xyfjwk": "wkxysz",
		"xyfjts": "tsxysz",
		"xyfjbj": "bjxysz",
		"xyfjss": "ssxysz",
		"xyfjbl": "blxyfj",
	}
	if xianyu_body_name_map.has(Name):
		return xianyu_body_name_map[Name]
	if Name.get_slice("shishi", 1) != Name:
		return Name.get_slice("shishi", 1)
	elif Name.get_slice("youxiu", 1) != Name:
		return Name.get_slice("youxiu", 1)
	elif Name.get_slice("jingliang", 1) != Name:
		return Name.get_slice("jingliang", 1)
	elif Name.get_slice("putong", 1) != Name:
		return Name.get_slice("putong", 1)
	elif Name.get_slice("xieling", 1) != Name:
		return Name.get_slice("xieling", 1)
	elif Name.get_slice("hunqi", 1) != Name:
		return Name.get_slice("hunqi", 1)
	elif Name.get_slice("chuanshuo", 1) != Name:
		return Name.get_slice("chuanshuo", 1)
	elif Name.get_slice("shenqi", 1) != Name:
		return Name.get_slice("shenqi", 1)
	return Name


func normal_face_player(OBJ, dir, Player):
	if dir:
		OBJ.look_at(Player.position)
	else:
		OBJ.look_at(Player.position)
		OBJ.bullet_ani.flip_v = true


var _monsters_to_track = []


func track_monster(monster: Node):
	if not monster.tree_exited.is_connected(_on_monster_exited.bind(monster)):
		monster.tree_exited.connect(_on_monster_exited.bind(monster))
	_monsters_to_track.append(monster)


func _on_monster_exited(monster: Node):
	print("[Global monitor] Monster deleted: ", monster)
	print_stack()
	print("  delete frame: ", Engine.get_process_frames())

# ==============================================================================
# Phase 6-3: 现代 GDScript 规范 snake_case 双轨兼容函数入口
# ==============================================================================
