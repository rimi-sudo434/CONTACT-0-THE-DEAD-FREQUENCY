extends CanvasLayer

@onready var intro_music_player: AudioStreamPlayer = $IntroMusic

var slide := 1
var title_label: Label
var subtitle_label: Label
var info_label: Label
var action_button: Button
var art: Control
var elapsed := 0.0

var title_base_y := 120.0
var subtitle_base_y := 215.0
var info_base_y := 295.0

var button_audio: AudioStreamPlayer
var button_playback: AudioStreamGeneratorPlayback


func _ready():
	var main = get_parent()

	main.set_process(false)

	var signal_panel = main.get_node_or_null("SignalPanel")
	if signal_panel:
		signal_panel.set_process(false)

	var threat_timer = main.get_node_or_null("ThreatTimer")
	if threat_timer:
		threat_timer.stop()

	var incoming_signal = main.get_node_or_null(
		"SignalPanel/IncomingSignal"
	)

	if incoming_signal:
		incoming_signal.stop()

	# INTRO MUSIC
	if intro_music_player.stream:
		intro_music_player.volume_db = -3.0
		intro_music_player.play()
		print("INTRO MUSIC PLAYING")
	else:
		print("ERROR: IntroMusic Stream is empty!")

	create_button_sound()
	create_background()
	create_ui()
	create_art()

	show_slide_one()


func _process(delta):
	elapsed += delta

	if art:
		art.queue_redraw()

	if title_label:
		title_label.position.y = (
			title_base_y
			+ sin(elapsed * 1.7) * 5.0
		)

	if subtitle_label:
		subtitle_label.position.y = (
			subtitle_base_y
			+ sin(elapsed * 2.0 + 1.0) * 4.0
		)

	if info_label:
		info_label.position.y = (
			info_base_y
			+ sin(elapsed * 2.4 + 2.0) * 5.0
		)

	if action_button:
		var pulse = 1.0 + sin(elapsed * 3.0) * 0.025
		action_button.scale = Vector2(pulse, pulse)


# =========================================================
# BUTTON SOUND
# =========================================================

func create_button_sound():
	button_audio = AudioStreamPlayer.new()
	button_audio.name = "ButtonBeep"

	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 22050.0
	generator.buffer_length = 0.15

	button_audio.stream = generator
	button_audio.volume_db = -2.0

	add_child(button_audio)

	button_audio.play()

	button_playback = (
		button_audio.get_stream_playback()
		as AudioStreamGeneratorPlayback
	)


func play_button_beep():
	if button_audio == null:
		return

	if button_playback == null:
		button_playback = (
			button_audio.get_stream_playback()
			as AudioStreamGeneratorPlayback
		)

	var frames = 2205

	for i in range(frames):
		var t = float(i) / 22050.0

		var frequency = 720.0 - t * 180.0

		var envelope = 1.0

		if t < 0.015:
			envelope = t / 0.015
		else:
			envelope = 1.0 - (
				(t - 0.015) / 0.085
			)

		envelope = max(envelope, 0.0)

		var sample = (
			sin(TAU * frequency * t)
			* 0.18
			* envelope
		)

		button_playback.push_frame(
			Vector2(sample, sample)
		)


# =========================================================
# BACKGROUND
# =========================================================

func create_background():
	var bg = ColorRect.new()

	bg.position = Vector2(0, 0)
	bg.size = Vector2(1280, 720)
	bg.color = Color("#02040B")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(bg)
	move_child(bg, 0)

	var stars = StarBackground.new()

	stars.position = Vector2(0, 0)
	stars.size = Vector2(1280, 720)
	stars.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(stars)
	move_child(stars, 1)


# =========================================================
# UI
# =========================================================

