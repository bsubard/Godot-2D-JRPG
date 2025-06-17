# monster.gd (attached to each monster Area2D in the world)
extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		# IMPORTANT: Store our own unique name before starting combat.
		GlobalState.last_fought_monster_name = self.name

		# Go to combat scene
		get_tree().change_scene_to_file("res://battle.tscn")
