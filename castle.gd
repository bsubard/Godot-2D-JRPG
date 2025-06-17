# castle_entrance.gd
extends Area2D

# Set this to "res://town.tscn" in the Inspector.
@export var target_scene: String


func _on_body_entered(body):
	if body.is_in_group("player"):
		# Just change the scene. No saving, no tracking.
		get_tree().change_scene_to_file("res://town.tscn")
