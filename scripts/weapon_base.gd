extends Area2D
@export var is_ranged: bool = false
@export var is_melee: bool = false
@export var is_throwable: bool = false
@export var damage: int  # Obrażenia
@export var current_ammo: int  # Ilośc amunicji w magazynku
@export var max_ammo: int  # Amunicja początkowa
@export var fire_rate: float  # Czas pomiędzy strzałami
@export var weapon_sprite: Texture  # Sprite broni
@export var held_weapon_sprite: Texture  # Sprite trzymanej broni
@export var player_sprite: Texture  # Sprite playera trzymajacego broń
@export var sound_range: float  # Zasięg dźwięku broni

@onready var attack_sound = $AttackSound
@onready var pickup_sound = $PickupSound
@onready var throw_sound = $ThrowSound


signal sound_emitted(position: Vector2, range: float)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.get_parent().name == "Player":
		global_position = get_parent().global_position
		self.rotation = (get_global_mouse_position() - global_position).normalized().angle()		

func attack():
	attack_sound.play()
	emit_signal("sound_emitted", global_position, sound_range)  # Emituj sygnał z pozycją i zasięgiem dźwięku


func _on_WeaponBase_body_entered(body):
	# Sprawdza, czy ciało kolidujące jest `CharacterBody2D` i ma nadrzędny węzeł `Player`
	if body is CharacterBody2D and body.get_parent().name == "Player":
		body.near_weapon = self  # Ustawia broń jako `near_weapon` w `Player.gd`
	print("Gracz w pobliżu broni:")
func _on_WeaponBase_body_exited(body):
	if body is CharacterBody2D and body.get_parent().name == "Player":
		body.near_weapon = null  # Resetuje broń, gdy gracz się oddala
		print("Gracz oddalił się od broni.")
		
func _on_tree_entered() -> void:
	if self.get_parent().name == "CharacterBody2D":
		$CollisionShape2D.set_deferred("disabled",true)
