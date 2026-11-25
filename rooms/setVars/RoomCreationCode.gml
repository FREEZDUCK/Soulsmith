/// setVars - Global variable initialization
/// This room runs once at game start, before any other room.

// Guard: prevent initializing globals more than once (e.g. after game_restart)
if (!variable_global_exists("varsInitialized") || !global.varsInitialized)
{
	// Project version - update whenever the project version changes
	global.version = "0.0.24v";

	// Economy
	global.start_gold = 50000; // enough for a Furnace (100) + a Hatcher (150) + a little spare
	global.gold = global.start_gold;

	// Shared 9-slice panel sprite used by the info panels (scr_ui_info_panel)
	global.spr_ui_panel = sprite_add("assets/sprites/ui/panels/mono.png", 1, false, false, 0, 0);
	var _panel_ns = sprite_nineslice_create();
	_panel_ns.enabled = true;
	_panel_ns.left = 4;
	_panel_ns.top = 4;
	_panel_ns.right = 4;
	_panel_ns.bottom = 4;
	sprite_set_nineslice(global.spr_ui_panel, _panel_ns);

	// Ending screen: latched so it is shown at most once per game (see obj_ending_screen)
	global.ending_triggered = false;

	// Defeat: set when the Core's HP reaches 0 (see fabric_core), cleared when the Play room starts
	global.game_over = false;

	// Fabric / Stuff data, loaded once from disk
	global.fabric_data = scr_json_load("data/fabric.json");
	global.stuff_data = scr_json_load("data/stuff.json");
	// Material tiers in the exact order written in stuff.json (first entry = first material).
	// Struct key order is arbitrary, so the order is read from the file text itself.
	global.stuff_order = [];
	var _ordered_keys = scr_json_key_order("data/stuff.json");
	for (var _i = 0; _i < array_length(_ordered_keys); _i++) {
		if (variable_struct_exists(global.stuff_data, _ordered_keys[_i])) {
			array_push(global.stuff_order, _ordered_keys[_i]);
		}
	}

	// Unit data, loaded once from disk. global.unit_by_material maps a Stuff material (e.g.
	// "debris") to the Unit key that hatches from it, built from each Unit's "material" field
	// so new Units/materials only require editing data/unit.json.
	global.unit_data = scr_json_load("data/unit.json");
	global.unit_by_material = {};
	var _unit_keys = variable_struct_get_names(global.unit_data);
	for (var _i = 0; _i < array_length(_unit_keys); _i++) {
		var _unit_key = _unit_keys[_i];
		var _unit_entry = variable_struct_get(global.unit_data, _unit_key);
		if (variable_struct_exists(_unit_entry, "material")) {
			global.unit_by_material[$ _unit_entry.material] = _unit_key;
		}
	}

	// Enemy data, loaded once from disk (see data/enemy.json; same shape/mechanics as Units)
	global.enemy_data = scr_json_load("data/enemy.json");

	// Selection state
	global.selected_fabric = noone;
	global.hovered_stuff = noone;
	global.hovered_unit = noone;
	global.selected_unit_info = noone;
	global.controlled_unit = noone;

	global.varsInitialized = true;
}

// Proceed to the title screen
room_goto(TitleScreen);
