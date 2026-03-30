extends Control

# Referências dos nós da sua árvore
@onready var fundo = $Fundo
@onready var fundo_pergaminho = $FundoPergaminho
@onready var caixa_botoes = $CaixaBotoes
@onready var anim_player = $AnimationPlayer

# Referências dos botões para o efeito de afundar
@onready var btn_continuar = $CaixaBotoes/BtnContinuar
@onready var btn_opcoes = $CaixaBotoes/BtnOpcoes
@onready var btn_menu = $CaixaBotoes/BtnMenu

# Ajuste conforme a escala do seu pixel art (16x16 / 16x32)
const PROFUNDIDADE_CLIQUE = 4 

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if event.is_action_pressed("skip"):
		if anim_player.is_playing():
			return
			
		if get_tree().paused and visible:
			_fechar_menu()
			get_viewport().set_input_as_handled()
			
		elif not get_tree().paused and _nenhum_outro_menu_aberto():
			_abrir_menu()
			get_viewport().set_input_as_handled()

# --- SEQUÊNCIA DE ANIMAÇÃO ---

func _abrir_menu():
	get_tree().paused = true
	visible = true
	caixa_botoes.visible = false 
	
	anim_player.play("abrir_pergaminho")
	await anim_player.animation_finished
	
	caixa_botoes.visible = true 

func _fechar_menu():
	# Esconde os botões para não ficarem "flutuando" enquanto o pergaminho enrola
	caixa_botoes.visible = false 
	
	# Toca a animação de trás para frente
	anim_player.play_backwards("abrir_pergaminho")
	await anim_player.animation_finished
	
	# Só despausa e esconde tudo após o término da animação
	get_tree().paused = false
	visible = false

# --- VERIFICAÇÃO DE SEGURANÇA ---

func _nenhum_outro_menu_aberto() -> bool:
	var menu_layer = get_parent()
	for menu in menu_layer.get_children():
		if menu is Control and menu != self and menu.visible:
			return false 
	return true

# --- EFEITO VISUAL DE CLIQUE (AFUNDAR) ---

func _on_btn_continuar_button_down():
	btn_continuar.position.y += PROFUNDIDADE_CLIQUE

func _on_btn_continuar_button_up():
	btn_continuar.position.y -= PROFUNDIDADE_CLIQUE

func _on_btn_opcoes_button_down():
	btn_opcoes.position.y += PROFUNDIDADE_CLIQUE

func _on_btn_opcoes_button_up():
	btn_opcoes.position.y -= PROFUNDIDADE_CLIQUE

func _on_btn_menu_button_down():
	btn_menu.position.y += PROFUNDIDADE_CLIQUE

func _on_btn_menu_button_up():
	btn_menu.position.y -= PROFUNDIDADE_CLIQUE

# --- AÇÕES DOS BOTÕES ---

func _on_btn_continuar_pressed():
	# Se a animação de abertura ainda estiver rodando, bloqueia o clique
	if anim_player.is_playing():
		return
	
	# CHAVE DO SUCESSO: Executa a mesma lógica do ESC para sair
	_fechar_menu()

func _on_btn_opcoes_pressed():
	if anim_player.is_playing(): return
	print("Menu de Opções será implementado aqui.")

func _on_btn_menu_pressed():
	if anim_player.is_playing(): return
	print("Retorno ao Menu Principal será implementado aqui.")
