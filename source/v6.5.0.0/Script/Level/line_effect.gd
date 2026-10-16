extends Line2D

var Type: String
var Player: BaseHero
var Monster: BaseMonster
var reduce_count: int


func _physics_process(delta: float) -> void:
	Player = RoleProp.source_player
	if Player != null:
		points[1] = Player.position

	reduce_count += 1
	if reduce_count % 60 == 0:
		reduce_count = 0
		match Type:
			"Red":
				if Player != null:
					Player.effect_reducehp(RoleProp.roleprop.SHp * 0.03, "magic")
			"Blue":
				if Player != null:
					RoleProp.roleprop.Mp -= RoleProp.roleprop.SMp * 0.03
