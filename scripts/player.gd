extends CharacterBody2D

@onready var main = get_tree().get_root().get_node("Main")
@onready var bullet = load("res://scenes/Bullet02.tscn")
@onready var ammo_bar = $"/root/Main/Player/CharacterBody2D/AmmoUI/Control/AmmoBar" 

@export var ghost_node: PackedScene
@onready var ghost_timer = $GhostTimer
@onready var dash_timer = $DashTimer
@onready var dash_cooldown = $DashCooldown

@export var speed = 400
var max_ammo: int
var current_ammo: int
var fire_rate = 0  # Czas (w sekundach) między strzałami
var can_fire = true

var dashing = false
var can_dash = true



func _ready():
	max_ammo = ammo_bar.max_value
	current_ammo = max_ammo
	update_ammo_bar()

func read_input():
	if not dashing:
		var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
		velocity = input_direction * speed
		look_at(get_global_mouse_position())

func _input(_event):
	
	if Input.is_action_just_pressed("LMB"): 
		shoot()
	if Input.is_action_just_pressed("SPACE"):
		dash()

func _physics_process(_delta):
	read_input()
	move_and_slide()

func shoot():
	if can_fire and current_ammo > 0:
		can_fire = false
		var instance = bullet.instantiate()
		
		# Ustawienie pocisku na pozycji gracza
		instance.position = global_position
		
		# Przekazujemy pozycję kursora jako cel dla pocisku
		instance.target_position = get_global_mouse_position()
		
		get_tree().current_scene.add_child(instance)

		# Zmniejsz amunicję i zaktualizuj pasek
		current_ammo -= 1
		update_ammo_bar()
		
		# Oczekiwanie przed kolejnym strzałem
		await get_tree().create_timer(fire_rate).timeout
		can_fire = true
	elif current_ammo <= 0:
		print("Out of ammo!")


func update_ammo_bar():
	ammo_bar.value = current_ammo

func add_ghost():
	var ghost = ghost_node.instantiate()
	
	ghost.set_property(position, $Sprite2D.scale, $".".rotation)
	ghost.look_at(get_global_mouse_position().rotated(PI/2))
	get_tree().current_scene.add_child(ghost)

func _on_ghost_timer_timeout() -> void:
	print("added ghost")
	add_ghost()

func dash():
	if not dashing and can_dash:
		velocity = velocity*1.2
		dashing = true
		can_dash = false
		collision_mask = 1
		ghost_timer.start()
		dash_timer.start()
		dash_cooldown.start()
		set_process_input(false)
	


func _on_dash_timer_timeout() -> void:
	velocity = velocity/1.2
	collision_mask = 5
	dashing = false
	set_process_input(true)
	ghost_timer.stop()


func _on_dash_cooldown_timeout() -> void:
	can_dash = true
