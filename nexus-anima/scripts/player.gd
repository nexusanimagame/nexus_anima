extends CharacterBody2D

# Velocidades calculadas para sprites 16x32 em 640x360
@export var walk_speed: float = 50.0
@export var run_speed: float = 100.0
@export var friction: float = 800.0

# NOVO: Arraste aqui o seu player_skin_tone_1.tres no Inspetor para ser o padrão
@export var default_skin: SpriteFrames

var last_direction: Vector2 = Vector2.DOWN
var is_breaking: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Adiciona ao grupo para o menu encontrar o player facilmente
	add_to_group("player")
	
	# Aplica a skin padrão se ela estiver definida no Inspetor
	if default_skin:
		anim.sprite_frames = default_skin
	
	# Garante que a direção inicial seja explicitamente para baixo (frente)
	last_direction = Vector2.DOWN
	# Atualiza a animação imediatamente
	update_animation(Vector2.ZERO)

func _physics_process(delta: float) -> void:
	# 1. Captura de Input (8 direções)
	var input_vec = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_vec != Vector2.ZERO:
		is_breaking = false
		last_direction = input_vec.normalized()
		
		# Define se está correndo ou andando
		var speed = run_speed if Input.is_action_pressed("run") else walk_speed
		velocity = last_direction * speed
	else:
		# Lógica de "Break" (desaceleração rápida após corrida)
		if velocity.length() > walk_speed:
			is_breaking = true
		
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
		if velocity.length() < 5.0:
			is_breaking = false

	move_and_slide()
	update_animation(input_vec)

# --- FUNÇÃO DE TROCA DE SKIN (Chamada pelo Menu) ---
func change_skin_frames(new_frames: SpriteFrames) -> void:
	if anim and new_frames:
		anim.sprite_frames = new_frames
		# Força o play na animação atual para atualizar o visual no mesmo frame
		anim.play(anim.animation)

func update_animation(input: Vector2) -> void:
	var state = "idle"
	
	if is_breaking:
		state = "break"
	elif input != Vector2.ZERO:
		state = "run" if Input.is_action_pressed("run") else "walk"
	
	var dir_suffix = get_direction_name(last_direction)
	var anim_name = state + "_move_" + dir_suffix
	
	# Verifica se a animação existe na skin atual antes de dar play
	if anim.sprite_frames.has_animation(anim_name):
		anim.play(anim_name)
	
	# Inverte o sprite horizontalmente para direções esquerdas
	if last_direction.x != 0:
		anim.flip_h = last_direction.x < 0

func get_direction_name(dir: Vector2) -> String:
	var x = abs(dir.x)
	var y = abs(dir.y)
	
	# Prioriza direções puras ou diagonais
	if y > 2 * x:
		return "back" if dir.y < 0 else "front"
	if x > 2 * y:
		return "side"
	
	# Se chegar aqui, é diagonal
	return "back_side" if dir.y < 0 else "front_side"
