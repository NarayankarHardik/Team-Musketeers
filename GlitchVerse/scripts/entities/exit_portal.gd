class_name ExitPortal
extends Area2D
## Level exit.

signal reached

var _t := 0.0


func _ready() -> void:
    collision_layer = 0
    collision_mask = 8
    var cs := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(18, 28)
    cs.shape = rect
    add_child(cs)
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player") and body.alive:
        reached.emit()


func _process(delta: float) -> void:
    _t += delta
    queue_redraw()


func _draw() -> void:
    var col := Color("7dffb2")
    draw_circle(Vector2.ZERO, 24.0, Color(col, 0.10))
    for i in 3:
        var start := _t * (1.5 + i * 0.8) * (1.0 if i % 2 == 0 else -1.0)
        draw_arc(Vector2.ZERO, 8.0 + i * 5.0, start, start + PI * 1.5, 24, Color(col, 0.9 - i * 0.2), 2.5)
    draw_circle(Vector2.ZERO, 3.0, Color.WHITE)
