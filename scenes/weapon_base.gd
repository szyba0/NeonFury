extends Area2D

@onready var sprite_node = $Sprite2D
@export var weapon_type: String = "BaseWeapon"  # Typ broni
@export var damage: int = 10  # Obrażenia
@export var ammo: int = 30  # Amunicja początkowa
@export var fire_rate: float = 0.5  # Czas pomiędzy strzałami
@export var sprite: Texture  # Sprite broni

# Funkcja wywoływana, gdy gracz podnosi broń
func on_pickup():
	queue_free()  # Usuń broń z ziemi po podniesieniu
func _on_WeaponBase_body_entered(body):
	# Sprawdza, czy ciało kolidujące jest `CharacterBody2D` i ma nadrzędny węzeł `Player`
	if body is CharacterBody2D and body.get_parent().name == "Player":
		body.near_weapon = self  # Ustawia broń jako `near_weapon` w `Player.gd`
		print("Gracz w pobliżu broni:", weapon_type)
func _on_WeaponBase_body_exited(body):
	if body is CharacterBody2D and body.get_parent().name == "Player":
		body.near_weapon = null  # Resetuje broń, gdy gracz się oddala
		print("Gracz oddalił się od broni.")

# Funkcja wywoływana podczas ustawiania `sprite`
func set_sprite(new_sprite):
	sprite = new_sprite
	if sprite_node:
		sprite_node.texture = sprite  # Ustawia teksturę na `Sprite2D`
