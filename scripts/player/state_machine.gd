extends Node

var current_state: Node
var states: Dictionary = {}
var player: CharacterBody3D

func _ready() -> void:
	player = get_parent()
	
	# Recorremos todos los nodos hijos (Idle, Run, Slide, Air, Wall, Chain)
	for child in get_children():
		# Si el nodo tiene la función "enter", es un estado válido
		if child.has_method("enter"):
			states[child.name.to_lower()] = child
			child.player = player
			if child.has_signal("transition_requested"):
				child.transition_requested.connect(_on_transition_requested)

	# Arrancamos el juego en el estado de correr
	if states.has("run"):
		current_state = states["run"]
		current_state.enter()

func _on_transition_requested(_from: Node, to: String) -> void:
	var state_name = to.to_lower()
	
	if not states.has(state_name):
		print("¡ERROR! No encuentro el estado: ", state_name)
		return
		
	if current_state:
		current_state.exit()
		
	current_state = states[state_name]
	current_state.enter()

func _physics_process(delta: float) -> void:
	if current_state and current_state.has_method("physics_update"):
		current_state.physics_update(delta)
