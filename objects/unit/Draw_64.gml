/// Idle-chatter speech bubble (white square with a little tail) above the Unit, drawn in Draw GUI
/// so the text stays crisp regardless of camera zoom (see Step_0 for when chat_text is set).
if (chat_text == "" || chat_life <= 0 || state == "die") exit;

var _s = scr_gui_scale();
var _pos = scr_world_to_gui(x, bbox_top);
var _px = _pos[0] / _s;
var _py = _pos[1] / _s;

scr_gui_scale_begin(_s);
draw_set_font(font_bold);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _pad = 6;
var _tw = string_width(chat_text);
var _th = string_height(chat_text);
var _w = _tw + _pad * 2;
var _h = _th + _pad * 2 - 2;
var _bx = round(_px - _w / 2);
var _by = round(_py - 10 - _h);

draw_set_alpha(clamp(chat_life / 0.3, 0, 1)); // short fade-out at the end
// bubble: dark outline, white fill, tail pointing down at the Unit
draw_set_colour(c_black);
draw_rectangle(_bx - 1, _by - 1, _bx + _w, _by + _h, false);
draw_triangle(_bx + _w / 2 - 6, _by + _h, _bx + _w / 2 + 6, _by + _h, _bx + _w / 2, _by + _h + 8, false);
draw_set_colour(c_white);
draw_rectangle(_bx, _by, _bx + _w - 1, _by + _h - 1, false);
draw_triangle(_bx + _w / 2 - 4, _by + _h - 1, _bx + _w / 2 + 4, _by + _h - 1, _bx + _w / 2, _by + _h + 5, false);
draw_set_colour(c_black);
draw_text(_bx + _pad, _by + _pad - 1, chat_text);

draw_set_alpha(1);
draw_set_colour(c_white);
scr_gui_scale_end();
