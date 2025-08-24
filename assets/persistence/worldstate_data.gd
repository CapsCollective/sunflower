extends PersistentDataSection

const PD_SECTION_WORLDSTATE = "worldstate"
const PD_SECTION_WORLDSTATE_BLACKBOARD = "blackboard"

const DEFAULT_BLACKBOARD = {
	"farmer_met": false,
	"farmer_questions_returning": false,
	"farmer_hunger": 0,
	"farmer_mood": 0,
	"scientist_met": false,
	"scientist_questions_returning": false,
	"scientist_hunger": 0,
	"scientist_mood": 0,
}

var blackboard: Dictionary # <String, Variant>

func get_tag() -> String:
	return PD_SECTION_WORLDSTATE

func serialise() -> Dictionary:
	return {
		PD_SECTION_WORLDSTATE_BLACKBOARD: blackboard
	}

func deserialise(data: Dictionary) -> DeserialisationResult:
	blackboard = data.get(PD_SECTION_WORLDSTATE_BLACKBOARD, DEFAULT_BLACKBOARD.duplicate(true))
	return DeserialisationResult.OK
