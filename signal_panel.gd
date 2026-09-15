extends ColorRect

var target_frequency: float = 60.0
var target_amplitude: float = 50.0
var target_phase: float = 20.0

var decode_time: float = 0.0
var decoding: bool = false

var wave_time: float = 0.0

var signal_audio: AudioStreamPlayer = null
var signal_playback: AudioStreamGeneratorPlayback = null

var control_audio: AudioStreamPlayer = null

var pulse_active: bool = false
var pulse_time: float = 0.0


func _ready():

	$FrequencySlider.value = 50
	$AmplitudeSlider.value = 50
	$PhaseSlider.value = 50

	$DecodeResult.text = "AWAITING SIGNAL..."

	$TransmissionLabel.text = "CONTACT-0 DETECTED\nSOURCE UNKNOWN"

	$TimerLabel.text = "DECODE: READY"

	$Waveform.width = 3.0
	$TargetWaveform.width = 3.0

	$Waveform.default_color = Color("#38BDF8")
	$TargetWaveform.default_color = Color("#FF4B4B")

	if not $FrequencySlider.value_changed.is_connected(
		_on_frequency_changed
	):

		$FrequencySlider.value_changed.connect(
			_on_frequency_changed
		)

	if not $AmplitudeSlider.value_changed.is_connected(
		_on_amplitude_changed
	):

		$AmplitudeSlider.value_changed.connect(
			_on_amplitude_changed
		)

	if not $PhaseSlider.value_changed.is_connected(
		_on_phase_changed
	):

		$PhaseSlider.value_changed.connect(
			_on_phase_changed
		)

	if not $DecodeButton.pressed.is_connected(
		_on_decode_button_pressed
	):

		$DecodeButton.pressed.connect(
			_on_decode_button_pressed
		)

	var main_scene = get_tree().current_scene

	if main_scene != null:

		var pulse_button = main_scene.get_node_or_null(
			"PerimeterPanel/PulseButton"
		)

		if pulse_button != null:

			if not pulse_button.pressed.is_connected(
				_on_pulse_button_pressed
			):

				pulse_button.pressed.connect(
					_on_pulse_button_pressed
				)

	create_signal_audio()
	create_control_audio()

	queue_redraw()


func _process(delta):

	wave_time += delta

	if pulse_active:

		pulse_time += delta

		if pulse_time >= 0.70:

			pulse_active = false
			pulse_time = 0.0

	update_waveforms()

	fill_signal_audio()

	if decoding:

		decode_time -= delta

		$TimerLabel.text = "DECODE: " + str(
			max(
				0,
				ceil(decode_time)
			)
		) + "s"

		if decode_time <= 0.0:

			decode_time = 0.0

			decoding = false

			$TimerLabel.text = "DECODE: COMPLETE"

			$DecodeResult.text = "SIGNAL DECODED"

			$TransmissionLabel.text = get_mystery_message()

			var main_scene = get_tree().current_scene

			if main_scene != null:

				if main_scene.has_method("add_score"):

					main_scene.add_score(250)

				if main_scene.has_method(
					"signal_decode_completed"
				):

					main_scene.signal_decode_completed()

			play_decode_success_sound()

	queue_redraw()


# =========================================================
# FREQUENCY
# =========================================================

func _on_frequency_changed(value):

	if decoding:
		return

	play_parameter_beep(
		250.0 + value * 6.0
	)

	update_signal_status()


# =========================================================
# AMPLITUDE
# =========================================================

func _on_amplitude_changed(value):

	if decoding:
		return

	play_parameter_beep(
		400.0 + value * 5.0
	)

	update_signal_status()


# =========================================================
# PHASE
# =========================================================

func _on_phase_changed(value):

	if decoding:
		return

	play_parameter_beep(
		550.0 + value * 4.0
	)

	update_signal_status()


# =========================================================
# SIGNAL STATUS
# =========================================================

func update_signal_status():

	var difference = 0.0

	difference += abs(
		$FrequencySlider.value
		- target_frequency
	)

	difference += abs(
		$AmplitudeSlider.value
		- target_amplitude
	)

	difference += abs(
		$PhaseSlider.value
		- target_phase
	)

	if difference < 15.0:

		$DecodeResult.text = "SIGNAL LOCK ACQUIRED"

	elif difference < 35.0:

		$DecodeResult.text = "SIGNAL PARTIALLY ALIGNED"

	else:

		$DecodeResult.text = "SIGNAL MISALIGNED"


# =========================================================
# DECODE
# =========================================================

