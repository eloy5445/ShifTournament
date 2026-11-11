extends State

@export var slide_impulse: float = 14.0
@export var slide_duration: float = 0.8
@export var slide_friction: float = 8.0
var slide_timer: float = 0.0

func enter() -> void:
	slide_timer = slide_duration
	var dir := Vector3(player.velocity.x, 0, player.velocity.z).normalized()
	if dir == Vector3.ZERO:
		dir = -player.transform.basis.z
	player.velocity.x = dir.x * slide_impulse
	player.velocity.z = dir.z * slide_impulse
	
	# --- AGACHARSE ---
	player.camera.position.y = player.default_camera_y - 0.5
	player.collision_shape.shape.height = player.default_shape_height / 2.0
	player.collision_shape.position.y = player.default_shape_y - 0.5
	
	# --- EFECTO DE VELOCIDAD EXTREMA (FOV KICK) ---
	# Abrimos el FOV de golpe al iniciar el slide
	player.camera.fov = player.max_fov + 10.0
	
	# --- INCLINACIÓN DE CÁMARA (CAMERA ROLL) ---
	# Hacemos que la cámara se incline 5 grados hacia la derecha
	var tween = create_tween()
	tween.tween_property(player.camera, "rotation:z", deg_to_rad(-5.0), 0.2)

func exit() -> void:
	# --- LEVANTARSE ---
	player.camera.position.y = player.default_camera_y
	player.collision_shape.shape.height = player.default_shape_height
	player.collision_shape.position.y = player.default_shape_y
	
	# --- RESTAURAR CÁMARA ---
	# El player.gd se encargará de suavizar el FOV de vuelta a la normalidad
	player.camera.fov = player.base_fov
	
	# Quitamos la inclinación suavemente
	var tween = create_tween()
	tween.tween_property(player.camera, "rotation:z", 0.0, 0.2)

func physics_update(delta: float) -> void:
	slide_timer -= delta
	player.velocity.x = move_toward(player.velocity.x, 0, slide_friction * delta)
	player.velocity.z = move_toward(player.velocity.z, 0, slide_friction * delta)
	
	# --- CADENA EN EL SLIDE ---
	if Input.is_action_just_pressed("chain"):
		transition_requested.emit(self, "Chain")
		return

	# Cancelar con salto
	if player.jump_buffer_timer > 0.0 and player.is_on_floor():
		player.velocity.y = player.jump_velocity
		player.jump_buffer_timer = 0.0
		transition_requested.emit(self, "run")
		return

	# Fin del slide
	if slide_timer <= 0.0 or not player.is_on_floor():
		transition_requested.emit(self, "run")
