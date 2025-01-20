extends "res://scripts/weapon_base.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.get_parent().name == "WeaponHolder":
		$Sprite2D.texture = held_weapon_sprite

func attack():
	if can_attack and current_ammo > 0:
		attack_sound.play()
		can_attack = false
		var rng = RandomNumberGenerator.new()
		for i in range(4):
			var x_rand = rng.randi_range(-15.0, 15.0)
			var y_rand = rng.randi_range(-15.0, 15.0)
			var instance = bullet.instantiate()
			if get_parent().name == "WeaponHolder":
				# Ustawienie pozycji początkowej pocisku przed graczem/przeciwnikiem
				var offset_position = global_position + Vector2(cos(rotation), sin(rotation)) * 20 + Vector2(x_rand,y_rand)
				instance.position = offset_position  # Pocisk nie startuje w pozycji przeciwnika, aby uniknąć trafienia
				# Strzał w kierunku, w który patrzy przeciwnik
				instance.target_position = global_position + Vector2(cos(rotation), sin(rotation)) * 1000  # Duża odległość
			else:
				var offset_position = global_position + Vector2(30, 7).rotated(global_rotation)
				instance.position = offset_position
				instance.target_position = get_global_mouse_position()  + Vector2(x_rand,y_rand)# Strzał do myszy dla Player
				emit_signal("sound_emitted", 300.0)

			instance.damage = damage
			get_tree().current_scene.add_child(instance)

		# Zmniejsz amunicję i zaktualizuj pasek
		current_ammo -= 1
		
		# Oczekiwanie przed kolejnym strzałem
		await get_tree().create_timer(fire_rate).timeout
		can_attack = true
	elif current_ammo <= 0:
		print("Out of ammo!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
