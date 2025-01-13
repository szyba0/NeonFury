extends CharacterBody2D

@onready var bullet = load("res://scenes/Bullet02.tscn")
@onready var ammo_bar = $AmmoUI/Control/AmmoBar
@onready var points_counter = $PointsUI/Control/PointsCounter
@onready var combo_counter = $ComboUI/Control/ComboCounter

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

var bullet_collision_position
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

var points: int = 0
var combo_count: int = 0
var max_combo: int = 0
var combo_points_multiplier = 1
var kills:int = 0

var current_weapon : Area2D = null

func _ready():
	#max_ammo = ammo_bar.max_value
	#current_ammo = max_ammo
	update_ammo_bar()
	death_label.visible = false  # Ukryj DeathLabel na początku
	death_overlay.visible = false  # Ukryj czerwony overlay na początku

func read_input():
	if not dashing and not is_dead:
		var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
		velocity = input_direction * speed
		look_at(get_global_mouse_position())

func _input(_event):
	if is_dead:
		return 
	if current_weapon:
		if Input.is_action_pressed("LMB") and current_weapon.is_throwable and not current_weapon.is_melee and has_weapon:
			throw_weapon(current_weapon)
		elif Input.is_action_pressed("LMB") and has_weapon: 
			current_weapon.attack()
			update_ammo_bar()
	 
	
	if Input.is_action_just_pressed("SPACE"):
		dash()
		
	if Input.is_action_just_pressed("RMB") and near_weapon and not has_weapon and near_weapon.can_pickup:
		pickup_weapon(near_weapon)
	elif Input.is_action_just_pressed("RMB") and near_weapon and has_weapon and near_weapon.can_pickup:
		throw_weapon(current_weapon)
		pickup_weapon(near_weapon)
	elif Input.is_action_just_pressed("RMB") and not near_weapon and has_weapon:
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
	dropped_weapon.rotation = rotation  # Ustawienie rotacji zgodnej z rotacją gracza
	dropped_weapon.current_ammo = weapon.current_ammo
	remove_child(weapon)
	dropped_weapon.position = global_position
	dropped_weapon.target_position = get_global_mouse_position()
	get_tree().current_scene.add_child(dropped_weapon)
	dropped_weapon.launch()
	$Sprite2D.texture = sprite_no_weapon  # Reset na domyślny sprite bez broni
	dropped_weapon.throw_sound.play()
	current_weapon = null
	has_weapon = false
	print("Broń została upuszczona:", dropped_weapon.get_parent().name)
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
func _process(_delta):
	if is_dead:
		# Po śmierci naciśnięcie `R` od razu resetuje poziom
		if Input.is_action_just_pressed("Restart"):
			restart_level()
	else:
		# Jeśli gracz żyje, przytrzymanie `R` przez `reset_hold_time` zresetuje poziom
		reset_level_if_held(_delta)

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
		ammo_bar.text = str(current_weapon.current_ammo) + " / " + str(current_weapon.max_ammo)
	else:
		ammo_bar.visible = false
		ammo_bar.text = ""

func update_points():
	points_counter.text = "Pts: " + str(points)

func update_combo():
	if combo_count > 0:
		combo_counter.visible = true
		combo_counter.text = "Combo: " +str(combo_count)
	else:
		combo_counter.visible = false
		combo_counter.text = ""

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
	


func _on_collision_detector(position: Variant) -> void:
	print("signal received")
	bullet_collision_position = position

func combo(pts):
	$ComboTimer.start()
	points = points + pts*combo_points_multiplier
	update_points()
	combo_count += 1
	combo_points_multiplier += 1
	if combo_count> max_combo:
		max_combo = combo_count
	kills += 1
	update_combo()
	print(combo_counter)


func _on_combo_timer_timeout() -> void:
	print("Combo coutner ended on ", combo_counter)
	combo_count = 0
	combo_points_multiplier = 1
	update_combo()
	
	
func display_points_screen():
	$PointScreenUI/PointScreen/points.text = str(points)
	$PointScreenUI/PointScreen/kills.text = str(kills)
	$PointScreenUI/PointScreen/combo.text = str(max_combo)
	$TimerUI/Panel.stop()
	$PointScreenUI/PointScreen/time.text = $TimerUI/Panel/Minutes.text +$TimerUI/Panel/Seconds.text+$TimerUI/Panel/Msecs.text
	$PointScreenUI/PointScreen.visible = true
