extends Node2D
class_name Role4Bullet
var Player: BaseHero
var OldMonster: BaseMonster
var TargetMonster: BaseMonster
var HitCount: int = 0
var Speed = 10
var IsSet: bool


func _physics_process(delta: float) -> void:
	if not IsSet:
		TargetMonster = CheckMonster()
		OldMonster = TargetMonster
		IsSet = true
	if TargetMonster != null:
		self.position += Global.get_position_between(self, TargetMonster) * Speed
	else:
		queue_free()
	if TargetMonster == null or OldMonster == null:
		self.queue_free()


func _on_queue_timer_timeout() -> void:
	queue_free()


func CheckMonster():
	var MrList = []
	if Player is BaseHero:
		MrList = Player.get_parent().get_parent().monster.get_children()
	for i in MrList:
		if _is_valid_tmc_target(i):
			return i
	return null


func _is_valid_tmc_target(target: Node) -> bool:
	if target == null:
		return false
	if not is_instance_valid(target):
		return false
	if not (target is BaseMonster):
		return false
	if target == OldMonster:
		return false
	if target.Hp <= 0:
		return false
	if target.get_meta("pet_tiger_unit", false) or target.get_meta("is_summon", false):
		return false
	return true


func _process(delta: float) -> void:
	if HitCount > 3:
		queue_free()


func _on_check_body_entered(body: Node2D) -> void:
	if body == null:
		return
	if body is BaseMonster:
		if body == TargetMonster and _is_valid_tmc_target(body):
			OldMonster = TargetMonster
			(
				Global
				. add_buff(
					body.buff,
					{
						"Name": "Voodoo",
						"AddTime": 5,
						"ReduceInterval": 1,
						"value": 0,
						"CanAdd": true,
						"AttackKind": "real",
					}
				)
			)
			(
				Global
				. add_buff(
					body.buff,
					{
						"Name": "stun",
						"AddTime": 0.3,
						"ReduceInterval": 0,
						"value": 0,
						"CanAdd": false,
						"AttackKind": "",
					}
				)
			)
			TargetMonster = CheckMonster()
