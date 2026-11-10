extends State

@export var chain_speed: float = 35.0

var target_position: Vector3
var is_pulling: bool = false

func enter() -> void:
	print("¡ENTRÉ AL ESTADO CHAIN!")
	
	# Comprobamos si el rayo choca con un enemigo
	if player.chain_ray.is_colliding() and player.chain_ray.get_collider().is_in_group("enemies"):
		print("¡LE DI AL ENEMIGO!")
		target_position = player.chain_ray.get_collider().global_position
		is_pulling = true
	else:
		print("FALLÉ EL TIRO")
		transition_requested.emit(self, "run")

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	# --- NUEVO: Cancelar la cadena con un salto ---
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
