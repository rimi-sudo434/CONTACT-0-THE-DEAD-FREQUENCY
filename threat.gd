extends ColorRect

var speed: float = 80.0
var integrity: float = 100.0

var start_y: float
var move_time: float = 0.0

var destroying: bool = false


func _ready():

	color = Color(
		0,
		0,
		0,
		0
	)

	start_y = position.y

	queue_redraw()


func _process(delta):

	if destroying:
		return

	var main_scene = get_tree().current_scene

	if main_scene != null:

		if main_scene.get("game_over") == true:
			return


	move_time += delta

	position.x -= (
		speed * delta
	)


	position.y = (
		start_y
		+ sin(
			move_time * 2.5
		) * 45.0
	)


	rotation = (
		sin(
			move_time * 2.5
		) * 0.08
	)


	# -------------------------------------------------------
	# HIT STATION
	# -------------------------------------------------------

	if position.x < -80:

		integrity -= 10.0

		var integrity_label = (
			get_parent().get_node_or_null(
				"IntegrityLabel"
			)
		)


		if integrity_label != null:

			integrity_label.text = (
				"STATION INTEGRITY: "
				+ str(
					max(
						0,
						integrity
					)
				)
				+ "%"
			)


		if integrity <= 0:

			integrity = 0


			if integrity_label != null:

				integrity_label.text = (
					"STATION INTEGRITY: 0%"
				)


			var main = get_tree().current_scene

			if main != null:

				if main.has_method(
					"show_game_over"
				):

					main.show_game_over()

			return


		position.x = 500

		start_y = randf_range(
			120.0,
			480.0
		)

		move_time = 0.0


	queue_redraw()


# =========================================================
# DESTROY BY PULSE
# =========================================================

func destroy_by_pulse():

	if destroying:
		return

	destroying = true

	set_process(false)


	# SCORE

	var main_scene = get_tree().current_scene

	if main_scene != null:

		if main_scene.has_method(
			"add_score"
		):

			main_scene.add_score(100)


	# BIG BLAST

	create_blast_effect()

	play_blast_sound()


	# HIDE NORMAL SHIP

	modulate = Color(
		1.0,
		0.35,
		0.20,
		1.0
	)


	# BIG EXPANSION

	pivot_offset = Vector2(
		0,
		0
	)

	var tween = create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		self,
		"scale",
		Vector2(
			2.3,
			2.3
		),
		0.25
	)

	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		0.32
	)

	tween.set_parallel(false)

	tween.tween_callback(
		queue_free
	)


# =========================================================
# FIRE / BLAST EFFECT
# =========================================================

func create_blast_effect():

	var blast = Node2D.new()

	blast.name = "BlastEffect"

	get_parent().add_child(
		blast
	)

	blast.position = position

	blast.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)


	# FIRE PARTICLES

	for i in range(28):

		var particle = ColorRect.new()

		particle.position = Vector2(
			0,
			0
		)

		var size = randf_range(
			5.0,
			14.0
		)

		particle.size = Vector2(
			size,
			size
		)

		particle.color = Color(
			1.0,
			randf_range(
				0.10,
				0.55
			),
			0.02,
			1.0
		)

		particle.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

		blast.add_child(
			particle
		)


		var angle = randf_range(
			0.0,
			TAU
		)

		var distance = randf_range(
			50.0,
			150.0
		)

		var target = Vector2(
			cos(angle),
			sin(angle)
		) * distance


		var particle_tween = blast.create_tween()

		particle_tween.set_parallel(true)

		particle_tween.tween_property(
			particle,
			"position",
			target,
			randf_range(
				0.25,
				0.50
			)
		)

		particle_tween.tween_property(
			particle,
			"modulate:a",
			0.0,
			0.45
		)

		particle_tween.tween_property(
			particle,
			"size",
			Vector2(
				1,
				1
			),
			0.45
		)


	# CENTRAL FLASH

	var flash = ColorRect.new()

	flash.position = Vector2(
		-35,
		-35
	)

	flash.size = Vector2(
		70,
		70
	)

	flash.color = Color(
		1.0,
		0.85,
		0.35,
		0.95
	)

	flash.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	blast.add_child(
		flash
	)


	var flash_tween = blast.create_tween()

	flash_tween.set_parallel(true)

	flash_tween.tween_property(
		flash,
		"scale",
		Vector2(
			3.5,
			3.5
		),
		0.30
	)

	flash_tween.tween_property(
		flash,
		"modulate:a",
		0.0,
		0.30
	)


	# REMOVE EFFECT

	var cleanup = blast.create_tween()

	cleanup.tween_interval(
		0.65
	)

	cleanup.tween_callback(
		blast.queue_free
	)


