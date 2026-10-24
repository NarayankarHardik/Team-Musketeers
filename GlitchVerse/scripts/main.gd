extends Node
## Scene manager: menu -> level select -> level -> results -> final report.
## Also owns the full-screen glitch post-processing layer.

var ui: CanvasLayer
var fx_mat: ShaderMaterial
var level: GameLevel
var menu_bg: GlitchBackground
var current_screen: Control
var pause_screen: Control


func _ready() -> void:
    randomize()
    ui = CanvasLayer.new()
    ui.layer = 20
    add_child(ui)
    _setup_fx()
    show_menu()


func _setup_fx() -> void:
    var layer := CanvasLayer.new()
    layer.layer = 100
    add_child(layer)
    var rect := ColorRect.new()
    rect.anchor_right = 1.0
    rect.anchor_bottom = 1.0
    rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    fx_mat = ShaderMaterial.new()
    fx_mat.shader = load("res://shaders/glitch_post.gdshader")
    rect.material = fx_mat
    layer.add_child(rect)


func _process(delta: float) -> void:
    GameState.glitch_amount = move_toward(GameState.glitch_amount, 0.0, delta * 2.5)
    fx_mat.set_shader_parameter("glitch", GameState.glitch_amount)


# ------------------------------------------------------------------ helpers
func _drop(node: Node) -> void:
    if is_instance_valid(node):
        if node.get_parent() != null:
            node.get_parent().remove_child(node)
        node.queue_free()


func _clear() -> void:
    get_tree().paused = false
    GameState.time_frozen = false
    _drop(current_screen)
    _drop(pause_screen)
    _drop(level)
    _drop(menu_bg)
    current_screen = null
    pause_screen = null
    level = null
    menu_bg = null


func _set_screen(screen: Control) -> void:
    _drop(current_screen)
    ui.add_child(screen)
    current_screen = screen


# ------------------------------------------------------------------ screens
func show_menu() -> void:
    _clear()
    menu_bg = GlitchBackground.new()
    add_child(menu_bg)
    var m := MenuScreen.new()
    m.new_game.connect(_on_new_game)
    m.level_select.connect(show_level_select)
    m.quit_game.connect(_on_quit)
    _set_screen(m)


func show_level_select() -> void:
    _clear()
    menu_bg = GlitchBackground.new()
    add_child(menu_bg)
    var s := LevelSelectScreen.new()
    s.level_chosen.connect(_on_level_chosen)
    s.back_pressed.connect(show_menu)
    _set_screen(s)


func start_level(index: int) -> void:
    _clear()
    GameState.current_level = index
    level = GameLevel.new()
    level.level_index = index
    level.completed.connect(_on_level_completed)
    add_child(level)


func show_end() -> void:
    _drop(level)
    level = null
    _drop(menu_bg)
    menu_bg = GlitchBackground.new()
    add_child(menu_bg)
    var e := EndScreen.new()
    e.play_again_pressed.connect(_on_new_game)
    e.menu_pressed.connect(show_menu)
    _set_screen(e)


# ---------------------------------------------------------------- callbacks
func _on_new_game() -> void:
    GameState.start_new_game()
    start_level(0)


func _on_quit() -> void:
    get_tree().quit()


func _on_level_chosen(index: int) -> void:
    GameState.level_results.clear()
    start_level(index)


func _on_level_completed(result: Dictionary) -> void:
    GameState.record_result(level.level_index, result)
    var rs := ResultScreen.new()
    rs.result = result
    rs.is_last = level.level_index >= Levels.LEVELS.size() - 1
    rs.next_pressed.connect(_on_next)
    rs.retry_pressed.connect(_on_retry)
    rs.menu_pressed.connect(show_menu)
    _set_screen(rs)


func _on_next() -> void:
    if GameState.current_level >= Levels.LEVELS.size() - 1:
        show_end()
    else:
        start_level(GameState.current_level + 1)


func _on_retry() -> void:
    start_level(GameState.current_level)


# -------------------------------------------------------------------- pause
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause") and is_instance_valid(level) and not level.finished and not get_tree().paused:
        _open_pause()
        get_viewport().set_input_as_handled()


func _open_pause() -> void:
    var ps := PauseScreen.new()
    ps.resume_pressed.connect(_close_pause)
    ps.restart_pressed.connect(_on_retry)
    ps.menu_pressed.connect(show_menu)
    ui.add_child(ps)
    pause_screen = ps
    get_tree().paused = true


func _close_pause() -> void:
    get_tree().paused = false
    _drop(pause_screen)
    pause_screen = null
