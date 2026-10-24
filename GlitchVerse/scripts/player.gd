class_name Player
extends CharacterBody2D
## Player controller: movement plus the three glitch abilities
## (gravity flip, dimension phase-shift, time freeze).

signal died
signal dimension_changed(dimension: int)
signal gravity_flipped(direction: float)
signal time_freeze_started
signal time_freeze_ended
signal ability_denied(ability: String)

const SPEED := 235.0
const ACCEL := 2200.0
const FRICTION := 2600.0
const AIR_CONTROL := 0.85
const JUMP_VELOCITY := 520.0
const GRAVITY := 1500.0
const MAX_FALL := 850.0
const COYOTE_TIME := 0.10
const JUMP_BUFFER := 0.12

const FLIP_COOLDOWN := 0.5
const DIMENSION_COOLDOWN := 0.3
const FREEZE_DURATION := 4.0
const FREEZE_COOLDOWN := 5.0
const DASH_COOLDOWN := 1.35
const DASH_DURATION := 0.16
const DASH_SPEED := 570.0

const SIZE := Vector2(20, 28)

var abilities := {"gravity": false, "dimension": false, "time": false, "dash": true}
var gravity_dir := 1.0      # 1 = falls down, -1 = falls up
var dimension := 0          # 0 = cyan (A), 1 = magenta (B)
var alive := true

var flip_cd := 0.0
var dim_cd := 0.0
var freeze_left := 0.0
var freeze_cd := 0.0
var dash_cd := 0.0
var dash_time := 0.0

var _coyote := 0.0
var _jump_buffer := 0.0
var _air_time := 0.0
var _was_on_floor := false
var _visual_flip := 1.0
var _face := 1.0
var _squash := Vector2.ONE
var _trail: Array = []
var _trail_timer := 0.0
var _anim_t := 0.0
var _check_shape := RectangleShape2D.new()


func _ready() -> void:
    add_to_group("player")
    collision_layer = 8
    collision_mask = 1 | 2
    up_direction = Vector2.UP
    slide_on_ceiling = false
    z_index = 5
    var cs := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = SIZE
    cs.shape = rect
    add_child(cs)
    _check_shape.size = SIZE - Vector2(6, 6)


func configure(ability_dict: Dictionary) -> void:
    for k in abilities.keys():
        abilities[k] = bool(ability_dict.get(k, k == "dash"))


func _physics_process(delta: float) -> void:
    if not alive:
        return
    _tick_timers(delta)
    _handle_abilities()
    _handle_movement(delta)
    _update_visuals(delta)
    if position.y > 900.0 or position.y < -100.0:
        die()


# ---------------------------------------------------------------- abilities
func _tick_timers(delta: float) -> void:
    flip_cd = maxf(0.0, flip_cd - delta)
    dim_cd = maxf(0.0, dim_cd - delta)
    freeze_cd = maxf(0.0, freeze_cd - delta)
    dash_cd = maxf(0.0, dash_cd - delta)
    dash_time = maxf(0.0, dash_time - delta)
    if freeze_left > 0.0:
        freeze_left -= delta
        if freeze_left <= 0.0:
            freeze_left = 0.0
            GameState.time_frozen = false
            freeze_cd = FREEZE_COOLDOWN
            Sfx.play("unfreeze")
            time_freeze_ended.emit()


func _handle_abilities() -> void:
    if Input.is_action_just_pressed("flip_gravity") and abilities["gravity"] and flip_cd <= 0.0:
        _flip_gravity()
    if Input.is_action_just_pressed("switch_dimension") and abilities["dimension"] and dim_cd <= 0.0:
        _switch_dimension()
    if Input.is_action_just_pressed("dash") and abilities["dash"] and dash_cd <= 0.0:
        _start_dash()
    if Input.is_action_just_pressed("freeze_time") and abilities["time"] and freeze_cd <= 0.0 and freeze_left <= 0.0:
        freeze_left = FREEZE_DURATION
        GameState.time_frozen = true
        GameState.add_glitch(0.9)
        Sfx.play("freeze")
        time_freeze_started.emit()


func _start_dash() -> void:
    var direction := _face
    var input_dir := Input.get_axis("move_left", "move_right")
    if input_dir != 0.0:
        direction = signf(input_dir)
        _face = direction
    velocity.x = direction * DASH_SPEED
    velocity.y *= 0.18
    dash_time = DASH_DURATION
    dash_cd = DASH_COOLDOWN
    _squash = Vector2(1.35, 0.72)
    GameState.add_glitch(0.35)
    Sfx.play("dash")


func _flip_gravity() -> void:
    gravity_dir = -gravity_dir
    up_direction = Vector2(0.0, -gravity_dir)
    velocity.y = gravity_dir * 60.0
    flip_cd = FLIP_COOLDOWN
    _coyote = 0.0
    _jump_buffer = 0.0
    GameState.add_glitch(0.8)
    Sfx.play("flip")
    gravity_flipped.emit(gravity_dir)


