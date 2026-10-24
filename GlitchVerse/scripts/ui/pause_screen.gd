class_name PauseScreen
extends Control
## Pause overlay (keeps running while the tree is paused).

signal resume_pressed
signal restart_pressed
signal menu_pressed


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    theme = UITheme.get_theme()
    anchor_right = 1.0
    anchor_bottom = 1.0
    add_child(UITheme.backdrop(0.7))
    var center := UITheme.centered()
    add_child(center)
    var panel := PanelContainer.new()
    center.add_child(panel)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 12)
    panel.add_child(box)
    var title := UITheme.label("PAUSED", 48, UITheme.CYAN)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(title)
    var resume := UITheme.button("RESUME", 300)
    resume.pressed.connect(func(): resume_pressed.emit())
    box.add_child(resume)
    var restart := UITheme.button("RESTART SECTOR", 300)
    restart.pressed.connect(func(): restart_pressed.emit())
    box.add_child(restart)
    var menu := UITheme.button("MAIN MENU", 300)
    menu.pressed.connect(func(): menu_pressed.emit())
    box.add_child(menu)
    resume.grab_focus.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        resume_pressed.emit()
        accept_event()
