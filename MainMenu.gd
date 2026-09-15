extends CanvasLayer


# =========================================================
# VARIABLES
# =========================================================

var slide_background: ColorRect
var slide_content: Control
var art: Control

var intro_audio: AudioStreamPlayer
var intro_playback: AudioStreamGeneratorPlayback

var intro_time: float = 0.0
var current_slide: int = 1


# =========================================================
# READY
# =========================================================

func _ready():

	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	stop_gameplay()

	create_intro_audio()

	create_slide_1()


# =========================================================
# PROCESS
# =========================================================

func _process(delta):

	intro_time += delta

	fill_intro_audio()

	animate_intro()


# =========================================================
# STOP GAMEPLAY DURING INTRO
# =========================================================

func stop_gameplay():

	var main_scene = get_parent()

	if main_scene == null:
		return

	main_scene.set_process(false)

	var threat_timer = main_scene.get_node_or_null(
		"ThreatTimer"
	)

	if threat_timer != null:
		threat_timer.stop()

	var signal_panel = main_scene.get_node_or_null(
		"SignalPanel"
	)

	if signal_panel != null:

		signal_panel.set_process(false)

		var incoming = signal_panel.get_node_or_null(
			"IncomingSignal"
		)

		if incoming != null:
			incoming.stop()


# =========================================================
# START ACTUAL GAME
# =========================================================

func start_game():

	var main_scene = get_parent()

	if main_scene == null:
		return

	# Stop intro music

	if intro_audio != null:
		intro_audio.stop()

	# Start Main process

	main_scene.set_process(true)

	# Start signal system

	var signal_panel = main_scene.get_node_or_null(
		"SignalPanel"
	)

	if signal_panel != null:

		signal_panel.set_process(true)

		var incoming = signal_panel.get_node_or_null(
			"IncomingSignal"
		)

		if incoming != null:

			incoming.volume_db = -5.0

			if not incoming.playing:
				incoming.play()

	# Start threat timer

	var threat_timer = main_scene.get_node_or_null(
		"ThreatTimer"
	)

	if threat_timer != null:

		threat_timer.wait_time = 2.5
		threat_timer.start()

	# Remove intro

	queue_free()


# =========================================================
# SLIDE 1
# =========================================================

func create_slide_1():

	current_slide = 1

	clear_slide()

	create_background()

	create_art()

	create_floating_title(
		"CONTACT-0",
		Vector2(0, 80),
		72
	)

	create_floating_subtitle(
		"THE DEAD FREQUENCY",
		Vector2(0, 165),
		30
	)

	create_glowing_text(
		"UNKNOWN SIGNAL DETECTED",
		Vector2(0, 245),
		20
	)

	var button = create_button(
		"CONTINUE",
		Vector2(440, 560),
		Vector2(400, 70),
		25
	)

	button.pressed.connect(
		_on_continue_pressed
	)


# =========================================================
# SLIDE 2
# =========================================================

func create_slide_2():

	current_slide = 2

	clear_slide()

	create_background()

	create_art()

	create_floating_title(
		"HORIZON-9",
		Vector2(0, 100),
		68
	)

	create_glowing_text(
		"SIGNAL SOURCE: UNKNOWN",
		Vector2(0, 230),
		23
	)

	var button = create_button(
		"START MISSION",
		Vector2(420, 555),
		Vector2(440, 75),
		26
	)

	button.pressed.connect(
		_on_start_pressed
	)


# =========================================================
# BUTTON EVENTS
# =========================================================

func _on_continue_pressed():

	create_slide_2()


func _on_start_pressed():

	start_game()


# =========================================================
# BACKGROUND
# =========================================================

func create_background():

	slide_background = ColorRect.new()

	slide_background.name = "IntroBackground"

	slide_background.position = Vector2.ZERO

	slide_background.size = Vector2(
		1280,
		720
	)

	slide_background.color = Color(
		0.002,
		0.004,
		0.015,
		1.0
	)

	slide_background.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	add_child(slide_background)

	slide_content = Control.new()

	slide_content.position = Vector2.ZERO

	slide_content.size = Vector2(
		1280,
		720
	)

	slide_content.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	slide_background.add_child(
		slide_content
	)


