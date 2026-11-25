/// Fabric purchase/placement UI: TAB toggles a sliding panel of buyable Fabrics
fnt_regular = font_bold; // native font resource: crisp at its own pixel size
spr_panel = sprite_add("assets/sprites/ui/panels/mono.png", 1, false, false, 0, 0);
var _ns = sprite_nineslice_create();
_ns.enabled = true;
_ns.left = 4;
_ns.top = 4;
_ns.right = 4;
_ns.bottom = 4;
sprite_set_nineslice(spr_panel, _ns);

open = false;
slide = 0;
scroll_x = 0;

// Sized for font_basic (28px line height): sprite on top, name and price underneath
panel_h = 124;
entry_w = 116;
entry_h = 108;
entry_pad = 10;
over_panel = false; // mouse is over the open panel (read by obj_camera so the wheel scrolls the list, not the zoom)

placement_mode = false;
placement_type = "";
placement_sprite = -1;
placement_valid = false;
placement_x = 0;
placement_y = 0;
placement_w = 0;
placement_h = 0;
placement_left = 0;
placement_top = 0;

// Build the list of purchasable Fabrics (info.cost != "noone")
purchasable = [];
var _names = variable_struct_get_names(global.fabric_data);
for (var _i = 0; _i < array_length(_names); _i++) {
    var _key = _names[_i];
    var _entry = variable_struct_get(global.fabric_data, _key);
    var _cost = _entry.info.cost;
    if (is_string(_cost) && _cost == "noone") continue;

    var _spr = scr_fabric_make_sprite(_key, _entry.info);
    // Middle Center origin, matching the placed Fabric so the ghost lines up with the footprint grid
    sprite_set_offset(_spr, sprite_get_width(_spr) div 2, sprite_get_height(_spr) div 2);
    array_push(purchasable, {
        key: _key,
        sprite: _spr,
        cost: is_string(_cost) ? real(_cost) : _cost, // JSON may store cost as a string (e.g. "120")
    });
}
