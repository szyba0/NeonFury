extends "res://scripts/weapon_base.gd"


# Called when the node enters the scene tree for the first time.

func attack():
	if can_attack and current_ammo > 0:
		attack_sound.play()
		can_attack = false
		var instance = bullet.instantiate()
		# Ustawienie pocisku na pozycji gracza
		instance.position = global_position
		# Przekazujemy pozycję kursora jako cel dla pocisku
		instance.target_position = get_global_mouse_position()
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
