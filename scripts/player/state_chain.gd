extends State

@export var chain_speed: float = 35.0

var target_position: Vector3
var is_pulling: bool = false

func enter() -> void:
	print("¡ENTRÉ AL ESTADO CHAIN!")
	
	# Comprobamos si el rayo choca con un enemigo o un maniquí de prueba
	if player.chain_ray.is_colliding():
		var objetivo = player.chain_ray.get_collider()
		
		if objetivo.is_in_group("enemies") or objetivo.is_in_group("test_dummy"):
			print("¡LE DI AL OBJETIVO!")
			target_position = objetivo.global_position
			is_pulling = true
			
			# --- EMITIMOS LA SEÑAL PARA EL TUTORIAL ---
			player.gancho_usado.emit()
			
			# (Opcional) Aquí podrías reproducir un sonido de "cadena enganchada"
			return
			
	# Si no le da a nada, fallamos el tiro
	print("FALLÉ EL TIRO")
	transition_requested.emit(self, "run")

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	# --- Cancelar la cadena con un salto ---
	if Input.is_action_just_pressed("jump"):
		transition_requested.emit(self, "air")
		return

	if is_pulling:
		# Movemos al jugador hacia el objetivo muy rápido
		var dir = (target_position - player.global_position).normalized()
		player.velocity = dir * chain_speed
		
		# Si llegamos cerca del enemigo, frenamos y volvemos a correr
		if player.global_position.distance_to(target_position) < 2.0:
			player.velocity *= 0.2
			transition_requested.emit(self, "run")
	else:
		# Si no estamos enganchados, aplicamos gravedad normal
		player.velocity.y -= player.gravity * delta
