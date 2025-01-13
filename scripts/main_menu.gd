extends Control

var save_path = "res://last_level.save"
var last_level
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	load_data()
	$VBoxContainer/StartButton.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	#$AnimationPlayer.play("fade_in")
	#await $AnimationPlayer.animation_finished
	self.visible = false
	self.get_parent().get_node("LevelSelectionNode").visible = true
	#get_tree().change_scene_to_file("res://scenes/levels/level_selection_node.tscn")


func _on_options_button_pressed() -> void:
	self.visible = false
	self.get_parent().get_node("OptionsNode").visible = true


func _on_quit_button_pressed() -> void:
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	get_tree().quit()


func _on_continue_button_pressed() -> void:
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(last_level)


func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path,FileAccess.READ)
		last_level = file.get_var()
	else:
		print("No data saved")
		last_level = "res://scenes/levels/level_01/level_01.tscn"