func create_ui():
	title_label = Label.new()

	title_label.position = Vector2(0, 115)
	title_label.size = Vector2(1280, 105)

	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	title_label.add_theme_font_size_override(
		"font_size",
		72
	)

	title_label.add_theme_color_override(
		"font_color",
		Color("#F0FAFF")
	)

	title_label.add_theme_color_override(
		"font_shadow_color",
		Color("#00DFFF")
	)

	title_label.add_theme_constant_override(
		"shadow_offset_x",
		3
	)

	title_label.add_theme_constant_override(
		"shadow_offset_y",
		3
	)

	add_child(title_label)


	subtitle_label = Label.new()

	subtitle_label.position = Vector2(0, 210)
	subtitle_label.size = Vector2(1280, 65)

	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	subtitle_label.add_theme_font_size_override(
		"font_size",
		34
	)

	subtitle_label.add_theme_color_override(
		"font_color",
		Color("#55E8FF")
	)

	subtitle_label.add_theme_color_override(
		"font_shadow_color",
		Color("#783CFF")
	)

	subtitle_label.add_theme_constant_override(
		"shadow_offset_x",
		3
	)

	subtitle_label.add_theme_constant_override(
		"shadow_offset_y",
		3
	)

	add_child(subtitle_label)


	info_label = Label.new()

	info_label.position = Vector2(0, 285)
	info_label.size = Vector2(1280, 70)

	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	info_label.add_theme_font_size_override(
		"font_size",
		27
	)

	info_label.add_theme_color_override(
		"font_color",
		Color("#FF73D9")
	)

	info_label.add_theme_color_override(
		"font_shadow_color",
		Color("#662CFF")
	)

	info_label.add_theme_constant_override(
		"shadow_offset_x",
		2
	)

	info_label.add_theme_constant_override(
		"shadow_offset_y",
		2
	)

	add_child(info_label)


	action_button = Button.new()

	action_button.position = Vector2(475, 585)
	action_button.size = Vector2(330, 65)

	action_button.add_theme_font_size_override(
		"font_size",
		23
	)

	action_button.add_theme_color_override(
		"font_color",
		Color("#EFFFFF")
	)

	action_button.add_theme_color_override(
		"font_hover_color",
		Color("#FFFFFF")
	)

	action_button.add_theme_color_override(
		"font_pressed_color",
		Color("#8FFFFF")
	)

	add_child(action_button)

	action_button.pressed.connect(
		_on_button_pressed
	)


# =========================================================
# ART
# =========================================================

func create_art():
	art = IntroArt.new()

	art.position = Vector2(0, 0)
	art.size = Vector2(1280, 720)

	art.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(art)
	move_child(art, 2)


# =========================================================
# SLIDE ONE
# =========================================================

func show_slide_one():
	slide = 1

	title_base_y = 105.0
	subtitle_base_y = 195.0
	info_base_y = 270.0

	title_label.position.y = title_base_y
	subtitle_label.position.y = subtitle_base_y
	info_label.position.y = info_base_y

	title_label.text = "CONTACT-0"

	subtitle_label.text = "THE DEAD FREQUENCY"

	info_label.text = "UNKNOWN SIGNAL DETECTED"

	title_label.add_theme_font_size_override(
		"font_size",
		72
	)

	subtitle_label.add_theme_font_size_override(
		"font_size",
		34
	)

	info_label.add_theme_font_size_override(
		"font_size",
		27
	)

	title_label.add_theme_color_override(
		"font_color",
		Color("#F0FAFF")
	)

	subtitle_label.add_theme_color_override(
		"font_color",
		Color("#55E8FF")
	)

	info_label.add_theme_color_override(
		"font_color",
		Color("#FF73D9")
	)

	action_button.text = "[ CONTINUE ]"


# =========================================================
# SLIDE TWO
# =========================================================

func show_slide_two():
	slide = 2

	title_base_y = 110.0
	subtitle_base_y = 210.0
	info_base_y = 295.0

	title_label.position.y = title_base_y
	subtitle_label.position.y = subtitle_base_y
	info_label.position.y = info_base_y

	title_label.text = "HORIZON-9"

	subtitle_label.text = "SIGNAL SOURCE: UNKNOWN"

	info_label.text = "CONTROL PROTOCOL READY"

	title_label.add_theme_font_size_override(
		"font_size",
		78
	)

	subtitle_label.add_theme_font_size_override(
		"font_size",
		33
	)

	info_label.add_theme_font_size_override(
		"font_size",
		28
	)

	title_label.add_theme_color_override(
		"font_color",
		Color("#F4F0FF")
	)

	subtitle_label.add_theme_color_override(
		"font_color",
		Color("#B66CFF")
	)

	info_label.add_theme_color_override(
		"font_color",
		Color("#5FFFF0")
	)

	action_button.text = "[ START MISSION ]"


