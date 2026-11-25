/// Fabric info/upgrade panel, screen-space, next to the selected Fabric (see scr_ui_info_panel)
if (global.selected_fabric == noone || !instance_exists(global.selected_fabric)) exit;

var _inst = global.selected_fabric;
// Anchor on the Fabric's real (upgraded) bounding box so the panel never covers a grown Furnace
var _p_right = scr_world_to_gui(_inst.bbox_right, _inst.bbox_top);
var _p_left = scr_world_to_gui(_inst.bbox_left, _inst.bbox_top);

var _cur_key = _inst.level_order[_inst.level_idx];
var _cur_values = variable_struct_get(_inst.level_data, _cur_key);
var _next_values = _inst.get_next_level_values();
var _names = variable_struct_get_names(_cur_values);

var _rows = [];

for (var _i = 0; _i < array_length(_names); _i++) {
    var _n = _names[_i];
    if (_n == "cost") continue;
    var _unit = (string_pos("delay", _n) > 0 || string_pos("time", _n) > 0) ? "s" : "";
    var _row = { label: scr_pretty_var_name(_n), value: string(variable_struct_get(_cur_values, _n)) + _unit };
    if (!is_undefined(_next_values) && variable_struct_exists(_next_values, _n)) {
        _row.nxt = string(variable_struct_get(_next_values, _n)) + _unit;
    }
    array_push(_rows, _row);
}

// Type-specific rows (Core HP bar, Furnace heating count, Hatcher progress bar, ...)
var _extra = _inst.get_info_lines();
if (array_length(_extra) > 0) {
    if (array_length(_rows) > 0) array_push(_rows, { sep: true });
    for (var _i = 0; _i < array_length(_extra); _i++) {
        array_push(_rows, _extra[_i]);
    }
}

if (array_length(_rows) > 0) array_push(_rows, { sep: true });
var _is_max = _inst.is_max_level();
if (_is_max) {
    array_push(_rows, { text: "MAX LEVEL", col: c_yellow });
} else {
    var _cost = _inst.get_upgrade_cost();
    array_push(_rows, { label: "Upgrade Cost", value: scr_comma_number(_cost) + "G", value_col: (global.gold >= _cost) ? c_lime : c_red });
}

var _hints = [];
if (!_is_max) array_push(_hints, ["E", "Upgrade"]);
if (_inst.fabric_type != "core") array_push(_hints, ["X", "Remove"]);

scr_ui_info_panel(_p_right[0], _p_right[1], _p_left[0], scr_capitalize(_inst.fabric_type), _inst.ui_colour, "Lv." + string(_inst.get_display_level()), _rows, _hints);
