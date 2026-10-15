extends Node

func _ready() -> void :
	var old_unlocked: bool = bool(PlayerData.player_data.get("月兔已解锁", false))
	var old_monster_blood: bool = bool(MainSet.set_data.get("MonsterBloodSHow", true))
	PlayerData.player_data["月兔已解锁"] = false
	MainSet.set_data["MonsterBloodSHow"] = false

	var scene: = load("res://Scene/Monster/Monster_130.tscn") as PackedScene
	var monster: = scene.instantiate() as Monster130
	add_child(monster)
	await get_tree().process_frame
	monster.Hp = 0
	monster.state_death()
	await get_tree().create_timer(1.5, false).timeout
	if is_instance_valid(monster):
		push_error("嫦娥死亡动画结束后仍未清理")
		get_tree().quit(1)
		return
	if not bool(PlayerData.player_data.get("月兔已解锁", false)):
		push_error("嫦娥死亡后未解锁月兔")
		get_tree().quit(1)
		return

	PlayerData.player_data["月兔已解锁"] = old_unlocked
	MainSet.set_data["MonsterBloodSHow"] = old_monster_blood
	print("CHANGE_DEATH_PROBE_OK")
	get_tree().quit()

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	push_error(message)
	get_tree().quit(1)
