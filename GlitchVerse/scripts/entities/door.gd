class_name Door
extends StaticBody2D
## Energy barrier tile. Opens when the key is collected (group "doors").

var opened := false
var _shape: CollisionShape2D
var _t := 0.0


func _ready() -> void:
    add_to_group("doors")
    collision_layer = 1
    collision_mask = 0
    _shape = CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(32, 32)
    _shape.shape = rect
    add_child(_shape)


func open() -> void:
    if opened:
        return
    opened = true
    _shape.set_deferred("disabled", true)
    var tw := create_tween()
    tw.tween_property(self, "modulate:a", 0.0, 0.5)
    tw.tween_callback(queue_free)


func _process(delta: float) -> void:
    _t += delta
    queue_redraw()


func _draw() -> void:
    var gold := Color("ffb02e")
    draw_rect(Rect2(-16, -16, 32, 32), Color(gold, 0.16))
    for x in [-11.0, 0.0, 11.0]:
        draw_line(Vector2(x, -16), Vector2(x, 16), Color(gold, 0.55 + 0.3 * sin(_t * 4.0 + x)), 2.0)
    draw_rect(Rect2(-16, -16, 32, 32), Color(gold, 0.35), false, 1.0)
