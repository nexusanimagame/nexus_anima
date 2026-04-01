extends Control

# ==========================================
# --- REFERÊNCIAS DOS NÓS ---
# ==========================================
@onready var fundo = $Fundo
@onready var fundo_bolsa = $FundoBolsa
@onready var fundo_grade = $FundoGrade 
@onready var grade_itens = $GradeItens
@onready var anim_player = $AnimationPlayer

# Controlo de estado para saber se a mochila está aberta
var esta_aberto: bool = false

# ==========================================
# --- INICIALIZAÇÃO ---
# ==========================================
func _ready():
	visible = false
	grade_itens.visible = false
	fundo_grade.visible = false 
	
	# Garante que o inventário e a animação funcionem mesmo com o jogo pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	anim_player.process_mode = Node.PROCESS_MODE_ALWAYS

# ==========================================
# --- CONTROLO DE ENTRADA (TECLADO) ---
# ==========================================
func _unhandled_input(event):
	# Trava de segurança para não interromper a animação no meio
	if anim_player.is_playing():
		return

	# AÇÃO TAB (Abrir/Fechar)
	if event.is_action_pressed("inventory"):
		if esta_aberto:
			_fechar_mochila()
		else:
			# Impede de abrir a mochila se o Menu de Pausa (ESC) já estiver a travar o jogo
			if not get_tree().paused:
				_abrir_mochila()
				
		get_viewport().set_input_as_handled()

	# AÇÃO ESC (Apenas Fechar)
	elif event.is_action_pressed("skip"):
		if esta_aberto:
			_fechar_mochila()
			get_viewport().set_input_as_handled()

# ==========================================
# --- ANIMAÇÕES E TRAVA DO PLAYER ---
# ==========================================
func _abrir_mochila():
	esta_aberto = true
	visible = true
	
	# PAUSA O JOGO AQUI: Congela o player e o mundo imediatamente
	get_tree().paused = true
	
	# Esconde a grade e o fundo enquanto a bolsa abre
	grade_itens.visible = false 
	fundo_grade.visible = false
	
	anim_player.play("abrir_bolsa")
	await anim_player.animation_finished
	
	# Revela o fundo e a grade de itens
	fundo_grade.visible = true
	grade_itens.visible = true 

func _fechar_mochila():
	esta_aberto = false
	
	# Esconde a grade e o fundo imediatamente
	grade_itens.visible = false 
	fundo_grade.visible = false
	
	anim_player.play_backwards("abrir_bolsa")
	await anim_player.animation_finished
	
	visible = false
	
	# DESPAUSA O JOGO AQUI: Devolve o movimento ao player quando a mochila some
	get_tree().paused = false
