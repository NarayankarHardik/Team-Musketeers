class_name Burst
extends Node2D
## One-shot particle burst, frees itself when finished.

var particles: Array = []
var color := Color.WHITE


static func spawn(parent: Node, pos: Vector2, col: Color, count: int = 24, speed: float = 240.0) -> void:
    var b := Burst.new()
    b.position = pos
    b.color = col
    for i in count:
        var ang := randf() * TAU
        var sp := randf_range(0.3, 1.0) * speed
        b.particles.append({
            "p": Vector2.ZERO,
            "v": Vector2(cos(ang), sin(ang)) * sp,
            "life": randf_range(0.35, 0.8),
            "size": randf_range(2.0, 5.0),
        })
    parent.add_child(b)


func _ready() -> void:
    z_index = 10


func _process(delta: float) -> void:
    var any_alive := false
    for p in particles:
        p["life"] -= delta
        if p["life"] > 0.0:
            p["p"] += p["v"] * delta
            p["v"] *= 0.96
            any_alive = true
    queue_redraw()
    if not any_alive:
        queue_free()


func _draw() -> void:
    for p in particles:
        if p["life"] > 0.0:
            var s: float = p["size"]
            var a := clampf(float(p["life"]) / 0.8, 0.0, 1.0)
            draw_rect(Rect2(p["p"] - Vector2(s, s) / 2.0, Vector2(s, s)), Color(color, a))
