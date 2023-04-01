extends Node

func remove_all_children(parent):
    for child in parent.get_children():
        child.queue_free()
