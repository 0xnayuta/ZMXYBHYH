extends SceneTree
func _init() -> void :
	print("CLEAN_PROBE_START spine=" + str(ClassDB.class_exists("SpineSprite")))
	quit(0)
