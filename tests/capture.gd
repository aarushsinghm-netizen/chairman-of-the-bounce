extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func save_frame(game: Node, name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	game.get_viewport().get_texture().get_image().save_png("res://docs/" + name + ".png")

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	game.muted = true
	game.persist_scores = false
	game.best = 0
	await save_frame(game, "Chairman - Menu")
	game.start_game()
	game.charge = 0.4
	game.launch()
	for frame in range(40):
		game._physics_process(1.0 / 60)
	await save_frame(game, "Chairman - Gameplay")
	game.show_credits()
	await save_frame(game, "Chairman - Credits")
	game.close_credits()
	game.landed = 5
	game.finish_game()
	await save_frame(game, "Chairman - Ending")
	quit()
