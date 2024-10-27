extends CharacterBody2D

@onready var main = get_tree().get_root().get_node("Main")
@onready var bullet = load("res://scenes/Bullet02.tscn")
@onready var ammo_bar = $"/root/Main/Player/CharacterBody2D/AmmoUI/Control/AmmoBar" 


@export var speed = 400
@export var sprite_no_weapon: Texture  # Sprite gracza bez broni
@export var sprite_rifle: Texture      # Sprite gracza z karabinem
#var max_ammo: int
#var current_ammo: int
#var fire_rate = 0  # Czas (w sekundach) między strzałami
var can_fire = true

var current_weapon_data = null  # Dane aktualnej broni
var has_weapon = false  # Czy gracz trzyma broń
var near_weapon = null  # Broń, przy której gracz się znajduje


func _ready():
	#max_ammo = ammo_bar.max_value
	#current_ammo = max_ammo
	update_ammo_bar()

func read_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_direction * speed
	look_at(get_global_mouse_position())

func _input(_event):
	if Input.is_action_just_pressed("LMB"): 
		shoot()
	if Input.is_action_pressed("RMB") and near_weapon:
		pickup_weapon(near_weapon)

func _physics_process(_delta):
	read_input()
	move_and_slide()

func pickup_weapon(weapon):
	if has_weapon:
		drop_weapon()  # Upuszczenie obecnej broni, jeśli gracz już ją posiada
		# Oczekiwanie przed przypisaniem nowej broni do sprite’a gracza
		await get_tree().create_timer(0.2).timeout  # Czas opóźnienia, np. 0.2 sekundy

	# Zapisujemy dane nowej broni
	current_weapon_data = {
		"type": weapon.weapon_type,
		"damage": weapon.damage,
		"ammo": weapon.ammo,
		"fire_rate": weapon.fire_rate
	}
	has_weapon = true
	
	# Ustawiamy sprite gracza na podstawie podniesionej broni
	match weapon.weapon_type:
		"Rifle":
			$Sprite2D.texture = sprite_rifle
		_:
			$Sprite2D.texture = sprite_no_weapon  # Domyślny sprite bez broni
	
	# Wywołanie funkcji usunięcia broni z ziemi
	weapon.on_pickup()
	
	print("Picked up:", current_weapon_data["type"])
	update_ammo_bar()

func drop_weapon():
	if current_weapon_data == null:
		return  # Jeśli gracz nie ma broni, nie trzeba nic robić
	# Tworzenie nowej instancji `WeaponBase`, która reprezentuje obecną broń
	var weapon_scene_path = ""
	match current_weapon_data["type"]:
		"Rifle":
			weapon_scene_path = "res://scenes/Rifle.tscn"
		_:
			weapon_scene_path = "res://scenes/WeaponBase.tscn"  # Domyślna scena, jeśli typ jest nieznany

	# Wczytaj scenę broni i stwórz jej instancję
	var weapon_scene = load(weapon_scene_path)
	var dropped_weapon = weapon_scene.instantiate()
	# Ustaw pozycję broni na niewielką odległość przed graczem
	var drop_offset = Vector2(10, 0).rotated(rotation)  # Przesunięcie 10 pikseli przed graczem
	dropped_weapon.position = global_position + drop_offset
	dropped_weapon.rotation = rotation  # Ustawienie rotacji zgodnej z rotacją gracza
	dropped_weapon.weapon_type = current_weapon_data["type"]
	dropped_weapon.damage = current_weapon_data["damage"]
	dropped_weapon.ammo = current_weapon_data["ammo"]
	dropped_weapon.fire_rate = current_weapon_data["fire_rate"]
	dropped_weapon.sprite = $Sprite2D.texture  # Przypisanie sprite’a obecnej broni

	# Dodanie broni do obecnej sceny, aby pojawiła się na ziemi
	get_tree().current_scene.add_child(dropped_weapon)

	# Zresetowanie obecnej broni w gracza
	current_weapon_data = null
	has_weapon = false
	$Sprite2D.texture = sprite_no_weapon  # Reset na domyślny sprite bez broni

	print("Broń została upuszczona:", dropped_weapon.weapon_type)

func shoot():
	# Najpierw sprawdzamy, czy gracz ma broń
	if current_weapon_data == null:
		print("You don't have a weapon!")
		return  # Jeśli nie ma broni, kończymy funkcję
	if has_weapon and can_fire and current_weapon_data["ammo"] > 0:
		can_fire = false
		var instance = bullet.instantiate()
		
		# Ustawienie pocisku na pozycji gracza
		instance.position = global_position
		
		# Przekazujemy pozycję kursora jako cel dla pocisku
		instance.target_position = get_global_mouse_position()
		instance.damage = current_weapon_data["damage"]
		get_tree().current_scene.add_child(instance)

		# Zmniejsz amunicję i zaktualizuj pasek
		current_weapon_data["ammo"] -= 1
		update_ammo_bar()
		
		# Oczekiwanie przed kolejnym strzałem
		await get_tree().create_timer(current_weapon_data["fire_rate"]).timeout
		can_fire = true
	elif current_weapon_data["ammo"] <= 0:
		print("Out of ammo!")


func update_ammo_bar():
	if has_weapon:
		ammo_bar.value = current_weapon_data["ammo"]
	else:
		ammo_bar.value = 0
