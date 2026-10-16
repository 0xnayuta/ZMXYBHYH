class_name SxmgCSM
extends Area2D


func _ready() -> void:
	if ResourceLoader.exists("res://Art/2_6_0_0/Level_sxmg/csm/csm.wav"):
		Global.addBGM_(self, "res://Art/2_6_0_0/Level_sxmg/csm/csm.wav")


func _on_body_entered(body: Node2D) -> void:
	if body is BaseHero:
		Global.call_deferred("change_scene", "res://Scene/Level/Level_sxmg.tscn")
