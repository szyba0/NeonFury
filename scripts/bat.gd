extends "res://scripts/weapon_base.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func attack():
	if can_attack:
		attack_sound.play()
		$CollisionShape2D.set_deferred("disabled",false)
		#$AnimationPlayer.speed_scale = 1 
		$AnimationPlayer.play("attack_animations/attack_bat")
		can_attack = false
		await get_tree().create_timer(0.4).timeout
		#$AnimationPlayer.speed_scale = -1
		$AnimationPlayer.play_backwards("attack_animations/attack_bat")
		await get_tree().create_timer(fire_rate).timeout
		can_attack = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack_animations/attack_bat":
		$CollisionShape2D.set_deferred("disabled",true)


func _on_body_entered(body: Node2D) -> void:
	# Sprawdza, czy ciało kolidujące jest `CharacterBody2D` i ma nadrzędny węzeł `Player`
	if body is CharacterBody2D and body.get_parent().name == "Player":
		body.near_weapon = self  # Ustawia broń jako `near_weapon` w `Player.gd`
		print("Gracz w pobliżu broni:")
	else:
		if body.has_method("take_damage"):
			body.take_damage(damage)
