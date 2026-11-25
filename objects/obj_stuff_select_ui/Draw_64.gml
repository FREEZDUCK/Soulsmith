/// Stuff hover info panel, screen-space, next to the hovered object (see scr_ui_info_panel)
if (global.hovered_stuff == noone || !instance_exists(global.hovered_stuff)) exit;

var _inst = global.hovered_stuff;
var _pos = scr_world_to_gui(_inst.bbox_right, _inst.y);
var _pos_l = scr_world_to_gui(_inst.bbox_left, _inst.y);

// Title colour follows the material tier (global.stuff_order, first = lowest tier)
var _tier_cols = [
    make_colour_rgb(190, 190, 190), make_colour_rgb(150, 170, 255), make_colour_rgb(255, 140, 60), make_colour_rgb(150, 205, 215),
    make_colour_rgb(120, 220, 120), make_colour_rgb(255, 220, 90), make_colour_rgb(200, 150, 255), make_colour_rgb(170, 60, 220)
];
var _tier = 0;
for (var _i = 0; _i < array_length(global.stuff_order); _i++) {
    if (global.stuff_order[_i] == _inst.stuff_type) _tier = _i;
}
var _title_col = _tier_cols[min(_tier, array_length(_tier_cols) - 1)];

var _rows = [];
if (is_real(_inst.melt_tem)) {
    array_push(_rows, {
        label: "Heat",
        bar: _inst.tem / _inst.melt_tem,
        text: scr_comma_number(_inst.tem) + " / " + scr_comma_number(_inst.melt_tem),
        col: make_colour_rgb(255, 120, 40)
    });
} else {
    array_push(_rows, { label: "Heat", value: "MAX", value_col: c_yellow });
}
array_push(_rows, { sep: true });
array_push(_rows, { label: "Selling Value", value: scr_comma_number(_inst.value) + "G", value_col: c_yellow });

var _sell_text = "Sell";
if (_inst.selected) {
    var _selected_count = 0;
    with (stuff) {
        if (selected) _selected_count++;
    }
    if (_selected_count > 1) _sell_text = "Sell All (" + string(_selected_count) + ")";
}

scr_ui_info_panel(_pos[0], _pos[1], _pos_l[0], _inst.name, _title_col, "", _rows, [["Q", _sell_text]]);
