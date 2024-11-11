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

var can_harm = false

var bullet = load("res://scenes/Bullet02.tscn")

@onready var attack_sound = $AttackSound
@onready var pickup_sound = $PickupSound
@onready var throw_sound = $ThrowSound


signal sound_emitted(position: Vector2, range: float)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func on_pickup():
	$CollisionShape2D.disabled = true
	queue_free()  # Usuń broń z ziemi po podniesieniu

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.get_parent().name == "Player":
		global_position = get_parent().global_position
		self.rotation = (get_global_mouse_position() - global_position).normalized().angle()		
	if can_harm:
		position+=Vector2(1,0).rotated(45)*400*delta
		

func attack():
	attack_sound.play()
	emit_signal("sound_emitted", global_position, sound_range)  # Emituj sygnał z pozycją i zasięgiem dźwięku


func _on_WeaponBase_body_entered(body):
	# Sprawdza, czy ciało kolidujące jest `CharacterBody2D` i ma nadrzędny węzeł `Player`
	if body is CharacterBody2D and body.get_parent().name == "Player":
		body.near_weapon = self  # Ustawia broń jako `near_weapon` w `Player.gd`
	print("Gracz w pobliżu broni:")
	if can_harm and body.get_parent().name == "Enemy" and body.has_method("take_damage"):
		if is_throwable:
			body.take_damage(damage)
		else:
			body.take_damage(damage/2)
			
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
	can_harm = true
	can_pickup = false
	
	await get_tree().create_timer(1.5).timeout
	can_harm = false
	can_pickup = true
