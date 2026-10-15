extends Node
class_name CheckC

func _physics_process(delta: float) -> void :

























































































	pass
func RemoveWhenLh(num):
	if PlayerData.player_data["coin_num"] >= num:
		removedata()

func zl_zb():
	var list = []
	for i in range(1, 10):
		for u in PlayerData.player_data["装备列表"]["页码" + str(i + 1)]:
			list.push_back(u)
	return list
func removedata():
	MemoryClass.Remove()
	get_tree().change_scene_to_file("res://Scene/Main_menu/Main_Menu.tscn")
func CheckMagicWeaponInfo():
	var List = zl_zb()
	if List.size() != null:
		for i in List:
			pass
	pass
