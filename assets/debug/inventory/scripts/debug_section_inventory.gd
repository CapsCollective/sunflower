extends DebugSection

const items_dt: Datatable = preload("res://assets/datatables/tables/items_dt.tres")
const inventory_row_scn = preload("res://assets/debug/inventory/scenes/inventory_row.tscn")

@onready var inventory_list: Container = %InventoryList
@onready var item_options: OptionButton = %ItemOptions
@onready var item_count: Range = %ItemCount
@onready var add_button: Button = %AddButton
var all_item_ids = []

func _ready():
	add_button.button_up.connect(add_items)
	GameManager.inventory_updated.connect(on_inventory_updated)
	for item in items_dt:
		all_item_ids.append(item.key)
		item_options.add_item(item.value.name)
	refresh_inventory()

func on_inventory_updated(_item_id, _count):
	refresh_inventory()

func refresh_inventory():
	for child in inventory_list.get_children():
		child.queue_free()
	
	for item in items_dt:
		if GameManager.get_item_count(item.key) > 0:
			var row = inventory_row_scn.instantiate()
			inventory_list.add_child(row)
			row.item_id = item.key

func add_items():
	GameManager.change_item_count(all_item_ids[item_options.selected], int(item_count.value))
