class_name MetadataSection extends PersistentDataSection

func _init(file: PersistentDataFile):
	file.register_metadata(self)
