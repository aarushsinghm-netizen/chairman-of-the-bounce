extends Node2D
## Everything visible except the plain panels, meter, and text is a downloaded asset.
## The wonky collage is intentional. Physics is a small arcade simulation, not RigidBody2D.

const CHAIR = preload("res://assets/openmoji/chair.svg")
const DUCK = preload("res://assets/twemoji/duck.svg")
const COFFEE = preload("res://assets/twemoji/coffee.svg")
const TROPHY = preload("res://assets/twemoji/trophy.svg")
const BACKUP = preload("res://assets/gameicons/return.svg")
const HAND = preload("res://assets/font/PatrickHand-Regular.ttf")
const MUSIC = preload("res://assets/audio/happy-loop.mp3")
const START = Vector2(155, 477)
const DESK_Y = 480.0
const CHAIR_FEET = 33.0
const EVENTS = ["normal office", "the desk has wheels now", "moon office. why", "air conditioner too strong", "final chair interview"]

var mode = "menu"
var chair_pos = START
var velocity = Vector2.ZERO
var angle = 0.0
var spin = 0.0
var airborne = false
var charging = false
var charge = 0.0
var age = 0.0
var round_time = 0.0
var desk_x = 600.0
var desk_width = 190.0
var lives = 5
var landed = 0
var score = 0
var best = 0
var persist_scores = true
var tokens = 2
var used_rescue = false
var duck_taken = false
var coffee_hit = false
var sticky = 0.0
var travelled = 0.0
var result_timer = 0.0
var message = "hold SPACE, then let go. furniture science."
var muted = false
var left_held = false
var right_held = false
var music_player: AudioStreamPlayer
var effects: AudioStreamPlayer
var ui: CanvasLayer
var status_label: Label
var info_label: Label
var menu: Control
var credits: Control
var end_panel: Control
var pause_panel: Control
var paused_game = false
var credit_return = "menu"
var floor_texture: Texture2D
var block_texture: Texture2D
var impact_sound: AudioStream
var paused_before_credits = false

func _ready() -> void:
	if ResourceLoader.exists("res://assets/kenney/floor.png"):
		floor_texture = load("res://assets/kenney/floor.png")
	if ResourceLoader.exists("res://assets/kenney/block.png"):
		block_texture = load("res://assets/kenney/block.png")
	if ResourceLoader.exists("res://assets/audio/impact.ogg"):
		impact_sound = load("res://assets/audio/impact.ogg")
	music_player = AudioStreamPlayer.new()
	music_player.stream = MUSIC
	music_player.volume_db = -19
	add_child(music_player)
	music_player.finished.connect(func(): music_player.play())
	effects = AudioStreamPlayer.new()
	effects.volume_db = -9
	add_child(effects)
	var save = ConfigFile.new()
	if save.load("user://chair-score.cfg") == OK:
		best = int(save.get_value("game", "best", 0))
	build_ui()
	update_ui()

func label_at(parent: Node, words: String, pos: Vector2, font_size: int = 26, width: float = 850) -> Label:
	var label = Label.new()
	label.text = words
	label.position = pos
	label.size.x = width
	label.add_theme_font_override("font", HAND)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("292b38"))
	parent.add_child(label)
	return label

func button_at(parent: Node, words: String, pos: Vector2, callback: Callable, width: float = 180) -> Button:
	var button = Button.new()
	button.text = words
	button.position = pos
	button.size = Vector2(width, 48)
	button.add_theme_font_override("font", HAND)
	button.add_theme_font_size_override("font_size", 24)
	button.focus_mode = Control.FOCUS_ALL
	parent.add_child(button)
	button.pressed.connect(callback)
	return button

func panel_at() -> Control:
	var panel = Panel.new()
	panel.position = Vector2(75, 100)
	panel.size = Vector2(850, 470)
	var style = StyleBoxFlat.new()
	style.bg_color = Color("f8edbe")
	style.border_color = Color("343442")
	style.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", style)
	ui.add_child(panel)
	return panel

