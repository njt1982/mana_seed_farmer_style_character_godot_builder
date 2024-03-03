@tool
extends Node2D

class_name Character

@export_group("Character Config")
@export_dir var opt_dir = "res://assets/farmer_base_sheets"


var style_settings : Dictionary = {}

const LAYERS : Array[String] = [
	"00undr",
	"01body",
	"02sock",
	"03fot1",
	"04lwr1",
	"05shrt",
	"06lwr2",
	"07fot2",
	"08lwr3",
	"09hand",
	"10outr",
	"11neck",
	"12face",
	"13hair",
	"14head",
]

var animation_player : AnimationPlayer

func _set(property, value):
	if LAYERS.has(property):
		if value == "None":
			style_settings.erase(property)
			style_settings.erase(property + "_style")
		else:
			style_settings[property] = value
			style_settings[property + "_style"] = 0
			
			if property == "14head":
				if value.ends_with("_e"):
					self.set("13hair", "None")

		if Engine.is_editor_hint():
			refresh_sprites()
			notify_property_list_changed()
	elif property.ends_with("_style"):
		style_settings[property] = value
		if Engine.is_editor_hint():
			refresh_sprites()


func _get(property):
	if (LAYERS.has(property) or property.ends_with("_style")) and style_settings.has(property):
		return style_settings[property]
	

func _get_property_list() -> Array:
	var props : Array[Dictionary] = []
	
	for L in LAYERS:
		var files : Array[String] = []
		
		# Body is not optional! ;)
		if L != "01body":
			files.append("None")
		
		for f in DirAccess.get_files_at(opt_dir + "/" + L):
			if f.ends_with(".png"):
				f = f.replace("fbas_" + L + "_", "")
				f = f.replace(".png", "")
				files.append(f)
		
		if files.size() > 0:
			props.append({
				name = L,
				type = TYPE_STRING,
				usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_NIL_IS_VARIANT,
				hint = PROPERTY_HINT_ENUM,
				hint_string = ','.join(files)
			})
			
			if get(L):
				props.append({
					name = L + "_style",
					type = TYPE_INT,
					usage = PROPERTY_USAGE_DEFAULT,
					hint = PROPERTY_HINT_RANGE,
					hint_string = "0,50"  # TODO - calculate from the shader?
				})
			
	return props

var defined_animations = [
	{ "name": "idle",            "loop_mode": Animation.LOOP_NONE,   "frame_time": 1,                                      "length": 1.00, "frames": [0],                       "flip": 0 },
	{ "name": "walk_down",       "loop_mode": Animation.LOOP_LINEAR, "frame_time": 0.135,                                  "length": 0.81, "frames": [48, 49, 50, 48, 49, 50],  "flip": [0, 0, 0, 1, 1, 1] },
	{ "name": "walk_up",         "loop_mode": Animation.LOOP_LINEAR, "frame_time": 0.135,                                  "length": 0.81, "frames": [52, 53, 54, 52, 53, 54],  "flip": [0, 0, 0, 1, 1, 1] },
	{ "name": "walk_right",      "loop_mode": Animation.LOOP_LINEAR, "frame_time": 0.135,                                  "length": 0.81, "frames": [64, 65, 66, 67, 68, 69],  "flip": 0 },
	{ "name": "run_down",        "loop_mode": Animation.LOOP_LINEAR, "frame_time": [0, 0.080, 0.135, 0.250, 0.330, 0.385], "length": 0.50, "frames": [48, 49, 51, 48, 49, 51],  "flip": [0, 0, 0, 1, 1, 1] },
	{ "name": "run_up",          "loop_mode": Animation.LOOP_LINEAR, "frame_time": [0, 0.080, 0.135, 0.250, 0.330, 0.385], "length": 0.50, "frames": [52, 53, 55, 52, 53, 55],  "flip": [0, 0, 0, 1, 1, 1] },
	{ "name": "run_right",       "loop_mode": Animation.LOOP_LINEAR, "frame_time": [0, 0.080, 0.135, 0.250, 0.330, 0.385], "length": 0.50, "frames": [64, 65, 70, 67, 68, 71],  "flip": 0 },
	{ "name": "death",           "loop_mode": Animation.LOOP_NONE,   "frame_time": [0, 0.2, 0.4, 0.5, 0.7],                "length": 1.00, "frames": [178, 179, 180, 179, 180], "flip": 0 },
	{ "name": "forehand_strike", "loop_mode": Animation.LOOP_NONE,   "frame_time": [0, 0.18, 0.26, 0.34],                  "length": 0.64, "frames": [131, 132, 133, 133],      "flip": 0 },
	
]

