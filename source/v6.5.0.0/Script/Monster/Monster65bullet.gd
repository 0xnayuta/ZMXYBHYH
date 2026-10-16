extends Node2D
var GetPlayer: BaseHero
var AddCount: int = 0
@onready var pler: AnimationPlayer = $Pler


func _ready():
	set_meta("is_monster_bullet", true)
	pler.play("wang")


func _physics_process(delta: float) -> void:
	if GetPlayer != null:
		GetPlayer.velocity.x = 0
		GetPlayer.velocity.y = 0

	if AddCount % 30 == 0:
		if GetPlayer != null:
			(
				Global
				. add_buff(
					GetPlayer.buff,
					{
						"Name": "speed_down",
						"AddTime": 2,
						"ReduceInterval": 0,
						"value": 0.6,
						"AttackKind": "",
					}
				)
			)

			(
				Global
				. add_buff(
					GetPlayer.buff,
					{
						"Name": "silent",
						"AddTime": 2,
						"ReduceInterval": 0,
						"value": 0.3,
						"AttackKind": "",
						"CanAdd": false,
						"DeBuff": true,
					}
				)
			)
	AddCount += 1


func _on_check_body_entered(body: Node2D) -> void:
	if body is BaseHero:
		GetPlayer = body

		(
			Global
			. add_buff(
				body.buff,
				{
					"Name": "speed_down",
					"AddTime": 2,
					"ReduceInterval": 0,
					"value": 0.6,
					"AttackKind": "",
				}
			)
		)

		(
			Global
			. add_buff(
				body.buff,
				{
					"Name": "silent",
					"AddTime": 2,
					"ReduceInterval": 0,
					"value": 0.3,
					"AttackKind": "",
					"CanAdd": false,
					"DeBuff": true,
				}
			)
		)


func _on_check_body_exited(body: Node2D) -> void:
	GetPlayer = null


func _on_hit_box_area_entered(area: Area2D) -> void:
	var target = area.get_parent().get_parent()
