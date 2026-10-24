class_name GameLevel
extends Node2D
## Builds a playable sector from the ASCII map in levels.gd, runs the timer,
## scoring, death/respawn and win logic.

signal completed(result: Dictionary)

const TILE := 32
var cols := 40
const ROWS := 21
const OFFSET := Vector2(0, 48)   # room under the HUD bar

const BASE_SCORE := 500
const SHARD_SCORE := 100
const DEATH_PENALTY := 50
const TIME_SCORE := 10           # points per second under par

var level_index := 0
var data: Dictionary = {}
var theme_color := Color("22e6ff")
var player: Player
var hud: HUD
var world: Node2D

var elapsed := 0.0
var deaths := 0
var shards_total := 0
var shards_collected := 0
var has_key := false
var finished := false

var _grid: Array = []
var _blocks: Array = []
var _respawn_pending := false


func _ready() -> void:
    data = Levels.LEVELS[level_index]
    for map_row in data["map"]:
        cols = maxi(cols, str(map_row).length())
    theme_color = Color(str(data["color"]))

    # Keep the atmosphere fixed to the screen while the later sectors scroll.
    var bg_layer := CanvasLayer.new()
    bg_layer.layer = -10
    add_child(bg_layer)
    var bg := GlitchBackground.new()
    bg.tint = theme_color
    bg_layer.add_child(bg)

    world = Node2D.new()
    add_child(world)

    var layer := CanvasLayer.new()
    layer.layer = 5
    add_child(layer)
    hud = HUD.new()
    hud.level = self
    layer.add_child(hud)

    _build_world()
    hud.notify(str(data["mechanic"]) + " ONLINE", 2.5)


func _process(delta: float) -> void:
    if not finished:
        elapsed += delta


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("restart_level") and not finished:
        restart_full()


## Restart the sector from scratch (timer and deaths reset).
func restart_full() -> void:
    elapsed = 0.0
    deaths = 0
    hud.notify("SECTOR RESET", 1.2)
    _build_world()


# -------------------------------------------------------------- world build
func _build_world() -> void:
    _respawn_pending = false
    GameState.time_frozen = false
    for c in world.get_children():
        world.remove_child(c)
        c.queue_free()
    has_key = false
    shards_collected = 0
    shards_total = 0
    _blocks.clear()
    _grid.clear()
    for r in ROWS:
        _grid.append(_padded_row(r))

    _build_blocks()

    var start := OFFSET + Vector2(TILE * 2.5, 640.0)
    for r in ROWS:
        for c in cols:
            var ch: String = _grid[r][c]
            match ch:
                "P":
                    start = _tile_center(c, r)
                "^":
                    _spawn_spike(c, r, true)
                "v":
                    _spawn_spike(c, r, false)
                "o":
                    _spawn_pickup(c, r, "shard")
                "K":
                    _spawn_pickup(c, r, "key")
                "D":
                    _spawn_door(c, r)
                "L":
                    _spawn_laser(c, r)
                "E":
                    _spawn_exit(c, r)
    _spawn_saws()
    _spawn_platforms()
    _spawn_player(start)
    queue_redraw()


func _padded_row(r: int) -> String:
    var rows: Array = data["map"]
    var s := ""
    if r < rows.size():
        s = str(rows[r])
    return s.rpad(cols, ".").substr(0, cols)


func _tile_center(c: int, r: int) -> Vector2:
    return OFFSET + Vector2(c * TILE + TILE / 2.0, r * TILE + TILE / 2.0)


## Merge neighbouring tiles of the same type into larger collision rectangles.
func _build_blocks() -> void:
    var used := {}
    for r in ROWS:
        for c in cols:
            var ch: String = _grid[r][c]
            if not "#AB".contains(ch) or used.has(Vector2i(c, r)):
                continue
            var w := 1
            while c + w < cols and _grid[r][c + w] == ch and not used.has(Vector2i(c + w, r)):
                w += 1
            var h := 1
            var can_grow := true
            while can_grow and r + h < ROWS:
                for x in range(c, c + w):
                    if _grid[r + h][x] != ch or used.has(Vector2i(x, r + h)):
                        can_grow = false
                        break
                if can_grow:
                    h += 1
            for yy in range(r, r + h):
                for xx in range(c, c + w):
                    used[Vector2i(xx, yy)] = true
            _add_block(ch, c, r, w, h)


func _add_block(ch: String, c: int, r: int, w: int, h: int) -> void:
    var layer_bits := {"#": 1, "A": 2, "B": 4}
    var body := StaticBody2D.new()
    body.collision_layer = layer_bits[ch]
    body.collision_mask = 0
    body.position = OFFSET + Vector2((c + w / 2.0) * TILE, (r + h / 2.0) * TILE)
    var cs := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(w * TILE, h * TILE)
    cs.shape = rect
    body.add_child(cs)
    world.add_child(body)
    _blocks.append({
        "ch": ch,
        "rect": Rect2(OFFSET + Vector2(c * TILE, r * TILE), Vector2(w * TILE, h * TILE)),
    })


