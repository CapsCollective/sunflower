extends DebugSection

var regex: RegEx = RegEx.new()

@onready var refresh_button: Button = %RefreshButton
@onready var save_button: Button = %SaveButton
@onready var reset_button: Button = %ResetButton
@onready var load_content_button: Button = %LoadContentButton
@onready var savegame_text: RichTextLabel = %SavegameText
@onready var filepath_button: Button = %FilepathButton

func _ready():
	regex.compile("(\"[A-z0-9]*\":)")
	refresh_button.button_up.connect(on_refresh_button_up)
	save_button.button_up.connect(on_save_button_up)
	load_content_button.button_up.connect(on_load_content_button_up)
	reset_button.button_up.connect(on_reset_button_up)

func on_opened():
	refresh_details()

func on_closed():
	load_content_button.visible = true
	savegame_text.text = String()

func on_refresh_button_up():
	refresh_details()

func on_save_button_up():
	Savegame.save_file()

func on_load_content_button_up():
	load_content_button.visible = false
	savegame_text.text = "loading..."
	await get_tree().create_timer(0.1).timeout
	refresh_details()

func on_reset_button_up():
	Savegame.reset_file()
	get_tree().reload_current_scene()
	on_opened()

func refresh_details():
	var filename = Savegame.get_file_name()
	filepath_button.text = filename
	var filepath = ProjectSettings.globalize_path(filename)
	filepath_button.tooltip_text = filepath
	filepath_button.pressed.connect(func(): OS.shell_show_in_file_manager(filepath))
	if not load_content_button.visible:
		load_file_content()

func load_file_content():
	var json_string = JSON.stringify(Savegame.get_dump(), "\t")
	json_string = regex.sub(json_string, "[b]$1[/b]", true)
	savegame_text.text = json_string