func _on_decode_button_pressed():

	if decoding:
		return

	decoding = true

	decode_time = 10.0

	$DecodeResult.text = "DECODING CONTACT-0..."

	$TransmissionLabel.text = (
		"ANALYZING UNKNOWN FREQUENCY..."
	)

	$TimerLabel.text = "DECODE: 10s"

	play_decode_start_sound()


# =========================================================
# PULSE
# =========================================================

func _on_pulse_button_pressed():

	if pulse_active:
		return

	pulse_active = true
	pulse_time = 0.0

	play_pulse_control_sound()

	var main_scene = get_tree().current_scene

	if main_scene == null:
		return

	var perimeter = main_scene.get_node_or_null(
		"PerimeterPanel"
	)

	if perimeter == null:
		return

	var threat = perimeter.get_node_or_null(
		"Threat"
	)

	if threat == null:
		return

	if threat.has_method(
		"destroy_by_pulse"
	):

		threat.destroy_by_pulse()


# =========================================================
# WAVEFORMS
# =========================================================

func update_waveforms():

	var waveform = $Waveform
	var target_waveform = $TargetWaveform

	waveform.clear_points()
	target_waveform.clear_points()

	var frequency = $FrequencySlider.value
	var amplitude = $AmplitudeSlider.value
	var phase = $PhaseSlider.value

	var width = 500.0
	var center_y = 385.0

	var player_amplitude = (
		amplitude / 100.0
	) * 65.0

	var target_amp = (
		target_amplitude / 100.0
	) * 65.0

	var player_frequency = (
		0.04
		+ frequency / 100.0 * 0.12
	)

	var target_frequency_visual = (
		0.04
		+ target_frequency / 100.0 * 0.12
	)

	for i in range(101):

		var x = (
			float(i) / 100.0
		) * width

		var player_wave = sin(
			x * player_frequency
			+ phase * 0.08
			+ wave_time * 3.0
		)

		var target_wave = sin(
			x * target_frequency_visual
			+ target_phase * 0.08
			+ wave_time * 3.0
		)

		var player_y = (
			center_y
			+ player_wave * player_amplitude
		)

		var target_y = (
			center_y
			+ target_wave * target_amp
		)

		waveform.add_point(
			Vector2(
				55.0 + x,
				player_y
			)
		)

		target_waveform.add_point(
			Vector2(
				55.0 + x,
				target_y
			)
		)


# =========================================================
# MYSTERY MESSAGE
# =========================================================

func get_mystery_message():

	var difference = 0.0

	difference += abs(
		$FrequencySlider.value
		- target_frequency
	)

	difference += abs(
		$AmplitudeSlider.value
		- target_amplitude
	)

	difference += abs(
		$PhaseSlider.value
		- target_phase
	)

	if difference < 10.0:

		return (
			"CONTACT-0 DETECTED\n"
			+ "SIGNAL PATTERN: ARTIFICIAL"
		)

	if difference < 25.0:

		return (
			"WARNING\n"
			+ "SIGNAL ORIGIN CANNOT BE LOCATED"
		)

	return (
		"CONTACT-0\n"
		+ "POSSIBLE EXTRATERRESTRIAL SOURCE"
	)


# =========================================================
# CONTINUOUS SIGNAL AUDIO
# =========================================================

func create_signal_audio():

	signal_audio = AudioStreamPlayer.new()

	signal_audio.name = "IncomingSignal"

	var generator = AudioStreamGenerator.new()

	generator.mix_rate = 22050.0
	generator.buffer_length = 0.6

	signal_audio.stream = generator

	signal_audio.volume_db = -5.0

	add_child(signal_audio)

	signal_audio.play()

	signal_playback = (
		signal_audio.get_stream_playback()
		as AudioStreamGeneratorPlayback
	)


func fill_signal_audio():

	if signal_playback == null:
		return

	var available = (
		signal_playback.get_frames_available()
	)

	var count = min(
		available,
		700
	)

	var frequency = (
		180.0
		+ $FrequencySlider.value * 3.0
	)

	var amplitude = (
		0.10
		+ $AmplitudeSlider.value
		/ 100.0 * 0.10
	)

	for i in range(count):

		var t = (
			wave_time
			+ float(i) / 22050.0
		)

		var carrier = sin(
			t * TAU * frequency
		)

		var harmonic = sin(
			t * TAU * frequency * 2.0
		)

		var pulse = sin(
			t * TAU * 5.0
		)

		var sample = (
			carrier * amplitude
			+ harmonic * amplitude * 0.30
			+ pulse * 0.025
		)

		signal_playback.push_frame(
			Vector2(
				sample,
				sample
			)
		)


# =========================================================
# CONTROL BEEP
# =========================================================