# =========================================================
# BUTTON
# =========================================================

func _on_button_pressed():
	play_button_beep()

	if slide == 1:
		show_slide_two()
	else:
		start_game()


# =========================================================
# START GAME
# =========================================================

func start_game():
	if intro_music_player:
		intro_music_player.stop()

	var main = get_parent()

	main.set_process(true)

	var signal_panel = main.get_node_or_null(
		"SignalPanel"
	)

	if signal_panel:
		signal_panel.set_process(true)

	var incoming_signal = main.get_node_or_null(
		"SignalPanel/IncomingSignal"
	)

	if incoming_signal:
		incoming_signal.play()

	var threat_timer = main.get_node_or_null(
		"ThreatTimer"
	)

	if threat_timer:
		threat_timer.start()

	queue_free()


# =========================================================
# STAR BACKGROUND
# =========================================================

class StarBackground extends Control:

	var time := 0.0


	func _ready():
		set_process(true)


	func _process(delta):
		time += delta
		queue_redraw()


	func _draw():
		draw_circle(
			Vector2(640, 390),
			350,
			Color(
				0.03,
				0.12,
				0.22,
				0.18
			)
		)

		for i in range(130):
			var speed = (
				4.0
				+ float(i % 8) * 2.0
			)

			var x = fmod(
				float(i * 137)
				+ time * speed,
				1280.0
			)

			var y = float(
				(i * 83) % 720
			)

			var size = (
				0.7
				+ float(i % 4) * 0.7
			)

			var twinkle = (
				0.40
				+ sin(
					time * 2.5
					+ float(i)
				) * 0.25
			)

			draw_circle(
				Vector2(x, y),
				size,
				Color(
					0.55,
					0.78,
					1.0,
					twinkle
				)
			)


# =========================================================
# INTRO ART
# =========================================================

class IntroArt extends Control:

	var time := 0.0


	func _ready():
		set_process(true)


	func _process(delta):
		time += delta
		queue_redraw()


	func _draw():
		draw_cosmic_glow()
		draw_signal_from_alien()
		draw_signal_from_human()
		draw_human()
		draw_alien()
		draw_signal_particles()


# =========================================================
# COSMIC GLOW
# =========================================================

	func draw_cosmic_glow():
		draw_circle(
			Vector2(640, 410),
			230,
			Color(
				0.04,
				0.25,
				0.35,
				0.10
			)
		)

		draw_circle(
			Vector2(640, 410),
			150,
			Color(
				0.15,
				0.15,
				0.5,
				0.08
			)
		)


# =========================================================
# ALIEN TO HUMAN SIGNAL
# =========================================================

	func draw_signal_from_alien():
		var points = PackedVector2Array()

		for i in range(150):
			var x = (
				850.0
				- float(i) * 3.0
			)

			var wave = sin(
				float(i) * 0.35
				+ time * 5.0
			)

			var y = (
				420.0
				+ wave * 15.0
			)

			points.append(
				Vector2(x, y)
			)

		if points.size() > 1:
			draw_polyline(
				points,
				Color(
					0.35,
					0.75,
					1.0,
					0.8
				),
				3.0
			)

		var pulse_x = (
			850.0
			- fmod(
				time * 180.0,
				450.0
			)
		)

		draw_circle(
			Vector2(
				pulse_x,
				420.0
			),
			13.0,
			Color(
				0.2,
				0.85,
				1.0,
				0.12
			)
		)

		draw_circle(
			Vector2(
				pulse_x,
				420.0
			),
			5.0,
			Color("#BFFFFF")
		)