func build_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	status_label = label_at(ui, "", Vector2(25, 12), 28)
	info_label = label_at(ui, "", Vector2(25, 54), 22)
	button_at(ui, "credits", Vector2(890, 15), show_credits, 90)
	menu = panel_at()
	label_at(menu, "CHAIRMAN OF THE BOUNCE", Vector2(25, 15), 47)
	label_at(menu, "a very normal chair-flipping job interview", Vector2(28, 75), 26)
	label_at(menu, "Land 5 chairs upright on the desk before your confidence runs out.\nHold SPACE / left mouse to charge. Release to throw.\nA / D or arrow keys: rotate your chair in the air.\nB / right mouse: BOUNCE BACK! one rescue per throw.\nA failed throw earns a rescue token. Failure is literally useful.\nCatch ducks for points. Coffee makes rotation sticky. Sorry.", Vector2(28, 130), 26)
	button_at(menu, "ok employ me", Vector2(28, 385), start_game, 210)
	button_at(menu, "asset credits", Vector2(260, 385), show_credits, 180)
	label_at(menu, "R restart   /   ESC pause   /   M mute", Vector2(460, 395), 23, 370)
	credits = panel_at()
	credits.hide()
	label_at(credits, "things i downloaded", Vector2(25, 12), 38)
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(25, 65)
	scroll.size = Vector2(795, 320)
	credits.add_child(scroll)
	var text = RichTextLabel.new()
	text.custom_minimum_size = Vector2(770, 0)
	text.fit_content = true
	text.bbcode_enabled = true
	text.add_theme_font_override("normal_font", HAND)
	text.add_theme_font_size_override("normal_font_size", 23)
	text.add_theme_color_override("default_color", Color("292b38"))
	text.text = "[b]Chair:[/b] OpenMoji contributors, CC BY-SA 4.0. Unmodified SVG.\n[url=https://github.com/hfg-gmuend/openmoji]OpenMoji source[/url]\n\n[b]Duck, coffee, trophy:[/b] Twemoji, Twitter and contributors, CC BY 4.0.\n[url=https://github.com/twitter/twemoji]Twemoji source[/url]\n\n[b]Floor + desk tiles:[/b] Kenney, Scribble Platformer, CC0.\n[url=https://kenney.nl/assets/scribble-platformer]Kenney artwork[/url]\n\n[b]Clunks:[/b] Kenney, Impact Sounds, CC0.\n[url=https://kenney.nl/assets/impact-sounds]Kenney sound pack[/url]\n\n[b]Music:[/b] Happy Loop by wipics, CC0 / public domain.\n[url=https://opengameart.org/content/happy-loop]OpenGameArt music[/url]\n\n[b]Rescue icon:[/b] Backup by Lorc, Game-icons.net, CC BY 3.0.\n[url=https://game-icons.net/1x1/lorc/backup.html]Icon source[/url]\n\n[b]Font:[/b] Patrick Hand by Patrick Wagesreiter, SIL OFL 1.1.\n[url=https://github.com/google/fonts/tree/main/ofl/patrickhand]Font source[/url]\n\nGodot Engine, MIT license. See licenses folder.\nAI-assisted code and assembly with OpenAI Codex. Downloaded art/audio, no generated art.\nFull file-by-file sources, hashes and licenses: ASSET_SOURCES.md."
	text.meta_clicked.connect(func(url): OS.shell_open(str(url)))
	scroll.add_child(text)
	button_at(credits, "back to chairs", Vector2(25, 402), close_credits, 210)
	end_panel = panel_at()
	end_panel.hide()
	pause_panel = panel_at()
	pause_panel.hide()
	label_at(pause_panel, "furniture break", Vector2(30, 35), 46)
	label_at(pause_panel, "ESC to resume. Your chair is waiting.", Vector2(30, 120), 28)
	button_at(pause_panel, "resume", Vector2(30, 215), toggle_pause)
	button_at(pause_panel, "restart", Vector2(230, 215), start_game)
	button_at(pause_panel, "menu", Vector2(430, 215), go_menu)

func start_game() -> void:
	mode = "play"
	lives = 5
	landed = 0
	score = 0
	tokens = 2
	round_time = 0
	desk_x = 600
	left_held = false
	right_held = false
	paused_game = false
	menu.hide()
	end_panel.hide()
	pause_panel.hide()
	credits.hide()
	reset_throw()
	message = "land the chair upright. the desk is the rectangle."
	if not muted:
		music_player.play()

func reset_throw() -> void:
	chair_pos = START
	velocity = Vector2.ZERO
	angle = 0
	spin = 0
	airborne = false
	charging = false
	charge = 0
	used_rescue = false
	duck_taken = false
	coffee_hit = false
	sticky = 0
	age = 0
	travelled = 0
	result_timer = 0
	desk_width = 190 - landed * 12

func launch() -> void:
	if mode != "play" or airborne or result_timer > 0 or paused_game:
		return
	charging = false
	airborne = true
	velocity = Vector2(255 + charge * 225, -620 - charge * 250)
	spin = 6.8 + charge * 2.0
	message = "A / D to rotate. B to bounce back. please stick the landing."
	play_clunk(1.25)

func rescue() -> void:
	if not airborne or used_rescue or tokens <= 0 or paused_game:
		return
	tokens -= 1
	used_rescue = true
	velocity.y = -450
	velocity.x *= 0.65
	angle = 0
	spin = 0
	sticky = 0
	message = "BOUNCE BACK!! chair has reconsidered its life choices"
	play_clunk(1.7)

