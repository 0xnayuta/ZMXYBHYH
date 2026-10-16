extends BaseMagicWeapon
class_name Zcld

var is_zcld = true


func _ready():
	FB_Level = PlayerData.get_most_level("zcld")


func _physics_process(delta: float) -> void:
	FB_Level = PlayerData.get_most_level("zcld")
	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func use_skill():
	use_over()
