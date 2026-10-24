class_name MovingPlatform
extends AnimatableBody2D
## Platform that oscillates along an axis. Stops while time is frozen.

var size := Vector2(96, 16)
var origin := Vector2.ZERO
var axis := Vector2.RIGHT
var amplitude := 160.0
var speed := 0.9
var phase := 0.0

var _t := 0.0


func _ready() -> void:
    add_to_group("freezable")
    sync_to_physics = true
    collision_layer = 1
    collision_mask = 0
    var cs := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = size
    cs.shape = rect
    add_child(cs)
    _t = phase
    position = origin + axis * sin(_t) * amplitude


func _physics_process(delta: float) -> void:
    if not GameState.time_frozen:
        _t += delta * speed
    position = origin + axis * sin(_t) * amplitude


func _process(_delta: float) -> void:
    queue_redraw()


func _draw() -> void:
    var col := Color("9fc6ff") if GameState.time_frozen else Color("6ea8ff")
    var r := Rect2(-size / 2.0, size)
    draw_rect(r, col.darkened(0.6))
    draw_rect(r, col, false, 2.0)
    draw_rect(Rect2(r.position + Vector2(4, 4), Vector2(size.x - 8.0, 3)), Color(col, 0.6))