# =========================================================
# HUMAN TO ALIEN SIGNAL
# =========================================================

	func draw_signal_from_human():
		var points = PackedVector2Array()

		for i in range(150):
			var x = (
				430.0
				+ float(i) * 3.0
			)

			var wave = sin(
				float(i) * 0.32
				- time * 4.5
			)

			var y = (
				455.0
				+ wave * 13.0
			)

			points.append(
				Vector2(x, y)
			)

		if points.size() > 1:
			draw_polyline(
				points,
				Color(
					1.0,
					0.35,
					0.85,
					0.8
				),
				3.0
			)

		var pulse_x = (
			430.0
			+ fmod(
				time * 160.0,
				450.0
			)
		)

		draw_circle(
			Vector2(
				pulse_x,
				455.0
			),
			13.0,
			Color(
				1.0,
				0.25,
				0.8,
				0.12
			)
		)

		draw_circle(
			Vector2(
				pulse_x,
				455.0
			),
			5.0,
			Color("#FFD5F5")
		)


# =========================================================
# SIGNAL PARTICLES
# =========================================================

	func draw_signal_particles():
		for i in range(14):
			var p = float(i) / 14.0

			var x = (
				470.0
				+ p * 340.0
			)

			var y = (
				438.0
				+ sin(
					time * 2.0
					+ p * 15.0
				) * 20.0
			)

			draw_circle(
				Vector2(x, y),
				2.5,
				Color(
					0.5,
					0.8,
					1.0,
					0.45
				)
			)


