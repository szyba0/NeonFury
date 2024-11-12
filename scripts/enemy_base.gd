extends CharacterBody2D

@export var max_health: int = 10
#@export var is_knockable: bool = true
@export var patrol_speed: float = 100.0
@export var chase_speed: float = 150.0
@export var hearing_range: float = 300.0
@export var vision_range: float = 400.0
@export var attack_range: float = 50.0
@export var knockdown_duration: float = 3.0
@export var damage_threshold: int = 10    # Próg obrażeń dla knockdownu
@export var is_patroling: bool = false

@export var normal_head_sprite: Texture
@export var injured_head_sprite: Texture
@export var knocked_down_sprite: Texture  # Sprite dla stanu knockdownu
@export var dead_sprite: Texture          # Sprite dla stanu martwego

@onready var knockdown_timer = $KnockdownTimer  # Timer do kontrolowania stanu knockdownu
@onready var collision_shape = $CollisionShape2D  # Referencja do CollisionShape2D
@onready var legs_sprite = $LegsSprite
@onready var arms_sprite = $ArmsSprite
@onready var head_sprite = $HeadSprite
@onready var weapon_holder = $WeaponHolder
@onready var animation_player = $AnimationPlayer
@onready var hearing_area = $HearingArea  # Odwołanie do Area2D dla słyszenia
@onready var hearing_shape = $HearingArea/CollisionShape2D  # Odwołanie do CollisionShape2D wewnątrz HearingArea
@onready var raycast = $RayCast2D

var current_health: int
var is_dead: bool = false
var is_injured: bool = false
var is_knocked_down: bool = false
var has_weapon: bool = false
var player = null
var is_chasing = false
var current_patrol_path: PathFollow2D = null
var is_attacking = false

var patrol_paths: Array[Path2D] = []
var current_patrol_index: int = 0
var current_path_curve: Curve2D = null  # Krzywa aktualnej ścieżki

func _ready():
	velocity = Vector2.ZERO
	#hearing_shape.shape.radius = hearing_range
	hearing_area.connect("body_entered", Callable(self, "_on_hearing_area_body_entered"))
	head_sprite.texture = normal_head_sprite
	current_health = max_health
	#choose_nearest_path()

func _process(delta):
	if is_dead:
		return

	if is_chasing and player and not is_knocked_down and not is_injured:
		chase_player(delta)
	elif current_patrol_path and not is_knocked_down and not is_injured:
		patrol_path(delta)

	#check_player_visibility()
	#update_animation()

# Funkcje patrolowania
func patrol_path(delta):
	if current_patrol_path and current_path_curve:
		# Obliczamy przemieszczenie po ścieżce na podstawie prędkości i czasu delta
		var distance = patrol_speed * delta
		var path_length = current_path_curve.get_baked_length()
		current_patrol_path.progress_ratio += distance / path_length

		# Przeciwnik obraca się w stronę celu
		var direction = (current_patrol_path.global_position - global_position).normalized()
		rotation = direction.angle()

		# Ustawiamy animację chodzenia
		#play_walk_animation()

		# Przemieszczamy przeciwnika
		move_towards(current_patrol_path.global_position, patrol_speed)
		
		# Jeśli doszedł do końca ścieżki, resetujemy `progress_ratio` i losowo zmieniamy ścieżkę
		if current_patrol_path.progress_ratio >= 0.9 or current_patrol_path.progress_ratio <= 0.0:
			# Zmieniamy ścieżkę z szansą 30% tylko na końcu ścieżki
			if randf() <= 0.0:
				choose_random_path()
				current_patrol_path.progress_ratio = 0.0  # Resetujemy na początek



