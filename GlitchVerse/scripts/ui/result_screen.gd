class_name ResultScreen
extends Control
## Shown after a sector is cleared: score breakdown and next actions.

signal next_pressed
signal retry_pressed
signal menu_pressed

var result: Dictionary = {}
var is_last := false


func _fmt(t: float) -> String:
    return "%02d:%04.1f" % [int(t / 60.0), fmod(t, 60.0)]


func _ready() -> void:
    theme = UITheme.get_theme()
    anchor_right = 1.0
    anchor_bottom = 1.0
    add_child(UITheme.backdrop())
    var center := UITheme.centered()
    add_child(center)
    var panel := PanelContainer.new()
    center.add_child(panel)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 8)
    panel.add_child(box)

    var title := UITheme.label("SECTOR CLEARED", 46, UITheme.CYAN)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(title)
    var sub := UITheme.label(str(result["name"]), 22, UITheme.YELLOW)
    sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(sub)

    var grid := GridContainer.new()
    grid.columns = 2
    grid.add_theme_constant_override("h_separation", 80)
    grid.add_theme_constant_override("v_separation", 6)
    box.add_child(grid)
    _row(grid, "TIME", "%s   (par %s)" % [_fmt(result["time"]), _fmt(result["par"])])
    _row(grid, "BASE", "+%d" % int(result["base"]))
    _row(grid, "DATA SHARDS  %d / %d" % [int(result["shards"]), int(result["shards_total"])], "+%d" % int(result["shard_points"]))
    _row(grid, "TIME BONUS", "+%d" % int(result["time_bonus"]))
    _row(grid, "DEATHS  %d" % int(result["deaths"]), "-%d" % int(result["death_penalty"]))

    var total := UITheme.label("SCORE  %d      RANK  %s" % [int(result["score"]), str(result["rank"])], 34, UITheme.YELLOW)
    total.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(total)

    var next := UITheme.button("FINAL REPORT" if is_last else "NEXT SECTOR", 300)
    next.pressed.connect(func(): next_pressed.emit())
    box.add_child(next)
    var retry := UITheme.button("RETRY SECTOR", 300)
    retry.pressed.connect(func(): retry_pressed.emit())
    box.add_child(retry)
    var menu := UITheme.button("MAIN MENU", 300)
    menu.pressed.connect(func(): menu_pressed.emit())
    box.add_child(menu)
    next.grab_focus.call_deferred()


func _row(grid: GridContainer, left: String, right: String) -> void:
    grid.add_child(UITheme.label(left, 20, Color(0.85, 0.92, 1.0)))
    var r := UITheme.label(right, 20, Color.WHITE)
    r.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    grid.add_child(r)
