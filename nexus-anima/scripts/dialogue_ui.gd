extends CanvasLayer

@onready var fade = $Fade
@onready var box = $DialogBox
@onready var label: RichTextLabel = $DialogBox/RichTextLabel
@onready var portrait: TextureRect = $Portrait
@onready var options_container = $DialogBox/OptionsContainer
@onready var label_sim = $DialogBox/OptionsContainer/Sim
@onready var label_nao = $DialogBox/OptionsContainer/Nao

var is_active: bool = false
var typing: bool = false
var full_text: String = ""
var char_index: int = 0
var typing_speed: float = 0.02
var timer: float = 0.0

var waiting_for_choice: bool = false
var current_selection: int = 0 

func _ready():
	label.theme = null
	label.bbcode_enabled = true
	hide_ui()

func start_dialogue(text: String, npc_texture: Texture2D, ask_question: bool = false):
	label.text = ""
	label.visible_characters = 0
	char_index = 0
	timer = 0.0
	is_active = true
	waiting_for_choice = ask_question
	
	if options_container:
		options_container.visible = false
	
	fade.visible = true
	box.visible = true
	
	if portrait and npc_texture:
		portrait.texture = npc_texture
		portrait.visible = true
	
	full_text = text
	typing = true

func _process(delta):
	if not is_active: return
	
	if typing:
		timer += delta
		if timer >= typing_speed:
			timer = 0.0
			if char_index < full_text.length():
				char_index += 1
				label.text = full_text
				label.visible_characters = char_index
			else:
				finish_typing()
		
		if Input.is_action_just_pressed("ui_accept"):
			label.visible_characters = full_text.length()
			finish_typing()
			get_viewport().set_input_as_handled() 
			
	elif waiting_for_choice:
		handle_choice_input()

func finish_typing():
	typing = false
	if waiting_for_choice and options_container:
		options_container.visible = true
		update_selection_visual()

func handle_choice_input():
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		current_selection = 1 if current_selection == 0 else 0
		update_selection_visual()
	
	if Input.is_action_just_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		confirm_choice()

func update_selection_visual():
	if label_sim and label_nao:
		label_sim.modulate = Color.YELLOW if current_selection == 0 else Color.WHITE
		label_nao.modulate = Color.YELLOW if current_selection == 1 else Color.WHITE

func confirm_choice():
	waiting_for_choice = false
	var final_choice = current_selection 
	
	hide_ui()
	is_active = false
	
	if final_choice == 0: # SIM
		# Tenta achar o menu pelo grupo primeiro
		var custom_menu = get_tree().get_first_node_in_group("customization_menu")
		if custom_menu:
			custom_menu.open_menu()
		else:
			# Se falhar o grupo, tenta pelo nó irmão (ajuste conforme sua árvore)
			var menu_irmao = get_parent().get_node_or_null("CustomizationMenu")
			if menu_irmao:
				menu_irmao.open_menu()
			else:
				print("ERRO: Menu de customização não encontrado!")
				_release_player()
	else:
		_release_player()

func _release_player():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(true)

func end_dialogue():
	hide_ui()
	is_active = false

func hide_ui():
	fade.visible = false
	box.visible = false
	if options_container: options_container.visible = false
	if portrait: portrait.visible = false
