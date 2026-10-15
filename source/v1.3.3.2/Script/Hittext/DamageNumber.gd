extends TextureRect

var need_number: int
var Type: String
var is_crit: bool
var is_set = false
var target: BaseObject



func _physics_process(_delta: float) -> void :
	if not is_set:
		changepic(Type, need_number, is_crit)
		is_set = true


func changepic(Type_: String, num: int, _crit: bool):
	if num == null:
		self.set_texture(null)
		return
	if Type_ == "cure":
		self.set_texture(load("res://Art/AllNumber/" + str(Type_) + "/" + str(Type_) + "_" + str(int(num)) + ".png"))
		return
	if target != null:
		if target is BaseHero:
			if Type_ != "real":
				self.set_texture(load("res://Art/AllNumber/monster/" + str(Type_) + "/" + str(Type_) + "_" + str(int(num)) + ".png"))
			else:
				self.set_texture(load("res://Art/AllNumber/" + str(Type_) + "/" + str(Type_) + "_" + str(int(num)) + ".png"))

		elif target is BaseMonster:
			if is_crit:
				var tt = Type_ + "crit"

				self.set_texture(load("res://Art/AllNumber/" + str(tt) + "/" + str(Type) + "_" + str(int(num)) + ".png"))
			else:
				if Type == "physics":
					print("789")

					self.set_texture(load("res://Art/AllNumber/magic/" + str(Type_) + "_" + str(int(num)) + ".png"))

				else:
					self.set_texture(load("res://Art/AllNumber/" + str(Type_) + "/" + str(Type_) + "_" + str(int(num)) + ".png"))
