extends CharacterBody2D

@export var interact_distance: float = 25.0
@export var dialogue_text: String = "Nexus: Anima. O elo da alma..."

var is_dialogue_active: bool = false
var player_ref: CharacterBody2D = null

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# --- Lógica de Segurança ---
func get_ui_node(node_name: String):
	var node = get_tree().root.find_child(node_name, true, false)
	if node == null:
		print("ERRO: Não encontrei o nó: ", node_name)
	return node

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")
	
	var dialog_box = get_ui_node("Dialog_Box")
	if dialog_box:
		dialog_box.visible = false
		var timer = dialog_box.find_child("Timer")
		if timer:
			timer.timeout.connect(_on_typewriter_timeout)

func _process(_delta: float) -> void:
	if not player_ref: return
	
	# Busca a UI a cada tentativa de interação para evitar erro de carregamento
	var dialog_box = get_ui_node("Dialog_Box")
	if not dialog_box: return # Interrompe o script se a UI sumir

	var dist = global_position.distance_to(player_ref.global_position)
	
	if not is_dialogue_active:
		if dist <= 50:
			update_facing_direction((player_ref.global_position - global_position).normalized())
			if dist <= interact_distance and Input.is_action_just_pressed("interact"):
				start_dialogue(dialog_box)
	else:
		if Input.is_action_just_pressed("enter"):
			end_dialogue(dialog_box)

func start_dialogue(box):
	is_dialogue_active = true
	player_ref.set_physics_process(false)
	box.visible = true
	var label = box.find_child("RichTextLabel")
	var timer = box.find_child("Timer")
	if label and timer:
		label.text = dialogue_text
		label.visible_characters = 0
		timer.start()

func end_dialogue(box):
	is_dialogue_active = false
	player_ref.set_physics_process(true)
	box.visible = false
	var timer = box.find_child("Timer")
	if timer: timer.stop()

func _on_typewriter_timeout():
	var box = get_ui_node("Dialog_Box")
	if box:
		var label = box.find_child("RichTextLabel")
		if label and label.visible_characters < label.text.length():
			label.visible_characters += 1

func update_facing_direction(dir: Vector2):
	var x = abs(dir.x)
	var y = abs(dir.y)
	var suffix = "front"
	if y > 2 * x: suffix = "back" if dir.y < 0 else "front"
	elif x > 2 * y: suffix = "side"
	else: suffix = "back_side" if dir.y < 0 else "front_side"
	anim.play("idle_move_" + suffix)
	anim.flip_h = dir.x < 0