# ------------------------------------------------------------------ spawners
func _spawn_spike(c: int, r: int, up: bool) -> void:
    var s := Spike.new()
    s.up = up
    s.position = _tile_center(c, r)
    world.add_child(s)


func _spawn_pickup(c: int, r: int, kind: String) -> void:
    var p := Pickup.new()
    p.kind = kind
    p.position = _tile_center(c, r)
    p.collected.connect(_on_pickup_collected)
    world.add_child(p)
    if kind == "shard":
        shards_total += 1


func _spawn_laser(c: int, r: int) -> void:
    var laser := LaserBarrier.new()
    laser.position = _tile_center(c, r)
    laser.phase = float(c * 13 + r * 7) / 19.0
    world.add_child(laser)


func _spawn_door(c: int, r: int) -> void:
    var d := Door.new()
    d.position = _tile_center(c, r)
    world.add_child(d)


func _spawn_exit(c: int, r: int) -> void:
    var e := ExitPortal.new()
    e.position = _tile_center(c, r)
    e.reached.connect(_on_exit_reached)
    world.add_child(e)


func _spawn_saws() -> void:
    for s in data.get("saws", []):
        var row: int = s["row"]
        var c1: int = s["c1"]
        var c2: int = s["c2"]
        var saw := Saw.new()
        saw.x_a = c1 * TILE + TILE / 2.0
        saw.x_b = c2 * TILE + TILE / 2.0
        saw.speed = float(s.get("speed", 110))
        saw.phase = float(s.get("phase", 0))
        var y: float = OFFSET.y + row * TILE + TILE / 2.0 + float(s.get("yoff", 0))
        saw.position = Vector2(saw.x_a, y)
        world.add_child(saw)


func _spawn_platforms() -> void:
    for pd in data.get("platforms", []):
        var w: int = pd["w"]
        var row: int = pd["row"]
        var cx: float = pd["cx"]
        var mp := MovingPlatform.new()
        mp.size = Vector2(w * TILE, 16)
        mp.origin = Vector2(cx * TILE, OFFSET.y + row * TILE + 8.0)
        mp.axis = Vector2.RIGHT if str(pd.get("axis", "x")) == "x" else Vector2.DOWN
        mp.amplitude = float(pd["amp"]) * TILE
        mp.speed = float(pd.get("speed", 1.0))
        mp.phase = float(pd.get("phase", 0.0))
        world.add_child(mp)


func _spawn_player(pos: Vector2) -> void:
    player = Player.new()
    player.position = pos
    player.configure(data["abilities"])
    var camera := Camera2D.new()
    camera.name = "LevelCamera"
    camera.enabled = cols > 40
    camera.position_smoothing_enabled = cols > 40
    camera.position_smoothing_speed = 8.0
    camera.limit_left = 0
    camera.limit_right = cols * TILE
    camera.limit_top = 0
    camera.limit_bottom = OFFSET.y + ROWS * TILE
    player.add_child(camera)
    world.add_child(player)
    player.died.connect(_on_player_died)
    player.dimension_changed.connect(_on_dimension_changed)
    player.ability_denied.connect(_on_ability_denied)
    player.time_freeze_started.connect(_on_freeze_started)


# ------------------------------------------------------------------ callbacks
func _on_pickup_collected(kind: String, where: Vector2) -> void:
    if kind == "shard":
        shards_collected += 1
        Sfx.play("collect")
        Burst.spawn(world, where, Color("ffe14d"), 14, 170.0)
        hud.notify("+%d DATA SHARD" % SHARD_SCORE, 1.0)
    else:
        has_key = true
        Sfx.play("key")
        Burst.spawn(world, where, Color("ffb02e"), 26, 230.0)
        for d in get_tree().get_nodes_in_group("doors"):
            d.open()
        hud.notify("KEY ACQUIRED - BARRIER DISABLED", 2.5)


func _on_dimension_changed(_dim: int) -> void:
    queue_redraw()


func _on_ability_denied(_ability: String) -> void:
    hud.notify("PHASE BLOCKED - SOLID MATTER", 1.2)


func _on_freeze_started() -> void:
    hud.notify("TIME FROZEN", 1.0)


func _on_player_died() -> void:
    if finished:
        return
    deaths += 1
    Sfx.play("die")
    GameState.add_glitch(1.0)
    Burst.spawn(world, player.position, Color("ff4d6d"), 34, 300.0)
    hud.notify("SYSTEM FAILURE  -%d" % DEATH_PENALTY, 1.2)
    _respawn_pending = true
    get_tree().create_timer(0.7, false).timeout.connect(_respawn)


