extends Area3D

# --- LA NUEVA SEÑAL ---
signal arma_recogida 

var player_in_area: bool = false

func _ready() -> void:
	# Si el área está dentro de la cámara, es porque ya es el arma equipada.
	if get_parent().get_parent() is Camera3D:
		set_deferred("monitoring", false)
		queue_free()
		return

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		player_in_area = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		player_in_area = false

func _process(delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("swap_weapon"):
		recoger_arma()

func recoger_arma() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player: return
	
	var cam = player.get_node("Camera3D")
	
	# Borramos el arma actual
	for child in cam.get_children():
		if child.has_method("use_weapon"):
			child.queue_free()
	
	# Cargamos la escena del arma
	var mi_escena = load(get_parent().scene_file_path)
	
	if mi_escena:
		var nueva_arma = mi_escena.instantiate()
		cam.add_child(nueva_arma)
		nueva_arma.name = "WeaponSlot"
		player.current_weapon = nueva_arma 
		print("¡Arma recogida!")
		
		# --- EMITIMOS LA SEÑAL ---
		arma_recogida.emit()
	
	
	get_parent().queue_free()
