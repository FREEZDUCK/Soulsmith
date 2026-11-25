/// Hover + click handling for the title screen buttons, in the same base (1366x768)
/// units as Draw GUI (see scr_gui_scale), so hit-testing matches the scaled layout.
var _s = scr_gui_scale();
var _gw = display_get_gui_width() / _s;
var _cx = _gw / 2;
var _mx = device_mouse_x_to_gui(0) / _s;
var _my = device_mouse_y_to_gui(0) / _s;

hovered_index = -1;
for (var _i = 0; _i < array_length(buttons); _i++) {
    var _left = _cx - button_w / 2;
    var _top = buttons_top + _i * (button_h + button_gap);
    if (_mx >= _left && _mx <= _left + button_w && _my >= _top && _my <= _top + button_h) {
        hovered_index = _i;
    }
}

if (hovered_index != -1) {
    global.ui_hover = true;
    if (!global.click_consumed && mouse_check_button_pressed(mb_left)) {
        global.click_consumed = true;
        switch (buttons[hovered_index].action) {
            case "start":
                room_goto(Play);
                break;
            case "exit":
                game_end();
                break;
            default:
                // "settings" has no menu implemented yet
                break;
        }
    }
}