# =========================================================
# IMPROVED FEMALE ASTRONAUT
# =========================================================

	func draw_human():
		var x = 280.0
		var y = 435.0

		var breathe = (
			sin(time * 2.0) * 2.5
		)

		var arm_move = (
			sin(time * 3.0) * 6.0
		)

		# -------------------------------------------------
		# BACKPACK
		# -------------------------------------------------

		draw_oval(
			Vector2(
				x - 70,
				y + 82 + breathe
			),
			34,
			72,
			Color("#718792")
		)

		draw_rect(
			Rect2(
				x - 94,
				y + 42 + breathe,
				40,
				95
			),
			Color("#94A9B4")
		)

		draw_rect(
			Rect2(
				x - 90,
				y + 58 + breathe,
				32,
				9
			),
			Color("#344C59")
		)

		draw_rect(
			Rect2(
				x - 90,
				y + 76 + breathe,
				32,
				6
			),
			Color("#506873")
		)

		# -------------------------------------------------
		# MAIN TORSO
		# -------------------------------------------------

		draw_oval(
			Vector2(
				x,
				y + 96 + breathe
			),
			72,
			78,
			Color("#DDE9EE")
		)

		# Lower suit
		draw_oval(
			Vector2(
				x,
				y + 138 + breathe
			),
			64,
			45,
			Color("#B4C6CF")
		)

		# -------------------------------------------------
		# NECK - IMPORTANT CONNECTION
		# -------------------------------------------------

		# Dark neck seal
		draw_oval(
			Vector2(
				x,
				y + 20 + breathe
			),
			31,
			25,
			Color("#243943")
		)

		# White collar directly touching torso
		draw_oval(
			Vector2(
				x,
				y + 31 + breathe
			),
			39,
			23,
			Color("#D6E4E9")
		)

		# Collar shadow
		draw_arc(
			Vector2(
				x,
				y + 28 + breathe
			),
			34,
			0.15,
			PI - 0.15,
			20,
			Color("#8399A3"),
			5.0
		)

		# -------------------------------------------------
		# SHOULDERS
		# -------------------------------------------------

		draw_oval(
			Vector2(
				x - 48,
				y + 55 + breathe
			),
			29,
			25,
			Color("#C7D8DF")
		)

		draw_oval(
			Vector2(
				x + 48,
				y + 55 + breathe
			),
			29,
			25,
			Color("#C7D8DF")
		)

		# -------------------------------------------------
		# CHEST
		# -------------------------------------------------

		draw_rect(
			Rect2(
				x - 39,
				y + 67 + breathe,
				78,
				47
			),
			Color("#233A47")
		)

		draw_rect(
			Rect2(
				x - 31,
				y + 76 + breathe,
				62,
				8
			),
			Color("#0A151C")
		)

		for i in range(4):
			var glow = (
				0.5
				+ sin(
					time * 4.0
					+ float(i)
				) * 0.4
			)

			draw_circle(
				Vector2(
					x - 22 + i * 15,
					y + 100 + breathe
				),
				4.0,
				Color(
					0.2,
					0.9,
					1.0,
					glow
				)
			)

		# Chest center light
		draw_rect(
			Rect2(
				x - 7,
				y + 116 + breathe,
				14,
				4
			),
			Color("#58F6FF")
		)

		# -------------------------------------------------
		# HELMET
		# -------------------------------------------------

		draw_circle(
			Vector2(
				x,
				y - 48 + breathe
			),
			69,
			Color("#E5F1F4")
		)

		# Helmet lower connection
		draw_oval(
			Vector2(
				x,
				y + 2 + breathe
			),
			55,
			28,
			Color("#B8CBD3")
		)

		# Dark helmet rim
		draw_circle(
			Vector2(
				x,
				y - 48 + breathe
			),
			56,
			Color("#6F8995")
		)

		# Visor
		draw_oval(
			Vector2(
				x,
				y - 48 + breathe
			),
			48,
			51,
			Color("#142B3B")
		)

		# Visor blue glow
		draw_arc(
			Vector2(
				x,
				y - 48 + breathe
			),
			48,
			3.5,
			5.8,
			30,
			Color(
				0.25,
				0.85,
				1.0,
				0.45
			),
			3.0
		)

		# -------------------------------------------------
		# FACE
		# -------------------------------------------------

		draw_oval(
			Vector2(
				x,
				y - 42 + breathe
			),
			31,
			37,
			Color("#D9A07E")
		)

		# Hair
		draw_arc(
			Vector2(
				x,
				y - 47 + breathe
			),
			32,
			PI,
			TAU,
			25,
			Color("#25262D"),
			9.0
		)

		draw_line(
			Vector2(
				x - 30,
				y - 48 + breathe
			),
			Vector2(
				x - 35,
				y - 10 + breathe
			),
			Color("#25262D"),
			7.0
		)

		draw_line(
			Vector2(
				x + 30,
				y - 48 + breathe
			),
			Vector2(
				x + 35,
				y - 10 + breathe
			),
			Color("#25262D"),
			7.0
		)

		# Eyes
		draw_circle(
			Vector2(
				x - 11,
				y - 44 + breathe
			),
			4.0,
			Color.WHITE
		)

		draw_circle(
			Vector2(
				x + 11,
				y - 44 + breathe
			),
			4.0,
			Color.WHITE
		)

		draw_circle(
			Vector2(
				x - 11,
				y - 44 + breathe
			),
			1.8,
			Color("#111111")
		)

		draw_circle(
			Vector2(
				x + 11,
				y - 44 + breathe
			),
			1.8,
			Color("#111111")
		)

		# Nose
		draw_line(
			Vector2(
				x,
				y - 40 + breathe
			),
			Vector2(
				x - 2,
				y - 29 + breathe
			),
			Color("#A96D53"),
			2.0
		)

		# Mouth
		draw_arc(
			Vector2(
				x,
				y - 24 + breathe
			),
			9,
			0.2,
			PI - 0.2,
			12,
			Color("#713F39"),
			2.0
		)

		# -------------------------------------------------
		# LEFT ARM
		# -------------------------------------------------

		draw_line(
			Vector2(
				x - 55,
				y + 59 + breathe
			),
			Vector2(
				x - 110,
				y + 116 + breathe
			),
			Color("#DDE9EE"),
			28.0
		)

		# Elbow joint
		draw_circle(
			Vector2(
				x - 83,
				y + 87 + breathe
			),
			15,
			Color("#AFC2CB")
		)

		# Left glove
		draw_circle(
			Vector2(
				x - 112,
				y + 117 + breathe
			),
			17,
			Color("#F0F7F9")
		)

		# -------------------------------------------------
		# RIGHT ARM
		# -------------------------------------------------

		draw_line(
			Vector2(
				x + 55,
				y + 59 + breathe
			),
			Vector2(
				x + 125,
				y + 103 + arm_move
			),
			Color("#DDE9EE"),
			28.0
		)

		# Right elbow
		draw_circle(
			Vector2(
				x + 88,
				y + 82 + arm_move
			),
			15,
			Color("#AFC2CB")
		)

		# Right glove
		draw_circle(
			Vector2(
				x + 125,
				y + 103 + arm_move
			),
			17,
			Color("#F0F7F9")
		)

		# Wrist light
		draw_circle(
			Vector2(
				x + 128,
				y + 103 + arm_move
			),
			5,
			Color("#5FFFFF")
		)


