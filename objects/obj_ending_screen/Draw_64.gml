/// Full-screen "Victory" overlay, shown once the ending has been triggered (see Step)
if (!active) exit;

var _s = scr_gui_scale();
scr_gui_scale_begin(_s);

var _gw = display_get_gui_width() / _s;
var _gh = display_get_gui_height() / _s;
var _cx = _gw / 2;
var _cy = _gh / 2;

draw_set_alpha(0.8);
draw_rectangle_colour(0, 0, _gw, _gh, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_font(fnt_title);
draw_set_colour(defeated ? c_red : c_yellow);
draw_text_transformed(_cx, _cy - 60, defeated ? "Defeat" : "Victory!", 2, 2, 0);

draw_set_font(fnt_button);
draw_set_colour(c_white);
draw_text(_cx, _cy - 10, defeated ? "The Core has fallen" : ("You reached " + scr_comma_number(global.gold) + "G"));

var _button_left = _cx - button_w / 2;
var _button_top = _cy + 50;
draw_sprite_stretched_ext(spr_panel, 0, _button_left, _button_top, button_w, button_h, hovered ? c_white : c_ltgray, hovered ? 1 : 0.9);
draw_set_colour(hovered ? c_yellow : c_white);
draw_text(_cx, _button_top + button_h / 2, "Return to Title");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);

scr_gui_scale_end();
