extends StaticBody3D

const RADIUS: int = 1

var crop_name: String
var grid_position: Vector2i

func initialise(target_crop_name: String):
	crop_name = target_crop_name

func serialise():
	var zone_crops = Savegame.player.crops.get(GameManager.current_zone.id, null)
	
	if not zone_crops:
		Savegame.player.crops[GameManager.current_zone.id] = {}
		zone_crops = Savegame.player.crops[GameManager.current_zone.id]
	
	zone_crops[grid_position] = {"name": crop_name}
	Savegame.save_file()
