extends CharacterBody2D

@onready var main = get_tree().get_root().get_node("Main")
@onready var bullet = load("res://scenes/Bullet02.tscn")
@onready var ammo_bar = $"/root/Main/Player/CharacterBody2D/AmmoUI/Control/AmmoBar" 

@export var speed = 400
var max_ammo: int
var current_ammo: int
var fire_rate = 0.5  # Czas (w sekundach) między strzałami
var can_fire = true

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
	if can_fire:
		if current_ammo > 0:
			can_fire = false
			var instance = bullet.instantiate()
			instance.direction = Vector2.RIGHT.rotated(rotation)
			instance.position = global_position
			#instance.spawnRot = global_rotation
			#main.add_child(instance)
			get_tree().current_scene.add_child(instance)
			
			current_ammo -= 1
			update_ammo_bar()
			await get_tree().create_timer(fire_rate).timeout
			can_fire = true
		else:
			print("Out of ammo!")
		

func update_ammo_bar():
	ammo_bar.value = current_ammo
