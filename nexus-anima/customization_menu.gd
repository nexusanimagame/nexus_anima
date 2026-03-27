extends Control

@onready var btn_vermelho = $Vermelho
@onready var btn_azul = $Azul
@onready var btn_sair = $Sair

func _ready():
	visible = false
	add_to_group("customization_menu")
	# Centraliza o menu na tela (dentro do CanvasLayer)
	set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)

func open_menu():
	visible = true
	# Trava o movimento do jogador
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)
	
	# Foca no primeiro botão para navegar com teclado/gamepad
	if btn_vermelho:
		btn_vermelho.call_deferred("grab_focus")

# --- LÓGICA DE CORES ---

func _on_vermelho_pressed():
	# Color(Vermelho, Verde, Azul, Opacidade) - Valores de 0 a 1
	apply_color_to_player(Color(1.0, 0.3, 0.3)) # Um vermelho vivo, mas não estourado
	print("Cor vermelha aplicada!")

func _on_azul_pressed():
	apply_color_to_player(Color(0.3, 0.3, 1.0)) # Um azul vibrante
	print("Cor azul aplicada!")

func _on_sair_pressed():
	visible = false
	# Devolve a movimentação ao player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(true)

# --- FUNÇÃO AUXILIAR ---

func apply_color_to_player(new_color: Color):
	# 1. Busca o jogador pelo grupo
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# 2. Busca o nó de animação dentro do jogador
		var sprite = player.get_node_or_null("AnimatedSprite2D")
		if sprite:
			# 3. Aplica o filtro de cor
			sprite.modulate = new_color
		else:
			print("ERRO: O player não tem um nó chamado AnimatedSprite2D")
