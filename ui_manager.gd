extends Control

class_name UIManager

@onready
var button_container = get_node("/root/Node2D/Control/VBoxContainer")

func _ready():
	return
	GameManager.initUI()

func create_button(action_name, action_id):
	var button = Button.new()
	button.text = action_name
	button.pressed.connect(GameManager.change_action.bind(action_id))
	button_container.add_child(button)

# todo: need graphics like Legioncraft
