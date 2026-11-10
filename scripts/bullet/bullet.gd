extends Area3D

@export var speed: float = 10.0
@export var knockback_force: float = 15.0
@export var damage: float = 10.0 
@export var pickup_scene: PackedScene 
@export var is_rocket: bool = false # <-- ESTA ERA LA QUE FALTABA
@export var explosion_radius: float = 4.0 # <-- Y ESTA TAMBIÉN

var direction: Vector3 = Vector3.ZERO
var is_from_player: bool = false
var ignore_body: Node3D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# La bala desaparece a los 3 segundos si no choca
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node3D) -> void:
	if body == ignore_body:
		return

	if is_from_player:
		# Si es un cohete, explota al chocar con CUALQUIER cosa
		if is_rocket:
			explode()
		elif body.is_in_group("enemies"):
			if body.has_method("recibir_daño"):
				body.recibir_daño(damage, global_position, pickup_scene)
			queue_free()
		elif body is StaticBody3D:
			queue_free()
	else:
		# Si la bala es del enemigo
		if body is Player:
			body.velocity += direction * knockback_force
			queue_free()
		elif body is StaticBody3D:
			queue_free()

func explode() -> void:
	print("¡EXPLOSIÓN DE COHETE!")
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if global_position.distance_to(enemy.global_position) <= explosion_radius:
			if enemy.has_method("recibir_daño"):
				enemy.recibir_daño(damage, enemy.global_position, pickup_scene)
	
	queue_free()
