extends Node2D

var threat_scene = preload("res://threat.tscn")

var mission_time: float = 60.0
var game_over: bool = false
var mission_won: bool = false

var signal_decoded: bool = false

var score: int = 0
var score_accumulator: float = 0.0

var score_label: Label = null
var game_over_overlay: ColorRect = null
var victory_overlay: ColorRect = null

var emergency_audio: AudioStreamPlayer = null
var victory_audio: AudioStreamPlayer = null


func _ready():

	$ThreatTimer.wait_time = 2.5
	$ThreatTimer.one_shot = false
	$ThreatTimer.start()

	create_score_display()


func _process(delta):

	if game_over or mission_won:
		return

	mission_time -= delta

	# Survival score: +2 every second

	score_accumulator += delta * 2.0

	if score_accumulator >= 1.0:

		var points = int(score_accumulator)

		score += points

		score_accumulator -= points

		update_score_display()

	# Mission timer

	var timer_label = $SignalPanel.get_node_or_null(
		"TimerLabel"
	)

	if timer_label != null:

		if not $SignalPanel.decoding:

			timer_label.text = "MISSION: " + str(
				max(
					0,
					ceil(mission_time)
				)
			)

	# 60 seconds reached

	if mission_time <= 0.0:

		mission_time = 0.0

		# WIN only if signal was decoded

		if signal_decoded:

			show_victory()

		else:

			show_game_over()


# =========================================================
# SCORE
# =========================================================

func create_score_display():

	score_label = Label.new()

	score_label.name = "ScoreDisplay"

	# Completely inside right panel

	score_label.position = Vector2(
		850,
		15
	)

	score_label.size = Vector2(
		350,
		60
	)

	score_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	score_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	score_label.text = "SCORE: 0"

	score_label.add_theme_font_size_override(
		"font_size",
		32
	)

	score_label.add_theme_color_override(
		"font_color",
		Color(
			0.80,
			0.95,
			1.0
		)
	)

	score_label.add_theme_color_override(
		"font_shadow_color",
		Color(
			0,
			0,
			0,
			0.9
		)
	)

	score_label.add_theme_constant_override(
		"shadow_offset_x",
		3
	)

	score_label.add_theme_constant_override(
		"shadow_offset_y",
		3
	)

	score_label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	add_child(score_label)


func update_score_display():

	if score_label == null:
		return

	score_label.text = "SCORE: " + str(score)


func add_score(points: int):

	if game_over or mission_won:
		return

	score += points

	update_score_display()

	animate_score()


func animate_score():

	if score_label == null:
		return

	var tween = score_label.create_tween()

	tween.tween_property(
		score_label,
		"scale",
		Vector2(
			1.20,
			1.20
		),
		0.10
	)

	tween.tween_property(
		score_label,
		"scale",
		Vector2(
			1.0,
			1.0
		),
		0.20
	)


# =========================================================
# SIGNAL DECODED
# Called from SignalPanel
# =========================================================

func signal_decode_completed():

	if game_over or mission_won:
		return

	signal_decoded = true


# =========================================================
# SPAWN ALIEN
# =========================================================

func _on_threat_timer_timeout():

	if game_over or mission_won:
		return

	var old_threat = $PerimeterPanel.get_node_or_null(
		"Threat"
	)

	if old_threat != null:
		return

	var new_threat = threat_scene.instantiate()

	new_threat.name = "Threat"

	$PerimeterPanel.add_child(
		new_threat
	)

	new_threat.position = Vector2(
		500,
		randf_range(
			150.0,
			480.0
		)
	)


# =========================================================
# VICTORY
# =========================================================

