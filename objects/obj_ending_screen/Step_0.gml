/// Watch global.gold every step and show the ending screen once it exceeds 1000.
/// global.ending_triggered (set in rooms/setVars) latches this so it never re-triggers.
if (!active && global.game_over) {
    active = true;
    defeated = true;
    if (instance_exists(obj_wave_controller)) obj_wave_controller.alarm[0] = -1; // no more waves
}

if (!active && !global.ending_triggered && global.gold > 22222222221000) {
    global.ending_triggered = true;
    active = true;
}

if (!active) exit;

// Take over input while shown, so the Play room's UI/world underneath stays frozen
global.ui_hover = true;

var _s = scr_gui_scale();
var _gw = display_get_gui_width() / _s;
var _gh = display_get_gui_height() / _s;
var _cx = _gw / 2;
var _cy = _gh / 2;
var _mx = device_mouse_x_to_gui(0) / _s;
var _my = device_mouse_y_to_gui(0) / _s;

var _button_left = _cx - button_w / 2;
var _button_top = _cy + 50;
hovered = (_mx >= _button_left && _mx <= _button_left + button_w && _my >= _button_top && _my <= _button_top + button_h);

if (!global.click_consumed && mouse_check_button_pressed(mb_left)) {
    global.click_consumed = true;
    if (hovered) {
        active = false;
        room_goto(TitleScreen);
    }
}