func _switch_dimension() -> void:
    var new_dim := 1 - dimension
    var layer_bit := 2 if new_dim == 0 else 4
    if _overlaps(layer_bit):
        Sfx.play("deny")
        ability_denied.emit("dimension")
        return
    dimension = new_dim
    collision_mask = 1 | layer_bit
    dim_cd = DIMENSION_COOLDOWN
    GameState.add_glitch(1.0)
    Sfx.play("phase")
    dimension_changed.emit(dimension)


## True if switching into the dimension on `mask` would put us inside solid blocks.
func _overlaps(mask: int) -> bool:
    var params := PhysicsShapeQueryParameters2D.new()
    params.shape = _check_shape
    params.transform = global_transform
    params.collision_mask = mask
    var hits := get_world_2d().direct_space_state.intersect_shape(params, 1)
    return not hits.is_empty()


# ----------------------------------------------------------------- movement
func _handle_movement(delta: float) -> void:
    var dir := Input.get_axis("move_left", "move_right")
    if dir != 0.0:
        _face = signf(dir)

    if dash_time > 0.0:
        move_and_slide()
        _was_on_floor = is_on_floor()
        return

    var on_floor := is_on_floor()
    if on_floor:
        _coyote = COYOTE_TIME
    else:
        _coyote -= delta
        velocity.y += GRAVITY * gravity_dir * delta
        velocity.y = clampf(velocity.y, -MAX_FALL, MAX_FALL)

    if Input.is_action_just_pressed("jump"):
        _jump_buffer = JUMP_BUFFER
    else:
        _jump_buffer -= delta

    if _jump_buffer > 0.0 and _coyote > 0.0:
        velocity.y = -JUMP_VELOCITY * gravity_dir
        _jump_buffer = 0.0
        _coyote = 0.0
        _squash = Vector2(0.75, 1.3)
        Sfx.play("jump")

    # variable jump height: release early to cut the jump short
    if Input.is_action_just_released("jump") and velocity.y * gravity_dir < 0.0:
        velocity.y *= 0.45

    var accel := ACCEL if on_floor else ACCEL * AIR_CONTROL
    if dir != 0.0:
        velocity.x = move_toward(velocity.x, dir * SPEED, accel * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

    move_and_slide()

    var now_floor := is_on_floor()
    if now_floor and not _was_on_floor and _air_time > 0.12:
        _squash = Vector2(1.3, 0.72)
        Sfx.play("land")
    _air_time = 0.0 if now_floor else _air_time + delta
    _was_on_floor = now_floor


func die() -> void:
    if not alive:
        return
    alive = false
    visible = false
    GameState.time_frozen = false
    died.emit()


# ------------------------------------------------------------------- visuals
func _update_visuals(delta: float) -> void:
    _anim_t += delta
    _visual_flip = lerpf(_visual_flip, gravity_dir, minf(1.0, delta * 14.0))
    _squash = _squash.lerp(Vector2.ONE, minf(1.0, delta * 12.0))
    _trail_timer -= delta
    if _trail_timer <= 0.0 and velocity.length() > 120.0:
        _trail_timer = 0.03
        _trail.append({"pos": global_position, "life": 0.25, "flip": _visual_flip})
    for t in _trail:
        t["life"] -= delta
    _trail = _trail.filter(func(t): return t["life"] > 0.0)
    queue_redraw()


func _draw() -> void:
    var col := Color("22e6ff") if dimension == 0 else Color("ff3df2")
    var dark := Color("11152c")
    var metal := Color("dce9f6")
    var moving := clampf(absf(velocity.x) / SPEED, 0.0, 1.0)
    var walk := sin(_anim_t * 12.0) * moving
    var blink := 0.18 if fposmod(_anim_t + 0.25, 4.6) < 0.11 else 1.0
    var dash_glow := 0.25 if dash_time > 0.0 else 0.0

    # Soft energy afterimages.
    for t in _trail:
        var a: float = float(t["life"]) / 0.25 * 0.22
        var point := to_local(t["pos"])
        draw_circle(point, 10.0, Color(col, a))
        draw_rect(Rect2(point + Vector2(-6, -7), Vector2(12, 14)), Color(col, a * 0.8), true)

    draw_set_transform(Vector2(0.0, -8.0 * _visual_flip), 0.0, Vector2(_squash.x * _face, _squash.y * _visual_flip))

    # Antenna and head halo make the silhouette readable at a glance.
    draw_circle(Vector2(0, -20), 15.5, Color(col, 0.08 + dash_glow))
    draw_line(Vector2(0, -20), Vector2(2.0 + sin(_anim_t * 2.2), -28), metal, 3.0, true)
    draw_circle(Vector2(2.0 + sin(_anim_t * 2.2), -29), 4.2, Color(col, 0.25))
    draw_circle(Vector2(2.0 + sin(_anim_t * 2.2), -29), 2.2, col)

    # Long segmented arms with shoulder joints, forearms, and rounded hands.
    var arm_swing := walk * 4.8
    for side in [-1.0, 1.0]:
        var shoulder := Vector2(side * 9.0, -2.0)
        var elbow := Vector2(side * (14.5 + arm_swing * side), 6.0 + arm_swing * 0.45)
        var wrist := Vector2(side * (18.0 + arm_swing * side), 13.0 - arm_swing * 0.5)
        draw_line(shoulder, elbow, dark, 7.0, true)
        draw_line(shoulder, elbow, metal, 4.5, true)
        draw_circle(shoulder, 4.0, Color(col, 0.95))
        draw_circle(elbow, 3.4, Color("899bb8"))
        draw_line(elbow, wrist, dark, 6.0, true)
        draw_line(elbow, wrist, metal, 3.8, true)
        draw_circle(wrist, 3.7, Color(col, 0.95))
        draw_circle(wrist, 2.0, metal)

    # Two long mechanical legs animate independently while running.
    for side in [-1.0, 1.0]:
        var hip := Vector2(side * 5.0, 12.0)
        var knee := Vector2(side * (5.0 + walk * 4.3 * side), 19.5)
        var ankle := Vector2(side * (5.0 + walk * 6.0 * side), 25.0)
        draw_line(hip, knee, dark, 7.0, true)
        draw_line(hip, knee, metal, 4.4, true)
        draw_circle(knee, 3.0, Color(col, 0.9))
        draw_line(knee, ankle, dark, 6.0, true)
        draw_line(knee, ankle, metal, 3.6, true)
        var foot := Rect2(ankle + Vector2(-5.0, -1.0), Vector2(10.0, 5.0))
        draw_rect(foot, dark, true)
        draw_rect(Rect2(foot.position + Vector2(1.0, 0.0), Vector2(8.0, 2.0)), col, true)

    # Torso: rounded by layered plates and drawn seams.
    draw_rect(Rect2(-10.0, -5.0, 20.0, 19.0), dark, true)
    draw_rect(Rect2(-9.0, -4.0, 18.0, 17.0), metal, true)
    draw_rect(Rect2(-7.0, -2.0, 14.0, 13.0), Color("95a9c6"), true)
    draw_rect(Rect2(-7.0, -2.0, 14.0, 3.0), Color.WHITE, true)
    draw_line(Vector2(-6.0, 3.5), Vector2(-6.0, 8.0), Color("52617d"), 1.0)
    draw_line(Vector2(6.0, 3.5), Vector2(6.0, 8.0), Color("52617d"), 1.0)
    draw_circle(Vector2(0, 5.0), 6.8, Color(col, 0.16 + dash_glow))
    draw_circle(Vector2(0, 5.0), 4.7, dark)
    draw_circle(Vector2(0, 5.0), 3.4, col)
    draw_circle(Vector2(-1.0, 4.0), 1.2, Color.WHITE)

    # Head shell, ear pods, large friendly LED eyes, and tiny digital smile.
    draw_rect(Rect2(-14.0, -22.0, 28.0, 20.0), dark, true)
    draw_rect(Rect2(-12.5, -21.0, 25.0, 17.0), metal, true)
    draw_rect(Rect2(-10.0, -18.8, 20.0, 12.0), Color("12233f"), true)
    draw_rect(Rect2(-15.5, -16.0, 3.0, 7.0), Color(col, 0.9), true)
    draw_rect(Rect2(12.5, -16.0, 3.0, 7.0), Color(col, 0.9), true)
    for ex in [-5.0, 5.0]:
        draw_circle(Vector2(ex, -13.2), 3.35, Color(col, 0.24))
        draw_rect(Rect2(ex - 2.2, -15.8, 4.4, 5.5 * blink), Color("f3fbff"), true)
        draw_rect(Rect2(ex - 0.8 + 0.4 * _face, -14.5, 1.6, 3.2 * blink), col, true)
        draw_circle(Vector2(ex - 0.7, -15.0), 0.75 * blink, Color.WHITE)
    draw_line(Vector2(-2.0, -7.0), Vector2(2.0, -7.0), Color("6ed6e8"), 1.6, true)
    draw_circle(Vector2(-10.0, -20.0), 1.4, Color.WHITE)
    draw_circle(Vector2(10.0, -20.0), 1.4, Color.WHITE)

    # Small floating pixels appear during a dash.
    if dash_time > 0.0:
        for i in range(3):
            var px := -22.0 - float(i) * 5.0
            draw_rect(Rect2(px, -2.0 + float(i % 2) * 5.0, 3.0, 3.0), Color(col, 0.8 - i * 0.2), true)

    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
