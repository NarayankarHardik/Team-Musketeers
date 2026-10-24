class_name MenuScreen
extends Control
## Title screen.

signal new_game
signal level_select
signal quit_game

var _howto: Control = null


## Animated RGB-split title.
class TitleDraw extends Control:
    var _t := 0.0

    func _ready() -> void:
        custom_minimum_size = Vector2(1000, 160)

    func _process(delta: float) -> void:
        _t += delta
        queue_redraw()

    func _draw() -> void:
        var font := ThemeDB.fallback_font
        var glitching := fmod(_t, 3.0) < 0.15
        var jitter := Vector2(randf_range(-10.0, 10.0), randf_range(-3.0, 3.0)) if glitching else Vector2.ZERO
        var pos := Vector2(0, 104)
        draw_string(font, pos + Vector2(4, 0) + jitter, "GLITCHVERSE", HORIZONTAL_ALIGNMENT_CENTER, 1000, 96, Color(1, 0.24, 0.95, 0.85))
        draw_string(font, pos - Vector2(4, 0) - jitter, "GLITCHVERSE", HORIZONTAL_ALIGNMENT_CENTER, 1000, 96, Color(0.13, 0.9, 1.0, 0.85))
        draw_string(font, pos, "GLITCHVERSE", HORIZONTAL_ALIGNMENT_CENTER, 1000, 96, Color.WHITE)
        draw_string(font, Vector2(0, 148), "THE WORLD IS BROKEN", HORIZONTAL_ALIGNMENT_CENTER, 1000, 26, Color(1, 0.88, 0.3))


func _ready() -> void:
    theme = UITheme.get_theme()
    anchor_right = 1.0
    anchor_bottom = 1.0

    var center := UITheme.centered()
    add_child(center)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 14)
    center.add_child(box)

    box.add_child(TitleDraw.new())
    var spacer := Control.new()
    spacer.custom_minimum_size = Vector2(0, 16)
    box.add_child(spacer)

    var b_new := UITheme.button("NEW GAME")
    b_new.pressed.connect(func(): new_game.emit())
    box.add_child(b_new)
    var b_sel := UITheme.button("LEVEL SELECT")
    b_sel.pressed.connect(func(): level_select.emit())
    box.add_child(b_sel)
    var b_how := UITheme.button("HOW TO PLAY")
    b_how.pressed.connect(_show_howto)
    box.add_child(b_how)
    var b_quit := UITheme.button("QUIT")
    b_quit.pressed.connect(func(): quit_game.emit())
    box.add_child(b_quit)
    b_new.grab_focus.call_deferred()

    var foot := UITheme.label("PS01  -  ARTIFICIAL ARCADE VI  -  ATHARVA UNIVERSITY", 14, Color(1, 1, 1, 0.45))
    foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    foot.anchor_right = 1.0
    foot.anchor_top = 1.0
    foot.anchor_bottom = 1.0
    foot.offset_top = -34.0
    add_child(foot)


func _show_howto() -> void:
    if _howto != null:
        return
    _howto = Control.new()
    _howto.anchor_right = 1.0
    _howto.anchor_bottom = 1.0
    add_child(_howto)
    _howto.add_child(UITheme.backdrop(0.8))
    var center := UITheme.centered()
    _howto.add_child(center)
    var panel := PanelContainer.new()
    center.add_child(panel)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 8)
    panel.add_child(box)
    box.add_child(UITheme.label("HOW TO PLAY", 36, UITheme.CYAN))
    var lines := [
        "A / D  or  Arrow keys ........ Move",
        "W / Space / Up ............... Jump (hold for a higher jump)",
        "Q / Shift .................... Flip gravity   (early and later sectors)",
        "E ............................ Switch dimension   (phase sectors)",
        "F ............................ Freeze time for 4 s",
        "X / Ctrl ...................... Dash forward (short cooldown)",
        "R ............................ Restart the sector",
        "Esc / P ...................... Pause",
        "",
        "Reach the green exit portal. Collect data shards (+100 each).",
        "Finish under par time for a bonus, every death costs 50 points.",
        "Menu > Level Select: press F9 to unlock every sector.",
    ]
    for line in lines:
        box.add_child(UITheme.label(line, 18, Color(0.9, 0.95, 1.0)))
    var close := UITheme.button("BACK", 200)
    close.pressed.connect(_close_howto)
    box.add_child(close)
    close.grab_focus.call_deferred()


func _close_howto() -> void:
    if _howto != null:
        _howto.queue_free()
        _howto = null
