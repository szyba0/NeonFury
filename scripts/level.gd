extends Node2D

@export var patrol_paths: Array[Path2D]  # Tablica referencji do ścieżek patrolowych
@onready var pause_menu = $Player/CharacterBody2D/PauseUI/PauseMenu
var is_paused = false

signal change_scene_signal(target_scene)


func _ready():
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	
	randomize()  # Ustaw losowy seed dla generatora liczb losowych
	# Dodaj wszystkie ścieżki patrolowe do tablicy ręcznie lub automatycznie

	
	# Przekaż ścieżki patrolowe do każdego przeciwnika w poziomie
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.connect("died",enemy_died)
		enemy.set_patrol_paths(patrol_paths)

	
func _input(event):
	if event.is_action_pressed("PAUSE"):
		toggle_pause()

func toggle_pause():
	if !get_tree().paused:
		get_tree().paused = true
		pause_menu.show()


func enemy_died(pts):
	$Player.get_child(0).combo(pts)


func _on_change_scene_signal(target_scene: Variant) -> void:
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target_scene)
