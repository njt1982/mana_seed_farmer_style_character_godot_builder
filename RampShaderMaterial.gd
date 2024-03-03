extends ShaderMaterial

class_name RampShaderMaterial

var type : String
var num_styles : int = 0

func _init():
	shader = preload("./ramp.gdshader")

func set_ramp(layer_name: String, _type : String):
	self.type = _type
	
	var base_ramp : Texture2D
	var seed_ramp : Texture2D
	var seed2_ramp : Texture2D
	
	var base_ramp_steps : int = 0
	var seed_ramp_steps : int = 0
	var seed2_ramp_steps : int = 0
	
	self.num_styles = 0
	
	match layer_name:
		"01body" :
			base_ramp = load( "res://assets/_supporting files/palettes/base ramps/skin color base ramp.png")
			seed_ramp = load("res://assets/_supporting files/palettes/mana seed skin ramps.png")
			base_ramp_steps = 5
			seed_ramp_steps = base_ramp_steps
			self.num_styles = 17
			
		"13hair" :
			base_ramp = load( "res://assets/_supporting files/palettes/base ramps/hair color base ramp.png")
			seed_ramp = load("res://assets/_supporting files/palettes/mana seed hair ramps.png")
			base_ramp_steps = 6
			seed_ramp_steps = base_ramp_steps
			self.num_styles = 57

		_:
			match self.type:
				"00a":
					base_ramp = load( "res://assets/_supporting files/palettes/base ramps/3-color base ramp (00a).png")
					seed_ramp = load("res://assets/_supporting files/palettes/mana seed 3-color ramps.png")
					base_ramp_steps = 4
					seed_ramp_steps = base_ramp_steps
					self.num_styles = 47
				"00b":
					base_ramp = load( "res://assets/_supporting files/palettes/base ramps/4-color base ramp (00b).png")
					seed_ramp = load("res://assets/_supporting files/palettes/mana seed 4-color ramps.png")
					base_ramp_steps = 5
					seed_ramp_steps = base_ramp_steps
					self.num_styles = 57
				"00c":
					base_ramp = load( "res://assets/_supporting files/palettes/base ramps/2x 3-color base ramps (00c).png")
					seed_ramp = load("res://assets/_supporting files/palettes/mana seed 3-color ramps.png")
					seed2_ramp = seed_ramp
					base_ramp_steps = 8
					seed_ramp_steps = 4
					seed2_ramp_steps = 4
					self.num_styles = 47
				"00d":
					base_ramp = load( "res://assets/_supporting files/palettes/base ramps/4-color + 3-color base ramps (00d).png")
					seed_ramp = load("res://assets/_supporting files/palettes/mana seed 4-color ramps.png")
					seed2_ramp = load("res://assets/_supporting files/palettes/mana seed 3-color ramps.png")
					base_ramp_steps = 9
					seed_ramp_steps = 5
					seed2_ramp_steps = 4
					self.num_styles = 57

				_:
					print_debug("Unknown ramp type: " + _type)
	
	set_shader_parameter("base_ramp", base_ramp)
	set_shader_parameter("base_ramp_steps", base_ramp_steps)

	set_shader_parameter("seed_ramp", seed_ramp)
	set_shader_parameter("seed_ramp_steps", seed_ramp_steps)

	set_shader_parameter("seed2_ramp", seed2_ramp)
	set_shader_parameter("seed2_ramp_steps", seed2_ramp_steps)


func set_style(style : int):
	style = clampi(style, 0, self.num_styles - 1)
	set_shader_parameter("style", style)
