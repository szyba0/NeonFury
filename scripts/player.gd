extends CharacterBody2D

@onready var main = get_tree().get_root().get_node("Main")
@onready var bullet = load("res://scenes/Bullet02.tscn")
@onready var ammo_bar = $"/root/Main/Player/CharacterBody2D/AmmoUI/Control/AmmoBar" 

@export var ghost_node: PackedScene
@onready var ghost_timer = $GhostTimer

@export var speed = 400
var max_ammo: int
var current_ammo: int
var fire_rate = 0  # Czas (w sekundach) między strzałami
var can_fire = true

var dash_speed = 500
var dashing = false



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
	add_ghost()

func dash():
	ghost_timer.start()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position", position+velocity*0.4, 0.25)
	
	await tween.finished
	ghost_timer.stop()
