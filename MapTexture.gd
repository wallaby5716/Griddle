extends Sprite

var grid_rows = 1
var grid_cols = 1
var grid_cell_size = 100
var grid_color = Color.black
var line_thickness = 2
var font_size = 16
var font_outline = false
var grid_offset = Vector2.ZERO
var why_dont_node_paths_work_like_it_says = true


func redraw():
    update()

func _draw():
    if texture != null:
        #print(is_inside_tree())
        var label_parent
        if why_dont_node_paths_work_like_it_says:
            label_parent = get_node("../LabelCoordBase")
        else:
            label_parent = get_node("../../LabelCoordBase")
        label_parent.get_font("font", "Label").size = font_size
        if font_outline:
            label_parent.get_font("font", "Label").outline_size = 1
        else:
            label_parent.get_font("font", "Label").outline_size = 0
        label_parent.add_color_override("font_color", grid_color)

        UTILS.remove_all_children(self)
        for row in range(grid_rows + 1):
            draw_line(grid_offset + Vector2(0, row * grid_cell_size), grid_offset + Vector2(grid_cols * grid_cell_size, row * grid_cell_size), grid_color, line_thickness)
            for col in range(grid_cols + 1):
                draw_line(grid_offset + Vector2(col * grid_cell_size, 0), grid_offset + Vector2(col * grid_cell_size, grid_rows * grid_cell_size), grid_color, line_thickness)
                if col < grid_cols and row < grid_rows:
                    var new_label = label_parent.duplicate(0)
                    new_label.text = str(col + 1) + ", " + str((grid_rows - row))
                    new_label.rect_position = grid_offset + Vector2(col * grid_cell_size, row * grid_cell_size) + Vector2(font_size / 2, grid_cell_size - (font_size * 1.5))
                    new_label.show()
                    add_child(new_label)
