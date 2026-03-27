extends CanvasLayer

@onready var fade = $Fade
@onready var box = $DialogBox
@onready var label: RichTextLabel = $DialogBox/RichTextLabel
@onready var portrait: TextureRect = $Portrait
@onready var back_portrait: Panel = $BackPortrait

var is_active: bool = false
var full_text: String = ""
var char_index: int = 0
var typing_speed: float = 0.02
var typing: bool = false
var timer: float = 0.0

func _ready():
	label.theme = null
	label.bbcode_enabled = false
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.fit_content = true
	label.add_theme_color_override("default_color", Color(1,1,1,1))
	hide_ui()

func start_dialogue(text: String, npc_texture: Texture2D):
	is_active = true
	fade.visible = true
	box.visible = true
	
	if back_portrait:
		back_portrait.visible = true
	
	if portrait and npc_texture:
		portrait.texture = npc_texture
		portrait.visible = true
	
	label.text = ""
	label.visible_characters = 0
	full_text = text
	char_index = 0
	timer = 0.0
	typing = true

func end_dialogue():
	is_active = false
	typing = false
	hide_ui()

func hide_ui():
	fade.visible = false
	box.visible = false
	if portrait: portrait.visible = false
	if back_portrait: back_portrait.visible = false

func _process(delta):
	if not is_active:
		return
	
	# Lógica da máquina de escrever
	if typing:
		timer += delta
		if timer >= typing_speed:
			timer = 0.0
			if char_index < full_text.length():
				char_index += 1
				label.text = full_text
				label.visible_characters = char_index
			else:
				typing = false

	# SE apertar Enter enquanto digita: completa o texto e para o efeito
	if Input.is_action_just_pressed("ui_accept") and typing:
		label.visible_characters = full_text.length()
		typing = false
		# Consome o input para que o NPC não feche o diálogo no mesmo frame
		get_viewport().set_input_as_handled()
