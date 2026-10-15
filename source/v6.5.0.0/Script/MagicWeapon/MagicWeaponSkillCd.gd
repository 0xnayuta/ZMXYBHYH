extends TextureRect
class_name mgcd
@onready var skillicon: TextureRect = $skillicon
@onready var pic_box: TextureProgressBar = $PicBox
@onready var last_time: Timer = $LastTime
@onready var time_text: Label = $TimeText

var SkillName: String
var MaxTime: float
var Iszhenfa: bool
var _last_icon_key: = ""

func _physics_process(delta: float) -> void :
	if SkillName != null and SkillName != "":
		var icon_key: = str(SkillName) + ":" + str(Iszhenfa)
		if _last_icon_key != icon_key:
			_last_icon_key = icon_key
			var icon_path: = "res://Art/TwentyEightConstellations/" + str(SkillName) + ".png" if Iszhenfa else "res://Art/MagicWeapon/Skill_Icon/" + str(SkillName) + ".png"
			var icon_texture: = Global.get_cached_texture(icon_path)
			skillicon.texture = icon_texture
			pic_box.texture_progress = icon_texture
		if MaxTime > 0:
			if last_time.is_stopped():
				last_time.start(MaxTime)
	if last_time.time_left <= 0:
		time_text.visible = false
		pic_box.value = 0
	else:
		time_text.visible = true
		if last_time.time_left > 1:
			time_text.text = str(snapped(last_time.time_left, 1))
		else:
			time_text.text = str(snapped(last_time.time_left, 0.1))
		pic_box.value = last_time.time_left / float(MaxTime)

func _on_last_time_timeout() -> void :
	MaxTime = 0


func _on_mouse_entered() -> void :
	pass
