extends ColorRect

var stars = []
var asteroids = []

func _ready():
	randomize()

	# Generate stars
	for i in range(180):
		stars.append({
			"pos": Vector2(
				randf_range(0, 1280),
				randf_range(0, 720)
			),
			"size": randf_range(1.0, 2.5),
			"brightness": randf_range(0.4, 1.0)
		})

	# Generate asteroids
	for i in range(12):
		asteroids.append({
			"pos": Vector2(
				randf_range(0, 1280),
				randf_range(0, 720)
			),
			"size": randf_range(8, 25),
			"rotation": randf_range(0, TAU)
		})

	queue_redraw()


func _draw():
	# Deep space background
	draw_rect(
		Rect2(0, 0, size.x, size.y),
		Color("#02050C")
	)

	# Stars
	for star in stars:
		var brightness = star["brightness"]
		var star_color = Color(
			0.6,
			0.8,
			1.0,
			brightness
		)

		draw_circle(
			star["pos"],
			star["size"],
			star_color
		)

	# Asteroids
	for asteroid in asteroids:
		var pos = asteroid["pos"]
		var asteroid_size = asteroid["size"]

		var points = PackedVector2Array()

		for j in range(7):
			var angle = (TAU / 7.0) * j
			var radius = asteroid_size * randf_range(0.75, 1.15)

			points.append(
				pos + Vector2(
					cos(angle),
					sin(angle)
				) * radius
			)

		draw_colored_polygon(
			points,
			Color("#252C38")
		)
