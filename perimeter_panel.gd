extends ColorRect

var space_time: float = 0.0

var stars = []
var asteroids = []


func _ready():

	randomize()

	# Stars

	for i in range(100):

		stars.append({
			"position": Vector2(
				randf_range(0, 640),
				randf_range(0, 650)
			),
			"size": randf_range(1.0, 2.5),
			"speed": randf_range(5.0, 25.0)
		})


	# Asteroids

	for i in range(10):

		asteroids.append({
			"position": Vector2(
				randf_range(0, 640),
				randf_range(80, 560)
			),
			"size": randf_range(8.0, 20.0),
			"speed": randf_range(15.0, 40.0),
			"rotation": randf_range(0.0, TAU)
		})

	queue_redraw()


func _process(delta):

	space_time += delta


	# Stars movement

	for star in stars:

		star["position"].x -= (
			star["speed"] * delta
		)

		if star["position"].x < 0:

			star["position"].x = 640


	# Asteroid movement

	for asteroid in asteroids:

		asteroid["position"].x -= (
			asteroid["speed"] * delta
		)

		asteroid["rotation"] += (
			delta * 0.4
		)


		if asteroid["position"].x < -30:

			asteroid["position"].x = 670

			asteroid["position"].y = (
				randf_range(80, 560)
			)

	queue_redraw()


func _draw():

	# Deep space

	draw_rect(
		Rect2(0, 0, 640, 650),
		Color("#01040A")
	)


	# Stars

	for star in stars:

		draw_circle(
			star["position"],
			star["size"],
			Color("#BBD7F2")
		)


	# Distant planet

	var planet = Vector2(530, 120)

	draw_circle(
		planet,
		75,
		Color("#142B45")
	)

	draw_circle(
		planet,
		67,
		Color("#204664")
	)

	draw_arc(
		planet,
		80,
		0,
		TAU,
		64,
		Color("#5B9AC5"),
		2
	)


	# Asteroids

	for asteroid in asteroids:

		var p = asteroid["position"]
		var r = asteroid["size"]

		var points = PackedVector2Array()

		for i in range(7):

			var angle = (
				asteroid["rotation"]
				+ (TAU / 7.0) * i
			)

			points.append(
				p
				+ Vector2(
					cos(angle),
					sin(angle)
				) * r
			)


		draw_colored_polygon(
			points,
			Color("#303944")
		)

		draw_polyline(
			points,
			Color("#66717E"),
			1.5
		)


	# Observation window

	draw_rect(
		Rect2(15, 75, 610, 500),
		Color("#17334A"),
		false,
		3
	)
