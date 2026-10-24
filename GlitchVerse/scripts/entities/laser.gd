class_name LaserBarrier
extends Area2D
## Pulsing laser shutter. A bright beam is dangerous; a warm warning state telegraphs activation.

var phase := 0.0
var period := 1.75
var active_start := 0.48
var active_end := 1.22
var _clock := 0.0
var _active := false
var _shape: CollisionShape2D

func _ready() -> void:
    collision_layer = 0
    collision_mask = 8
    monitoring = true
    _clock = phase
    _shape = CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(25.0, 6.0)
    _shape.shape = rect
    _shape.disabled = true
    add_child(_shape)
    add_to_group("laser_barriers")
    _sync_state()

func _physics_process(delta: float) -> void:
    if GameState.time_frozen:
        # Time-freeze pauses the cycle and makes the beam harmless until time resumes.
        _shape.set_deferred("disabled", true)
        queue_redraw()
        return
    _clock += delta
    var cycle := fposmod(_clock, period)
    var should_be_active := cycle >= active_start and cycle < active_end
    _active = should_be_active
    _shape.set_deferred("disabled", not _active)
    if _active:
        for body in get_overlapping_bodies():
            if body.has_method("die"):
                body.die()
    queue_redraw()

func _sync_state() -> void:
    var cycle := fposmod(_clock, period)
    _active = cycle >= active_start and cycle < active_end
    _shape.disabled = not _active

func _draw() -> void:
    var cycle := fposmod(_clock, period)
    var warning := not _active and cycle > active_start - 0.34
    var col := Color("9fc6ff") if GameState.time_frozen else (Color("ff405c") if _active else (Color("ffb02e") if warning else Color("496078")))
    # Metal emitters and a horizontal beam / warning line.
    draw_rect(Rect2(-14.0, -7.0, 5.0, 14.0), Color("18243d"), true)
    draw_rect(Rect2(9.0, -7.0, 5.0, 14.0), Color("18243d"), true)
    draw_rect(Rect2(-13.0, -5.0, 3.0, 10.0), Color(col, 0.95), true)
    draw_rect(Rect2(10.0, -5.0, 3.0, 10.0), Color(col, 0.95), true)
    var alpha := 0.95 if _active else (0.45 + 0.25 * sin(_clock * 20.0) if warning else 0.12)
    draw_rect(Rect2(-12.0, -2.0, 24.0, 4.0), Color(col, alpha * 0.24), true)
    draw_line(Vector2(-12.0, 0.0), Vector2(12.0, 0.0), Color(col, alpha), 2.0 if _active else 1.0, true)
    if _active:
        draw_line(Vector2(-10.0, -3.0), Vector2(10.0, 3.0), Color.WHITE, 1.0, true)
