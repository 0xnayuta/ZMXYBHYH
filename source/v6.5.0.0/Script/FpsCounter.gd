extends CanvasLayer

func _enter_tree() -> void :
	layer = 128

var fps_label: Label
var _elapsed: float = 0.0

func _ready() -> void :
	fps_label = Label.new()
	fps_label.name = "FpsCounter"
	fps_label.add_theme_color_override("font_color", Color(0, 1, 0, 1))
	fps_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	fps_label.add_theme_constant_override("outline_size", 2)
	fps_label.add_theme_font_size_override("font_size", 14)
	fps_label.position = Vector2(5, 5)
	add_child(fps_label)

func _process(_delta: float) -> void :
	_elapsed += _delta
	if _elapsed < 0.25:
		return
	_elapsed = 0.0
	if fps_label:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