func show_victory():

	if victory_overlay != null:
		return

	mission_won = true

	$ThreatTimer.stop()

	# Stop threat

	var threat = $PerimeterPanel.get_node_or_null(
		"Threat"
	)

	if threat != null:

		threat.set_process(false)

	# Stop signal panel animation

	var signal_panel = $SignalPanel

	if signal_panel != null:

		signal_panel.set_process(false)

	# =====================================================
	# GREEN SCREEN
	# =====================================================

	victory_overlay = ColorRect.new()

	victory_overlay.name = "VictoryScreen"

	victory_overlay.position = Vector2.ZERO

	victory_overlay.size = Vector2(
		1280,
		720
	)

	victory_overlay.color = Color(
		0.01,
		0.12,
		0.05,
		0.92
	)

	victory_overlay.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	victory_overlay.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	add_child(
		victory_overlay
	)

	# =====================================================
	# GREEN PULSE
	# =====================================================

	var green_flash = ColorRect.new()

	green_flash.position = Vector2.ZERO

	green_flash.size = Vector2(
		1280,
		720
	)

	green_flash.color = Color(
		0.05,
		1.0,
		0.25,
		0.0
	)

	green_flash.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	victory_overlay.add_child(
		green_flash
	)

	var flash_tween = victory_overlay.create_tween()

	flash_tween.set_loops()

	flash_tween.tween_property(
		green_flash,
		"color:a",
		0.22,
		0.55
	)

	flash_tween.tween_property(
		green_flash,
		"color:a",
		0.03,
		0.75
	)

	# =====================================================
	# GREEN SCANNING LIGHT
	# =====================================================

	var scan_light = ColorRect.new()

	scan_light.position = Vector2(
		-300,
		0
	)

	scan_light.size = Vector2(
		220,
		720
	)

	scan_light.color = Color(
		0.1,
		1.0,
		0.4,
		0.12
	)

	scan_light.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	victory_overlay.add_child(
		scan_light
	)

	var scan_tween = victory_overlay.create_tween()

	scan_tween.set_loops()

	scan_tween.tween_property(
		scan_light,
		"position:x",
		1280,
		2.0
	)

	scan_tween.tween_property(
		scan_light,
		"position:x",
		-300,
		0.05
	)

	# =====================================================
	# GREEN PARTICLES
	# =====================================================

	create_victory_particles()

	# =====================================================
	# MAIN TITLE
	# =====================================================

	var title = Label.new()

	title.text = "MISSION COMPLETE"

	title.position = Vector2(
		120,
		180
	)

	title.size = Vector2(
		1040,
		110
	)

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	title.add_theme_font_size_override(
		"font_size",
		70
	)

	title.add_theme_color_override(
		"font_color",
		Color(
			0.80,
			1.0,
			0.85
		)
	)

	title.add_theme_color_override(
		"font_shadow_color",
		Color(
			0,
			0,
			0,
			1
		)
	)

	title.add_theme_constant_override(
		"shadow_offset_x",
		5
	)

	title.add_theme_constant_override(
		"shadow_offset_y",
		5
	)

	title.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	victory_overlay.add_child(
		title
	)

	title.modulate.a = 0.0

	title.scale = Vector2(
		0.65,
		0.65
	)

	var title_tween = victory_overlay.create_tween()

	title_tween.set_parallel(true)

	title_tween.tween_property(
		title,
		"modulate:a",
		1.0,
		0.7
	)

	title_tween.tween_property(
		title,
		"scale",
		Vector2(
			1.10,
			1.10
		),
		0.7
	)

	title_tween.set_parallel(false)

	title_tween.tween_property(
		title,
		"scale",
		Vector2(
			1.0,
			1.0
		),
		0.2
	)

	# =====================================================
	# CONTACT ESTABLISHED
	# =====================================================

	var contact = Label.new()

	contact.text = "CONTACT ESTABLISHED"

	contact.position = Vector2(
		240,
		330
	)

	contact.size = Vector2(
		800,
		70
	)

	contact.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	contact.add_theme_font_size_override(
		"font_size",
		34
	)

	contact.add_theme_color_override(
		"font_color",
		Color(
			0.55,
			1.0,
			0.70
		)
	)

	contact.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	victory_overlay.add_child(
		contact
	)

	contact.modulate.a = 0.0

	var contact_tween = victory_overlay.create_tween()

	contact_tween.tween_interval(
		0.7
	)

	contact_tween.tween_property(
		contact,
		"modulate:a",
		1.0,
		0.7
	)

	# =====================================================
	# UNKNOWN SOURCE
	# =====================================================

	var mystery = Label.new()

	mystery.text = "SIGNAL SOURCE: UNKNOWN"

	mystery.position = Vector2(
		300,
		500
	)

	mystery.size = Vector2(
		680,
		55
	)

	mystery.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	mystery.add_theme_font_size_override(
		"font_size",
		22
	)

	mystery.add_theme_color_override(
		"font_color",
		Color(
			0.75,
			0.90,
			0.80
		)
	)

	mystery.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	victory_overlay.add_child(
		mystery
	)

	mystery.modulate.a = 0.0

	var mystery_tween = victory_overlay.create_tween()

	mystery_tween.tween_interval(
		1.4
	)

	mystery_tween.tween_property(
		mystery,
		"modulate:a",
		1.0,
		0.9
	)

	# =====================================================
	# SUCCESS SOUND
	# =====================================================

	play_victory_sound()

	get_tree().paused = true


# =========================================================
# VICTORY PARTICLES
# =========================================================

