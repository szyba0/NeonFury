extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(_event):
	if Input.is_action_just_pressed("PAUSE"):
		get_viewport().set_input_as_handled()
		print("b")
		if(get_tree().paused):
			$".".hide()
			get_tree().paused = false

func _on_resume_button_pressed() -> void:
	$".".hide()
	get_tree().paused = false


func _on_exit_button_pressed() -> void:
	get_tree().quit()
