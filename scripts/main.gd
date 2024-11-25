extends Node2D

@export var patrol_paths: Array[Path2D]  # Tablica referencji do ścieżek patrolowych

func _ready():
	randomize()  # Ustaw losowy seed dla generatora liczb losowych
	# Dodaj wszystkie ścieżki patrolowe do tablicy ręcznie lub automatycznie
	patrol_paths = [$Path_Room1, $Path_Room2]
	$FastEnemy.connect("died",enemy_died)
	$TankEnemy.connect("died",enemy_died)
	
	# Przekaż ścieżki patrolowe do każdego przeciwnika w poziomie
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.set_patrol_paths(patrol_paths)

func enemy_died(pts):
	print("signal received")
	$Player.get_child(0).combo(pts)
