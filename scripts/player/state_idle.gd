extends State

@export var slide_impulse: float = 14.0
@export var slide_duration: float = 0.8
@export var slide_friction: float = 8.0
var slide_timer: float = 0.0

func enter() -> void:
	slide_timer = slide_duration
	var dir := Vector3(player.velocity.x, 0, player.velocity.z).normalized()
	if dir == Vector3.ZERO:
		dir = -player.transform.basis.z
	player.velocity.x = dir.x * slide_impulse
	player.velocity.z = dir.z * slide_impulse

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	
	slide_timer -= delta
	player.velocity.x = move_toward(player.velocity.x, 0, slide_friction * delta)
	player.velocity.z = move_toward(player.velocity.z, 0, slide_friction * delta)
	

	if player.jump_buffer_timer > 0.0:
		player.velocity.y = player.jump_velocity
		player.jump_buffer_timer = 0.0
		transition_requested.emit(self, "Run")
		return

	if slide_timer <= 0.0 or not player.is_on_floor():
		transition_requested.emit(self, "Run")
