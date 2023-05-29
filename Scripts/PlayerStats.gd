extends Node
#Player variables
 
signal PlayerDamaged
 
var health = 100
var max_health = 100
var armor = 0
var max_armor = 100
var guns_carried = []
var ammo_pistol = 999
var ammo_rocket = 3
var ammo_shells = 10
var ammo_uzi = 25
var ammo_max_pistol = 999
var ammo_max_rocket = 50
var ammo_max_shells = 100
var ammo_max_uzi = 200
var current_gun = "Pistol"
@onready var pistol = preload("res://scenes/Weapons/pistol.tscn")
@onready var carried_guns = [pistol]

func reset():
	health = 100
	max_health = 100
	armor = 0
	max_armor = 100
	guns_carried = []
	ammo_pistol = 999
	ammo_rocket = 3
	ammo_shells = 10
	ammo_uzi = 25
	ammo_max_pistol = 999
	ammo_max_rocket = 50
	ammo_max_shells = 100
	ammo_max_uzi = 200
	current_gun = "Pistol"
	carried_guns = [pistol]
	
func take_damage(amount):
	if amount > armor:
		amount = amount - armor
		armor = 0
	else:
		change_armor(-amount)
		return
	###apply remaining damage to health
	change_health(-amount)
	PlayerDamaged.emit()
		
	
func change_health(amount):
	health += amount
	health = clamp(health, 0, max_health)
	
func change_armor(amount):
	armor += amount
	armor = clamp(armor,0,max_armor)
	
func change_pistol_ammo(amount):
	ammo_pistol+=amount
	ammo_pistol = clamp(ammo_pistol,0,ammo_max_pistol)
	
func change_shotgun_ammo(amount):
	ammo_shells+=amount
	ammo_shells = clamp(ammo_shells,0,ammo_max_shells)
	
func change_rocket_ammo(amount):
	ammo_rocket+=amount
	ammo_rocket = clamp(ammo_rocket,0,ammo_max_rocket)
	
func change_uzi_ammo(amount):
	ammo_uzi+=amount
	ammo_uzi = clamp(ammo_uzi,0,ammo_max_uzi)
	
func get_pistol_ammo():
	return str(ammo_pistol)
 
func get_shotgun_ammo():
	return str(ammo_shells)
 
func get_rocket_ammo():
	return str(ammo_rocket)
	
func get_uzi_ammo():
	return str(ammo_uzi)
	
func get_health():
	return str(health)
 
func get_armor():
	return str(armor)
