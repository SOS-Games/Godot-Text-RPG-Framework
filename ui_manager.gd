extends Control

class_name UIManager

@onready
var button_container = get_node("/root/Node2D/Control/VBoxContainer")

func _ready():
	GameManager.initUI()
	return

	# create 3 buttons for each action
	create_button("Mining", "mining")
	create_button("Fishing", "fishing")
	create_button("Woodcutting", "woodcutting")
	'''
	var mining_button = Button.new()
	mining_button.text = "Mining"
	mining_button.pressed.connect(GameManager.change_action.bind("mining"))

	var fishing_button = Button.new()
	fishing_button.text = "Fishing"
	fishing_button.pressed.connect(GameManager.change_action.bind("fishing"))

	var woodcutting_button = Button.new()
	woodcutting_button.text = "Woodcutting"
	woodcutting_button.pressed.connect(GameManager.change_action.bind("woodcutting"))
	'''
	#var button_container = get_node("/root/Node2D/Control/VBoxContainer")
	#button_container.add_child(mining_button)
	#button_container.add_child(fishing_button)
	#button_container.add_child(woodcutting_button)

func create_button(action_name, action_id):
	var button = Button.new()
	button.text = action_name
	button.pressed.connect(GameManager.change_action.bind(action_id))
	button_container.add_child(button)
