extends Area2D

# Parametry pocisku
var speed = 800  # Prędkość pocisku
var direction = Vector2.ZERO  # Kierunek pocisku
var damage = 10  # Obrażenia

func _ready():
	# Timer, aby automatycznie usunąć pocisk po 3 sekundach
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _physics_process(delta):
	# Przesuń pocisk zgodnie z kierunkiem i prędkością
	position += direction * speed * delta

	# Ustaw `target_position` w `RayCast2D` na odległość, którą pocisk pokona w tej klatce
	$RayCast2D.target_position = direction * speed * delta

	# Sprawdź, czy `RayCast2D` wykrywa kolizję
	if $RayCast2D.is_colliding():
		var collider = $RayCast2D.get_collider()
		_on_Bullet_body_entered(collider)

func _on_Bullet_body_entered(body):
	# Sprawdź, czy obiekt ma metodę `take_damage`, aby zadać obrażenia
	if body.has_method("take_damage"):
		body.take_damage(damage)

	# Usuń pocisk po kolizji
	queue_free()
