# exit_town.gd
extends Area2D


func _on_body_entered(body):
	if body.is_in_group("player"):
		# 1. Set the flag to true. We are telling the next scene (the world)
		#    that the player needs to be placed at the castle exit.
		GlobalState.spawn_at_castle_exit = true
		
		# 2. Change back to the world scene.
		get_tree().change_scene_to_file("res://world.tscn")
