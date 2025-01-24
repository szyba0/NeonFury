extends Area2D
@export var is_ranged: bool = false
@export var is_melee: bool = false
@export var is_throwable: bool = false
@export var is_one_handed: bool = false
@export var damage: int  # Obrażenia
@export var current_ammo: int  # Ilośc amunicji w magazynku
@export var max_ammo: int  # Amunicja początkowa
@export var fire_rate: float  # Czas pomiędzy strzałami
@export var weapon_sprite: Texture  # Sprite broni
@export var held_weapon_sprite: Texture  # Sprite trzymanej broni
@export var sound_range: float  # Zasięg dźwięku broni
@export var scene_path : String
var can_pickup: bool = true
var can_attack: bool = true

var target_position: Vector2
var speed = 3  # Prędkość pocisku
var direction  # Kierunek pocisku
var can_harm = false

var bullet = load("res://scenes/Bullet02.tscn")

@onready var attack_sound = $AttackSound
@onready var pickup_sound = $PickupSound
@onready var throw_sound = $ThrowSound


signal sound_emitted(position: Vector2, range: float)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.get_parent().name == "WeaponHolder":
		$Sprite2D.texture = held_weapon_sprite
		$CollisionShape2D.set_deferred("disabled",true)
func on_pickup():
	$CollisionShape2D.disabled = true
	queue_free()  # Usuń broń z ziemi po podniesieniu

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.get_parent().name == "Player":
		global_position = get_parent().global_position
		self.rotation = (get_global_mouse_position() - global_position).normalized().angle()
	elif self.get_parent().name == "WeaponHolder":
		var enemy = get_parent().get_parent()
		global_position = enemy.global_position
		self.rotation = enemy.rotation

func _physics_process(delta):
	if can_harm:
		if is_throwable and not is_melee:
			pass
		else:
			$Sprite2D.rotate(0.2)
		$RayCast2D.target_position = direction * speed * delta
		if $RayCast2D.is_colliding():
			var collider = $RayCast2D.get_collider()
			can_harm = false
			speed = 0
			_on_WeaponBase_body_entered(collider)
		position += direction * speed * delta
	# Przesuń pocisk zgodnie z kierunkiem i prędkością\
	
	# Ustaw `target_position` w `RayCast2D` na odległość, którą pocisk pokona w tej klatce
		
	# Sprawdź, czy `RayCast2D` wykrywa kolizję
		

#func attack():
	#attack_sound.play()
	#emit_signal("sound_emitted", global_position, sound_range)  # Emituj sygnał z pozycją i zasięgiem dźwięku


func _on_WeaponBase_body_entered(body):
	# Sprawdza, czy ciało kolidujące jest `CharacterBody2D` i ma nadrzędny węzeł `Player`
	if self.get_parent().name == "WeaponHolder":
		if body.has_method("take_damage"):
			body.take_damage(damage)
	else:
		if body is CharacterBody2D and body.get_parent().name == "Player":
			body.near_weapon = self  # Ustawia broń jako `near_weapon` w `Player.gd`
		print("Gracz w pobliżu broni:")
		if can_harm and not body.get_parent().name == "Player":
			print(body.get_parent().name)
			can_harm = false
			if body.has_method("take_damage"):
				if is_throwable:
					body.take_damage(damage)
				else:
					body.take_damage(damage/2)
			if is_throwable:
				queue_free()
			
			print("hit")
			
func _on_WeaponBase_body_exited(body):
	if body is CharacterBody2D and body.get_parent().name == "Player":
		body.near_weapon = null  # Resetuje broń, gdy gracz się oddala
		print("Gracz oddalił się od broni.")
		
func _on_tree_entered() -> void:
	if self.get_parent().name == "CharacterBody2D":
		$CollisionShape2D.set_deferred("disabled",true)
	if is_ranged and self.get_parent().name == "CharacterBody2D":
		$Sprite2D.texture = held_weapon_sprite

func launch():
	direction = (get_global_mouse_position()-position)
	#direction = (target_position - global_position).normalized()
	look_at(target_position)
	rotation += deg_to_rad(90)
	can_harm = true
	can_pickup = false
	await get_tree().create_timer(0.5).timeout
	can_harm = false
	can_pickup = true
