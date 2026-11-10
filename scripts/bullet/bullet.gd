extends Area3D

@export var speed: float = 10.0
@export var damage: float = 10.0
@export var knockback_force: float = 15.0

var direction: Vector3 = Vector3.ZERO
var is_from_player: bool = false
var ignore_body: Node3D = null

func _ready() -> void:
	
	body_entered.connect(_on_body_entered)
	
	# ¡NUEVO! La bala se destruye a sí misma después de 3 segundos
	await get_tree().create_timer(5.0).timeout
	queue_free()
	
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node3D) -> void:
	# Si la bala choca con el cuerpo que debe ignorar, no hace nada
	if body == ignore_body:
		return

	if is_from_player and body.is_in_group("enemies"):
		queue_free()
	elif not is_from_player and body is Player:
		body.velocity += direction * knockback_force
		queue_free()
	elif body is StaticBody3D:
		queue_free()
