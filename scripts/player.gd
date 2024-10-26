extends CharacterBody2D

@onready var main = get_tree().get_root().get_node("Main")
@onready var bullet = load("res://scenes/bullet_01.tscn")
@onready var ammo_bar = $"/root/Main/AmmoBar" 

@export var speed = 400
var max_ammo: int
var current_ammo: int

func _ready():
	max_ammo = ammo_bar.max_value
	current_ammo = max_ammo
	update_ammo_bar()

func read_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_direction * speed
	look_at(get_global_mouse_position())

func _input(_event):
	if Input.is_action_just_pressed("LMB"): 
		shoot()

func _physics_process(_delta):
	read_input()
	move_and_slide()

func shoot():
	if current_ammo > 0:
		var instance = bullet.instantiate()
		instance.direction = rotation
		instance.spawnPos = global_position
		instance.spawnRot = global_rotation
		main.add_child(instance)
		
		current_ammo -= 1
		update_ammo_bar()
	else:
		print("Out of ammo!")

func update_ammo_bar():
	ammo_bar.value = current_ammo
