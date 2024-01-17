extends DebugSection

@onready var refresh_button: Button = %RefreshButton
@onready var save_button: Button = %SaveButton
@onready var reset_button: Button = %ResetButton
@onready var savegame_text: RichTextLabel = %SavegameText
@onready var filepath_label: Label = %FilepathLabel
var regex: RegEx = RegEx.new()

func _ready():
	regex.compile("(\"[A-z0-9]*\":)")
	refresh_button.button_up.connect(on_refresh_button_up)
	save_button.button_up.connect(on_save_button_up)
	reset_button.button_up.connect(on_reset_button_up)

func on_opened():
	refresh_content()

func on_refresh_button_up():
	refresh_content()

func on_save_button_up():
	Savegame.save_file()

func on_reset_button_up():
	Savegame.reset_file()
	#TODO Reload scene or safe equivalent
	on_opened()

func refresh_content():
	var json_string = JSON.stringify(Savegame.get_dump(), "\t")
	json_string = regex.sub(json_string, "[b]$1[/b]", true)
	savegame_text.text = json_string
	var filename = Savegame.get_file_name()
	filepath_label.text = filename
	filepath_label.tooltip_text = ProjectSettings.globalize_path(filename)
