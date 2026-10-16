extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var Drop: bool
var MyName: String
var objattackDic = {}
var hit_name


func _get_trap_power() -> float:
	if RoleProp == null or not (RoleProp.roleprop is Dictionary):
		return 0.0
	return float(RoleProp.roleprop.get("SHp", 0.0)) * 0.05


func _physics_process(delta: float) -> void:
	hit_name = MyName
	if objattackDic.is_empty():
		objattackDic = {
			"Trap1": {"power": 0.0, "hurtBack": [15, -15], "attackKind": "real"},
			"Trap2": {"power": 0.0, "hurtBack": [15, -15], "attackKind": "real"},
			"Trap3": {"power": 0.0, "hurtBack": [15, -15], "attackKind": "real"}
		}
	var trap_power: float = _get_trap_power()
	objattackDic["Trap1"]["power"] = trap_power
	objattackDic["Trap2"]["power"] = trap_power
	objattackDic["Trap3"]["power"] = trap_power
	if MyName == "Trap1":
		if not Drop:
			animation_player.play("Trap2")
	if MyName == "Trap3":
		animation_player.play("Trap3")


func _on_area_2d_area_entered(area: Area2D, _extra = null) -> void:
	if MyName == "Trap1":
		Drop = true
		animation_player.play("Trap1")
		await animation_player.animation_finished
		animation_player.play("Trap2")
		Drop = false


func _on_hit_box_area_entered(area: Area2D, _extra = null) -> void:
	var target = area.get_parent().get_parent()
	if target is BaseHero:
		target.reduce_hp(_get_trap_power(), self, self)
		if RoleProp.is_ws_state:
			return
		if target is role3:
			if target.Is_sdBuff:
				return
		if target is role3:
			if target.IsTMc:
				return
		target.state_behit()
		if randi_range(0, 100) < 50:
			target.attack_to_left(self, self)
		else:
			target.attack_to_right(self, self)
