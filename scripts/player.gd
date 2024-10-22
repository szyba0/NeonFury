extends CharacterBody2D

var speed = 400

func read_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_direction * speed
	look_at(get_global_mouse_position())
	

func _physics_process(_delta):
	read_input()
	move_and_slide()
