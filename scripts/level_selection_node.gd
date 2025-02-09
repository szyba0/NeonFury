extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#$AnimationPlayer.play("fade_out")
	#await $AnimationPlayer.animation_finished


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_level_00_button_pressed() -> void:
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://scenes/levels/level_00/level_00.tscn")


func _on_level_01_button_pressed() -> void:
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://scenes/levels/level_01/level_01.tscn")

func _on_level_02_button_pressed() -> void:
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://scenes/levels/level_02/level_02.tscn")

func _on_return_button_pressed() -> void:
	self.visible = false
	self.get_parent().get_node("MainMenuNode").visible = true
