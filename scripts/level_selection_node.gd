extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_level_00_button_pressed() -> void:
	pass # Replace with function body.


func _on_level_01_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_01/level_01.tscn")


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")