func _ready():
	build_animations()
	refresh_sprites()
	animation_player.play("character_animations/idle")

func randomize_style():
	var rng = RandomNumberGenerator.new()
	
	var prop_list = get_property_list()
	for p in prop_list:
		if LAYERS.has(p.name):
			var values = p.hint_string.split(",")
			var i = rng.randi_range(0, values.size() - 1)
			set(p.name, values[i])

func randomize_colours():
	var rng = RandomNumberGenerator.new()
	for child in get_children():
		if child is Node2D and child.material is RampShaderMaterial:
			if child.material.type != "":
				set(child.name + "_style", rng.randi_range(0, child.material.num_styles))
				#child.material.set_style(rng.randi_range(0, child.material.num_styles))

func refresh_sprites():
	for L in LAYERS:
		
		var sprite : Sprite2D
		if has_node(L):
			sprite = get_node(L)
		else:
			sprite = Sprite2D.new()
			sprite.name = L
			sprite.hframes = 16
			sprite.vframes = 16
			
			# Apply shader
			sprite.material = RampShaderMaterial.new()
			add_child(sprite)

		var selected = get(L)
		if selected and selected is String:
			sprite.visible = true
			var filename = "fbas_%s_%s.png" % [L, selected]
			sprite.texture = load(opt_dir + "/" + L + "/" + filename)
			
			var first_underscore_pos = selected.find("_")
			if first_underscore_pos > -1:
				var ramp_name = selected.substr(first_underscore_pos + 1)
				# Occasionally there may be something like a trailing _e, remove it.
				if ramp_name.find("_") > -1:
					ramp_name = ramp_name.substr(0, ramp_name.find("_"))

				sprite.material.set_ramp(L, ramp_name)
				var style = get(L + "_style")
				if style == null:
					style = 0
				sprite.material.set_style(style)
			else:
				print_debug("No underscore found in: " + selected)

		else:
			sprite.visible = false

func build_animations():	
	animation_player = AnimationPlayer.new()
	add_child(animation_player)

	var ap_library = AnimationLibrary.new()
	animation_player.add_animation_library("character_animations", ap_library)

	for i in defined_animations.size():
		var da = defined_animations[i]
		var a = Animation.new()
		a.loop_mode = da.loop_mode
		a.length = da.length
		defined_animations[i].animation = a
		ap_library.add_animation(da.name, a)
		
	for L in LAYERS:
		for da in defined_animations:
			var a : Animation = da.animation
			var frame = a.add_track(Animation.TYPE_VALUE)
			var flip = a.add_track(Animation.TYPE_VALUE)
			a.track_set_path(frame, "%s:frame" % L)
			a.track_set_path(flip, "%s:flip_h" % L)
			
			a.track_set_interpolation_type(frame, Animation.INTERPOLATION_NEAREST)
			a.track_set_interpolation_type(flip,  Animation.INTERPOLATION_NEAREST)
			
			for i in da.frames.size():
				var t : float = da.frame_time[i] if typeof(da.frame_time) == TYPE_ARRAY else (i * da.frame_time)
				a.track_insert_key(frame, t, da.frames[i])
			
			if typeof(da.flip) == TYPE_ARRAY:
				for i in da.flip.size():
					var t : float = da.frame_time[i] if typeof(da.frame_time) == TYPE_ARRAY else (i * da.frame_time)
					a.track_insert_key(flip, t, da.flip[i])
			else:
				a.track_insert_key(flip, 0, da.flip)
