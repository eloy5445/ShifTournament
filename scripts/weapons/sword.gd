extends WeaponBase

func _ready() -> void:
	damage = 100.0
	knockback_force = 25.0
	fire_rate = 0.5
	is_melee = true

func use_weapon(origin: Node3D, target_pos: Vector3, shooter_is_player: bool) -> void:
	if time_since_last_shot < fire_rate: return
	time_since_last_shot = 0.0
	
	# Si es el jugador, hacemos un RayCast rápido para ver si toca al enemigo
	if shooter_is_player:
		var space_state = get_world_3d().direct_space_state
		var from = origin.global_position
		var to = target_pos
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		
		if result and result.collider.is_in_group("enemies"):
			print("¡ESPADAZO!")
			result.collider.queue_free() # Muerte instantánea
