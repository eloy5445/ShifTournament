extends StaticBody3D

@export var shoot_range: float = 35.0
@export var telegraph_time: float = 0.5
@export var cooldown_time: float = 1.5
@export var health: float = 30.0
@export var weapon_scene_to_drop: PackedScene # <-- Arrastra aquí el WeaponPickup.tscn en el Inspector

@onready var player = get_tree().get_first_node_in_group("player")
@onready var vision_ray: RayCast3D = $VisionRay
var can_shoot: bool = true

func _ready() -> void:
	if not player: print("¡ERROR! Falta el grupo 'player'")
	shoot_loop()

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
	
	# Disparamos
	for child in get_children():
		if child.has_method("use_weapon"):
			child.use_weapon(self, player.global_position, false)
			break
			
	if mesh and mesh.get_surface_override_material(0):
		mesh.get_surface_override_material(0).albedo_color = Color(1, 0, 0)
	can_shoot = true

# --- RECIBIR DAÑO Y MORIR ---
func recibir_daño(cantidad: float, posicion_impacto: Vector3, _pickup: PackedScene) -> void:
	health -= cantidad
	print("¡Enemigo herido! Vida restante: ", health)
	
	if health <= 0:
		print("¡ENEMIGO ELIMINADO!")
		# Soltamos el arma
		if weapon_scene_to_drop:
			var drop = weapon_scene_to_drop.instantiate()
			get_tree().current_scene.add_child(drop)
			drop.global_position = posicion_impacto
		queue_free()