func create_victory_particles():

	var particles = Node2D.new()

	particles.name = "VictoryParticles"

	particles.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	victory_overlay.add_child(
		particles
	)

	for i in range(55):

		var particle = ColorRect.new()

		var size = randf_range(
			3.0,
			10.0
		)

		particle.size = Vector2(
			size,
			size
		)

		particle.position = Vector2(
			randf_range(
				50.0,
				1230.0
			),
			randf_range(
				100.0,
				650.0
			)
		)

		particle.color = Color(
			randf_range(
				0.20,
				0.50
			),
			1.0,
			randf_range(
				0.35,
				0.70
			),
			1.0
		)

		particle.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

		particles.add_child(
			particle
		)

		var target = Vector2(
			particle.position.x
			+ randf_range(
				-80.0,
				80.0
			),
			particle.position.y
			- randf_range(
				50.0,
				220.0
			)
		)

		var tween = particles.create_tween()

		tween.set_loops()

		tween.tween_property(
			particle,
			"position",
			target,
			randf_range(
				1.0,
				2.0
			)
		)

		tween.tween_property(
			particle,
			"position",
			particle.position,
			0.05
		)


# =========================================================
# VICTORY SOUND
# =========================================================

func play_victory_sound():

	victory_audio = AudioStreamPlayer.new()

	victory_audio.name = "VictorySound"

	var generator = AudioStreamGenerator.new()

	generator.mix_rate = 22050.0

	generator.buffer_length = 2.0

	victory_audio.stream = generator

	victory_audio.volume_db = 3.0

	victory_audio.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	victory_overlay.add_child(
		victory_audio
	)

	victory_audio.play()

	var playback = (
		victory_audio.get_stream_playback()
		as AudioStreamGeneratorPlayback
	)

	if playback == null:
		return

	var sample_rate = 22050.0

	var duration = 1.6

	var count = min(
		int(sample_rate * duration),
		playback.get_frames_available()
	)

	for i in range(count):

		var t = float(i) / sample_rate

		var progress = (
			t / duration
		)

		# Rising futuristic tone

		var frequency = lerp(
			420.0,
			1100.0,
			progress
		)

		var main_tone = sin(
			t * TAU * frequency
		)

		var harmonic = sin(
			t * TAU * frequency * 2.0
		)

		# Success chime

		var chime = sin(
			t * TAU * 1320.0
		)

		var envelope = 1.0

		if progress < 0.08:

			envelope = progress / 0.08

		else:

			envelope = 1.0 - (
				progress * 0.45
			)

		var sample = (
			main_tone * 0.35
			+ harmonic * 0.12
			+ chime * 0.10
		)

		sample *= envelope

		playback.push_frame(
			Vector2(
				sample,
				sample
			)
		)


# =========================================================
# GAME OVER
# =========================================================

func show_game_over():

	if game_over_overlay != null:
		return

	game_over = true

	$ThreatTimer.stop()

	var threat = $PerimeterPanel.get_node_or_null(
		"Threat"
	)

	if threat != null:

		threat.set_process(false)

	var signal_panel = $SignalPanel

	if signal_panel != null:

		signal_panel.set_process(false)

	game_over_overlay = ColorRect.new()

	game_over_overlay.name = "GameOverScreen"

	game_over_overlay.position = Vector2.ZERO

	game_over_overlay.size = Vector2(
		1280,
		720
	)

	game_over_overlay.color = Color(
		0.08,
		0.0,
		0.0,
		0.92
	)

	game_over_overlay.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	game_over_overlay.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	add_child(
		game_over_overlay
	)

	# Red emergency pulse

	var red_flash = ColorRect.new()

	red_flash.position = Vector2.ZERO

	red_flash.size = Vector2(
		1280,
		720
	)

	red_flash.color = Color(
		1.0,
		0.0,
		0.0,
		0.0
	)

	red_flash.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	game_over_overlay.add_child(
		red_flash
	)

	var red_tween = game_over_overlay.create_tween()

	red_tween.set_loops()

	red_tween.tween_property(
		red_flash,
		"color:a",
		0.40,
		0.25
	)

	red_tween.tween_property(
		red_flash,
		"color:a",
		0.05,
		0.65
	)

	# Dark space

	var dark_tween = game_over_overlay.create_tween()

	dark_tween.tween_property(
		$PerimeterPanel,
		"modulate",
		Color(
			0.08,
			0.08,
			0.10
		),
		1.2
	)

	# Destruction

	create_station_destruction_effect()

	# Alien

	create_alien_signal()

	# Main title

	var title = Label.new()

	title.text = "MISSION FAILED"

	title.position = Vector2(
		150,
		130
	)

	title.size = Vector2(
		980,
		120
	)

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	title.add_theme_font_size_override(
		"font_size",
		78
	)

	title.add_theme_color_override(
		"font_color",
		Color(
			1.0,
			0.86,
			0.86
		)
	)

	title.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	game_over_overlay.add_child(
		title
	)

	title.modulate.a = 0.0

	var title_tween = game_over_overlay.create_tween()

	title_tween.tween_property(
		title,
		"modulate:a",
		1.0,
		0.65
	)

	# Final message

	var subtitle = Label.new()

	subtitle.text = "CONTACT-0 HAS BEEN LOST"

	subtitle.position = Vector2(
		240,
		525
	)

	subtitle.size = Vector2(
		800,
		60
	)

	subtitle.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	subtitle.add_theme_font_size_override(
		"font_size",
		25
	)

	subtitle.add_theme_color_override(
		"font_color",
		Color(
			0.95,
			0.95,
			0.95
		)
	)

	subtitle.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	game_over_overlay.add_child(
		subtitle
	)

	subtitle.modulate.a = 0.0

	var subtitle_tween = game_over_overlay.create_tween()

	subtitle_tween.tween_interval(
		0.8
	)

	subtitle_tween.tween_property(
		subtitle,
		"modulate:a",
		1.0,
		0.8
	)

	play_game_over_sound()

	get_tree().paused = true


