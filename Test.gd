extends Node2D

@onready var c : Character = $Character

func _ready():
	var ob : OptionButton = $CanvasLayer/OptionButton
	for i in c.defined_animations.size():
		ob.add_item(c.defined_animations[i].name)


func _on_option_button_item_selected(index):
	c.animation_player.play("character_animations/" + c.defined_animations[index].name)
