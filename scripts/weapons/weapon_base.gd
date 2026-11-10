extends Node3D
class_name WeaponBase

@export var damage: float = 10.0
@export var knockback_force: float = 15.0
@export var fire_rate: float = 0.5 
@export var is_melee: bool = false
@export var bullet_scene: PackedScene # <-- ¡Añadimos la bala aquí!

var time_since_last_shot: float = 0.0

func _process(delta: float) -> void:
	time_since_last_shot += delta

func use_weapon(origin: Node3D, target_pos: Vector3, shooter_is_player: bool) -> void:
	if time_since_last_shot < fire_rate:
		return
		
	time_since_last_shot = 0.0
	
	if is_melee:
		# perform_melee(origin, shooter_is_player) # Lo haremos luego
		pass
	else:
		shoot_projectile(origin, target_pos, shooter_is_player)

func shoot_projectile(origin: Node3D, target_pos: Vector3, shooter_is_player: bool) -> void:
	if not bullet_scene: 
		print("¡ERROR! No hay bala asignada en el arma.")
		return
		
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	var dir = (target_pos - origin.global_position).normalized()
	
	# Hacemos que la bala aparezca un poquito más adelante
	bullet.global_position = origin.global_position + (dir * 1.5) 
	bullet.direction = dir
	bullet.is_from_player = shooter_is_player
	bullet.ignore_body = origin
	bullet.knockback_force = knockback_force
