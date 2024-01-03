extends PersistentDataFile

func get_file_name() -> String:
	return "user://savegame.save"

const Metadata = preload("res://assets/persistence/metadata.gd")
@onready var metadata: Metadata = Metadata.new(self)

const ExampleData = preload("res://assets/persistence/example_data.gd")
@onready var example: ExampleData = ExampleData.new(self)

const PlayerData = preload("res://assets/persistence/player_data.gd")
@onready var player: PlayerData = PlayerData.new(self)

func save_file():
	super()
	Utils.log_info("Serialisation", "Saved game to disk as ", get_file_name())
