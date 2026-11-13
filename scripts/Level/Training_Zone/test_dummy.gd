extends StaticBody3D

signal recibio_disparo
signal maniqui_destruido 

@export var health: float = 100.0
var max_health: float
var posicion_inicial: Vector3

func _ready() -> void:
	max_health = health
	posicion_inicial = global_position

func recibir_daño(cantidad: float, posicion_impacto: Vector3, _pickup: PackedScene) -> void:
	health -= cantidad
	recibio_disparo.emit()
	
	# Efecto visual de daño
	var mesh = $MeshInstance3D
	if mesh and mesh.get_surface_override_material(0):
		var mat = mesh.get_surface_override_material(0)
		var color_original = mat.albedo_color
		mat.albedo_color = Color(1, 0, 0)
		await get_tree().create_timer(0.1).timeout
		mat.albedo_color = color_original
	
	# Si se queda sin vida, se "apaga" pero no se destruye
	if health <= 0:
		maniqui_destruido.emit() 
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED # Desactiva sus colisiones y lógica
		# No usamos queue_free() para poder revivirlo

# Función para revivir al maniquí
func revivir() -> void:
	health = max_health
	global_position = posicion_inicial
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
