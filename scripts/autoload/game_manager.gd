extends Node

signal tiempo_actualizado(tiempo_restante: float)
signal jugador_muere()

var tiempo_maximo: float = 8.0
var tiempo_actual: float = 8.0
var juego_activo: bool = true

func _process(delta: float) -> void:
	if not juego_activo:
		return
		
	# El tiempo baja
	tiempo_actual -= delta
	tiempo_actual = max(0.0, tiempo_actual) # Para que no baje de 0
	
	# Avisamos a la pantalla para que actualice el número
	tiempo_actualizado.emit(tiempo_actual)
	
	# Si llega a 0, el jugador muere
	if tiempo_actual <= 0.0:
		juego_activo = false
		jugador_muere.emit()
		print("¡TIEMPO AGOTADO! Has muerto.")

# Esta función la llamaremos cuando agarremos un arma nueva
func reiniciar_tiempo() -> void:
	tiempo_actual = tiempo_maximo
	tiempo_actualizado.emit(tiempo_actual)
