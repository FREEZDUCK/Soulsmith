/// Draw the title screen: gradient backdrop, logo, and the three menu buttons,
/// scaled uniformly like the rest of the UI (see scr_gui_scale).
var _s = scr_gui_scale();
scr_gui_scale_begin(_s);

var _gw = display_get_gui_width() / _s;
var _gh = display_get_gui_height() / _s;
var _cx = _gw / 2;

var _col_bottom = make_colour_rgb(24, 28, 40);
draw_rectangle_colour(0, 0, _gw, _gh, c_black, c_black, _col_bottom, _col_bottom, false);

draw_sprite_ext(spr_logo, 0, _cx - logo_w / 2, logo_top, logo_scale, logo_scale, 0, c_white, 1);

draw_set_font(fnt_button);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

for (var _i = 0; _i < array_length(buttons); _i++) {
    var _left = _cx - button_w / 2;
    var _top = buttons_top + _i * (button_h + button_gap);
    var _hovered = (_i == hovered_index);

    draw_sprite_stretched_ext(spr_panel, 0, _left, _top, button_w, button_h, _hovered ? c_white : c_ltgray, _hovered ? 1 : 0.9);
    draw_set_colour(_hovered ? c_yellow : c_white);
    draw_text(_cx, _top + button_h / 2, buttons[_i].label);
}

draw_set_font(fnt_version);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_set_colour(c_white);
draw_text(_gw - 12, _gh - 10, global.version);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);

scr_gui_scale_end();
