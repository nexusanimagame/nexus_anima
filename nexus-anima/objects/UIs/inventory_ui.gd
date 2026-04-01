extends Control

@onready var fundo = $Fundo
@onready var fundo_bolsa = $FundoBolsa
@onready var container_itens = $VBoxContainer
@onready var anim_player = $AnimationPlayer

var esta_aberto: bool = false

func _ready():
	visible = false
	container_itens.visible = false
	
	# Garante que a interface principal continue funcionando
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# BLINDAGEM: Força o próprio AnimationPlayer a nunca congelar
	anim_player.process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if anim_player.is_playing():
		return

	if event.is_action_pressed("inventory"):
		if esta_aberto:
			_fechar_mochila()
		else:
			if not get_tree().paused:
				_abrir_mochila()
				
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("skip"):
		if esta_aberto:
			_fechar_mochila()
			get_viewport().set_input_as_handled()

func _abrir_mochila():
	esta_aberto = true
	visible = true
	container_itens.visible = false 
	
	# Usamos stop() antes para garantir que ela resete se estiver bugada
	anim_player.stop()
	anim_player.play("abrir_bolsa")
	
	await anim_player.animation_finished
	container_itens.visible = true 

func _fechar_mochila():
	esta_aberto = false
	container_itens.visible = false 
	
	anim_player.stop()
	anim_player.play_backwards("abrir_bolsa")
	
	await anim_player.animation_finished
	visible = false
