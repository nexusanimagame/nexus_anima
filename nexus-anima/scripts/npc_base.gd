extends CharacterBody2D

@export var detection_distance: float = 25.0
@export var interact_distance: float = 25.0
@export var npc_portrait: Texture2D
@export var dialogue_text: String = "Olá! Eu sou um NPC para testes..."

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var effect_anim: AnimatedSprite2D = $AnimatedSprite2D2

var player_ref: CharacterBody2D
var dialogue_ui

var is_dialogue_active: bool = false

func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	# Certifique-se que sua DialogueUI está no grupo "dialogue_ui" nas configurações do nó!
	dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
	
	if effect_anim:
		effect_anim.visible = false

func _process(_delta):
	if not player_ref:
		return
	
	var dist = global_position.distance_to(player_ref.global_position)
	
	# Efeito visual de proximidade
	if dist <= detection_distance:
		if effect_anim and not effect_anim.visible:
			effect_anim.visible = true
			effect_anim.play()
		
		var dir = (player_ref.global_position - global_position).normalized()
		update_facing_direction(dir)
	else:
		if effect_anim and effect_anim.visible:
			effect_anim.visible = false
			effect_anim.stop()
		anim.play("idle_move_front")
	
	# LÓGICA DE INTERAÇÃO
	if dist <= interact_distance:
		# Iniciar com F
		if Input.is_action_just_pressed("interact") and not is_dialogue_active:
			start_dialogue()
		
		# Tentar fechar com Enter
		elif is_dialogue_active and Input.is_action_just_pressed("ui_accept"):
			# SÓ fecha se a DialogueUI já tiver terminado de escrever
			if dialogue_ui and not dialogue_ui.typing:
				end_dialogue()

func start_dialogue():
	if not dialogue_ui:
		print("ERRO: DialogueUI não encontrada")
		return
	
	is_dialogue_active = true
	dialogue_ui.start_dialogue(dialogue_text, npc_portrait)
	
	if player_ref:
		player_ref.set_physics_process(false)

func end_dialogue():
	is_dialogue_active = false
	if dialogue_ui:
		dialogue_ui.end_dialogue()
	
	if player_ref:
		player_ref.set_physics_process(true)

func update_facing_direction(dir: Vector2):
	var x = abs(dir.x)
	var y = abs(dir.y)
	var suffix = "front"
	
	if y > 2 * x:
		suffix = "back" if dir.y < 0 else "front"
	elif x > 2 * y:
		suffix = "side"
	else:
		suffix = "back_side" if dir.y < 0 else "front_side"
	
	anim.play("idle_move_" + suffix)
	anim.flip_h = dir.x < 0
