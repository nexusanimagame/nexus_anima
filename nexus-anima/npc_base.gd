extends CharacterBody2D

@export var detection_distance: float = 50.0
@export var interact_distance: float = 25.0
@export var dialogue_text: String = "Nexus: Anima. O elo da alma..."
@export var speaker_texture: Texture2D

var is_dialogue_active: bool = false
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var player_ref: CharacterBody2D
var ui_bg: ColorRect
var ui_icon: Node # Serve para Sprite2D ou TextureRect
var ui_box: Control
var ui_label: RichTextLabel
var ui_timer: Timer

func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	# Espera o jogo inteiro carregar para então esconder a UI
	call_deferred("_hide_ui_on_start")

func _hide_ui_on_start():
	if fetch_ui_nodes():
		if ui_bg: ui_bg.visible = false
		if ui_icon: ui_icon.visible = false
		if ui_box: ui_box.visible = false

func _process(_delta):
	if not player_ref: return
	var dist = global_position.distance_to(player_ref.global_position)
	
	if not is_dialogue_active:
		if dist <= detection_distance:
			var dir = (player_ref.global_position - global_position).normalized()
			update_facing_direction(dir)
			
			if dist <= interact_distance and Input.is_action_just_pressed("interact"):
				start_dialogue()
		else:
			anim.play("idle_move_front")
	else:
		if Input.is_action_just_pressed("enter"):
			end_dialogue()

func fetch_ui_nodes() -> bool:
	var canvas = get_tree().get_first_node_in_group("dialogue_ui")
	if not canvas: return false
	
	# Busca os nós de forma segura, não importa em qual sub-pasta estejam
	ui_bg = canvas.find_child("Background", true, false)
	ui_icon = canvas.find_child("Speaker_Icon", true, false)
	ui_box = canvas.find_child("Dialog_Box", true, false)
	
	if ui_box:
		ui_label = ui_box.find_child("RichTextLabel", true, false)
		ui_timer = ui_box.find_child("Timer", true, false)
		
		if ui_timer and not ui_timer.timeout.is_connected(_on_typewriter_timeout):
			ui_timer.timeout.connect(_on_typewriter_timeout)
			
	return true

func start_dialogue():
	if not fetch_ui_nodes() or not ui_box:
		print("ERRO: Nós da interface faltando ou nomes incorretos.")
		return
		
	is_dialogue_active = true
	player_ref.set_physics_process(false)
	
	if ui_bg: ui_bg.visible = true
	if ui_box: ui_box.visible = true
	
	if speaker_texture and ui_icon:
		ui_icon.texture = speaker_texture
		ui_icon.visible = true
		
	if ui_label:
		ui_label.text = dialogue_text
		ui_label.visible_characters = 0
	if ui_timer:
		ui_timer.start()

func end_dialogue():
	is_dialogue_active = false
	player_ref.set_physics_process(true)
	
	if ui_bg: ui_bg.visible = false
	if ui_box: ui_box.visible = false
	if ui_icon: ui_icon.visible = false
	if ui_timer: ui_timer.stop()

func _on_typewriter_timeout():
	if ui_label and ui_label.visible_characters < ui_label.text.length():
		ui_label.visible_characters += 1
	elif ui_timer:
		ui_timer.stop()

func update_facing_direction(dir: Vector2):
	var x = abs(dir.x)
	var y = abs(dir.y)
	var suffix = "front"
	if y > 2 * x: suffix = "back" if dir.y < 0 else "front"
	elif x > 2 * y: suffix = "side"
	else: suffix = "back_side" if dir.y < 0 else "front_side"
	
	anim.play("idle_move_" + suffix)
	anim.flip_h = dir.x < 0
