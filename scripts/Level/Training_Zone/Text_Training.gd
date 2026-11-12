extends CanvasLayer

@onready var texto = $TutorialText
var arma_en_escena: Node = null
var maniquies: Array = []
var maniquies_vivos: int = 0

func _ready() -> void:
	GameManager.juego_activo = false 
	GameManager.permitir_tiempo = false 
	GameManager.tiempo_actual = 8.0 
	texto.modulate.a = 0.0
	
	arma_en_escena = get_tree().current_scene.get_node_or_null("MachineGun") 
	
	# Buscamos a los maniquíes y contamos cuántos hay
	maniquies = get_tree().get_nodes_in_group("test_dummy")
	maniquies_vivos = maniquies.size()
	print("Maniquíes encontrados: ", maniquies_vivos)
	
	# Conectamos la señal de muerte de cada maniquí
	for maniqui in maniquies:
		maniqui.maniqui_destruido.connect(_on_maniqui_destruido)
	
	iniciar_tutorial()

func iniciar_tutorial() -> void:
	# --- FASE 1 ---
	await mostrar_mensaje("Bienvenido al Torneo. Toma tu arma del centro.")
	
	# --- FASE 2 ---
	texto.text = "Toma tu arma del centro para empezar."
	var tween_in = create_tween()
	tween_in.tween_property(texto, "modulate:a", 1.0, 0.5)
	await tween_in.finished
	if arma_en_escena:
		await arma_en_escena.get_child(0).arma_recogida 
	var tween_out = create_tween()
	tween_out.tween_property(texto, "modulate:a", 0.0, 0.5)
	await tween_out.finished
	
	# --- FASE 3 ---
	await mostrar_mensaje("Ese casco que llevas tiene un temporizador y una escopeta.")
	texto.text = "Pero tranquilo, el reloj no ha empezado. Primero, DESTRUYE a esos maniquíes."
	
	# Efecto de aparición del texto
	var tween_text = create_tween()
	tween_text.tween_property(texto, "modulate:a", 1.0, 0.5)
	await tween_text.finished
	
	# --- FASE 4: ESPERAR A QUE MUERAN TODOS ---
	print("Esperando a que destruyas a todos los maniquíes...")
	
	# Mientras queden maniquíes vivos, el script se queda esperando aquí
	while maniquies_vivos > 0:
		await get_tree().create_timer(0.1).timeout
	
	print("¡Todos los maniquíes destruidos! Avanzando...")
	
	# Desaparece el texto
	var tween_out_maniqui = create_tween()
	tween_out_maniqui.tween_property(texto, "modulate:a", 0.0, 0.5)
	await tween_out_maniqui.finished
	
	# --- FASE 5 ---
	await mostrar_mensaje("¡Bien! Ahora usa tu gancho (Click Derecho) para moverte.")
	
	# --- FASE 6 ---
	await mostrar_mensaje("¡Cuidado! Aparecen enemigos.")
	
	# --- FIN DEL TUTORIAL ---
	await mostrar_mensaje("Tutorial completado. ¡Que empiece el show!")
	
	GameManager.permitir_tiempo = true
	GameManager.juego_activo = true 
	GameManager.reiniciar_tiempo() 
	
	queue_free() 

# Esta función se ejecuta cada vez que un maniquí muere
func _on_maniqui_destruido() -> void:
	maniquies_vivos -= 1
	print("¡Maniquí destruido! Quedan: ", maniquies_vivos)

func mostrar_mensaje(mensaje: String) -> void:
	texto.text = mensaje
	var tween_in = create_tween()
	tween_in.tween_property(texto, "modulate:a", 1.0, 0.5)
	await tween_in.finished
	await get_tree().create_timer(3.0).timeout
	var tween_out = create_tween()
	tween_out.tween_property(texto, "modulate:a", 0.0, 0.5)
	await tween_out.finished
