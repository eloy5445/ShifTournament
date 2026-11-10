extends WeaponBase

func _ready() -> void:
	damage = 5.0
	knockback_force = 5.0 # Empuja poquito
	fire_rate = 0.1 # Dispara muy rápido
	is_melee = false
