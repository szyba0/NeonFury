extends Area2D

@onready var puddle_timer = $PuddleTimer

var killed_body = null
# Funkcja wywoływana, gdy ciało wchodzi w kontakt z kałużą
func _on_body_entered(body):
	if body is CharacterBody2D and body.get_parent().name == "Player":
		killed_body = body
		killed_body.die()  # Wywołaj funkcję `die()` w `Player.gd`
	puddle_timer.start()	
	
func _on_body_exited(_body) -> void:
	puddle_timer.stop()
	killed_body = null

func _on_puddle_timer_timeout() -> void:
	killed_body.die()
