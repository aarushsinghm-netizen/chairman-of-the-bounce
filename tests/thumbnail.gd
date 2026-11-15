extends SceneTree

class Cover extends Node2D:
 var font: Font
 var chair: Texture2D
 func _ready():
  font = load("res://assets/font/PatrickHand-Regular.ttf")
  var img = Image.new()
  img.load_svg_from_string(FileAccess.get_file_as_string("res://assets/openmoji/chair.svg"), 12.0)
  chair = ImageTexture.create_from_image(img)
 func centered(words: String, y: float, size: int):
  var width = font.get_string_size(words,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
  draw_string(font,Vector2((1024-width)/2,y),words,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color("292b38"))
 func _draw():
  draw_rect(Rect2(0,0,1024,1024),Color("f5e8af"))
  centered("CHAIRMAN",166,144)
  centered("OF THE BOUNCE",272,98)
  draw_set_transform(Vector2(512,638),-0.23)
  draw_texture_rect(chair,Rect2(-340,-340,680,680),false)
  draw_set_transform(Vector2.ZERO)

func _initialize():
 call_deferred("make_cover")
func make_cover():
 var viewport = SubViewport.new()
 viewport.size = Vector2i(1024,1024)
 viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
 root.add_child(viewport)
 var cover = Cover.new()
 viewport.add_child(cover)
 await process_frame
 await RenderingServer.frame_post_draw
 viewport.get_texture().get_image().save_png("res://docs/Chairman - Thumbnail.png")
 quit()