# =========================================================
# STATION DESTRUCTION
# =========================================================

func create_station_destruction_effect():

	var destruction = Node2D.new()

	destruction.name = "StationDestruction"

	destruction.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	game_over_overlay.add_child(
		destruction
	)

	for i in range(45):

		var particle = ColorRect.new()

		var size = randf_range(
			4.0,
			14.0
		)

		particle.size = Vector2(
			size,
			size
		)

		particle.position = Vector2(
			randf_range(
				100.0,
				1180.0
			),
			randf_range(
				100.0,
				620.0
			)
		)

		particle.color = Color(
			1.0,
			randf_range(
				0.15,
				0.60
			),
			0.03,
			1.0
		)

		particle.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

		destruction.add_child(
			particle
		)

		var direction = Vector2(
			randf_range(
				-1.0,
				1.0
			),
			randf_range(
				-1.0,
				1.0
			)
		).normalized()

		var distance = randf_range(
			60.0,
			260.0
		)

		var target = (
			particle.position
			+ direction * distance
		)

		var tween = destruction.create_tween()

		tween.set_parallel(true)

		tween.tween_property(
			particle,
			"position",
			target,
			randf_range(
				0.5,
				1.5
			)
		)

		tween.tween_property(
			particle,
			"modulate:a",
			0.0,
			1.2
		)


# =========================================================
# ALIEN SILHOUETTE
# =========================================================

func create_alien_signal():

	var alien_head = Polygon2D.new()

	alien_head.polygon = PackedVector2Array([
		Vector2(540, 270),
		Vector2(575, 245),
		Vector2(635, 235),
		Vector2(695, 245),
		Vector2(730, 270),
		Vector2(720, 335),
		Vector2(690, 365),
		Vector2(580, 365),
		Vector2(550, 335)
	])

	alien_head.color = Color(
		0.01,
		0.015,
		0.02,
		0.98
	)

	game_over_overlay.add_child(
		alien_head
	)

	var left_eye = Polygon2D.new()

	left_eye.polygon = PackedVector2Array([
		Vector2(570, 292),
		Vector2(620, 280),
		Vector2(610, 310),
		Vector2(575, 318)
	])

	left_eye.color = Color(
		1.0,
		0.02,
		0.01,
		1.0
	)

	game_over_overlay.add_child(
		left_eye
	)

	var right_eye = Polygon2D.new()

	right_eye.polygon = PackedVector2Array([
		Vector2(650, 280),
		Vector2(700, 292),
		Vector2(695, 318),
		Vector2(660, 310)
	])

	right_eye.color = Color(
		1.0,
		0.02,
		0.01,
		1.0
	)

	game_over_overlay.add_child(
		right_eye
	)


# =========================================================
# GAME OVER SOUND
# =========================================================

func play_game_over_sound():

	emergency_audio = AudioStreamPlayer.new()

	emergency_audio.name = "EmergencyAlarm"

	var generator = AudioStreamGenerator.new()

	generator.mix_rate = 22050.0
	generator.buffer_length = 1.5

	emergency_audio.stream = generator

	emergency_audio.volume_db = 5.0

	emergency_audio.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	game_over_overlay.add_child(
		emergency_audio
	)

	emergency_audio.play()

	var playback = (
		emergency_audio.get_stream_playback()
		as AudioStreamGeneratorPlayback
	)

	if playback == null:
		return

	var sample_rate = 22050.0
	var duration = 1.4

	var count = min(
		int(sample_rate * duration),
		playback.get_frames_available()
	)

	for i in range(count):

		var t = float(i) / sample_rate

		var siren_frequency = (
			500.0
			+ sin(
				t * TAU * 1.4
			) * 320.0
		)

		var siren = sin(
			t * TAU * siren_frequency
		)

		var rumble = sin(
			t * TAU * 55.0
		)

		var distortion = sin(
			t * TAU * 87.0
		)

		var sample = (
			siren * 0.35
			+ rumble * 0.45
			+ distortion * 0.12
		)

		var envelope = 1.0 - (
			t / duration
		)

		sample *= envelope

		playback.push_frame(
			Vector2(
				sample,
				sample
			)
		)
