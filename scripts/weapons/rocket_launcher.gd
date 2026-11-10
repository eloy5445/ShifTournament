extends WeaponBase

func _ready() -> void:
	damage = 50.0
	knockback_force = 50.0 # ¡Te manda a volar!
	fire_rate = 1.5 # Dispara lento
	is_melee = false
