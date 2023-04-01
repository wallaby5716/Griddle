extends Node2D

onready var map_texture = $MapTexture

var PANNING = false
var pan_offset = Vector2.ZERO
var DRAGGING_GRID = false
var grid_drag_offset = Vector2.ZERO

var map_filename = ""

func _ready():
    get_tree().connect("files_dropped", self, "_on_files_dropped")
    #print(OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + "/")
    #OS.shell_open(str("file://", OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)))

func _process(delta):
    if PANNING:
        var diff = map_texture.get_local_mouse_position() - pan_offset
        $Camera2D.position += -1 * diff
    if DRAGGING_GRID:
        map_texture.grid_offset = map_texture.get_local_mouse_position() - grid_drag_offset
        map_texture.redraw()

func _unhandled_input(event):
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_WHEEL_UP:
            zoom_in()
        elif event.button_index == BUTTON_WHEEL_DOWN:
            zoom_out()
        elif event.button_index == BUTTON_MIDDLE:
            if event.pressed:
                start_pan()
            else:
                stop_pan()
        elif event.button_index == BUTTON_LEFT:
            if event.pressed:
                print("hi")
                DRAGGING_GRID = true
                grid_drag_offset = map_texture.get_local_mouse_position() - map_texture.grid_offset
            else:
                DRAGGING_GRID = false
                grid_drag_offset = Vector2.ZERO

func zoom_in():
    $Camera2D.zoom *= 0.95

func zoom_out():
    $Camera2D.zoom *= 1.05

func start_pan():
    PANNING = true
    pan_offset = map_texture.get_local_mouse_position()

func stop_pan():
    PANNING = false
    pan_offset = Vector2.ZERO

func load_image(path):
    if path.get_extension() in ["jpg", "jpeg", "png", "tga", "bmp", "svg", "svgz", "webp"]:
        map_filename = path.get_file().get_basename()
        var tex = ImageTexture.new() # creating a new imagetexture node
        var image = Image.new() # creating new image node
        print(image.load(path))
        tex.create_from_image(image,0)
        map_texture.set_texture(tex)
        map_texture.grid_rows = int(map_texture.texture.get_size().y / map_texture.grid_cell_size)
        map_texture.grid_cols = int(map_texture.texture.get_size().x / map_texture.grid_cell_size)
        $ControlPanel/PanelBackground/LabelRows/ValueRows.text = str(map_texture.grid_rows)
        $ControlPanel/PanelBackground/LabelCols/ValueCols.text = str(map_texture.grid_cols)
        map_texture.position = Vector2.ZERO - (map_texture.texture.get_size() / 2) #(get_viewport_rect().size / 2) - (map_texture.texture.get_size() / 2)
        $Camera2D.zoom = Vector2.ONE
        prints(map_texture.grid_cols, map_texture.grid_rows)
        map_texture.update()

func _on_files_dropped(files, screen):
    load_image(files[0])

func _on_ButtonSaveMap():
    if map_texture.texture != null:
        $ControlPanel/DialogSaveMap.hide()
#        var viewport_container = ViewportContainer.new()
#        viewport_container.rect_size = map_texture.texture.get_size()
        var render_viewport = Viewport.new()
        $Camera2D.current = false
        render_viewport.size = map_texture.texture.get_size()
        render_viewport.render_target_update_mode = Viewport.UPDATE_ONCE
        render_viewport.set_vflip(true)
        map_texture.why_dont_node_paths_work_like_it_says = false
        remove_child(map_texture)
        render_viewport.add_child(map_texture)
        var reset_pos = map_texture.position
        map_texture.position = Vector2.ZERO
        add_child(render_viewport)
        yield(get_tree(), "idle_frame")
        yield(get_tree(), "idle_frame")


        var img = render_viewport.get_texture().get_data()
        img.save_png(OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + "/" + $ControlPanel/DialogSaveMap/LabelFilename/ValueFilename.text.strip_edges() + ".png")
        OS.shell_open(str("file://", OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)))
        render_viewport.remove_child(map_texture)
        add_child(map_texture)
        map_texture.why_dont_node_paths_work_like_it_says = true
        map_texture.redraw()
        $Camera2D.current = true
        map_texture.position = reset_pos
        remove_child(render_viewport)

func _on_ButtonCancel_pressed():
    $ControlPanel/DialogSaveMap.hide()

func _on_ButtonSaveMap_pressed():
#    print(map_filename)
    $ControlPanel/DialogSaveMap/LabelFilename/ValueFilename.text = map_filename
    $ControlPanel/DialogSaveMap.popup()

func _on_DialogSaveMap_about_to_show():
    $ControlPanel/DialogSaveMap.rect_position = (get_viewport_rect().size / 2) - ($ControlPanel/DialogSaveMap.rect_size/2)



func _on_ValueRows_text_entered(new_text):
    map_texture.grid_rows = int(new_text)
    $ControlPanel/PanelBackground/LabelRows/ValueRows.text = str(map_texture.grid_rows)
    map_texture.redraw()

func _on_ButtonGridRows_Adjust(inc_dec):
    map_texture.grid_rows += inc_dec
    $ControlPanel/PanelBackground/LabelRows/ValueRows.text = str(map_texture.grid_rows)
    map_texture.redraw()

func _on_ValueCols_text_entered(new_text):
    map_texture.grid_cols = int(new_text)
    $ControlPanel/PanelBackground/LabelCols/ValueCols.text = str(map_texture.grid_cols)
    map_texture.redraw()

func _on_ButtonGridCols_Adjust(inc_dec):
    map_texture.grid_cols += inc_dec
    $ControlPanel/PanelBackground/LabelCols/ValueCols.text = str(map_texture.grid_cols)
    map_texture.redraw()

func _on_ColorPicker_color_changed(color):
    map_texture.grid_color = color
    map_texture.redraw()

func _on_ButtonToggleCoordOutline_toggled(state):
        map_texture.font_outline = state
        map_texture.redraw()

func _on_ValueCellSize_text_entered(new_text):
    map_texture.grid_cell_size = int(new_text)
    $ControlPanel/PanelBackground/LabelCellSize/ValueCellSize.text = str(map_texture.grid_cell_size)
    map_texture.redraw()

func _on_ValueGridLineWidth_text_entered(new_text):
    map_texture.line_thickness = int(new_text)
    $ControlPanel/PanelBackground/LabelGridLineWidth/ValueGridLineWidth.text = str(map_texture.line_thickness)
    map_texture.redraw()

func _on_ValueCoordFontSize_text_entered(new_text):
    map_texture.font_size = int(new_text)
    $ControlPanel/PanelBackground/LabelCoordinateFontSize/ValueCoordFontSize.text = str(map_texture.font_size)
    map_texture.redraw()
