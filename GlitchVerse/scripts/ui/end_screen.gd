class_name EndScreen
extends Control
## Final results screen after the last sector.

signal play_again_pressed
signal menu_pressed


func _ready() -> void:
    theme = UITheme.get_theme()
    anchor_right = 1.0
    anchor_bottom = 1.0
    add_child(UITheme.backdrop(0.78))
    var center := UITheme.centered()
    add_child(center)
    var panel := PanelContainer.new()
    center.add_child(panel)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 8)
    panel.add_child(box)

    var title := UITheme.label("SYSTEM RESTORED", 50, UITheme.CYAN)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(title)

    var grid := GridContainer.new()
    grid.columns = 3
    grid.add_theme_constant_override("h_separation", 50)
    grid.add_theme_constant_override("v_separation", 6)
    box.add_child(grid)
    var max_total := 0
    for i in Levels.LEVELS.size():
        var d: Dictionary = Levels.LEVELS[i]
        grid.add_child(UITheme.label("SECTOR %02d  %s" % [i + 1, d["name"]], 20, Color(0.85, 0.92, 1.0)))
        if GameState.level_results.has(i):
            var r: Dictionary = GameState.level_results[i]
            max_total += int(r["max_score"])
            grid.add_child(UITheme.label(str(int(r["score"])), 20, Color.WHITE))
            grid.add_child(UITheme.label(str(r["rank"]), 20, UITheme.YELLOW))
        else:
            grid.add_child(UITheme.label("-", 20, Color(1, 1, 1, 0.4)))
            grid.add_child(UITheme.label("-", 20, Color(1, 1, 1, 0.4)))

    var total := GameState.get_total_score()
    var ratio := 0.0
    if max_total > 0:
        ratio = float(total) / float(max_total)
    var rank := "C"
    if ratio >= 0.9:
        rank = "S"
    elif ratio >= 0.75:
        rank = "A"
    elif ratio >= 0.55:
        rank = "B"
    var tl := UITheme.label("TOTAL SCORE  %d      OVERALL RANK  %s" % [total, rank], 32, UITheme.YELLOW)
    tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(tl)

    var again := UITheme.button("PLAY AGAIN", 300)
    again.pressed.connect(func(): play_again_pressed.emit())
    box.add_child(again)
    var menu := UITheme.button("MAIN MENU", 300)
    menu.pressed.connect(func(): menu_pressed.emit())
    box.add_child(menu)
    again.grab_focus.call_deferred()
