





















@tool
extends EditorPlugin

var import_plugin_spritesheet = null

func get_name():
	return "TexturePacker Importer"


func _enter_tree():
	import_plugin_spritesheet = preload("res://addons/codeandweb.texturepacker/texturepacker_import_spritesheet.gd").new()
	add_import_plugin(import_plugin_spritesheet)


func _exit_tree():
	remove_import_plugin(import_plugin_spritesheet)
	import_plugin_spritesheet = null
