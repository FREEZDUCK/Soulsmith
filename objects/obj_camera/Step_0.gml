/// Smooth movement + smooth zoom
var _dt = delta_time / 1000000;

var _mx = 0;
var _my = 0;
if (keyboard_check(ord("A"))) _mx -= 1;
if (keyboard_check(ord("D"))) _mx += 1;
if (keyboard_check(ord("W"))) _my -= 1;
if (keyboard_check(ord("S"))) _my += 1;

if (_mx != 0 || _my != 0) {
    var _len = sqrt(_mx * _mx + _my * _my);
    _mx /= _len;
    _my /= _len;
}

// Possessed Unit: the camera locks onto it and WASD drives the Unit instead (see scr_unit_control_step)
if (instance_exists(global.controlled_unit)) {
    _mx = 0;
    _my = 0;
    target_x = global.controlled_unit.x;
    target_y = global.controlled_unit.y - 8;
}

target_x += _mx * move_speed * zoom * _dt;
target_y += _my * move_speed * zoom * _dt;

var _wheel = 0;
var _wheel_on_ui = instance_exists(obj_fabric_purchase_ui) && obj_fabric_purchase_ui.over_panel;
if (!_wheel_on_ui) {
    if (mouse_wheel_up()) _wheel = -1;
    if (mouse_wheel_down()) _wheel = 1;
}
target_zoom = clamp(target_zoom + _wheel * 0.1, min_zoom, max_zoom);

x_pos = lerp(x_pos, target_x, 0.12);
y_pos = lerp(y_pos, target_y, 0.12);
zoom = lerp(zoom, target_zoom, 0.12);

var _vw = base_w * zoom;
var _vh = base_h * zoom;
camera_set_view_size(cam, _vw, _vh);
camera_set_view_pos(cam, x_pos - _vw / 2, y_pos - _vh / 2);
