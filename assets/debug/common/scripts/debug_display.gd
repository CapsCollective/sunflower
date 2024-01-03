extends Control

@onready var version_label: Label = $VersionLabel
@onready var tab_container: TabContainer = $TabContainer

func _ready():
	version_label.text = "v" + Utils.get_version()
	set_open(false)
	tab_container.tab_changed.connect(func(_i):
		notify_tab_state(tab_container.get_previous_tab(), false)
		notify_tab_state(tab_container.current_tab, true)
	)

func _input(event):
	if event.is_action_pressed("toggle_debug"):
		set_open(not is_open())
		get_viewport().set_input_as_handled()

func is_open() -> bool:
	return visible

func set_open(open: bool):
	visible = open
	notify_tab_state(tab_container.current_tab, open)

func notify_tab_state(tab_idx: int, open: bool):
	var tab = tab_container.get_tab_control(tab_idx)
	if tab is DebugSection:
		if open:
			tab.on_opened()
		else:
			tab.on_closed()
	
