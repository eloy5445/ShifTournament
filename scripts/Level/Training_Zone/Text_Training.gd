extends CanvasLayer

@onready var texto = $TutorialText
var arma_en_escena: Node = null
var maniquies: Array = []
var maniquies_vivos: int = 0
var player: Player = null

@export var enemigo_escena: PackedScene 

func _ready() -> void:
	if GameManager.salto_tutorial:
		saltar_al_combate()
		return

	GameManager.juego_activo = false 
	GameManager.permitir_tiempo = false 
	GameManager.tiempo_actual = 8.0 
	texto.modulate.a = 0.0
	
	player = get_tree().get_first_node_in_group("player")
	arma_en_escena = get_tree().current_scene.get_node_or_null("MachineGun") 
	maniquies = get_tree().get_nodes_in_group("test_dummy")
	maniquies_vivos = maniquies.size()
	
	for maniqui in maniquies:
		maniqui.maniqui_destruido.connect(_on_maniqui_destruido)
	
	iniciar_tutorial()

func saltar_al_combate() -> void:
	print("¡Checkpoint cargado! Saltando al combate final...")
	var player_nodo = get_tree().get_first_node_in_group("player")
	
	if player_nodo:
		var escena_arma = load("res://scenes/weapons/MachineGun.tscn") 
		if escena_arma:
			var arma = escena_arma.instantiate()
			player_nodo.get_node("Camera3D").add_child(arma)
			arma.name = "WeaponSlot"
			player_nodo.current_weapon = arma
	
	var arma_centro = get_tree().current_scene.get_node_or_null("MachineGun")
	if arma_centro:
		arma_centro.queue_free()
	
	await get_tree().physics_frame 
	
	abrir_puertas_y_spawnear()
	
	GameManager.permitir_tiempo = true
	GameManager.juego_activo = true 
	GameManager.reiniciar_tiempo() 
	
	await esperar_a_que_mueran_los_enemigos()
	
	texto.modulate.a = 0.0
	queue_free() 

func iniciar_tutorial() -> void:
	await mostrar_mensaje("Bienvenido al Torneo. Toma tu arma del centro.")
	
	texto.text = "Toma tu arma del centro para empezar."
	var tween_in = create_tween()
	tween_in.tween_property(texto, "modulate:a", 1.0, 0.5)
	await tween_in.finished
	if arma_en_escena:
		await arma_en_escena.get_child(0).arma_recogida 
	var tween_out = create_tween()
	tween_out.tween_property(texto, "modulate:a", 0.0, 0.5)
	await tween_out.finished
	
	await mostrar_mensaje("Ese casco que llevas tiene un temporizador y una escopeta.")
	texto.text = "Pero tranquilo, el reloj no ha empezado. Primero, DESTRUYE a esos maniquíes."
	var tween_text = create_tween()
	tween_text.tween_property(texto, "modulate:a", 1.0, 0.5)
	await tween_text.finished
	
	while maniquies_vivos > 0:
		await get_tree().create_timer(0.1).timeout
	
	var tween_out_maniqui = create_tween()
	tween_out_maniqui.tween_property(texto, "modulate:a", 0.0, 0.5)
	await tween_out_maniqui.finished
	
	for maniqui in maniquies:
		maniqui.revivir()
	
	maniquies_vivos = maniquies.size()
	await get_tree().create_timer(1.0).timeout 
	
	texto.text = "¡Bien hecho! Ahora usa tu gancho (Click Derecho) para acercarte a ellos y dispárales."
	var tween_text2 = create_tween()
	tween_text2.tween_property(texto, "modulate:a", 1.0, 0.5)
	await tween_text2.finished
	
	await player.gancho_usado 
	
	var tween_out_maniqui2 = create_tween()
	tween_out_maniqui2.tween_property(texto, "modulate:a", 0.0, 0.5)
	await tween_out_maniqui2.finished
	
	texto.text = "¡Buen gancho! También puedes deslizarte (Ctrl) y saltar por las paredes (Espacio cerca de una pared) hasta 3 veces."
	var tween_text3 = create_tween()
	tween_text3.tween_property(texto, "modulate:a", 1.0, 0.5)
	await tween_text3.finished
	await get_tree().create_timer(5.0).timeout
	var tween_out_maniqui3 = create_tween()
	tween_out_maniqui3.tween_property(texto, "modulate:a", 0.0, 0.5)
	await tween_out_maniqui3.finished
	
	await mostrar_mensaje("Recuerda: cuando el reloj llegue a 0, morirás. Para reiniciarlo, debes matar a un enemigo y recoger su arma con Shift.")
	await mostrar_mensaje("Bien, es hora de que calientes un poco antes del show.")
	
	GameManager.salto_tutorial = true 
	
	abrir_puertas_y_spawnear()
	
	texto.text = "¡Demuéstrales de qué estás hecho!"
	var tween_text4 = create_tween()
	tween_text4.tween_property(texto, "modulate:a", 1.0, 0.5)
	await tween_text4.finished
	
	GameManager.permitir_tiempo = true
	GameManager.juego_activo = true 
	GameManager.reiniciar_tiempo() 
	
	await esperar_a_que_mueran_los_enemigos()
	
	texto.modulate.a = 0.0
	await mostrar_mensaje("¡El público está listo! Prepárate para el Nivel 1.")
	
	queue_free()

