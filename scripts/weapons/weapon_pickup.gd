extends Area3D

@export var weapon_scene: PackedScene 
var player_in_area: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body is Player: player_in_area = true
func _on_body_exited(body: Node3D) -> void:
	if body is Player: player_in_area = false

func _process(delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("swap_weapon"):
		recoger_arma()

func recoger_arma() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player: return
	var cam = player.get_node("Camera3D")
	
	# Destruimos el arma vieja
	for child in cam.get_children():
		if child.has_method("use_weapon"):
			child.queue_free()
	
	# Instanciamos la nueva
	if weapon_scene:
		var nueva_arma = weapon_scene.instantiate()
		cam.add_child(nueva_arma)
		nueva_arma.name = "WeaponSlot"
	
	GameManager.reiniciar_tiempo()
	queue_free()
