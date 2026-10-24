class_name Saw
extends Area2D
## Patrolling saw blade. Frozen by the time-freeze ability: while frozen it is
## harmless and can be walked straight through.

var x_a := 0.0
var x_b := 0.0
var speed := 110.0
var phase := 0.0
var radius := 14.0

var _dist := 0.0
var _t := 0.0
var _spin := 0.0


func _ready() -> void:
    add_to_group("freezable")
    collision_layer = 0
    collision_mask = 8
    var cs := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = radius - 2.0
    cs.shape = circle
    add_child(cs)
    _dist = absf(x_b - x_a)
    _t = phase


func _physics_process(delta: float) -> void:
    if GameState.time_frozen:
        return
    _t += delta * speed
    position.x = minf(x_a, x_b) + pingpong(_t, _dist)
    _spin += delta * 14.0
    for b in get_overlapping_bodies():
        if b.has_method("die"):
            b.die()


func _process(_delta: float) -> void:
    queue_redraw()


func _draw() -> void:
    var frozen := GameState.time_frozen
    var col := Color("9fc6ff") if frozen else Color("ff4d6d")
    # rail
    var left := minf(x_a, x_b) - position.x
    var right := maxf(x_a, x_b) - position.x
    draw_line(Vector2(left, 0), Vector2(right, 0), Color(col, 0.18), 2.0)
    var pts := PackedVector2Array()
    var teeth := 10
    for i in teeth * 2:
        var ang := _spin + TAU * float(i) / float(teeth * 2)
        var rad := radius if i % 2 == 0 else radius - 5.0
        pts.append(Vector2(cos(ang), sin(ang)) * rad)
    draw_colored_polygon(pts, col.darkened(0.45))
    pts.append(pts[0])
    draw_polyline(pts, col, 2.0)
    draw_circle(Vector2.ZERO, 4.0, Color("12081f"))
