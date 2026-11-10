extends Node3D
class_name WeaponBase

@export var is_rocket: bool = false
@export var damage: float = 10.0
@export var knockback_force: float = 15.0
@export var fire_rate: float = 0.5 
@export var is_melee: bool = false
@export var bullet_scene: PackedScene 

var time_since_last_shot: float = 0.0

func _process(delta: float) -> void:
	time_since_last_shot += delta

func use_weapon(origin: Node3D, target_pos: Vector3, shooter_is_player: bool) -> void:
	if time_since_last_shot < fire_rate:
		return
	time_since_last_shot = 0.0
	
	if is_melee:
		perform_melee(origin, shooter_is_player)
	else:
		shoot_projectile(origin, target_pos, shooter_is_player)

func shoot_projectile(origin: Node3D, target_pos: Vector3, shooter_is_player: bool) -> void:
	if not bullet_scene: 
		print("¡ERROR! Esta arma no tiene bala asignada.")
		return
	
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	var dir = (target_pos - origin.global_position).normalized()
	bullet.global_position = origin.global_position + (dir * 1.5) 
	bullet.direction = dir
	bullet.is_from_player = shooter_is_player
	bullet.ignore_body = origin
	bullet.knockback_force = knockback_force
	bullet.damage = damage
	bullet.is_rocket = is_rocket

func perform_melee(origin: Node3D, shooter_is_player: bool) -> void:
	var cam = origin
	var player = get_tree().get_first_node_in_group("player")
	if shooter_is_player and player:
		cam = player.get_node("Camera3D")
		
	var space_state = cam.get_world_3d().direct_space_state
	var from = cam.global_position
	var to = from + (-cam.global_transform.basis.z * 3.5)
	var query = PhysicsRayQueryParameters3D.create(from, to)
	if shooter_is_player and player:
		query.exclude = [player.get_rid()]
	
	var result = space_state.intersect_ray(query)
	if result:
		var hit = result.collider
		if shooter_is_player and hit.is_in_group("enemies"):
			if hit.has_method("recibir_daño"):
				hit.recibir_daño(damage, result.position, null) 
		elif not shooter_is_player and hit is Player:
			hit.velocity += (-cam.global_transform.basis.z * knockback_force)