func _respawn() -> void:
    if _respawn_pending and not finished and is_inside_tree():
        _build_world()


func _on_exit_reached() -> void:
    if finished or not player.alive:
        return
    # The exit is never allowed to complete unless the player has collected the access key.
    # The full-height D barrier should make this redundant, but this guard prevents bypass exploits.
    if not has_key:
        hud.notify("ACCESS DENIED - FIND THE KEY TO OPEN THE REACTOR BARRIER", 2.2)
        return
    finished = true
    player.set_physics_process(false)
    GameState.time_frozen = false
    Sfx.play("win")
    GameState.add_glitch(1.0)
    Burst.spawn(world, player.position, Color("7dffb2"), 44, 340.0)
    hud.notify("SECTOR CLEARED", 3.0)

    var par: float = data["par_time"]
    var time_bonus := int(maxf(0.0, par - elapsed)) * TIME_SCORE
    var score := calc_score()
    var max_score := BASE_SCORE + shards_total * SHARD_SCORE + int(par * 0.5) * TIME_SCORE
    var ratio := float(score) / float(max_score)
    var rank := "C"
    if ratio >= 0.9:
        rank = "S"
    elif ratio >= 0.75:
        rank = "A"
    elif ratio >= 0.55:
        rank = "B"
    var result := {
        "level": level_index,
        "name": data["name"],
        "time": elapsed,
        "par": par,
        "time_bonus": time_bonus,
        "shards": shards_collected,
        "shards_total": shards_total,
        "shard_points": shards_collected * SHARD_SCORE,
        "deaths": deaths,
        "death_penalty": deaths * DEATH_PENALTY,
        "base": BASE_SCORE,
        "score": score,
        "max_score": max_score,
        "rank": rank,
    }
    await get_tree().create_timer(0.9).timeout
    if is_inside_tree():
        completed.emit(result)


func calc_score() -> int:
    var par: float = data["par_time"]
    var time_bonus := int(maxf(0.0, par - elapsed)) * TIME_SCORE
    return maxi(0, BASE_SCORE + shards_collected * SHARD_SCORE + time_bonus - deaths * DEATH_PENALTY)


# ------------------------------------------------------------------- drawing
func _draw() -> void:
    for b in _blocks:
        var rect: Rect2 = b["rect"]
        var ch: String = b["ch"]
        if ch == "#":
            _draw_wall(rect)
        else:
            _draw_phase_block(rect, 0 if ch == "A" else 1)


func _draw_wall(rect: Rect2) -> void:
    draw_rect(rect, Color("101329"))
    draw_rect(Rect2(rect.position + Vector2(2, 2), Vector2(maxf(0.0, rect.size.x - 4), maxf(0.0, rect.size.y - 4))), Color("171a38"))
    draw_rect(Rect2(rect.position, Vector2(rect.size.x, minf(4.0, rect.size.y))), Color(theme_color, 0.18))
    draw_line(rect.position + Vector2(2, 3), rect.position + Vector2(rect.size.x - 2, 3), Color(theme_color, 0.42), 1.0)
    var line_col := Color(theme_color, 0.12)
    var x := rect.position.x + TILE
    while x < rect.end.x - 1.0:
        draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), line_col, 1.0)
        x += TILE
    var y := rect.position.y + TILE
    while y < rect.end.y - 1.0:
        draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), line_col, 1.0)
        y += TILE
    draw_rect(rect, Color(theme_color, 0.62), false, 2.0)
    draw_line(rect.position + Vector2(2, rect.size.y - 2), rect.end - Vector2(2, 2), Color("040610", 0.7), 2.0)


func _draw_phase_block(rect: Rect2, which: int) -> void:
    var col := Color("22e6ff") if which == 0 else Color("ff3df2")
    var active := player != null and player.dimension == which
    if active:
        draw_rect(rect, Color(col, 0.30))
        draw_rect(rect, col, false, 2.0)
        draw_rect(Rect2(rect.position + Vector2(3, 3), Vector2(rect.size.x - 6.0, 3)), Color(col, 0.6))
    else:
        draw_rect(rect, Color(col, 0.05))
        var tl := rect.position
        var tr_pt := Vector2(rect.end.x, rect.position.y)
        var br := rect.end
        var bl := Vector2(rect.position.x, rect.end.y)
        var dash_col := Color(col, 0.4)
        draw_dashed_line(tl, tr_pt, dash_col, 1.5, 5.0)
        draw_dashed_line(tr_pt, br, dash_col, 1.5, 5.0)
        draw_dashed_line(br, bl, dash_col, 1.5, 5.0)
        draw_dashed_line(bl, tl, dash_col, 1.5, 5.0)
