/// Parent draw (shadow, selection outline, Hatcher sprite), then the stored Stuff on top of it
/// and a hatching progress bar underneath, all in world space so it pans/zooms with the Hatcher
event_inherited();

if (stored == noone || !instance_exists(stored)) exit;

draw_sprite_ext(stored.sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

var _bar_w = sprite_get_width(sprite_index);
var _bar_h = 8;
var _bar_x = x - _bar_w / 2;
var _bar_y = y + sprite_get_height(sprite_index) / 2 + 6;

scr_ui_draw_bar(_bar_x, _bar_y, _bar_x + _bar_w - 1, _bar_y + _bar_h - 1, progress, c_lime, 0);
