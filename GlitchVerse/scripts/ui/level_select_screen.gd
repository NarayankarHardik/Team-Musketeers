class_name LevelSelectScreen
extends Control
## Sector picker with best scores and locked sectors.

signal level_chosen(index: int)
signal back_pressed

var _grid: GridContainer


func _ready() -> void:
    theme = UITheme.get_theme()
    anchor_right = 1.0
    anchor_bottom = 1.0
    var center := UITheme.centered()
    add_child(center)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 14)
    center.add_child(box)
    var title := UITheme.label("SELECT SECTOR", 44, UITheme.CYAN)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(title)
    _grid = GridContainer.new()
    _grid.columns = 3
    _grid.add_theme_constant_override("h_separation", 14)
    _grid.add_theme_constant_override("v_separation", 12)
    box.add_child(_grid)
    var back := UITheme.button("BACK", 240)
    back.pressed.connect(func(): back_pressed.emit())
    box.add_child(back)
    var tip := UITheme.label("Tip: press F9 to unlock every sector", 14, Color(1, 1, 1, 0.45))
    tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(tip)
    _populate()


func _populate() -> void:
    for c in _grid.get_children():
        _grid.remove_child(c)
        c.queue_free()
    var first: Button = null
    for i in Levels.LEVELS.size():
        var d: Dictionary = Levels.LEVELS[i]
        var locked := i >= GameState.unlocked
        var best := int(GameState.best_scores.get(i, 0))
        var best_txt := "LOCKED" if locked else ("BEST  %d" % best if best > 0 else "NOT CLEARED")
        var b := Button.new()
        b.text = "SECTOR %02d\n%s\n%s\n%s" % [i + 1, d["name"], d["mechanic"], best_txt]
        b.custom_minimum_size = Vector2(278, 102)
        b.disabled = locked
        b.pressed.connect(func(): level_chosen.emit(i))
        _grid.add_child(b)
        if first == null and not locked:
            first = b
    if first != null:
        first.grab_focus.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
        GameState.unlock_all()
        _populate()
