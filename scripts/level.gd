extends Node2D

var save_path = "res://last_level.save"
var last_level
var target_scene = "res://scenes/levels/level_01/level_01.tscn"
var mouse_state = false

@export var patrol_paths: Array[Path2D]  # Tablica referencji do ścieżek patrolowych
@onready var pause_menu = $Player/CharacterBody2D/PauseUI/PauseMenu
var is_paused = false
signal pressedSpace
signal change_scene_signal(target_scene)


func _ready():
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	save()
	randomize()  # Ustaw losowy seed dla generatora liczb losowych
	# Dodaj wszystkie ścieżki patrolowe do tablicy ręcznie lub automatycznie
	
	# Przekaż ścieżki patrolowe do każdego przeciwnika w poziomie
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.connect("died",enemy_died)
		enemy.set_patrol_paths(patrol_paths)

	
func _input(event):
	if event.is_action_pressed("SPACE"):
		pressedSpace.emit()
	if event.is_action_pressed("PAUSE"):
		toggle_pause()
	

func toggle_pause():
	if !get_tree().paused:
		get_tree().paused = true
		pause_menu.show()

func enemy_died(pts):
	$Player.get_child(0).combo(pts)

func save():
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	last_level = "res://scenes/levels/level_01/level_01.tscn"
	file.store_var(last_level)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.get_parent().name == "Player":
		if body.kills == 7:
			$AnimationPlayer.play("fade_in")
			await $AnimationPlayer.animation_finished
			body.display_points_screen()
			body.is_paused = true
			await pressedSpace
			body.is_paused = false
			get_tree().change_scene_to_file(target_scene)
