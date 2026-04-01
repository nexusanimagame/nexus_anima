extends Control

# Isso criará um botão de "pasta" no Inspetor para você selecionar os arquivos
@export_file("*.tres") var caminho_pele_1: String
@export_file("*.tres") var caminho_pele_2: String
@export_file("*.tres") var caminho_pele_3: String
@export_file("*.tres") var caminho_pele_4: String
@export_file("*.tres") var caminho_pele_5: String

func _ready():
	visible = false
	if not is_in_group("customization_menu"):
		add_to_group("customization_menu")
	set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)

func open_menu():
	visible = true
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)
	
	var primeiro_btn = get_node_or_null("VBoxContainer/skin_tone_1")
	if primeiro_btn:
		primeiro_btn.call_deferred("grab_focus")

# --- CONEXÕES ---

func _on_skin_tone_1_pressed():
	_tentar_trocar(caminho_pele_1)

func _on_skin_tone_2_pressed():
	_tentar_trocar(caminho_pele_2)

func _on_skin_tone_3_pressed():
	_tentar_trocar(caminho_pele_3)

func _on_skin_tone_4_pressed():
	_tentar_trocar(caminho_pele_4)

func _on_skin_tone_5_pressed():
	_tentar_trocar(caminho_pele_5)

func _on_skip_pressed():
	visible = false
	var player = get_tree().get_first_node_in_group("player")
	if player: player.set_physics_process(true)

# --- FUNÇÃO DINÂMICA (Usa LOAD em vez de PRELOAD) ---

func _tentar_trocar(caminho: String):
	if caminho == "":
		print("FALHA: O caminho está vazio. Selecione o arquivo no Inspetor!")
		return
	
	# O comando LOAD carrega o arquivo na hora que você clica, ignorando erros prévios
	var recurso = load(caminho)
	
	if recurso == null:
		print("ERRO CRÍTICO: Godot não conseguiu ler o arquivo: ", caminho)
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("change_skin_frames"):
		player.change_skin_frames(recurso)
		print("Pele alterada com sucesso via Load!")
