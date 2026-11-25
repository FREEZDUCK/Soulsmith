/// Clicked Unit info panel, screen-space, next to the selected Unit (mirrors
/// obj_stuff_select_ui's hover panel, but triggered by a click and latched to the Unit via
/// global.selected_unit_info until it dies or the player clicks elsewhere). See scr_ui_info_panel.
/// Possessed Unit HUD (SPACE, see scr_unit_control_step): its HP bar along the bottom of the screen
if (instance_exists(global.controlled_unit)) {
    var _cu = global.controlled_unit;
    var _hs = scr_gui_scale();
    scr_gui_scale_begin(_hs);
    var _hgw = display_get_gui_width() / _hs;
    var _hgh = display_get_gui_height() / _hs;
    var _bw = 360;
    var _bh = 20;
    var _bx = round((_hgw - _bw) / 2);
    var _by = round(_hgh - 52);

    draw_set_font(font_bold);
    draw_set_valign(fa_bottom);
    draw_set_halign(fa_left);
    draw_set_colour(c_white);
    draw_text(_bx, _by - 4, _cu.unit_name);
    draw_set_halign(fa_right);
    draw_text(_bx + _bw, _by - 4, string(max(0, ceil(_cu.hp))) + " / " + string(_cu.max_hp));

    scr_ui_draw_bar(_bx, _by, _bx + _bw - 1, _by + _bh - 1, max(0, _cu.hp) / max(1, _cu.max_hp), make_colour_rgb(80, 200, 90), 0);

    draw_set_valign(fa_top);
    draw_set_halign(fa_center);
    draw_set_colour(make_colour_rgb(150, 155, 170));
    draw_text(round(_hgw / 2), _by + _bh + 4, (_cu.block_chance > 0) ? "WASD Move   LMB Attack   RMB Shield   SPACE Release" : "WASD Move   LMB Attack   SPACE Release");

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(c_white);
    scr_gui_scale_end();
}

if (instance_exists(global.controlled_unit)) exit; // no info panel while possessing
if (global.selected_unit_info == noone || !instance_exists(global.selected_unit_info)) exit;

var _inst = global.selected_unit_info;
var _pos = scr_world_to_gui(_inst.bbox_right, _inst.bbox_top);
var _pos_l = scr_world_to_gui(_inst.bbox_left, _inst.bbox_top);

var _rows = [
    { label: "HP", bar: max(0, _inst.hp) / max(1, _inst.max_hp), text: string(max(0, ceil(_inst.hp))) + " / " + string(_inst.max_hp), col: make_colour_rgb(80, 200, 90) },
    { sep: true },
    { label: "Attack Damage", value: string(_inst.attack_damage) },
    { label: "Attack Range", value: string(_inst.attack_range) },
    { label: "Move Speed", value: string(_inst.move_speed) }
];
if (_inst.block_chance > 0) {
    array_push(_rows, { label: "Block Chance", value: string(round(_inst.block_chance * 100)) + "%" });
}

if (_inst.locked) {
    array_push(_rows, { sep: true });
    array_push(_rows, { text: "LOCKED", col: c_yellow });
}
var _hints = [["L", _inst.locked ? "Unlock" : "Lock"]];

// Header tint = the Unit's data colour, brightened so dark Units stay readable
var _col = merge_colour(_inst.colour, c_white, 0.35);
scr_ui_info_panel(_pos[0], _pos[1], _pos_l[0], _inst.unit_name, _col, "", _rows, _hints);
