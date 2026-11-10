extends Label

func _ready() -> void:
	# Nos conectamos a las señales del GameManager
	GameManager.tiempo_actualizado.connect(actualizar_texto)
	GameManager.jugador_muere.connect(morir)

func actualizar_texto(tiempo: float) -> void:
	# Mostramos el tiempo con un decimal (ej: 8.0, 7.5)
	text = str(snapped(tiempo, 0.1))
	
	# Si queda poco tiempo, se pone rojo
	if tiempo < 3.0:
		modulate = Color(1, 0, 0) # Rojo
	else:
		modulate = Color(1, 1, 1) # Blanco

func morir() -> void:
	print("¡El HUD dice que hemos muerto!")
	# Aquí luego pondremos la pantalla de Game Over
