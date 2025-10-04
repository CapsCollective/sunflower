@tool
class_name Validations extends EditorScript

func _run():
	var manager = ValidationManager.new()
	manager.run_all_validations()

class ValidationManager:
	
	var validations = [DialogueScriptValidation]
	
	func run_all_validations() -> bool:
		print("Running all validations...")
		var result = true
		for validation in validations:
			var v = validation.new()
			print("- Running validation for ", v.get_name(), "...")
			if not v.run_validations():
				push_error("    VALIDATION FAILED")
				result = false
		if result:
			print("All validations passed!")
		else:
			push_error("Some validations failed - see above for more info.")
		return result

@abstract
class Validation:
	
	@abstract
	func get_name() -> String
	
	@abstract
	func run_validations() -> bool
