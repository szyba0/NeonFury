extends Area2D

# Funkcja wywoływana, gdy ciało wchodzi w kontakt z kałużą
func _on_body_entered(body):
	if body is CharacterBody2D and body.get_parent().name == "Player":
		body.die()  # Wywołaj funkcję `die()` w `Player.gd`