# =========================================================
# ASTRONAUT + ALIEN ART
# =========================================================

func create_art():

	art = IntroArt.new()

	art.position = Vector2.ZERO

	art.size = Vector2(
		1280,
		720
	)

	art.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	art.slide_number = current_slide

	slide_content.add_child(
		art
	)


# =========================================================
# FLOATING TITLE
# =========================================================

func create_floating_title(
	text_value: String,
	pos: Vector2,
	font_size: int
):

	var label = Label.new()

	label.text = text_value

	label.position = pos

	label.size = Vector2(
		1280,
		100
	)

	label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	label.add_theme_font_size_override(
		"font_size",
		font_size
	)

	label.add_theme_color_override(
		"font_color",
		Color(
			0.3,
			0.95,
			1.0
		)
	)

	label.add_theme_color_override(
		"font_shadow_color",
		Color(
			0.1,
			0.7,
			1.0,
			0.8
		)
	)

	label.add_theme_constant_override(
		"shadow_offset_x",
		4
	)

	label.add_theme_constant_override(
		"shadow_offset_y",
		4
	)

	label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	slide_content.add_child(label)

	label.set_meta(
		"floating",
		true
	)


# =========================================================
# FLOATING SUBTITLE
# =========================================================

func create_floating_subtitle(
	text_value: String,
	pos: Vector2,
	font_size: int
):

	var label = Label.new()

	label.text = text_value

	label.position = pos

	label.size = Vector2(
		1280,
		60
	)

	label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	label.add_theme_font_size_override(
		"font_size",
		font_size
	)

	label.add_theme_color_override(
		"font_color",
		Color(
			0.75,
			0.45,
			1.0
		)
	)

	label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	slide_content.add_child(label)


# =========================================================
# GLOWING TEXT
# =========================================================

func create_glowing_text(
	text_value: String,
	pos: Vector2,
	font_size: int
):

	var label = Label.new()

	label.text = text_value

	label.position = pos

	label.size = Vector2(
		1280,
		55
	)

	label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	label.add_theme_font_size_override(
		"font_size",
		font_size
	)

	label.add_theme_color_override(
		"font_color",
		Color(
			1.0,
			0.35,
			0.45
		)
	)

	label.add_theme_color_override(
		"font_shadow_color",
		Color(
			1.0,
			0.05,
			0.15,
			0.9
		)
	)

	label.add_theme_constant_override(
		"shadow_offset_x",
		3
	)

	label.add_theme_constant_override(
		"shadow_offset_y",
		3
	)

	label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	slide_content.add_child(label)


# =========================================================
# BUTTON
# =========================================================

func create_button(
	text_value: String,
	pos: Vector2,
	size_value: Vector2,
	font_size: int
) -> Button:

	var button = Button.new()

	button.text = text_value

	button.position = pos

	button.size = size_value

	button.add_theme_font_size_override(
		"font_size",
		font_size
	)

	button.add_theme_color_override(
		"font_color",
		Color(
			0.75,
			0.95,
			1.0
		)
	)

	button.add_theme_color_override(
		"font_hover_color",
		Color(
			1.0,
			1.0,
			1.0
		)
	)

	slide_content.add_child(button)

	return button


# =========================================================
# INTRO AUDIO
# =========================================================

func create_intro_audio():

	intro_audio = AudioStreamPlayer.new()

	intro_audio.name = "IntroHorrorMusic"

	var generator = AudioStreamGenerator.new()

	generator.mix_rate = 22050.0

	generator.buffer_length = 2.0

	intro_audio.stream = generator

	intro_audio.volume_db = -2.0

	add_child(intro_audio)

	intro_audio.play()

	intro_playback = (
		intro_audio.get_stream_playback()
		as AudioStreamGeneratorPlayback
	)


# =========================================================
# ANXIOUS HORROR MUSIC
# =========================================================

