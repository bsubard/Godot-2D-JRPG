# Player.gd
extends CharacterBody2D

# --- Configuration ---
const TILE_SIZE := 16
const MOVE_DURATION := 0.2 # How long each move takes in seconds

# --- State ---
# A reference to our tween. In Godot 4, the type hint is just 'Tween'.
@onready var tween: Tween = create_tween()
# A flag to prevent input while moving.
var is_moving := false


func _ready():
	# --- Case 1: Returning from the castle ---
	if GlobalState.spawn_at_castle_exit:
		GlobalState.spawn_at_castle_exit = false # Reset flag
		
		# The node name for the castle entrance is "castle"
		var castle_node = get_tree().get_root().find_child("castle", true, false)

		if castle_node:
			self.global_position = castle_node.global_position + Vector2(0, 16)
		else:
			print("ERROR: Could not find 'castle' node to position player.")

	# --- Case 2 (NEW): Returning from combat ---
	elif GlobalState.spawn_at_monster_location:
		GlobalState.spawn_at_monster_location = false # Reset flag

		# Find the monster using the name we saved before combat started
		var monster_name = GlobalState.last_fought_monster_name
		if monster_name != "":
			var monster_node = get_tree().get_root().find_child(monster_name, true, false)

			if monster_node:
				# Position the player 16 pixels below the monster (+16 on Y)
				self.global_position = monster_node.global_position + Vector2(0, 16)
				
				# Optional but recommended: Remove the defeated monster
				#monster_node.queue_free()
			else:
				print("ERROR: Could not find monster named '", monster_name, "' to position player.")
		else:
			print("ERROR: Returned from combat but no monster name was saved.")




func _process(delta):
	# We only process input if we are not already in the middle of a move.
	if not is_moving:
		handle_input()

func handle_input():
	var direction := Vector2.ZERO

	# Using elif ensures only one direction is chosen per frame,
	# which is typical for this kind of movement.
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1
	elif Input.is_key_pressed(KEY_S):
		direction.y += 1
	elif Input.is_key_pressed(KEY_A):
		direction.x -= 1
	elif Input.is_key_pressed(KEY_D):
		direction.x += 1
	
	# If a direction key was pressed, try to move.
	if direction != Vector2.ZERO:
		move(direction)

# The main movement logic
func move(direction: Vector2):
	# Calculate where we want to end up.
	var target_pos = global_position + direction * TILE_SIZE
	
	# --- The Crucial Collision Check ---
	# Before we move, we check if the target cell is occupied.
	if is_path_blocked(target_pos):
		# Optional: Play a "bump" sound or animation here.
		return # Stop the function, we can't move here.

	# If the path is clear, we start the move.
	is_moving = true
	
	# Create a new tween. It's safer than reusing a finished one.
	tween = get_tree().create_tween()
	
	# This is the smooth movement from your first script.
	tween.tween_property(self, "global_position", target_pos, MOVE_DURATION).set_trans(Tween.TRANS_SINE)
	
	# When the tween finishes, we'll call the _on_move_finished function.
	# We use bind() to pass the target_pos to the finished function.
	tween.finished.connect(_on_move_finished.bind(target_pos))


# This function checks for obstacles without needing a RayCast2D node.
func is_path_blocked(target_position: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	# We create a query to check for collisions between our current center 
	# and the target center. We exclude ourself from the check.
	var query = PhysicsRayQueryParameters2D.create(global_position, target_position, self.collision_mask, [self])
	
	var result = space_state.intersect_ray(query)
	
	# intersect_ray returns a dictionary if it hits something, and an empty one if not.
	# So, `not result.is_empty()` is a clear way to see if we hit something.
	return not result.is_empty()


# This function is called automatically when the tween completes.
func _on_move_finished(final_pos: Vector2):
	# It's good practice to snap the position to be perfectly on the grid
	# to avoid any floating point inaccuracies from the tween.
	global_position = final_pos
	is_moving = false
