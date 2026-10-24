class_name UITheme
extends RefCounted
## Shared neon UI theme and small widget helpers.

const CYAN := Color(0.13, 0.9, 1.0)
const MAGENTA := Color(1.0, 0.24, 0.95)
const YELLOW := Color(1.0, 0.88, 0.3)
const BLUE := Color(0.43, 0.66, 1.0)

static var _theme: Theme = null


static func get_theme() -> Theme:
    if _theme == null:
        _theme = _build()
    return _theme


static func box(bg: Color, border: Color, width: int = 2, radius: int = 10, margin: float = 14.0) -> StyleBoxFlat:
    var sb := StyleBoxFlat.new()
    sb.bg_color = bg
    sb.border_color = border
    sb.set_border_width_all(width)
    sb.set_corner_radius_all(radius)
    sb.set_content_margin_all(margin)
    sb.content_margin_left = margin + 14.0
    sb.content_margin_right = margin + 14.0
    return sb


static func _build() -> Theme:
    var t := Theme.new()
    t.default_font_size = 20
    t.set_stylebox("normal", "Button", box(Color(0.08, 0.07, 0.2, 0.92), Color(CYAN, 0.55)))
    t.set_stylebox("hover", "Button", box(Color(0.12, 0.12, 0.32, 1.0), CYAN))
    t.set_stylebox("pressed", "Button", box(Color(0.2, 0.1, 0.35, 1.0), MAGENTA))
    t.set_stylebox("disabled", "Button", box(Color(0.06, 0.06, 0.1, 0.8), Color(1, 1, 1, 0.12)))
    t.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), YELLOW))
    t.set_color("font_color", "Button", Color(0.87, 0.96, 1.0))
    t.set_color("font_hover_color", "Button", Color.WHITE)
    t.set_color("font_focus_color", "Button", Color.WHITE)
    t.set_color("font_pressed_color", "Button", MAGENTA)
    t.set_color("font_disabled_color", "Button", Color(1, 1, 1, 0.3))
    t.set_font_size("font_size", "Button", 22)
    t.set_stylebox("panel", "PanelContainer", box(Color(0.05, 0.04, 0.14, 0.95), Color(CYAN, 0.6), 2, 14, 26.0))
    return t


static func label(text: String, size: int = 20, color: Color = Color.WHITE) -> Label:
    var l := Label.new()
    l.text = text
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", color)
    return l


static func button(text: String, min_width: float = 320.0) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(min_width, 52)
    b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    return b


## Full-screen dark backdrop used by overlay screens.
static func backdrop(alpha: float = 0.62) -> ColorRect:
    var dim := ColorRect.new()
    dim.color = Color(0.0, 0.0, 0.05, alpha)
    dim.anchor_right = 1.0
    dim.anchor_bottom = 1.0
    return dim


static func centered() -> CenterContainer:
    var c := CenterContainer.new()
    c.anchor_right = 1.0
    c.anchor_bottom = 1.0
    return c
