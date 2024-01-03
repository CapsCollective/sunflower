class_name ValidationManager

const Utils = preload("res://assets/common/scripts/utils.gd") 
const validations = []

func run_all_validations() -> bool:
	Utils.push_info("Running all validations...")
	var result = true
	for validation in validations:
		var v = validation.new()
		Utils.push_info("- Running validation for ", v.get_name(), "...")
		if not v.run_validations():
			push_error("    VALIDATION FAILED")
			result = false
	if result:
		Utils.push_info("All validations passed!")
	else:
		push_error("Some validations failed - see above for more info.")
	return result

class Validation:
	
	func get_name() -> String:
		return "Validation"
	
	func run_validations() -> bool:
		return true