# =========================================================
# LOUD BLAST SOUND
# =========================================================

func play_blast_sound():

	var audio = AudioStreamPlayer.new()

	audio.name = "AlienBlast"

	var generator = AudioStreamGenerator.new()

	generator.mix_rate = 22050.0
	generator.buffer_length = 0.8

	audio.stream = generator

	audio.volume_db = 10.0

	audio.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	get_tree().current_scene.add_child(
		audio
	)

	audio.play()


	var playback = (
		audio.get_stream_playback()
		as AudioStreamGeneratorPlayback
	)

	if playback == null:
		return


	var sample_rate = 22050.0
	var duration = 0.55

	var sample_count = int(
		sample_rate * duration
	)

	var available = playback.get_frames_available()

	var count = min(
		sample_count,
		available
	)


	for i in range(count):

		var t = float(i) / sample_rate

		var progress = (
			t / duration
		)


		# FALLING HIGH TONE

		var frequency = lerp(
			1200.0,
			55.0,
			progress
		)

		var high = sin(
			t * TAU * frequency
		)


		# DEEP IMPACT

		var bass = sin(
			t * TAU * 65.0
		)


		# DISTORTION

		var distortion = sin(
			t * TAU * 91.0
		)


		var envelope = (
			1.0 - progress
		)


		var blast_sample = (
			high * 0.65
			+ bass * 0.75
			+ distortion * 0.35
		)


		blast_sample *= envelope
		blast_sample *= 0.75


		playback.push_frame(
			Vector2(
				blast_sample,
				blast_sample
			)
		)


# =========================================================
# ALIEN SHIP DRAW
# =========================================================

func _draw():

	var pos = Vector2.ZERO


	var hull = PackedVector2Array([
		pos + Vector2(-58, 5),
		pos + Vector2(-40, -10),
		pos + Vector2(-18, -22),
		pos + Vector2(20, -20),
		pos + Vector2(48, -8),
		pos + Vector2(62, 5),
		pos + Vector2(42, 17),
		pos + Vector2(8, 24),
		pos + Vector2(-30, 20)
	])


	draw_colored_polygon(
		hull,
		Color("#4B5863")
	)


	var lower_hull = PackedVector2Array([
		pos + Vector2(-40, 13),
		pos + Vector2(-20, 28),
		pos + Vector2(25, 27),
		pos + Vector2(45, 12)
	])


	draw_colored_polygon(
		lower_hull,
		Color("#202A32")
	)


	# CORE

	draw_circle(
		pos + Vector2(
			0,
			-12
		),
		18,
		Color("#294A5E")
	)


	draw_circle(
		pos + Vector2(
			-5,
			-17
		),
		5,
		Color("#6E9EB9")
	)


	# LEFT WING

	var left_wing = PackedVector2Array([
		pos + Vector2(-25, 2),
		pos + Vector2(-78, 28),
		pos + Vector2(-35, 18)
	])


	draw_colored_polygon(
		left_wing,
		Color("#35434D")
	)


	# RIGHT WING

	var right_wing = PackedVector2Array([
		pos + Vector2(25, 2),
		pos + Vector2(78, 28),
		pos + Vector2(35, 18)
	])


	draw_colored_polygon(
		right_wing,
		Color("#35434D")
	)


	# ENGINE FIRE

	draw_circle(
		pos + Vector2(
			-55,
			7
		),
		8,
		Color("#D9473E")
	)


	draw_circle(
		pos + Vector2(
			-66,
			7
		),
		4,
		Color("#FFB2A5")
	)


	# LIGHTS

	draw_circle(
		pos + Vector2(
			40,
			2
		),
		3,
		Color("#D9EEFF")
	)


	draw_circle(
		pos + Vector2(
			-35,
			13
		),
		3,
		Color("#D9EEFF")
	)


	draw_polyline(
		hull,
		Color("#91A0AA"),
		2
	)