# =========================================================
# ALIEN
# =========================================================

	func draw_alien():
		var x = 1000.0
		var y = 430.0

		var float_y = (
			sin(time * 1.5) * 8.0
		)

		var glow = (
			0.65
			+ sin(time * 4.0) * 0.2
		)

		# Outer aura
		draw_circle(
			Vector2(
				x,
				y - 45 + float_y
			),
			155,
			Color(
				0.1,
				0.7,
				0.9,
				0.035
			)
		)

		draw_circle(
			Vector2(
				x,
				y - 45 + float_y
			),
			125,
			Color(
				0.15,
				0.8,
				1.0,
				0.04
			)
		)

		# Neck
		draw_oval(
			Vector2(
				x,
				y + 55 + float_y
			),
			47,
			65,
			Color("#071216")
		)

		# Head
		draw_oval(
			Vector2(
				x,
				y - 45 + float_y
			),
			108,
			130,
			Color("#081419")
		)

		# Face
		draw_oval(
			Vector2(
				x,
				y - 38 + float_y
			),
			84,
			96,
			Color("#0D2227")
		)

		# Eyes
		draw_oval(
			Vector2(
				x - 36,
				y - 50 + float_y
			),
			28,
			15,
			Color(
				0.15,
				0.9,
				1.0,
				glow
			)
		)

		draw_oval(
			Vector2(
				x + 36,
				y - 50 + float_y
			),
			28,
			15,
			Color(
				0.15,
				0.9,
				1.0,
				glow
			)
		)

		# Eye cores
		draw_oval(
			Vector2(
				x - 36,
				y - 50 + float_y
			),
			11,
			7,
			Color("#DFFFFF")
		)

		draw_oval(
			Vector2(
				x + 36,
				y - 50 + float_y
			),
			11,
			7,
			Color("#DFFFFF")
		)

		# Nose
		draw_line(
			Vector2(
				x,
				y - 31 + float_y
			),
			Vector2(
				x - 5,
				y - 5 + float_y
			),
			Color("#2A5B63"),
			3.0
		)

		# Mouth
		draw_arc(
			Vector2(
				x,
				y + 9 + float_y
			),
			27,
			0.15,
			PI - 0.15,
			20,
			Color("#43818A"),
			3.0
		)

		# Shoulders
		draw_oval(
			Vector2(
				x,
				y + 105 + float_y
			),
			140,
			58,
			Color("#061013")
		)

		# Arms
		draw_line(
			Vector2(
				x - 90,
				y + 85 + float_y
			),
			Vector2(
				x - 140,
				y + 150 + float_y
			),
			Color("#0C1D21"),
			20.0
		)

		draw_line(
			Vector2(
				x + 90,
				y + 85 + float_y
			),
			Vector2(
				x + 140,
				y + 150 + float_y
			),
			Color("#0C1D21"),
			20.0
		)

		# Signal nodes
		for i in range(6):
			var angle = (
				time * 0.5
				+ float(i) * 1.05
			)

			var px = (
				x
				+ cos(angle) * 145.0
			)

			var py = (
				y
				- 35
				+ sin(angle) * 110.0
			)

			draw_circle(
				Vector2(px, py),
				3.0,
				Color(
					0.25,
					0.9,
					1.0,
					0.5
				)
			)


# =========================================================
# OVAL HELPER
# =========================================================

	func draw_oval(
		center: Vector2,
		radius_x: float,
		radius_y: float,
		color: Color
	):
		var points = PackedVector2Array()

		for i in range(41):
			var angle = (
				TAU
				* float(i)
				/ 40.0
			)

			var px = (
				center.x
				+ cos(angle) * radius_x
			)

			var py = (
				center.y
				+ sin(angle) * radius_y
			)

			points.append(
				Vector2(px, py)
			)

		draw_colored_polygon(
			points,
			color
		)
