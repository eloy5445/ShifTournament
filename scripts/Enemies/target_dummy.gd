extends StaticBody3D

@export var shoot_range: float = 35.0
@export var telegraph_time: float = 0.5
@export var cooldown_time: float = 1.5

@onready var player = get_tree().get_first_node_in_group("player")
@onready var vision_ray: RayCast3D = $VisionRay
@onready var weapon = $WeaponSlot # <-- AQUÍ ESTÁ LA MAGIA
var can_shoot: bool = true

func _ready() -> void:
	if not player:
		print("¡ERROR! Asegúrate de que el Player está en el grupo 'player'")
	shoot_loop()

func shoot_loop() -> void:
	while true:
		await get_tree().create_timer(cooldown_time).timeout
		
		if player and can_shoot:
			# Comprobamos si estamos en rango Y si lo podemos ver
			if global_position.distance_to(player.global_position) < shoot_range:
				check_vision()

func check_vision() -> void:
	# Hacemos que el rayo mire hacia el jugador
	vision_ray.look_at(player.global_position, Vector3.UP)
	vision_ray.force_raycast_update() # Forzamos a Godot a actualizar el rayo AHORA mismo
	
	# Si el rayo choca con algo y ese algo es el jugador
	if vision_ray.is_colliding() and vision_ray.get_collider() == player:
		start_telegraph()

func start_telegraph() -> void:
	can_shoot = false
	var mesh = $MeshInstance3D
	var mat = mesh.get_surface_override_material(0)
	
	mat.albedo_color = Color(1, 1, 0) # Se pone amarillo (Aviso)
	await get_tree().create_timer(telegraph_time).timeout
	
	# ¡Le decimos al arma que dispare!
	if weapon:
		weapon.use_weapon(self, player.global_position, false)
	
	mat.albedo_color = Color(1, 0, 0) # Vuelve a rojo
	can_shoot = true
