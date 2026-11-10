extends State

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var on_floor: bool = player.is_on_floor()
	
	var accel: float = player.acceleration if on_floor else player.air_acceleration
	var fric: float = player.friction if on_floor else player.air_friction

	if direction != Vector3.ZERO:
		player.velocity.x = move_toward(player.velocity.x, direction.x * player.run_speed, accel * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * player.run_speed, accel * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, fric * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, fric * delta)

	if player.jump_buffer_timer > 0.0 and on_floor:
		player.velocity.y = player.jump_velocity
		player.jump_buffer_timer = 0.0

	# Slide
	if Input.is_action_just_pressed("slide") and on_floor and Vector2(player.velocity.x, player.velocity.z).length() > 1.0:
		transition_requested.emit(self, "Slide")
		return

	# CADENA (Aquí está el truco: va ANTES de comprobar si estamos en el aire)
	if Input.is_action_just_pressed("chain"):
		transition_requested.emit(self, "Chain")
		return

	# Caer
	if not on_floor:
		transition_requested.emit(self, "Air")
