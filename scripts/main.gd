extends Node2D

@export var patrol_paths: Array[Path2D]  # Tablica referencji do ścieżek patrolowych

func _ready():
	randomize()  # Ustaw losowy seed dla generatora liczb losowych
	# Dodaj wszystkie ścieżki patrolowe do tablicy ręcznie lub automatycznie
	patrol_paths = [$Path_Room1, $Path_Room2]
	
	# Przekaż ścieżki patrolowe do każdego przeciwnika w poziomie
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.set_patrol_paths(patrol_paths)
