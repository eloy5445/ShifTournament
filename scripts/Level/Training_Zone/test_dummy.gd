extends StaticBody3D

signal recibio_disparo
signal maniqui_destruido # <-- NUEVA SEÑAL

@export var health: float = 100.0

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
	
	# Si se queda sin vida, avisamos y desaparecemos
	if health <= 0:
		maniqui_destruido.emit() # <-- AVISAMOS QUE MURIÓ
		queue_free()
