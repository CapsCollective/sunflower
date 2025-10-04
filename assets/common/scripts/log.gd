class_name Log

static func info(category_name: String, ...args: Array):
	print("LOG_INFO_" + category_name + ": " + "".join(args))

static func warn(category_name: String, ...args: Array):
	push_warning("LOG_WARN_" + category_name + ": ", "".join(args))

static func error(category_name: String, ...args: Array):
	push_error("LOG_ERROR_" + category_name + ": ", "".join(args))
