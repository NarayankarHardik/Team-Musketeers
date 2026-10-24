class_name HUD
extends Control
## In-game heads-up display, drawn with custom _draw calls.

var level: GameLevel

var _notice := ""
var _notice_t := 0.0
var _intro_t := 5.0
var _font: Font


func _ready() -> void:
    _font = ThemeDB.fallback_font
    anchor_right = 1.0
    anchor_bottom = 1.0
    mouse_filter = Control.MOUSE_FILTER_IGNORE


func notify(text: String, seconds: float = 2.0) -> void:
    _notice = text
    _notice_t = seconds


func _process(delta: float) -> void:
    _intro_t = maxf(0.0, _intro_t - delta)
    _notice_t = maxf(0.0, _notice_t - delta)
    queue_redraw()


func _text(text: String, pos: Vector2, size: int, color: Color) -> void:
    draw_string(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _text_aligned(text: String, pos: Vector2, width: float, size: int, color: Color, align: HorizontalAlignment) -> void:
    draw_string(_font, pos, text, align, width, size, color)


func _fmt_time(t: float) -> String:
    return "%02d:%04.1f" % [int(t / 60.0), fmod(t, 60.0)]


func _draw() -> void:
    if level == null or level.player == null:
        return
    var p: Player = level.player
    var col: Color = level.theme_color

    # ---- top bar
    draw_rect(Rect2(0, 0, 1280, 48), Color(0.03, 0.02, 0.09, 0.96))
    draw_rect(Rect2(0, 46, 1280, 2), Color(col, 0.8))
    _text("SECTOR %02d" % (level.level_index + 1), Vector2(20, 19), 13, Color(col, 0.9))
    _text(str(level.data["name"]), Vector2(20, 40), 20, Color.WHITE)

    # ---- ability chips
    var abil: Dictionary = p.abilities
    _chip(Vector2(288, 8), "Q", "GRAVITY", abil["gravity"], 1.0 - p.flip_cd / Player.FLIP_COOLDOWN, false, Color("22e6ff"))
    _chip(Vector2(410, 8), "E", "PHASE", abil["dimension"], 1.0 - p.dim_cd / Player.DIMENSION_COOLDOWN, false, Color("ff3df2"))
    var time_ratio := 1.0 - p.freeze_cd / Player.FREEZE_COOLDOWN
    var freezing := p.freeze_left > 0.0
    if freezing:
        time_ratio = p.freeze_left / Player.FREEZE_DURATION
    _chip(Vector2(532, 8), "F", "TIME", abil["time"], time_ratio, freezing, Color("6ea8ff"))
    _chip(Vector2(654, 8), "X", "DASH", abil["dash"], 1.0 - p.dash_cd / Player.DASH_COOLDOWN, p.dash_time > 0.0, Color("ffb02e"))

    # ---- stats (right)
    var par: float = level.data["par_time"]
    _text_aligned("TIME  %s   /   PAR  %s" % [_fmt_time(level.elapsed), _fmt_time(par)],
        Vector2(795, 20), 465.0, 15, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT)
    var key_txt := "   KEY: YES" if level.has_key else "   KEY: NEEDED"
    _text_aligned("SHARDS %d/%d    SCORE %d    DEATHS %d%s" % [
            level.shards_collected, level.shards_total, level.calc_score(), level.deaths, key_txt],
        Vector2(795, 40), 465.0, 15, Color("ffe14d"), HORIZONTAL_ALIGNMENT_RIGHT)

    # ---- time-freeze tint
    if GameState.time_frozen:
        draw_rect(Rect2(0, 48, 1280, 672), Color(0.35, 0.6, 1.0, 0.10))
        draw_rect(Rect2(3, 51, 1274, 666), Color(0.55, 0.75, 1.0, 0.5), false, 3.0)
        _text_aligned("TIME FROZEN  %.1f" % p.freeze_left, Vector2(0, 84), 1280.0, 22,
            Color(0.75, 0.88, 1.0, 0.9), HORIZONTAL_ALIGNMENT_CENTER)

    # ---- hint line (over the bottom wall row)
    _text_aligned(str(level.data["hint"]), Vector2(0, 710), 1280.0, 14, Color(1, 1, 1, 0.65),
        HORIZONTAL_ALIGNMENT_CENTER)

    # ---- notice
    if _notice_t > 0.0:
        var a := clampf(_notice_t * 2.0, 0.0, 1.0)
        _text_aligned(_notice, Vector2(2, 132), 1280.0, 28, Color(0, 0, 0, a * 0.7), HORIZONTAL_ALIGNMENT_CENTER)
        _text_aligned(_notice, Vector2(0, 130), 1280.0, 28, Color(1, 0.88, 0.3, a), HORIZONTAL_ALIGNMENT_CENTER)

    # ---- intro banner
    if _intro_t > 0.0:
        var ia := clampf(_intro_t, 0.0, 1.0)
        draw_rect(Rect2(0, 270, 1280, 170), Color(0.02, 0.01, 0.07, 0.82 * ia))
        draw_rect(Rect2(0, 270, 1280, 3), Color(col, ia))
        draw_rect(Rect2(0, 437, 1280, 3), Color(col, ia))
        _text_aligned("SECTOR %02d" % (level.level_index + 1), Vector2(0, 312), 1280.0, 20, Color(col, ia), HORIZONTAL_ALIGNMENT_CENTER)
        _text_aligned(str(level.data["name"]), Vector2(0, 366), 1280.0, 54, Color(1, 1, 1, ia), HORIZONTAL_ALIGNMENT_CENTER)
        _text_aligned(str(level.data["subtitle"]), Vector2(0, 402), 1280.0, 20, Color(1, 0.88, 0.3, ia), HORIZONTAL_ALIGNMENT_CENTER)
        _text_aligned("NEW MECHANIC: " + str(level.data["mechanic"]), Vector2(0, 428), 1280.0, 14, Color(1, 1, 1, 0.7 * ia), HORIZONTAL_ALIGNMENT_CENTER)


func _chip(pos: Vector2, key: String, label_text: String, available: bool, ratio: float, active: bool, col: Color) -> void:
    var r := Rect2(pos, Vector2(116, 32))
    ratio = clampf(ratio, 0.0, 1.0)
    draw_rect(r, Color(0, 0, 0, 0.45))
    if not available:
        draw_rect(r, Color(1, 1, 1, 0.12), false, 1.0)
        _text("[%s] %s" % [key, label_text], pos + Vector2(7, 21), 14, Color(1, 1, 1, 0.25))
        return
    var ready_now := ratio >= 1.0
    draw_rect(Rect2(pos, Vector2(r.size.x * ratio, r.size.y)), Color(col, 0.55 if active else 0.28))
    draw_rect(r, Color(col, 1.0 if (ready_now or active) else 0.45), false, 2.0)
    _text("[%s] %s" % [key, label_text], pos + Vector2(7, 21), 14, Color.WHITE)
