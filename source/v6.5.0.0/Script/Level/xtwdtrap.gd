extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cooldown_timer: Timer = $CooldownTimer

var hit_name
var get_name_
var IsHit: bool
var is_play
var total_hit = 0
var objattackDic = {}
var Player
var HitCount: int = 0


func _ready():
	cooldown_timer.wait_time = 5.0
	cooldown_timer.one_shot = true


func _physics_process(delta: float) -> void:
	var Parent = get_parent()
	Player = Parent.Role_

	if not IsHit:
		HitCount = 0
		animation_player.play("Empty")
	else:
		if HitCount % 120 == 0 and cooldown_timer.is_stopped():
			animation_player.play("Hit")
		HitCount += 1


func _on_hix_box_area_entered(area: Area2D) -> void:
	if not cooldown_timer.is_stopped():
		return

	var target: Node2D = null
	var node = area.get_parent()

	while node:
		if node is BaseHero or node is SummonBaseMonster:
			target = node
			break
		node = node.get_parent()

	if target == null or not is_instance_valid(target):
		return

	var target_max_hp: int
	if target is BaseHero:
		target_max_hp = RoleProp.roleprop.SHp
	elif target is SummonBaseMonster:
		target_max_hp = target.SHp
	else:
		target_max_hp = 100

	hit_name = "Trap_1"
	self.objattackDic["Trap_1"] = {"power": int(target_max_hp * 0.05), "hurtBack": [15, -15], "attackKind": "real"}

	if target.has_node("Buff"):
		(
			Global
			. AddBuff(
				target.get_node("Buff"),
				{
					"Name": "Fire",
					"AddTime": 2,
					"ReduceInterval": 0.5,
					"value": int(target_max_hp * 0.01),
					"AttackKind": "magic",
					"CanAdd": false,
					"DeBuff": true,
				}
			)
		)

	if target is BaseHero:
		if RoleProp.is_ws_state:
			return
		if target is Role3Hero:
			if target.Is_sdBuff or target.IsTMc:
				return
		target.state_behit()
		if randi_range(0, 100) < 50:
			target.attack_to_left(self, self)
		else:
			target.attack_to_right(self, self)

	elif target is SummonBaseMonster:
		if target.has_method("state_behit"):
			target.state_behit()

		if randi_range(0, 100) < 50:
			target.velocity.x = -15 * 25
			target.velocity.y = -15 * 15
		else:
			target.velocity.x = 15 * 25
			target.velocity.y = -15 * 15

	cooldown_timer.start()


func _on_area_2d_area_entered(area: Area2D) -> void:
	IsHit = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	IsHit = false


func _on_cooldown_timer_timeout() -> void:
	pass
