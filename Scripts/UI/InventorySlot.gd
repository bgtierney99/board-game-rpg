extends Control
class_name InventorySlot

const SLOT_SCENE:PackedScene = preload("res://Scenes/UI/Menus/inventory_slot.tscn")
@onready var slot_type = null
@onready var item_button = $ItemButton
@onready var details_panel = $DetailsPanel
@onready var item_info = $DetailsPanel/MarginContainer/ItemInfo
@onready var usage_panel = $UsagePanel
@onready var vbox_container = $UsagePanel/MarginContainer/VBoxContainer
@onready var subviewport = $SubViewport
@onready var slot_type_label = $SubViewport/SlotTypeLabel
var item:lootData = null

signal back_pressed(slot)
signal equip_item(slot)
signal unequip_item(slot)
signal move_item(slot)
signal use_item(slot)
signal discard_item(slot)

# Called when the node enters the scene tree for the first time.
func _ready():
	details_panel.z_index = 5
	usage_panel.z_index = 5
	details_panel.visible = false
	usage_panel.visible = false
	item_button.pressed.connect(open_usage_panel)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

static func new_slot() -> InventorySlot:
	var new_slot:InventorySlot = SLOT_SCENE.instantiate()
	return new_slot

func _on_item_button_focus_entered():
	usage_panel.visible = false
	if item:
		details_panel.visible = true

func open_usage_panel():
	if item:
		usage_panel.visible = true
		vbox_container.get_children().back().grab_focus()
		vbox_container.get_child(0).focus_neighbor_top = vbox_container.get_children().back().get_path()
		vbox_container.get_children().back().focus_neighbor_bottom = vbox_container.get_child(0).get_path()
		#item_button.focus_mode = FOCUS_NONE

func _on_item_button_focus_exited():
	if get_viewport().gui_get_focus_owner() != null:
		print("There's a focus!")
		if get_viewport().gui_get_focus_owner().get_parent() != vbox_container:
			print("Parent is not %s: %s"%[vbox_container, get_viewport().gui_get_focus_owner().get_parent()])
			usage_panel.visible = false
	details_panel.visible = false

func set_empty():
	set_item(null)
	
func set_item(new_item:lootData):
	item = new_item
	if new_item:
		slot_type_label.text = ""
		var stat_text = ""
		var stat_value = new_item.getValue()
		for key in new_item.stats["additions"].keys():
			var stat_boost = new_item.stats["additions"][key]
			if stat_boost != 0:
				stat_text += "\n[color=#28ff00]%+d %s[/color]"%[stat_boost, key]
		for key in new_item.stats["modifiers"].keys():
			var stat_boost = new_item.stats["modifiers"][key]
			if stat_boost != 0:
				stat_text += "\n[color=#28ff00]%+d%% %s[/color]"%[stat_boost*100, key]
		var item_type_text = new_item.item_type
		if not new_item.item_type:
			item_type_text == "Action"
		item_info.text = "%s\n%s\n%s\nPrice: [color=#28ff00]%s[/color]"%[
			new_item.name,
			item_type_text,
			new_item.description,
			new_item.price]
		var effect_description = ""
		if new_item.effect:
			effect_description = "Effect: %s"%new_item.effect.description
		if stat_value > 0:
			item_info.text += "\nValue: [color=#28ff00]%s[/color]%s\n%s"%[
				stat_value,
				stat_text,
				effect_description]
		var model = new_item.model.instantiate()
		model.name = "Model"
		subviewport.add_child(model)
		setup_usage_panel(new_item)
	else:
		if slot_type:
			slot_type_label.text = slot_type
		if subviewport.has_node("Model"):
			var model = subviewport.get_node("Model")
			subviewport.remove_child(model)
			model.queue_free()

func setup_usage_panel(slot_item: lootData):
	clear_usage_buttons()
	setup_panel_buttons(slot_item)
	add_usage_button("Back", back_pressed)
	#vbox_container.add_theme_constant_override("separation", 4)
	vbox_container.alignment = BoxContainer.ALIGNMENT_END
	
func setup_panel_buttons(_slot_item: lootData):
	pass

func add_usage_button(text: String, button_signal: Signal):
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 32)
	button.text = text
	button.pressed.connect(select_option.bind(button_signal))
	vbox_container.add_child(button)
	button.focus_previous = get_path_to(item_button)
	button.focus_neighbor_left = vbox_container.get_child(0).get_path()
	button.focus_neighbor_right = vbox_container.get_children().back().get_path()
	if vbox_container.get_child_count() > 1:
		var button_index = vbox_container.get_children().find(button)
		var prev_button:Button = vbox_container.get_child(button_index-1)
		button.focus_neighbor_top = prev_button.get_path()
		prev_button.focus_neighbor_bottom = button.get_path()
	
	
func button_action(function, parameters):
	var callable = Callable(self, function)
	callable.callv(parameters)

func clear_usage_buttons():
	for child in vbox_container.get_children():
		child.queue_free()

func _on_use_button_pressed():
	select_option(use_item)
	
func _on_discard_button_pressed():
	select_option(discard_item)

func select_option(button_signal:Signal):
	button_signal.emit(self)
	item_button.focus_mode = FOCUS_ALL
	item_button.grab_focus()
