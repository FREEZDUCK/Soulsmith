/// Next Wave countdown, fixed top-center screen-space: live seconds remaining on alarm[0],
/// which is reset to wave_interval * room_speed whenever a wave starts (see Alarm_0.gml).
if (global.game_over) exit;

var _seconds = max(0, ceil(alarm[0] / room_speed));
var _text = "Next Wave : " + string(_seconds) + "s";

scr_gui_scale_begin(scr_gui_scale());

draw_set_font(fnt_bold);
var _tw = string_width(_text);
var _th = string_height(_text);
var _pad = 6;
var _w = _tw + _pad * 2;
var _h = _th + _pad * 2;
var _x = (display_get_gui_width() / scr_gui_scale() - _w) / 2;
var _y = 10;

draw_sprite_stretched(spr_panel, 0, _x, _y, _w, _h);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);
draw_text(_x + _pad, _y + _pad, _text);
draw_set_colour(c_white);

scr_gui_scale_end();
