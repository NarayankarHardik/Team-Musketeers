class_name Pickup
extends Area2D
## Collectible: kind = "shard" (score) or "key" (opens the doors).

signal collected(kind: String, where: Vector2)

var kind := "shard"
var _t := 0.0


func _ready() -> void:
    collision_layer = 0
    collision_mask = 8
    var cs := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = 13.0
    cs.shape = circle
    add_child(cs)
    body_entered.connect(_on_body_entered)
    _t = randf() * TAU


func _process(delta: float) -> void:
    _t += delta * 3.0
    queue_redraw()


func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player") and body.alive:
        collected.emit(kind, global_position)
        queue_free()


func _draw() -> void:
    var bob := sin(_t) * 3.0
    if kind == "shard":
        var col := Color("ffe14d")
        draw_circle(Vector2(0, bob), 14.0, Color(col, 0.12))
        var pts := PackedVector2Array([
            Vector2(0, -11 + bob), Vector2(8, bob), Vector2(0, 11 + bob), Vector2(-8, bob)
        ])
        draw_colored_polygon(pts, Color(col, 0.85))
        pts.append(pts[0])
        draw_polyline(pts, Color.WHITE, 1.5)
    else:
        var col := Color("ffb02e")
        draw_circle(Vector2(0, bob), 18.0, Color(col, 0.14))
        draw_arc(Vector2(-6, bob), 6.0, 0.0, TAU, 20, col, 3.0)
        draw_line(Vector2(0, bob), Vector2(13, bob), col, 3.0)
        draw_line(Vector2(9, bob), Vector2(9, bob + 6), col, 3.0)
        draw_line(Vector2(13, bob), Vector2(13, bob + 4), col, 3.0)