func play_clunk(pitch: float = 1.0) -> void:
	if impact_sound and not muted:
		effects.stream = impact_sound
		effects.pitch_scale = pitch
		effects.play()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_M:
				muted = not muted
				music_player.stream_paused = muted
				if muted:
					effects.stop()
			KEY_ESCAPE:
				if credits.visible:
					close_credits()
				elif mode == "play":
					toggle_pause()
			KEY_R:
				if not credits.visible:
					start_game()
			KEY_B:
				if mode == "play" and not credits.visible:
					rescue()
			KEY_ENTER:
				if mode == "menu" and not credits.visible:
					start_game()
	if mode != "play" or paused_game or credits.visible:
		return
	var is_throw = (event is InputEventKey and event.keycode == KEY_SPACE) or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT)
	if is_throw:
		if event.is_pressed() and not airborne and result_timer <= 0:
			charging = true
		elif event.is_released() and charging:
			launch()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		rescue()

func toggle_pause() -> void:
	paused_game = not paused_game
	charging = false
	left_held = false
	right_held = false
	pause_panel.visible = paused_game

func go_menu() -> void:
	mode = "menu"
	paused_game = false
	pause_panel.hide()
	end_panel.hide()
	menu.show()

func show_credits() -> void:
	credit_return = mode
	paused_before_credits = paused_game
	paused_game = true
	charging = false
	credits.show()
	menu.hide()
	end_panel.hide()
	pause_panel.hide()

func close_credits() -> void:
	credits.hide()
	paused_game = paused_before_credits
	menu.visible = credit_return == "menu"
	end_panel.visible = credit_return == "end"
	pause_panel.visible = credit_return == "play" and paused_game

func duck_position() -> Vector2:
	return Vector2(desk_x - 95, 255 + sin(round_time * 1.6) * 22)

func coffee_position() -> Vector2:
	return Vector2(380 + sin(round_time) * 35, 345)

