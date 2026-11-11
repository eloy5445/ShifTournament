extends Node

signal tiempo_actualizado(tiempo_restante: float)
signal jugador_muere()

var tiempo_maximo: float = 8.0
var tiempo_actual: float = 8.0
var juego_activo: bool = false

func _process(delta: float) -> void:
	if not juego_activo:
		return
		
	tiempo_actual -= delta
	tiempo_actual = max(0.0, tiempo_actual)
	
	tiempo_actualizado.emit(tiempo_actual)
	
	if tiempo_actual <= 0.0:
		juego_activo = false
		jugador_muere.emit()
		print("¡TIEMPO AGOTADO! Reiniciando...")
		
		# Esperamos 1 segundo (para que el jugador asimile que perdió)
		await get_tree().create_timer(1.0).timeout
		
		# Reiniciamos el nivel
		reiniciar_tiempo()
		get_tree().reload_current_scene()

func reiniciar_tiempo() -> void:
	tiempo_actual = tiempo_maximo
	juego_activo = true
	tiempo_actualizado.emit(tiempo_actual)
