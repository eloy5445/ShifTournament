extends WeaponBase

func _ready() -> void:
	damage = 80.0        # Mismo daño que el cohete (mata de un tiro)
	fire_rate = 1.8      # Dispara lento
	is_melee = false
	is_rocket = false    # Sin explosión