func _physics_process(delta: float) -> void:
	if mode != "play" or paused_game:
		queue_redraw()
		return
	round_time += delta
	if result_timer > 0:
		result_timer -= delta
		if result_timer <= 0:
			if lives <= 0 or landed >= 5:
				finish_game()
			else:
				reset_throw()
		update_ui()
		queue_redraw()
		return
	desk_x = 600 + sin(round_time * (0.7 + landed * 0.22)) * (0 if landed == 0 else 100)
	if charging:
		charge = minf(charge + delta * 0.70, 1.0)
	if airborne:
		age += delta
		var gravity = 650.0 if landed == 2 else 980.0
		velocity.y += gravity * delta
		if landed == 3:
			velocity.x += sin(round_time * 2.0) * 110 * delta
		sticky = maxf(0, sticky - delta)
		var steer = float(right_held or Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(left_held or Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
		spin += steer * (3.0 if sticky > 0 else 15.0) * delta
		spin = clampf(spin, -13, 13)
		var previous_y = chair_pos.y
		chair_pos += velocity * delta
		angle += spin * delta
		travelled += absf(spin * delta)
		if chair_pos.x > 955:
			chair_pos.x = 955
			velocity.x = -absf(velocity.x) * 0.65
			message = "actual bounceback. the wall is also on theme."
			play_clunk()
		if chair_pos.x < 45:
			chair_pos.x = 45
			velocity.x = absf(velocity.x) * 0.65
		if not duck_taken and chair_pos.distance_to(duck_position()) < 54:
			duck_taken = true
			score += 50
			tokens = mini(5, tokens + 1)
			message = "DUCK CONSULTANT +50 / +1 rescue token"
			play_clunk(1.8)
		if not coffee_hit and chair_pos.distance_to(coffee_position()) < 48:
			coffee_hit = true
			sticky = 1.0
			message = "coffee incident. rotation sticky for 1 second."
			play_clunk(0.6)
		# Swept top crossing prevents falling through the desk at high speed.
		if velocity.y > 0 and previous_y + CHAIR_FEET <= DESK_Y and chair_pos.y + CHAIR_FEET >= DESK_Y and absf(chair_pos.x - desk_x) < desk_width / 2.0:
			if is_upright(angle):
				resolve_landing(true)
			else:
				resolve_landing(false)
		elif chair_pos.y > 565 or age > 10:
			resolve_landing(false)
	update_ui()
	queue_redraw()

func is_upright(radians: float) -> bool:
	return absf(wrapf(radians, -PI, PI)) < deg_to_rad(32)

func resolve_landing(success: bool) -> void:
	airborne = false
	charging = false
	result_timer = 1.45
	if success:
		chair_pos.y = DESK_Y - CHAIR_FEET
		angle = 0
		landed += 1
		var earned = 100 + int(travelled / TAU) * 25 + (50 if used_rescue else 0)
		score += earned
		message = "HIRED (temporarily) +%d | %d/5 chairs landed" % [earned, landed]
		play_clunk(1.3)
	else:
		lives -= 1
		tokens = mini(5, tokens + 1)
		message = "chair down. +1 rescue token. bounce back next time."
		play_clunk(0.7)

func finish_game() -> void:
	mode = "end"
	best = maxi(best, score)
	var save = ConfigFile.new()
	save.set_value("game", "best", best)
	if persist_scores:
		save.save("user://chair-score.cfg")
	for child in end_panel.get_children():
		child.queue_free()
	var won = landed >= 5
	label_at(end_panel, "YOU ARE THE CHAIRMAN" if won else "unfortunately, floor", Vector2(30, 30), 48)
	label_at(end_panel, "5 chairs. one extremely confused office." if won else "You can always bounce back. There is literally a button.", Vector2(30, 110), 28)
	label_at(end_panel, "score: %d     best: %d\nchairs landed: %d / 5\n%s" % [score, best, landed, "Your promotion is a slightly bigger chair." if won else "A bad throw gave you another rescue. Try using B earlier."], Vector2(30, 180), 30)
	button_at(end_panel, "again (R)", Vector2(30, 370), start_game, 200)
	button_at(end_panel, "credits", Vector2(250, 370), show_credits)
	button_at(end_panel, "menu", Vector2(450, 370), go_menu)
	end_panel.show()

func update_ui() -> void:
	status_label.text = "score %d    chairs %d/5    confidence %d    rescue %d" % [score, landed, lives, tokens]
	info_label.text = message if mode == "play" else "bounceback / furniture throwing simulator / best: %d" % best
	if mode == "play" and not airborne and result_timer <= 0:
		message = "hold SPACE / mouse to charge | A D rotate | B rescue | " + EVENTS[mini(landed, 4)]

func stamp(texture: Texture2D, center: Vector2, size: Vector2, rotation_angle: float = 0, tint: Color = Color.WHITE) -> void:
	draw_set_transform(center, rotation_angle)
	draw_texture_rect(texture, Rect2(-size / 2, size), false, tint)
	draw_set_transform(Vector2.ZERO)

func _draw() -> void:
	# Plain paper-like background, deliberately no custom illustration.
	for y in range(116, 600, 32):
		draw_line(Vector2(0, y), Vector2(1000, y + 2), Color("d2d4c8"), 1)
	draw_line(Vector2(65, 105), Vector2(65, 650), Color("d69898"), 2)
	for x in range(0, 1000, 64):
		if floor_texture:
			draw_texture_rect(floor_texture, Rect2(x, 598, 64, 64), false)
	if block_texture:
		for x in range(108, 212, 52):
			draw_texture_rect(block_texture, Rect2(x, 524, 52, 74), false)
		for x in range(int(desk_x - desk_width / 2), int(desk_x + desk_width / 2), 32):
			draw_texture_rect(block_texture, Rect2(x, DESK_Y, minf(32, desk_x + desk_width / 2 - x), 30), false)
		for x in [desk_x - desk_width / 2 + 15, desk_x + desk_width / 2 - 43]:
			draw_texture_rect(block_texture, Rect2(x, 510, 27, 88), false)
	draw_string(HAND, Vector2(desk_x - 60, 548), "LAND HERE", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("262633"))
	if mode == "play":
		if not duck_taken:
			stamp(DUCK, duck_position(), Vector2(57, 57))
		if not coffee_hit:
			stamp(COFFEE, coffee_position(), Vector2(55, 55), -0.18)
		if used_rescue:
			stamp(BACKUP, chair_pos + Vector2(0, -65), Vector2(28, 28))
		stamp(CHAIR, chair_pos, Vector2(108, 108), angle)
		draw_rect(Rect2(95, 570, 180, 16), Color("403c47"))
		draw_rect(Rect2(98, 573, 174 * charge, 10), Color("e8a34b"))
		draw_string(HAND, Vector2(95, 565), "power: %d%%" % int(charge * 100), HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("292b38"))
		draw_string(HAND, Vector2(320, 625), "SPACE throw     A D rotate     B bounce back     ESC pause", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("292b38"))
	else:
		stamp(CHAIR, Vector2(45, 430), Vector2(90, 90), -0.2)
		stamp(DUCK, Vector2(960, 560), Vector2(60, 60))
		if landed >= 5:
			stamp(TROPHY, Vector2(930, 190), Vector2(85, 85))
