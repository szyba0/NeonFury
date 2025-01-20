extends "res://scripts/weapon_base.gd"


# Called when the node enters the scene tree for the first time.

func attack():
	if can_attack and current_ammo > 0:
		attack_sound.play()
		can_attack = false
		var instance = bullet.instantiate()
		# Ustawienie pocisku na pozycji gracza
		# Kierunek strzału:
		if get_parent().name == "WeaponHolder":
			# Ustawienie pozycji początkowej pocisku przed graczem/przeciwnikiem
			var offset_position = global_position + Vector2(cos(rotation), sin(rotation)) * 20
			instance.position = offset_position  # Pocisk nie startuje w pozycji przeciwnika, aby uniknąć trafienia
			# Strzał w kierunku, w który patrzy przeciwnik
			instance.target_position = global_position + Vector2(cos(rotation), sin(rotation)) * 1000  # Duża odległość
		else:
			var offset_position = global_position + Vector2(30, 7).rotated(global_rotation)
			instance.position = offset_position  # Pocisk nie startuje w pozycji przeciwnika, aby unikną
			instance.target_position = get_global_mouse_position()  # Strzał do myszy dla Player
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