func create_control_audio():

	control_audio = AudioStreamPlayer.new()

	control_audio.name = "ControlBeep"

	var generator = AudioStreamGenerator.new()

	generator.mix_rate = 22050.0
	generator.buffer_length = 0.25

	control_audio.stream = generator

	control_audio.volume_db = 2.0

	add_child(control_audio)


func play_parameter_beep(
	frequency: float
):

	if control_audio == null:
		return

	control_audio.stop()
	control_audio.play()

	var playback = (
		control_audio.get_stream_playback()
		as AudioStreamGeneratorPlayback
	)

	if playback == null:
		return

	var sample_rate = 22050.0

	var duration = 0.10

	var count = min(
		int(
			sample_rate * duration
		),
		playback.get_frames_available()
	)

	for i in range(count):

		var t = float(i) / sample_rate

		var envelope = (
			1.0
			- t / duration
		)

		var sample = sin(
			t * TAU * frequency
		)

		sample *= envelope
		sample *= 0.35

		playback.push_frame(
			Vector2(
				sample,
				sample
			)
		)


func play_decode_start_sound():

	play_parameter_beep(800.0)

	await get_tree().create_timer(
		0.10
	).timeout

	play_parameter_beep(1100.0)


func play_decode_success_sound():

	play_parameter_beep(700.0)

	await get_tree().create_timer(
		0.10
	).timeout

	play_parameter_beep(1000.0)

	await get_tree().create_timer(
		0.10
	).timeout

	play_parameter_beep(1400.0)


func play_pulse_control_sound():

	play_parameter_beep(300.0)

	await get_tree().create_timer(
		0.07
	).timeout

	play_parameter_beep(600.0)

	await get_tree().create_timer(
		0.07
	).timeout

	play_parameter_beep(1100.0)


# =========================================================
# DRAW
# =========================================================

func _draw():

	draw_rect(
		Rect2(
			20.0,
			15.0,
			600.0,
			615.0
		),
		Color("#102238"),
		false,
		2.0
	)

	for x in range(
		40,
		600,
		40
	):

		draw_line(
			Vector2(x, 350),
			Vector2(x, 430),
			Color(
				0.15,
				0.35,
				0.50,
				0.18
			),
			1.0
		)

	for y in range(
		350,
		431,
		20
	):

		draw_line(
			Vector2(40, y),
			Vector2(600, y),
			Color(
				0.15,
				0.35,
				0.50,
				0.18
			),
			1.0
		)

	draw_line(
		Vector2(40, 385),
		Vector2(600, 385),
		Color(
			0.3,
			0.6,
			0.8,
			0.25
		),
		1.0
	)

	draw_astronaut()


# =========================================================
# ASTRONAUT
# =========================================================

