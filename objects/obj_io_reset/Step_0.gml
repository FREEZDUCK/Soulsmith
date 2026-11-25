/// Reset per-frame UI/input flags before other controllers run this step
global.ui_hover = false;
global.click_consumed = false;
// While a Unit is possessed (SPACE), its mouse buttons belong to it: every selection/drag/panel
// controller treats the mouse as being over UI
if (instance_exists(global.controlled_unit)) global.ui_hover = true;

/// Alt+Enter: toggle fullscreen/windowed. The latch only re-arms once Enter is released,
/// so holding the keys can never toggle more than once. The application surface, view and
/// GUI sizes are not touched; the runtime rescales them (Windows "keep aspect ratio"), so
/// camera, UI and mouse_x/mouse_y/device_mouse_*_to_gui stay consistent after switching.
if (!fullscreen_latched && keyboard_check(vk_alt) && keyboard_check_pressed(vk_enter)) {
    window_set_fullscreen(!window_get_fullscreen());
    fullscreen_latched = true;
}
if (!keyboard_check(vk_enter)) {
    fullscreen_latched = false;
}

/// Keep the GUI layer at native window resolution after fullscreen toggles / window resizes
if (window_get_width() != display_last_w || window_get_height() != display_last_h) {
    display_last_w = window_get_width();
    display_last_h = window_get_height();
    scr_set_display();
}
