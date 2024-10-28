extends CharacterBody2D

@export var max_health: int = 10         # Maksymalne zdrowie przeciwnika
@export var damage_threshold: int = 10    # Próg obrażeń dla knockdownu
@export var knockdown_duration: float = 3.0  # Czas trwania knockdownu w sekundach

@export var knocked_down_sprite: Texture  # Sprite dla stanu knockdownu
@export var hurt_sprite: Texture       # Sprite dla stanu uszkodzonego po powstaniu
@export var dead_sprite: Texture          # Sprite dla stanu martwego
@export var normal_sprite: Texture        # Sprite dla stanu normalnego

var current_health: int               # Aktualne zdrowie przeciwnika
var is_dead = false                   # Flaga śmierci przeciwnika
@onready var sprite_node = $Sprite2D  # Zakładamy, że sprite przeciwnika to Sprite2D
@onready var knockdown_timer = $KnockdownTimer  # Timer do kontrolowania stanu knockdownu
@onready var collision_shape = $CollisionShape2D  # Referencja do CollisionShape2D

func _ready():
	current_health = max_health
	sprite_node.texture = normal_sprite

# Funkcja przyjmująca obrażenia
func take_damage(damage: int):
	if is_dead:
		return  # Jeśli przeciwnik jest martwy, ignorujemy obrażenia

	current_health -= damage

	if current_health <= 0:
		die()
	elif current_health < damage_threshold:
		knockdown()

# Funkcja śmierci przeciwnika
func die():
	is_dead = true
	sprite_node.texture = dead_sprite  # Ustawienie sprite'a martwego przeciwnikaa
	collision_shape.set_deferred("disabled",true)    # Wyłączenie CollisionShape2D
	print("Enemy died.")

# Funkcja knockdownu przeciwnika
func knockdown():
	sprite_node.texture = knocked_down_sprite
	collision_shape.set_deferred("disabled",true)  # Zmiana sprite'a na knockdown
	print("Enemy knocked down.")
	knockdown_timer.start(knockdown_duration)  # Uruchomienie timera dla knockdownu

# Funkcja wywoływana po zakończeniu timera (przeciwnik wstaje i zmienia się na damaged_sprite)
func _on_KnockdownTimer_timeout():
	if not is_dead:  # Tylko jeśli przeciwnik nie jest martwy
		collision_shape.set_deferred("disabled",false)
		sprite_node.texture = hurt_sprite  # Zmiana sprite'a na uszkodzony po powstaniu
		print("Enemy stood up.")
