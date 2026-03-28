extends Control

func _ready():
	visible = false
	# Garante via código que este menu nunca congele
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if event.is_action_pressed("skip"):
		
		# CASO 1: O jogo JÁ ESTÁ pausado e este menu está aberto.
		# Neste caso, o ESC serve para despausar e fechar o menu.
		if get_tree().paused and visible:
			toggle_pause()
			get_viewport().set_input_as_handled()
			
		# CASO 2: O jogo NÃO está pausado. 
		# Só vamos permitir abrir o pause se nenhum outro menu estiver na tela.
		elif not get_tree().paused and _nenhum_outro_menu_aberto():
			toggle_pause()
			get_viewport().set_input_as_handled()

func toggle_pause():
	if get_tree().paused:
		get_tree().paused = false
		visible = false
		print("Jogo Despausado")
	else:
		get_tree().paused = true
		visible = true
		print("Jogo Pausado")

# --- FUNÇÃO DE SEGURANÇA (O Radar de Menus) ---
func _nenhum_outro_menu_aberto() -> bool:
	# Pega o CanvasLayer (MenuLayer) que guarda todos os menus
	var menu_layer = get_parent()
	
	# Verifica todos os "irmãos" (outros nós dentro do MenuLayer)
	for menu in menu_layer.get_children():
		# Se o nó for uma Interface (Control), não for ele mesmo, e estiver visível...
		if menu is Control and menu != self and menu.visible:
			print("Tentativa de pause bloqueada. Outro menu está aberto: ", menu.name)
			return false # Retorna falso, bloqueando o pause
			
	return true # Tudo limpo! Permite pausar.
