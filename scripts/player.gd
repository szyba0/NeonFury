extends CharacterBody2D

@onready var main = get_tree().get_root().get_node("Main")
@onready var bullet = load("res://scenes/Bullet02.tscn")
@onready var ammo_bar = $"/root/Main/Player/CharacterBody2D/AmmoUI/Control/AmmoBar" 

@export var ghost_node: PackedScene
@onready var ghost_timer = $GhostTimer
@onready var dash_timer = $DashTimer
@onready var dash_cooldown = $DashCooldown

@export var speed = 400
@export var sprite_no_weapon: Texture  # Sprite gracza bez broni
@export var sprite_2h: Texture
@export var sprite_1h: Texture           # Sprite gracza z karabinem
@export var death_text: String = "PRESS R TO RESTART"
@export var reset_hold_time: float = 1.0  # Czas przytrzymania `R` w sekundach, aby zresetować poziom podczas gry
@export var death_sprite: Texture  # Tekstura używana po śmierci gracza

var is_dead = false
@onready var death_label = $DeathUI/DeathLabel
@onready var death_overlay = $DeathUI/DeathOverlay
var reset_hold_timer = 0.0  # Zmienna do śledzenia czasu przytrzymania `R`
#var max_ammo: ints
#var current_ammo: int
#var fire_rate = 0  # Czas (w sekundach) między strzałami
var can_fire = true

var dashing = false
var can_dash = true

var current_weapon_data = null  # Dane aktualnej broni
var has_weapon = false  # Czy gracz trzyma broń
var near_weapon = null  # Broń, przy której gracz się znajduje
var weapon_type = null

var current_weapon : Area2D = null

func _ready():
	#max_ammo = ammo_bar.max_value
	#current_ammo = max_ammo
	update_ammo_bar()
	death_label.visible = false  # Ukryj DeathLabel na początku
	death_overlay.visible = false  # Ukryj czerwony overlay na początku

func read_input():
	if not dashing:
		var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
		velocity = input_direction * speed
		look_at(get_global_mouse_position())

func _input(_event):
	
	if Input.is_action_just_pressed("LMB") and has_weapon: 
		current_weapon.attack()
		update_ammo_bar()
	if Input.is_action_just_pressed("SPACE"):
		dash()
		
	if Input.is_action_pressed("RMB") and near_weapon and not has_weapon and near_weapon.can_pickup:
		pickup_weapon(near_weapon)
	elif Input.is_action_pressed("RMB") and near_weapon and has_weapon and near_weapon.can_pickup:
		throw_weapon(current_weapon)
		pickup_weapon(near_weapon)
	elif Input.is_action_pressed("RMB") and not near_weapon and has_weapon:
		throw_weapon(current_weapon)

func _physics_process(_delta):
	if is_dead:
		return  # Jeśli gracz jest martwy, nie aktualizujemy fizyki
	read_input()
	move_and_slide()

func pickup_weapon(weapon):
	has_weapon = true
	current_weapon = load(weapon.scene_path).instantiate()
	current_weapon.current_ammo = weapon.current_ammo
	
	weapon.on_pickup()
	
	if current_weapon.is_one_handed:
		$Sprite2D.texture = sprite_1h
		add_child(current_weapon)
	elif not current_weapon.is_one_handed:
		$Sprite2D.texture = sprite_2h
		add_child(current_weapon)
	else:
		$Sprite2D.texture = sprite_no_weapon
	current_weapon.pickup_sound.play()
	print("Picked up:", current_weapon.get_parent().name)
	update_ammo_bar()
	
