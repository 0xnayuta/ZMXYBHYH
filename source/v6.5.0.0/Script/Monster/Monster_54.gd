extends BaseMonster

var CheckCount: int = 0


func monster_54():
	self.is_boss = false
	self.my_mr_name = "青蛇"
	self.attack_in = 0
	self.level = 30
	self.SHp = 3000
	self.Hp = self.SHp
	self.def = 180
	self.mdef = 130
	self.crit = 5
	self.miss = 19
	self.lucky = 0
	self.Htarget = 0
	self.Toughness = 0
	self.ar = 0
	self.sp = 20
	self.Critreduce = 0
	self.speed = 7
	self.mysee = 400
	self.attackRange = 260
	self.attackDesire = 75
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 75
	self.fall_coin = 40
	self.objattackDic["hit1"] = {
		"power": 150,
		"hurtBack": [-8, 0],
		"attackKind": "magic",
	}
	self.fall_pro = 0.05
	self.fall_list = [
		{"name": "jssp", "value": 1},
		{"name": "lshb", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_54()


func call_bullet():
	if self.MonsterDirection:
		Global.add_bullet(
			"Monster54Bullet",
			self.bullet,
			self.MonsterDirection,
			1,
			Vector2(self.position.x + 220, self.position.y),
			"hit1",
			self.objattackDic["hit1"]
		)
	else:
		Global.add_bullet(
			"Monster54Bullet",
			self.bullet,
			self.MonsterDirection,
			1,
			Vector2(self.position.x - 220, self.position.y),
			"hit1",
			self.objattackDic["hit1"]
		)


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func CallBullet():
	return call_bullet()
