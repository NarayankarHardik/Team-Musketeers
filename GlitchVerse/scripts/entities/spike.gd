class_name Spike
extends Area2D
## Deadly spikes. `up` = true means the tips point up.

var up := true


func _ready() -> void:
    collision_layer = 0
    collision_mask = 8
    var cs := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(22, 14)
    cs.shape = rect
    cs.position = Vector2(0.0, 8.0 if up else -8.0)
    add_child(cs)
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
    if body.has_method("die"):
        body.die()


func _draw() -> void:
    var m := 1.0 if up else -1.0
    for x0 in [-16.0, 0.0]:
        var pts := PackedVector2Array([
            Vector2(x0, 16.0 * m), Vector2(x0 + 8.0, -2.0 * m), Vector2(x0 + 16.0, 16.0 * m)
        ])
        draw_colored_polygon(pts, Color("5a0f2a"))
        pts.append(pts[0])
        draw_polyline(pts, Color("ff4d6d"), 2.0)
