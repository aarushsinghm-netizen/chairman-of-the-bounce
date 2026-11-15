extends SceneTree

var failures = 0

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)
	else:
		print("PASS: ", description)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	game.muted = true
	game.persist_scores = false
	game.start_game()
	check(game.is_upright(TAU + 0.2), "upright detection wraps full rotations")
	check(not game.is_upright(PI), "upside-down chair is rejected")
	game.charge = 0.45
	game.launch()
	check(game.airborne and game.velocity.y < 0, "charged chair launches upward")
	var before = game.tokens
	game.rescue()
	check(game.tokens == before - 1 and game.used_rescue and game.spin == 0, "rescue consumes token and stabilizes chair")
	game.rescue()
	check(game.tokens == before - 1, "second rescue in one throw is blocked")
	var old_lives = game.lives
	game.resolve_landing(false)
	check(game.lives == old_lives - 1 and game.tokens == before, "failed throw costs confidence but earns rescue")
	game.start_game()
	game.toggle_pause()
	var old_position = game.chair_pos
	game._physics_process(0.5)
	check(game.chair_pos == old_position and not game.airborne, "pause freezes the simulation")
	game.toggle_pause()
	# Search actual trajectories with a short A-key brake, just as a player can.
	for stage in range(5):
		var found = false
		for brake_ticks in [0, 12, 24, 36, 48, 60]:
			if found:
				break
			for power in range(1, 101):
				game.start_game()
				game.landed = stage
				game.reset_throw()
				game.charge = power / 100.0
				game.launch()
				for tick in range(600):
					game.left_held = tick < brake_ticks
					game._physics_process(1.0 / 120.0)
					if not game.airborne:
						break
				if game.landed > stage:
					found = true
					print("Stage ", stage + 1, " reachable: charge ", power, "%, brake ", brake_ticks / 120.0, "s")
					break
		check(found, "round %d has a reachable upright landing" % (stage + 1))
	game.left_held = false
	game.start_game()
	game.airborne = true
	game.chair_pos = game.duck_position()
	game._physics_process(0.0001)
	check(game.duck_taken and game.score == 50 and game.tokens == 3, "duck collectible awards score and a token")
	game.start_game()
	game.airborne = true
	game.chair_pos = game.coffee_position()
	game._physics_process(0.0001)
	check(game.coffee_hit and game.sticky > 0, "coffee hazard affects steering")
	game.landed = 4
	game.travelled = TAU * 2
	game.resolve_landing(true)
	game._physics_process(2.0)
	check(game.mode == "end" and game.landed == 5 and game.end_panel.visible, "fifth landing finishes the game")
	game.start_game()
	game.lives = 1
	game.resolve_landing(false)
	game._physics_process(2.0)
	check(game.mode == "end" and game.lives == 0, "zero confidence finishes the game")
	game.queue_free()
	await process_frame
	print("Physics checks complete. Failures: ", failures)
	quit(0 if failures == 0 else 1)
