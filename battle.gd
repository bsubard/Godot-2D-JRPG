extends Node2D

# -- UI and Node References --
@onready var hero: Sprite2D = $hero
@onready var enemy: Sprite2D = $enemy
@onready var hero_hp_bar: TextureProgressBar = $hero_hp_bar
@onready var enemy_hp_bar: TextureProgressBar = $enemy_hp_bar
@onready var hero_mp_bar: TextureProgressBar = $hero_mp_bar
@onready var enemy_mp_bar: TextureProgressBar = $enemy_mp_bar
@onready var hero_hp_label: Label = $hero_hp_label
@onready var enemy_hp_label: Label = $enemy_hp_label
@onready var hero_mp_label: Label = $hero_mp_label
@onready var enemy_mp_label: Label = $enemy_mp_label
@onready var attack_button: Button = $HBoxContainer_menu/VBoxContainer_attack_magic/attack_button
@onready var magic_button: Button = $HBoxContainer_menu/VBoxContainer_attack_magic/magic_button
@onready var item_button: Button = $HBoxContainer_menu/VBoxContainer_item_run/item_button
@onready var run_button: Button = $HBoxContainer_menu/VBoxContainer_item_run/run_button

# -- Stats and State --
var hero_stats: Dictionary = {
	"stamina": 12, "strength": 55, "wisdom": 8, "agility": 7, "defence": 6
}
var enemy_stats: Dictionary = {
	"stamina": 15, "strength": 12, "wisdom": 5, "agility": 6, "defence": 4
}

var hero_max_hp: int
var hero_current_hp: int
var hero_max_mp: int
var hero_current_mp: int

var enemy_max_hp: int
var enemy_current_hp: int
var enemy_max_mp: int
var enemy_current_mp: int

var is_player_turn: bool = true
var is_animating: bool = false # Prevents multiple actions at once
var hero_initial_position: Vector2
var enemy_initial_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hero_initial_position = hero.position
	enemy_initial_position = enemy.position
	initialize_characters()
	update_all_ui()
	attack_button.pressed.connect(_on_attack_button_pressed)

func initialize_characters() -> void:
	hero_max_hp = hero_stats.stamina * 10
	hero_current_hp = hero_max_hp
	hero_max_mp = hero_stats.wisdom * 10
	hero_current_mp = hero_max_mp
	enemy_max_hp = enemy_stats.stamina * 10
	enemy_current_hp = enemy_max_hp
	enemy_max_mp = enemy_stats.wisdom * 10
	enemy_current_mp = enemy_max_mp

func update_all_ui() -> void:
	hero_hp_bar.max_value = hero_max_hp
	hero_hp_bar.value = hero_current_hp
	hero_hp_label.text = "HP: %d / %d" % [hero_current_hp, hero_max_hp]
	hero_mp_bar.max_value = hero_max_mp
	hero_mp_bar.value = hero_current_mp
	hero_mp_label.text = "MP: %d / %d" % [hero_current_mp, hero_max_mp]
	enemy_hp_bar.max_value = enemy_max_hp
	enemy_hp_bar.value = enemy_current_hp
	enemy_hp_label.text = "HP: %d / %d" % [enemy_current_hp, enemy_max_hp]
	enemy_mp_bar.max_value = enemy_max_mp
	enemy_mp_bar.value = enemy_current_mp
	enemy_mp_label.text = "MP: %d / %d" % [enemy_current_mp, enemy_max_mp]

# -- Turn Logic --

func _on_attack_button_pressed() -> void:
	if not is_player_turn or is_animating:
		return

	is_player_turn = false
	is_animating = true
	toggle_action_buttons(false)
	
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var attack_position = hero.position + Vector2(650, 0)
	
	tween.tween_property(hero, "position", attack_position, 0.4)
	tween.tween_callback(hero_deal_damage)
	tween.tween_property(hero, "position", hero_initial_position, 0.4).set_delay(0.2)
	tween.finished.connect(start_enemy_turn)

func hero_deal_damage() -> void:
	var hero_attack_power = hero_stats.strength * randf_range(0.8, 1.2)
	var enemy_defense_power = enemy_stats.defence * randf_range(0.8, 1.2)
	var damage = max(0, hero_attack_power - enemy_defense_power)
	
	enemy_current_hp = max(0, enemy_current_hp - int(damage))
	update_all_ui()
	
	if enemy_current_hp <= 0:
		handle_victory()

func start_enemy_turn() -> void:
	# If hero already won, don't let the enemy attack
	if enemy_current_hp <= 0:
		is_animating = false
		return

	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var attack_position = enemy.position + Vector2(-650, 0)
	
	tween.tween_property(enemy, "position", attack_position, 0.4).set_delay(0.5) # Small delay before enemy attacks
	tween.tween_callback(enemy_deal_damage)
	tween.tween_property(enemy, "position", enemy_initial_position, 0.4).set_delay(0.2)
	tween.finished.connect(end_enemy_turn)

func enemy_deal_damage() -> void:
	var enemy_attack_power = enemy_stats.strength * randf_range(0.8, 1.2)
	var hero_defense_power = hero_stats.defence * randf_range(0.8, 1.2)
	var damage = max(0, enemy_attack_power - hero_defense_power)

	hero_current_hp = max(0, hero_current_hp - int(damage))
	update_all_ui()

	if hero_current_hp <= 0:
		handle_defeat()

func end_enemy_turn() -> void:
	is_animating = false
	# Only give the turn back if the game isn't over
	if hero_current_hp > 0 and enemy_current_hp > 0:
		is_player_turn = true
		toggle_action_buttons(true)

func handle_victory() -> void:
	# 1. Set the flag to tell the player script what to do in the next scene.
	GlobalState.spawn_at_monster_location = true

	# 2. Change the scene back to the world.
	get_tree().change_scene_to_file("res://world.tscn")

func handle_defeat() -> void:
	# 1. Set the same flag. We want the same behavior for winning or losing.
	GlobalState.spawn_at_monster_location = true

	# 2. Change the scene.
	get_tree().change_scene_to_file("res://world.tscn")

func toggle_action_buttons(enabled: bool) -> void:
	attack_button.disabled = not enabled
	magic_button.disabled = not enabled
	item_button.disabled = not enabled
	run_button.disabled = not enabled

func _process(delta: float) -> void:
	pass
