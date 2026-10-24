class_name GlitchBackground
extends Node2D
## Animated synthwave-style backdrop (gradient, grid, floating glitch blocks).

var tint := Color("22e6ff")
var _t := 0.0
var _blocks: Array = []


func _ready() -> void:
    z_index = -10
    for i in 28:
        _blocks.append({
            "pos": Vector2(randf() * 1280.0, randf() * 720.0),
            "size": randf_range(6.0, 40.0),
            "speed": randf_range(8.0, 30.0),
            "phase": randf() * TAU,
        })


func _process(delta: float) -> void:
    _t += delta
    for b in _blocks:
        var pos: Vector2 = b["pos"]
        pos.y -= float(b["speed"]) * delta
        if pos.y < -50.0:
            pos.y = 770.0
        b["pos"] = pos
    queue_redraw()


func _draw() -> void:
    var top := Color("070514").lerp(tint, 0.05)
    var bottom := Color("1a0b3a").lerp(tint, 0.10)
    draw_polygon(
        PackedVector2Array([Vector2(0, 0), Vector2(1280, 0), Vector2(1280, 720), Vector2(0, 720)]),
        PackedColorArray([top, top, bottom, bottom])
    )
    # Distant skyline layers create depth without competing with the platforms.
    for layer in range(3):
        var base_y := 590.0 + float(layer) * 38.0
        var x_building := -16.0 + float(layer) * 13.0
        while x_building < 1300.0:
            var bw := 22.0 + fposmod(x_building * 1.71 + float(layer) * 17.0, 48.0)
            var bh := 38.0 + fposmod(x_building * 0.83 + float(layer) * 21.0, 120.0)
            var bcol := Color(tint, 0.035 + float(layer) * 0.025)
            draw_rect(Rect2(x_building, base_y - bh, bw, bh), bcol, true)
            draw_line(Vector2(x_building, base_y - bh), Vector2(x_building + bw, base_y - bh), Color(tint, 0.12 + float(layer) * 0.03), 1.0)
            for wy in range(int(base_y - bh + 10.0), int(base_y - 6.0), 16):
                if int(x_building + wy) % 3 != 0:
                    draw_rect(Rect2(x_building + 5.0, float(wy), 3.0, 4.0), Color(tint, 0.12))
            x_building += bw + 7.0 + float(layer) * 5.0
    draw_line(Vector2(0, 612), Vector2(1280, 612), Color(tint, 0.12), 2.0)
    for x in range(0, 1281, 64):
        draw_line(Vector2(x, 0), Vector2(x, 720), Color(tint, 0.05), 1.0)
    for y in range(0, 721, 64):
        draw_line(Vector2(0, y), Vector2(1280, y), Color(tint, 0.05), 1.0)
    for b in _blocks:
        var s: float = b["size"]
        var a := 0.05 + 0.04 * sin(_t + float(b["phase"]))
        var r := Rect2(b["pos"], Vector2(s, s))
        draw_rect(r, Color(tint, a))
        draw_rect(r, Color(tint, a * 2.0), false, 1.0)
    # Sparse motes and a second fine scanline layer add low-cost motion.
    for i in range(34):
        var sx := fposmod(float(i) * 173.0 + sin(_t * 0.6 + float(i)) * 18.0, 1280.0)
        var sy := fposmod(float(i) * 97.0 - _t * (10.0 + float(i % 5) * 3.0), 720.0)
        draw_circle(Vector2(sx, sy), 1.0 + float(i % 3) * 0.35, Color(tint, 0.12 + float(i % 4) * 0.035))
    var y_scan := fmod(_t * 60.0, 800.0) - 40.0
    draw_rect(Rect2(0, y_scan, 1280, 3), Color(tint, 0.05))
