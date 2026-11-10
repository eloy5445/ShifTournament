extends CharacterBody3D
class_name Player

# --- Movimiento ---
@export var run_speed: float = 10.0
@export var acceleration: float = 40.0
@export var friction: float = 30.0
@export var air_acceleration: float = 4.0
@export var air_friction: float = 2.0

# --- Salto ---
@export var jump_velocity: float = 8.0
@export var max_wall_jumps: int = 2
var current_wall_jumps: int = 0

# --- Cámara ---
@export var mouse_sensitivity: float = 0.002

# --- Nodos ---
@onready var camera: Camera3D = $Camera3D
@onready var state_machine: Node = $StateMachine
@onready var ray_right: RayCast3D = $RayRight
@onready var ray_left: RayCast3D = $RayLeft
@onready var chain_ray: RayCast3D = $Camera3D/ChainRay

# --- Colisiones Slide ---
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
var default_camera_y: float
var default_shape_height: float
var default_shape_y: float

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var jump_buffer_timer: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	default_camera_y = camera.position.y
	default_shape_height = collision_shape.shape.height
	default_shape_y = collision_shape.position.y

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2 + 0.01, PI/2 - 0.01)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = 0.15
	else:
		jump_buffer_timer = max(0.0, jump_buffer_timer - delta)

	if is_on_floor():
		current_wall_jumps = 0

	# --- ATAQUE / DISPARO ---
	if Input.is_action_just_pressed("attack"):
		for child in camera.get_children():
			if child.has_method("use_weapon"):
				var target_pos = camera.global_position + (-camera.global_transform.basis.z * 50.0)
				child.use_weapon(self, target_pos, true)
				break

	move_and_slide()

func detect_wall() -> bool:
	return ray_right.is_colliding() or ray_left.is_colliding()

func get_my_wall_normal() -> Vector3:
	if ray_right.is_colliding():
		return ray_right.get_collision_normal()
	if ray_left.is_colliding():
		return ray_left.get_collision_normal()
	return Vector3.ZERO
