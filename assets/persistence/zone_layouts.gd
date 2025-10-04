extends PersistentDataFile

func get_file_name() -> String:
	return "res://assets/content/zones/initial_zones_data.json"

const Metadata = preload("res://assets/persistence/metadata.gd")
@onready var metadata: Metadata = Metadata.new(self)

const ZonesData = preload("res://assets/persistence/zones_data.gd")
@onready var initial_zones: ZonesData = ZonesData.new(self)

func save_file():
	super()
	Log.info("Serialisation", "Saved initial zones to disk as ", get_file_name())