func draw_astronaut():

	var breathing = (
		sin(
			wave_time * 1.5
		) * 2.0
	)

	# Astronaut positioned toward
	# the right side of SignalPanel

	var base = Vector2(
		505.0,
		570.0 + breathing
	)

	# =====================================================
	# LEFT HAND ANIMATION
	# =====================================================

	var signal_motion_x = (
		sin(
			wave_time * 3.2
		) * 24.0
	)

	var signal_motion_y = (
		cos(
			wave_time * 4.0
		) * 13.0
	)

	# =====================================================
	# RIGHT HAND ANIMATION
	# =====================================================

	var defense_motion_x = (
		cos(
			wave_time * 2.7
		) * 18.0
	)

	var defense_motion_y = (
		sin(
			wave_time * 3.5
		) * 10.0
	)

	# =====================================================
	# PULSE ATTACK MOTION
	# =====================================================

	var attack_motion = 0.0

	if pulse_active:

		var progress = min(
			pulse_time / 0.70,
			1.0
		)

		attack_motion = (
			sin(
				progress * PI
			) * 90.0
		)

	# =====================================================
	# HELMET
	# =====================================================

	draw_circle(
		base + Vector2(
			0.0,
			-145.0
		),
		52.0,
		Color("#D5DCE2")
	)

	draw_circle(
		base + Vector2(
			0.0,
			-145.0
		),
		43.0,
		Color("#87949F")
	)

	# Visor

	draw_circle(
		base + Vector2(
			0.0,
			-145.0
		),
		37.0,
		Color("#10283A")
	)

	# Visor reflection

	draw_arc(
		base + Vector2(
			-8.0,
			-153.0
		),
		27.0,
		3.6,
		5.3,
		24,
		Color("#70BCE2"),
		3.0
	)

	# =====================================================
	# BODY
	# =====================================================

	draw_rect(
		Rect2(
			base.x - 48.0,
			base.y - 105.0,
			96.0,
			120.0
		),
		Color("#D5DCE2")
	)

	# Chest panel

	draw_rect(
		Rect2(
			base.x - 30.0,
			base.y - 82.0,
			60.0,
			45.0
		),
		Color("#263946")
	)

	draw_rect(
		Rect2(
			base.x - 20.0,
			base.y - 73.0,
			40.0,
			20.0
		),
		Color("#07131D")
	)

	# Life support

	draw_rect(
		Rect2(
			base.x - 66.0,
			base.y - 90.0,
			18.0,
			70.0
		),
		Color("#56636E")
	)

	draw_rect(
		Rect2(
			base.x + 48.0,
			base.y - 90.0,
			18.0,
			70.0
		),
		Color("#56636E")
	)

	# Shoulders

	draw_circle(
		base + Vector2(
			-51.0,
			-85.0
		),
		22.0,
		Color("#BBC5CC")
	)

	draw_circle(
		base + Vector2(
			51.0,
			-85.0
		),
		22.0,
		Color("#BBC5CC")
	)

	# =====================================================
	# LEFT ARM — SIGNAL CONTROL
	# =====================================================

	var signal_hand = base + Vector2(
		-105.0 + signal_motion_x,
		-35.0 + signal_motion_y
	)

	draw_line(
		base + Vector2(
			-48.0,
			-78.0
		),
		signal_hand,
		Color("#D5DCE2"),
		18.0
	)

	draw_circle(
		signal_hand,
		13.0,
		Color("#F3F5F7")
	)

	# Moving finger

	var finger_pos = signal_hand + Vector2(
		10.0,
		-4.0
		+ sin(
			wave_time * 5.0
		) * 4.0
	)

	draw_line(
		signal_hand,
		finger_pos,
		Color("#FFFFFF"),
		5.0
	)

	# =====================================================
	# RIGHT ARM — DEFENSE
	# =====================================================

	var pulse_hand = base + Vector2(
		105.0
		+ defense_motion_x
		+ attack_motion,
		-42.0
		+ defense_motion_y
	)

	draw_line(
		base + Vector2(
			48.0,
			-78.0
		),
		pulse_hand,
		Color("#D5DCE2"),
		18.0
	)

	draw_circle(
		pulse_hand,
		13.0,
		Color("#F3F5F7")
	)

	# =====================================================
	# PULSE ENERGY
	# =====================================================

	if pulse_active:

		var energy_alpha = (
			1.0
			- pulse_time / 0.70
		)

		var energy_radius = (
			20.0
			+ pulse_time * 130.0
		)

		draw_circle(
			pulse_hand,
			energy_radius,
			Color(
				0.20,
				0.80,
				1.0,
				energy_alpha * 0.25
			)
		)

		draw_arc(
			pulse_hand,
			energy_radius,
			0.0,
			TAU,
			40,
			Color(
				0.30,
				0.90,
				1.0,
				energy_alpha
			),
			4.0
		)

	# =====================================================
	# TERMINAL
	# =====================================================

	draw_rect(
		Rect2(
			base.x - 120.0,
			base.y - 22.0,
			240.0,
			65.0
		),
		Color("#182C3C")
	)

	draw_rect(
		Rect2(
			base.x - 98.0,
			base.y - 12.0,
			196.0,
			40.0
		),
		Color("#06111B"),
		false,
		2.0
	)

	# Terminal signal

	var previous = Vector2(
		base.x - 88.0,
		base.y + 8.0
	)

	for i in range(1, 28):

		var tx = (
			base.x
			- 88.0
			+ i * 6.5
		)

		var ty = (
			base.y
			+ 8.0
			+ sin(
				wave_time * 5.0
				+ i * 0.8
			) * 9.0
		)

		var current = Vector2(
			tx,
			ty
		)

		draw_line(
			previous,
			current,
			Color("#45D7FF"),
			2.0
		)

		previous = current

	# =====================================================
	# HAND GLOW
	# =====================================================

	draw_circle(
		signal_hand,
		18.0,
		Color(
			0.20,
			0.75,
			1.0,
			0.08
		)
	)

	draw_circle(
		pulse_hand,
		18.0,
		Color(
			0.30,
			0.85,
			1.0,
			0.08
		)
	)

	# =====================================================
	# LEGS
	# =====================================================

	draw_rect(
		Rect2(
			base.x - 38.0,
			base.y + 10.0,
			28.0,
			60.0
		),
		Color("#AEB8BF")
	)

	draw_rect(
		Rect2(
			base.x + 10.0,
			base.y + 10.0,
			28.0,
			60.0
		),
		Color("#AEB8BF")
	)
