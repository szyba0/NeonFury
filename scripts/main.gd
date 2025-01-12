extends Node2D

@export var patrol_paths: Array[Path2D]  # Tablica referencji do ścieżek patrolowych
@onready var pause_menu = $"/root/Main/Player/CharacterBody2D/PauseUI/PauseMenu"
var is_paused = false


func _ready():
	randomize()  # Ustaw losowy seed dla generatora liczb losowych
	# Dodaj wszystkie ścieżki patrolowe do tablicy ręcznie lub automatycznie
	
	# Przekaż ścieżki patrolowe do każdego przeciwnika w poziomie
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.set_patrol_paths(patrol_paths)

	
func _input(event):
	if event.is_action_pressed("PAUSE"):
		toggle_pause()

func toggle_pause():
	if !get_tree().paused:
		get_tree().paused = true
		pause_menu.show()


func enemy_died(pts):
	print("signal received")
	$Player.get_child(0).combo(pts)
