extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_NextLevel_body_entered(body):
	# Sprawdza, czy ciało kolidujące jest `CharacterBody2D` i ma nadrzędny węzeł `Player`
	if body is CharacterBody2D and body.get_parent().name == "Player":
		print(body.points)
		print("TEST")
		if body.points > 0:
			body.next_level()  # Ustawia broń jako `near_weapon` w `Player.gd`