func choose_nearest_path():
	var shortest_distance = INF
	var nearest_path = null
	for path in patrol_paths:
		var distance = global_position.distance_to(path.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_path = path

	if nearest_path:
		set_patrol_path(nearest_path)

func choose_random_path():
	if patrol_paths.size() > 1:
		var new_path = patrol_paths[randi() % patrol_paths.size()]
		
		# Upewniamy się, że nowa ścieżka jest inna niż obecna
		while new_path == current_patrol_path.get_parent():
			new_path = patrol_paths[randi() % patrol_paths.size()]
			
		# Ustaw nową ścieżkę
		set_patrol_path(new_path)


func set_patrol_paths(paths: Array[Path2D]):
	patrol_paths = paths
	if is_patroling:
		choose_nearest_path()  # Na początku wybierz najbliższą ścieżkę do patrolowania

func set_patrol_path(path: Path2D):
	if path and path.has_node("PathFollow2D"):
		current_patrol_path = path.get_node("PathFollow2D")
		current_patrol_path.progress_ratio = 0.0  # Zresetuj do początku
		current_path_curve = path.curve  # Przypisz krzywą ścieżki

# Funkcje pościgu i walki
func chase_player(delta):
	if global_position.distance_to(player.global_position) < attack_range:
		if has_weapon:
			attack_with_weapon()
		else:
			attack_melee()
	else:
		move_towards(player.global_position, chase_speed)

func move_towards(target_position: Vector2, speed: float):
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	# Jeśli się porusza, uruchamiamy animację chodzenia
	#if velocity.length() > 0.1:  # Tylko jeśli ma wyraźną prędkość
		#play_walk_animation()
	#else:
		#stop_walk_animation()


# Funkcje ataku
func attack_melee():
	if not is_attacking:
		is_attacking = true
		animation_player.play("MeleeAttack")
		await animation_player.wait_for_animation("MeleeAttack")
		is_attacking = false

func attack_with_weapon():
	if not is_attacking:
		is_attacking = true
		animation_player.play("RangedAttack")
		if weapon_holder.has_node("WeaponAnimationPlayer"):
			weapon_holder.get_node("WeaponAnimationPlayer").play("WeaponShoot")
		await animation_player.wait_for_animation("RangedAttack")
		is_attacking = false

# Reakcja na obrażenia
func take_damage(damage: int):
	if is_dead:
		return

	current_health -= damage
	if current_health <= 0:
		die()
	elif current_health < damage_threshold:
		knock_down()
	else:
		injured()

func die():
	is_dead = true
	velocity = Vector2.ZERO
	#animation_player.play("Dead")
	collision_shape.set_deferred("disabled",true)
	head_sprite.texture = dead_sprite

func knock_down():
	is_knocked_down = true
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled",true)
	head_sprite.texture = knocked_down_sprite
	knockdown_timer.start(knockdown_duration) 
	#stand_up()

func injured():
	#is_injured = true
	head_sprite.texture = injured_head_sprite

func stand_up():
	is_knocked_down = false
	animation_player.play("StandUp")

# Wykrywanie gracza
func _on_hearing_area_body_entered(body):
	if body.name == "SoundSource" and body.is_playing():
		is_chasing = true
		player = body.get_parent()
		print("Przeciwnik usłyszał strzał!")

func check_player_visibility():
	if player:
		raycast.cast_to = (player.global_position - global_position).normalized() * vision_range
		if raycast.is_colliding() and raycast.get_collider() == player:
			is_chasing = true
			print("Przeciwnik widzi gracza!")

func _on_KnockdownTimer_timeout():
	if not is_dead:
		collision_shape.set_deferred("disabled", false)
		head_sprite.texture = injured_head_sprite
		is_knocked_down = false
		print("Enemy stood up.")
		#stand_up()


#func play_walk_animation():
	#if arms_sprite.has_animation("Walk"):
		#arms_sprite.play("Walk")
	#if legs_sprite.has_animation("Walk"):
		#legs_sprite.play("Walk")
#
#func stop_walk_animation():
	#arms_sprite.stop()
	#legs_sprite.stop()
# Aktualizacja animacji
#func update_animation():
	#if is_dead:
		#animation_player.play("Dead")
	#elif is_knocked_down:
		#animation_player.play("KnockedDown")
	#elif is_injured:
		#animation_player.play("Injured")
	#else:
		#if velocity.length() > 0:
			#if arms_sprite.has_animation("Walk_With_Weapon") and has_weapon:
				#arms_sprite.play("Walk_With_Weapon")
			#elif arms_sprite.has_animation("Walk_NoWeapon") and not has_weapon:
				#arms_sprite.play("Walk_NoWeapon")
			#
			#if legs_sprite.has_animation("Walk"):
				#legs_sprite.play("Walk")
		#else:
			#arms_sprite.stop()
			#legs_sprite.stop()