func throw_weapon(weapon):
	# Wczytaj scenę broni i stwórz jej instancję
	var dropped_weapon = load(weapon.scene_path).instantiate()
	
	var drop_offset = Vector2(10, 0).rotated(rotation)  # Przesunięcie 10 pikseli przed graczem
	dropped_weapon.position = global_position + drop_offset

	dropped_weapon.rotation = rotation  # Ustawienie rotacji zgodnej z rotacją gracza
	dropped_weapon.current_ammo = weapon.current_ammo

	remove_child(weapon)
	get_tree().current_scene.add_child(dropped_weapon)
	dropped_weapon.launch(get_global_mouse_position())
	# Zresetowanie obecnej broni w gracza
	current_weapon = null
	has_weapon = false
	$Sprite2D.texture = sprite_no_weapon  # Reset na domyślny sprite bez broni
	print("Broń została upuszczona:", dropped_weapon.get_parent().name)
	
	update_ammo_bar()
	
func throw():
	# Najpierw sprawdzamy, czy gracz ma broń
	if current_weapon_data == null:
		print("You don't have a weapon!")
		return  # Jeśli nie ma broni, kończymy funkcję
	if has_weapon:
		var instance = bullet.instantiate()
		
		match current_weapon_data["type"]:
			"Rifle":
				instance.change_sprite(preload("res://assets/weapons/m16.png"))
			"Bat":
				instance.change_sprite(preload("res://assets/weapons/baseball_bat.png"))
			_:
				pass
		# Ustawienie pocisku na pozycji gracza
		instance.position = global_position
		instance.speed = 300
		# Przekazujemy pozycję kursora jako cel dla pocisku
		instance.target_position = get_global_mouse_position()
		instance.damage = 5
	#	if current_weapon_data["is_melee"]:
	#		remove_child(current_weapon)
		current_weapon = null
		current_weapon_data = null
		has_weapon = false
		$Sprite2D.texture = sprite_no_weapon
		get_tree().current_scene.add_child(instance)
		update_ammo_bar()

# Funkcja wywoływana przy śmierci gracza
func die():
	if dashing:
		return
	else:
		if is_dead:
			return  # Jeśli gracz już jest martwy, nic nie rób
		is_dead = true
		velocity = Vector2.ZERO  # Zatrzymujemy ruch gracza
		# Zmieniamy sprite gracza na sprite śmierci
		if death_sprite:
			$Sprite2D.texture = death_sprite
		death_label.text = death_text
		death_label.visible = true  # Wyświetlamy ekran śmierci
		death_overlay.visible = true  # Wyświetlamy czerwony overlay

# Funkcja do sprawdzenia przytrzymania `R` oraz resetu po śmierci
func _process(delta):
	if is_dead:
		# Po śmierci naciśnięcie `R` od razu resetuje poziom
		if Input.is_action_just_pressed("Restart"):
			restart_level()
	else:
		# Jeśli gracz żyje, przytrzymanie `R` przez `reset_hold_time` zresetuje poziom
		reset_level_if_held(delta)

# Funkcja do sprawdzenia, czy `R` jest przytrzymane odpowiednio długo
func reset_level_if_held(delta):
	if Input.is_action_pressed("Restart"):
		reset_hold_timer += delta
		if reset_hold_timer >= reset_hold_time:
			restart_level()
	else:
		reset_hold_timer = 0.0  # Zresetuj licznik, jeśli `R` nie jest przytrzymane

# Restart poziomu
func restart_level():
	get_tree().reload_current_scene()  # Przeładowanie bieżącej sceny

func update_ammo_bar():
	if has_weapon and current_weapon.is_ranged:
		ammo_bar.visible = true
		ammo_bar.value = current_weapon.current_ammo
	else:
		ammo_bar.visible = false
		ammo_bar.value = 0


func add_ghost():
	var ghost = ghost_node.instantiate()
	
	ghost.set_property(global_position, $Sprite2D.scale, $".".rotation)
	ghost.look_at(get_global_mouse_position().rotated(PI/2))
	get_tree().current_scene.add_child(ghost)

func _on_ghost_timer_timeout() -> void:
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
	


func _on_dash_timer_timeout() -> void:
	velocity = velocity/1.2
	collision_mask = 5
	dashing = false
	ghost_timer.stop()


func _on_dash_cooldown_timeout() -> void:
	can_dash = true
	