func fill_intro_audio():

	if intro_playback == null:
		return

	var frames = min(
		intro_playback.get_frames_available(),
		1000
	)

	var rate = 22050.0

	var intensity = 1.0

	if current_slide == 2:
		intensity = 1.55

	for i in range(frames):

		var t = (
			intro_time
			+ float(i) / rate
		)

		var drone = sin(
			t * TAU * 43.0
		)

		var dark = sin(
			t * TAU * 67.0
		)

		var tension = sin(
			t * TAU * 91.0
		)

		var high = sin(
			t * TAU * 307.0
		)

		var high2 = sin(
			t * TAU * 319.0
		)

		var pulse = sin(
			t * TAU * 2.0
		)

		var tremble = sin(
			t * TAU * 5.7
		)

		var volume_wave = (
			0.65
			+ 0.35 * sin(
				t * TAU * 0.17
			)
		)

		var sample = (
			drone * 0.24
			+ dark * 0.13
			+ tension * 0.07
			+ high * 0.018
			+ high2 * 0.014
			+ pulse * 0.025
			+ tremble * 0.012
		)

		sample *= volume_wave
		sample *= intensity

		var left = sample

		var right = (
			sample
			+ sin(
				t * TAU * 51.0
			) * 0.015
		)

		intro_playback.push_frame(
			Vector2(
				left,
				right
			)
		)


# =========================================================
# INTRO ANIMATION
# =========================================================

func animate_intro():

	if slide_background == null:
		return

	var pulse = (
		sin(
			intro_time * 1.8
		)
		+ 1.0
	) * 0.5

	slide_background.color = Color(
		0.002 + pulse * 0.006,
		0.004,
		0.015 + pulse * 0.012,
		1.0
	)

	if art != null:

		art.animation_time = intro_time

		art.slide_number = current_slide

		art.queue_redraw()

	# Floating title movement

	for child in slide_content.get_children():

		if child is Label:

			if child.has_meta("floating"):

				var base_y = child.get_meta(
					"base_y",
					child.position.y
				)

				child.set_meta(
					"base_y",
					base_y
				)

				child.position.y = (
					base_y
					+ sin(
						intro_time * 1.5
					) * 5.0
				)


# =========================================================
# CLEAR SLIDE
# =========================================================

func clear_slide():

	if slide_background != null:

		slide_background.queue_free()

		slide_background = null

	slide_content = null
	art = null


# =========================================================
# CUSTOM INTRO ART
# =========================================================

