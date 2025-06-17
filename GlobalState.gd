# GlobalState.gd
extends Node

# Flag for returning from the castle
var spawn_at_castle_exit: bool = false

# New flag for returning from combat
var spawn_at_monster_location: bool = false

# We need to store which monster we fought to find it again
var last_fought_monster_name: String = ""
