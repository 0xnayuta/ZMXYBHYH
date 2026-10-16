extends CanvasLayer


func _ready():
	bar.value = 0
	ResourceLoader.load_threaded_request("res://Scene/Main_menu/Main_Menu.tscn")


@onready var bar: ProgressBar = $ProgressBar


func _process(delta):
	var progress = []
	var status = ResourceLoader.load_threaded_get_status("res://Scene/Main_menu/Main_Menu.tscn", progress)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		bar.value = progress[0] * 100
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		bar.value = 100
		get_tree().change_scene_to_file("res://Scene/Main_menu/Main_Menu.tscn")
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		print("Boot load failed")