func abrir_puertas_y_spawnear() -> void:
	print("--- INICIANDO SPAWN DE ENEMIGOS ---") 
	
	var enemigos_viejos = get_tree().get_nodes_in_group("enemies")
	for enemigo in enemigos_viejos:
		enemigo.queue_free()
	
	await get_tree().create_timer(0.5).timeout 
	
	var puntos_spawn = [
		get_tree().current_scene.get_node_or_null("Spawn1"),
		get_tree().current_scene.get_node_or_null("Spawn2"),
		get_tree().current_scene.get_node_or_null("Spawn3"),
		get_tree().current_scene.get_node_or_null("Spawn4")
	]
	
	for punto in puntos_spawn:
		if punto and enemigo_escena:
			var nuevo_enemigo = enemigo_escena.instantiate()
			get_tree().current_scene.add_child(nuevo_enemigo)
			nuevo_enemigo.global_position = punto.global_position
			print("¡Enemigo spawneado en: ", punto.name, "!")

func _on_maniqui_destruido() -> void:
	maniquies_vivos -= 1

# --- ESPERAR A QUE MUERAN CON CHIVATO Y ABRIR PUERTA ---
func esperar_a_que_mueran_los_enemigos() -> void:
	print("Esperando a que mueran los enemigos del combate...")
	
	await get_tree().create_timer(1.0).timeout
	
	while true:
		var enemigos_restantes = get_tree().get_nodes_in_group("enemies")
		
		var nombres = []
		for e in enemigos_restantes:
			nombres.append(e.name)
		print("Enemigos restantes (", enemigos_restantes.size(), "): ", nombres)
		
		if enemigos_restantes.size() == 0:
			break
			
		await get_tree().create_timer(1.0).timeout
	
	print("¡Todos los enemigos eliminados!")
	
	GameManager.juego_activo = false
	GameManager.tiempo_actual = 8.0
	GameManager.tiempo_actualizado.emit(8.0)
	
	texto.text = "¡Excelente! Has pasado la prueba."
	texto.modulate.a = 1.0
	await get_tree().create_timer(3.0).timeout
	texto.modulate.a = 0.0
	
	# --- ABRIR LA PUERTA ---
	var puerta = get_tree().current_scene.get_node_or_null("Door")
	if puerta and puerta.has_node("AnimationPlayer"):
		print("¡Abriendo la puerta principal!")
		puerta.get_node("AnimationPlayer").play("Door_animation")
	else:
		print("¡ERROR! No se encontró el nodo 'Door' o no tiene un AnimationPlayer.")

func mostrar_mensaje(mensaje: String) -> void:
	texto.text = mensaje
	var tween_in = create_tween()
	tween_in.tween_property(texto, "modulate:a", 1.0, 0.5)
	await tween_in.finished
	await get_tree().create_timer(3.0).timeout
	var tween_out = create_tween()
	tween_out.tween_property(texto, "modulate:a", 0.0, 0.5)
	await tween_out.finished
