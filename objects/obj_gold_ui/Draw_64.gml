/// Fixed screen-space Gold display: "Gold : <amount>G" with comma formatting.
/// Laid out in base (1366x768) units and scaled by scr_gui_scale(), so it keeps the same
/// visual size in windowed and fullscreen modes.
var _text = "Gold : " + scr_comma_number(global.gold) + "G";

scr_gui_scale_begin(scr_gui_scale());

draw_set_font(fnt_bold);
var _tw = string_width(_text);
var _th = string_height(_text);
var _pad = 6;
var _w = _tw + _pad * 2;
var _h = _th + _pad * 2;
var _x = 10;
var _y = 10;

draw_sprite_stretched(spr_panel, 0, _x, _y, _w, _h);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);
draw_text(_x + _pad, _y + _pad, _text);
draw_set_colour(c_white);

scr_gui_scale_end();
