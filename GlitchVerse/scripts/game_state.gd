extends Node
## Global game state, input map set-up and save data (autoload: GameState).

const SAVE_PATH := "user://glitchverse_save.cfg"

var current_level := 0
var level_results: Dictionary = {}   # level index -> result dictionary (this run)
var best_scores: Dictionary = {}     # level index -> best score ever
var unlocked := 1                    # number of unlocked levels
var time_frozen := false             # true while the player's time-freeze is active
var glitch_amount := 0.0             # drives the post-processing shader


func _ready() -> void:
    _setup_input()
    load_progress()


# ---------------------------------------------------------------- input map
func _setup_input() -> void:
    _bind("move_left", [KEY_A, KEY_LEFT])
    _bind("move_right", [KEY_D, KEY_RIGHT])
    _bind("jump", [KEY_W, KEY_UP, KEY_SPACE])
    _bind("flip_gravity", [KEY_Q, KEY_SHIFT])
    _bind("switch_dimension", [KEY_E])
    _bind("freeze_time", [KEY_F])
    _bind("dash", [KEY_X, KEY_CTRL])
    _bind("restart_level", [KEY_R])
    _bind("pause", [KEY_ESCAPE, KEY_P])


func _bind(action: String, keys: Array) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action, 0.2)
    for k in keys:
        var ev := InputEventKey.new()
        ev.physical_keycode = k
        InputMap.action_add_event(action, ev)


# ------------------------------------------------------------------ progress
func start_new_game() -> void:
    level_results.clear()
    current_level = 0


func record_result(index: int, result: Dictionary) -> void:
    var score: int = result["score"]
    if not level_results.has(index) or score >= int(level_results[index]["score"]):
        level_results[index] = result
    if score > int(best_scores.get(index, 0)):
        best_scores[index] = score
    unlocked = mini(maxi(unlocked, index + 2), Levels.LEVELS.size())
    save_progress()


func get_total_score() -> int:
    var total := 0
    for k in level_results.keys():
        total += int(level_results[k]["score"])
    return total


func unlock_all() -> void:
    unlocked = Levels.LEVELS.size()
    save_progress()


func add_glitch(amount: float) -> void:
    glitch_amount = maxf(glitch_amount, amount)


func save_progress() -> void:
    var cfg := ConfigFile.new()
    cfg.set_value("progress", "unlocked", unlocked)
    cfg.set_value("progress", "best_scores", best_scores)
    cfg.save(SAVE_PATH)


func load_progress() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(SAVE_PATH) == OK:
        unlocked = int(cfg.get_value("progress", "unlocked", 1))
        best_scores = cfg.get_value("progress", "best_scores", {})
