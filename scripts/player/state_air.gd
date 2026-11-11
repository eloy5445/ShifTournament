extends State

@export var wall_jump_push: float = 4
@export var wall_jump_up: float = 15
@export var wall_slide_speed: float = 1.2

func enter() -> void:
	player.camera.position.y = player.default_camera_y
	player.collision_shape.shape.height = player.default_shape_height
	player.collision_shape.position.y = player.default_shape_y

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	var on_floor: bool = player.is_on_floor()
	var on_wall: bool = player.detect_wall()
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var accel: float = player.air_acceleration
	if direction != Vector3.ZERO:
		player.velocity.x = move_toward(player.velocity.x, direction.x * player.run_speed, accel * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * player.run_speed, accel * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.air_friction * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, player.air_friction * delta)

	# --- 1. CADENA EN EL AIRE (Prioridad Máxima) ---
	if Input.is_action_just_pressed("chain"):
		transition_requested.emit(self, "Chain")
		return

	# --- 2. WALL JUMP ---
	if on_wall and not on_floor:
		if player.velocity.y < -wall_slide_speed:
			player.velocity.y = -wall_slide_speed

		if player.jump_buffer_timer > 0.0 and player.current_wall_jumps < player.max_wall_jumps:
			player.velocity.y = wall_jump_up
			var wall_normal: Vector3 = player.get_my_wall_normal()
			player.velocity += wall_normal * wall_jump_push
			
			player.current_wall_jumps += 1
			player.jump_buffer_timer = 0.0
			return

	# --- 3. VOLVER A CORRER ---
	if on_floor:
		transition_requested.emit(self, "Run")