class IntroArt extends Control:

	var animation_time: float = 0.0

	var slide_number: int = 1


	func _draw():

		# =================================================
		# MOVING STARS
		# =================================================

		for i in range(90):

			var x = fmod(
				float(i * 97)
				+ animation_time * 18.0,
				1280.0
			)

			var y = fmod(
				float(i * 53),
				720.0
			)

			var brightness = (
				0.35
				+ 0.25 * sin(
					animation_time * 2.0
					+ float(i)
				)
			)

			draw_circle(
				Vector2(
					x,
					y
				),
				1.5,
				Color(
					0.4,
					0.75,
					1.0,
					brightness
				)
			)


		# =================================================
		# MYSTERIOUS CENTRAL GLOW
		# =================================================

		var glow = (
			0.08
			+ 0.04 * sin(
				animation_time * 2.0
			)
		)

		draw_circle(
			Vector2(
				640,
				395
			),
			190,
			Color(
				0.05,
				0.25,
				0.35,
				glow
			)
		)


		# =================================================
		# ASTRONAUT
		# =================================================

		var astronaut_x = 355.0

		var astronaut_y = (
			410.0
			+ sin(
				animation_time * 1.4
			) * 8.0
		)

		# Helmet outer

		draw_circle(
			Vector2(
				astronaut_x,
				astronaut_y
			),
			88,
			Color(
				0.75,
				0.82,
				0.88
			)
		)

		# Helmet dark visor

		draw_circle(
			Vector2(
				astronaut_x,
				astronaut_y - 5
			),
			64,
			Color(
				0.025,
				0.06,
				0.10
			)
		)

		# Visor glow

		draw_my_ellipse(
			Vector2(
				astronaut_x + 4,
				astronaut_y - 7
			),
			Vector2(
				48,
				55
			),
			Color(
				0.06,
				0.28,
				0.38
			)
		)

		# Human face

		draw_my_ellipse(
			Vector2(
				astronaut_x + 7,
				astronaut_y - 5
			),
			Vector2(
				31,
				40
			),
			Color(
				0.72,
				0.48,
				0.39
			)
		)

		# Hair

		draw_my_ellipse(
			Vector2(
				astronaut_x + 4,
				astronaut_y - 33
			),
			Vector2(
				27,
				15
			),
			Color(
				0.08,
				0.04,
				0.03
			)
		)

		# Human eyes

		var eye_shift = sin(
			animation_time * 2.0
		) * 2.0

		draw_circle(
			Vector2(
				astronaut_x - 4 + eye_shift,
				astronaut_y - 14
			),
			3.5,
			Color.WHITE
		)

		draw_circle(
			Vector2(
				astronaut_x + 18 + eye_shift,
				astronaut_y - 14
			),
			3.5,
			Color.WHITE
		)

		draw_circle(
			Vector2(
				astronaut_x - 2 + eye_shift,
				astronaut_y - 14
			),
			1.8,
			Color(
				0.02,
				0.08,
				0.12
			)
		)

		draw_circle(
			Vector2(
				astronaut_x + 20 + eye_shift,
				astronaut_y - 14
			),
			1.8,
			Color(
				0.02,
				0.08,
				0.12
			)
		)


		# =================================================
		# ALIEN
		# =================================================

		var alien_x = 925.0

		var alien_y = (
			405.0
			+ sin(
				animation_time * 1.1
				+ 1.5
			) * 10.0
		)

		# Alien head

		draw_my_ellipse(
			Vector2(
				alien_x,
				alien_y
			),
			Vector2(
				98,
				125
			),
			Color(
				0.06,
				0.10,
				0.13
			)
		)

		# Alien face

		draw_my_ellipse(
			Vector2(
				alien_x,
				alien_y + 10
			),
			Vector2(
				73,
				91
			),
			Color(
				0.09,
				0.19,
				0.20
			)
		)

		# Alien eyes pulse

		var eye_pulse = (
			0.65
			+ 0.35 * sin(
				animation_time * 3.0
			)
		)

		draw_my_ellipse(
			Vector2(
				alien_x - 30,
				alien_y - 17
			),
			Vector2(
				27,
				14
			),
			Color(
				0.15,
				1.0,
				0.72,
				eye_pulse
			)
		)

		draw_my_ellipse(
			Vector2(
				alien_x + 30,
				alien_y - 17
			),
			Vector2(
				27,
				14
			),
			Color(
				0.15,
				1.0,
				0.72,
				eye_pulse
			)
		)


		# =================================================
		# SIGNAL BETWEEN HUMAN AND ALIEN
		# =================================================

		var points = PackedVector2Array()

		for i in range(180):

			var x = 470.0 + float(i) * 2.0

			var y = (
				315.0
				+ sin(
					float(i) * 0.18
					+ animation_time * 7.0
				) * 12.0
			)

			points.append(
				Vector2(
					x,
					y
				)
			)

		if points.size() > 1:

			draw_polyline(
				points,
				Color(
					0.2,
					0.9,
					1.0,
					0.95
				),
				3.0
			)


		# =================================================
		# SIGNAL PULSES
		# =================================================

		var pulse_x = (
			470.0
			+ fmod(
				animation_time * 180.0,
				360.0
			)
		)

		draw_circle(
			Vector2(
				pulse_x,
				315.0
			),
			8,
			Color(
				0.4,
				1.0,
				1.0,
				0.85
			)
		)


		# =================================================
		# SLIDE 2 EXTRA RED WARNING LIGHT
		# =================================================

		if slide_number == 2:

			var warning_alpha = (
				0.04
				+ 0.05 * (
					sin(
						animation_time * 4.0
					)
					+ 1.0
				)
			)

			draw_rect(
				Rect2(
					0,
					0,
					1280,
					720
				),
				Color(
					0.8,
					0.02,
					0.04,
					warning_alpha
				)
			)


	# =====================================================
	# CUSTOM ELLIPSE
	# =====================================================

	func draw_my_ellipse(
		center: Vector2,
		radius: Vector2,
		color: Color
	):

		var points = PackedVector2Array()

		for i in range(40):

			var angle = (
				TAU
				* float(i)
				/ 40.0
			)

			points.append(
				center
				+ Vector2(
					cos(angle) * radius.x,
					sin(angle) * radius.y
				)
			)

		draw_colored_polygon(
			points,
			color
		)
