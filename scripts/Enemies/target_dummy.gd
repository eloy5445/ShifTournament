extends CharacterBody3D

@export var shoot_range: float = 35.0
@export var telegraph_time: float = 0.5
@export var cooldown_time: float = 1.5
@export var health: float = 30.0
@export var arma_que_suelta: PackedScene
@export var move_speed: float = 4.0
@export var preferred_distance: float = 10.0 # <-- NUEVO: Distancia a la que se queda

@onready var player = get_tree().get_first_node_in_group("player")
@onready var vision_ray: RayCast3D = $VisionRay
@onready var agent: NavigationAgent3D = $NavigationAgent3D
var can_shoot: bool = true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	if not player: print("¡ERROR! Falta el grupo 'player'")
	await get_tree().physics_frame
	shoot_loop()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	if player:
		var distance = global_position.distance_to(player.global_position)
		
		# --- NUEVA LÓGICA DE MOVIMIENTO ---
		# Si está muy lejos, se acerca. Si está muy cerca, retrocede. Si está en su zona, se queda quieto.
		if distance > preferred_distance + 1.5:
			# Se acerca
			agent.target_position = player.global_position
			var next_path_pos = agent.get_next_path_position()
			var direction = (next_path_pos - global_position).normalized()
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
		elif distance < preferred_distance - 1.5:
			# Retrocede (huye del jugador para mantener distancia)
			var direction = (global_position - player.global_position).normalized()
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
		else:
			# Está en su zona ideal, se queda quieto y te apunta
			velocity.x = move_toward(velocity.x, 0, 20 * delta)
			velocity.z = move_toward(velocity.z, 0, 20 * delta)
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)

	move_and_slide()

# --- Lógica de disparo ---
func shoot_loop() -> void:
	while true:
		await get_tree().create_timer(cooldown_time).timeout
		if player and can_shoot:
			if global_position.distance_to(player.global_position) < shoot_range:
				check_vision()

func check_vision() -> void:
	vision_ray.look_at(player.global_position, Vector3.UP)
	vision_ray.force_raycast_update()
	if vision_ray.is_colliding() and vision_ray.get_collider() == player:
		start_telegraph()

func start_telegraph() -> void:
	can_shoot = false
	var mesh = $MeshInstance3D
	if mesh and mesh.get_surface_override_material(0):
		mesh.get_surface_override_material(0).albedo_color = Color(1, 1, 0)
	
	await get_tree().create_timer(telegraph_time).timeout
	
	for child in get_children():
		if child.has_method("use_weapon"):
			child.use_weapon(self, player.global_position, false)
			break
			
	if mesh and mesh.get_surface_override_material(0):
		mesh.get_surface_override_material(0).albedo_color = Color(1, 0, 0)
	can_shoot = true

func recibir_daño(cantidad: float, posicion_impacto: Vector3, _pickup: PackedScene) -> void:
	health -= cantidad
	if health <= 0:
		if arma_que_suelta:
			var drop = arma_que_suelta.instantiate()
			get_tree().current_scene.add_child(drop)
			drop.global_position = posicion_impacto
		queue_free()
