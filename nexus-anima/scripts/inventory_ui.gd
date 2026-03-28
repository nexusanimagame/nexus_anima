extends Control

func _ready():
	# O inventário começa escondido
	visible = false

# Essa função escuta o teclado o tempo todo
func _unhandled_input(event):
	# Se apertar TAB (inventory)
	if event.is_action_pressed("inventory"):
		toggle_inventory()
	
	# Se apertar ESC (skip) e o inventário estiver aberto
	elif event.is_action_pressed("skip") and visible:
		close_inventory()
		# Impede que o ESC faça outras coisas no jogo ao mesmo tempo
		get_viewport().set_input_as_handled() 

func toggle_inventory():
	if visible:
		close_inventory()
	else:
		open_inventory()

func open_inventory():
	visible = true
	print("Inventário Aberto")
	
	# Trava o movimento do player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)

func close_inventory():
	visible = false
	print("Inventário Fechado")
	
	# Devolve o movimento ao player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(true)
