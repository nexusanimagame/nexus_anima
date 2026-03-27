extends CharacterBody2D

@export_group("Configurações de Diálogo")
@export var detection_distance: float = 25.0
@export var interact_distance: float = 25.0
@export var npc_portrait: Texture2D
@export var dialogue_text: String = "Você deseja mudar sua aparência?"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var effect_anim: AnimatedSprite2D = $AnimatedSprite2D2

var player_ref: CharacterBody2D
var dialogue_ui: CanvasLayer
var is_dialogue_active: bool = false

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")
	dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
	
	if effect_anim:
		effect_anim.visible = false

func _process(_delta: float) -> void:
	if not player_ref: 
		return
	
	var dist = global_position.distance_to(player_ref.global_position)
	
	if dist <= detection_distance:
		if effect_anim and not effect_anim.visible:
			effect_anim.visible = true
			effect_anim.play()
		
		var dir = (player_ref.global_position - global_position).normalized()
		update_facing_direction(dir)
		
		if Input.is_action_just_pressed("interact") and not is_dialogue_active:
			start_outfit_dialogue()
	else:
		if effect_anim and effect_anim.visible:
			effect_anim.visible = false
			effect_anim.stop()
		
		anim.play("idle_move_front")

	# --- CORREÇÃO AQUI ---
	# O NPC agora apenas reseta o próprio estado. Ele NÃO solta o player.
	# Quem solta o player agora é a DialogueUI (se NÃO) ou o CustomizationMenu (se SIM).
	if is_dialogue_active and dialogue_ui and not dialogue_ui.is_active:
		is_dialogue_active = false

func start_outfit_dialogue() -> void:
	if not dialogue_ui: return
	is_dialogue_active = true
	dialogue_ui.start_dialogue(dialogue_text, npc_portrait, true)
	if player_ref:
		player_ref.set_physics_process(false)

func update_facing_direction(dir: Vector2) -> void:
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
