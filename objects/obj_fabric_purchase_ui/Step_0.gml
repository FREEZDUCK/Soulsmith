/// Toggle panel, scroll list, select an entry, then place the Fabric in the world
if (keyboard_check_pressed(vk_tab) && !instance_exists(global.controlled_unit)) {
    open = !open;
}
slide = lerp(slide, open ? 1 : 0, 0.2);

// Same base (1366x768) units as Draw GUI, so hit-testing matches the scaled panel
var _s = scr_gui_scale();
var _gw = display_get_gui_width() / _s;
var _gh = display_get_gui_height() / _s;
var _panel_y = _gh - panel_h * slide;
var _mouse_gui_x = device_mouse_x_to_gui(0) / _s;
var _mouse_gui_y = device_mouse_y_to_gui(0) / _s;
var _over_panel = open && (_mouse_gui_y >= _panel_y) && (_mouse_gui_y <= _gh);
over_panel = _over_panel;

if (_over_panel) {
    global.ui_hover = true;

    if (mouse_wheel_up()) scroll_x -= 30;
    if (mouse_wheel_down()) scroll_x += 30;
}

var _total_w = array_length(purchasable) * (entry_w + entry_pad) + entry_pad;
var _max_scroll = max(0, _total_w - _gw);
scroll_x = clamp(scroll_x, 0, _max_scroll);

if (_over_panel && !global.click_consumed && mouse_check_button_pressed(mb_left)) {
    var _rel_x = _mouse_gui_x + scroll_x - entry_pad;
    var _index = floor(_rel_x / (entry_w + entry_pad));
    if (_index >= 0 && _index < array_length(purchasable)) {
        var _entry = purchasable[_index];
        if (global.gold >= _entry.cost) {
            placement_mode = true;
            placement_type = _entry.key;
            placement_sprite = _entry.sprite;
        }
    }
    global.click_consumed = true;
}

if (placement_mode) {
    global.ui_hover = true;

    var _grid = 16;
    // Hologram (and the placed Fabric) centered exactly on the mouse pointer: no grid snapping,
    // and the mouse is converted with the current camera view so it matches this frame's draw.
    var _mouse_world = scr_mouse_to_world();
    var _px = _mouse_world[0];
    var _py = _mouse_world[1];

    var _w = ceil(sprite_get_width(placement_sprite) / _grid) * _grid;
    var _h = ceil(sprite_get_height(placement_sprite) / _grid) * _grid;
    var _left = _px - _w / 2;
    var _top = _py - _h / 2;

    placement_x = _px;
    placement_y = _py;
    placement_w = _w;
    placement_h = _h;
    placement_left = _left;
    placement_top = _top;

    placement_valid = scr_fabric_area_free(_left, _top, _w, _h, noone);

    if (!global.click_consumed && !_over_panel && mouse_check_button_pressed(mb_left)) {
        if (placement_valid) {
            var _entry_cost = 0;
            for (var _i = 0; _i < array_length(purchasable); _i++) {
                if (purchasable[_i].key == placement_type) {
                    _entry_cost = purchasable[_i].cost;
                    break;
                }
            }
            if (global.gold >= _entry_cost) {
                var _obj_index = asset_get_index("fabric_" + placement_type);
                if (_obj_index != -1) {
                    global.gold -= _entry_cost;
                    instance_create_layer(_px, _py, "Instances", _obj_index);
                }
            }
            placement_mode = false;
        }
        global.click_consumed = true;
    }

    if (mouse_check_button_pressed(mb_right)) {
        placement_mode = false;
        global.click_consumed = true;
    }
}
