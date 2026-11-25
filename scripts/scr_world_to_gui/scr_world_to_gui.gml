/// @function scr_world_to_gui(wx, wy)
/// @description Converts world-space coordinates to GUI-space coordinates using the active view camera.
/// Goes world -> window via the on-screen rectangle of the application surface (handles camera
/// position/zoom and aspect-ratio letterboxing), then window -> GUI (see scr_set_display).
function scr_world_to_gui(_wx, _wy) {
    var _cam = view_camera[0];
    var _vx = camera_get_view_x(_cam);
    var _vy = camera_get_view_y(_cam);
    var _vw = camera_get_view_width(_cam);
    var _vh = camera_get_view_height(_cam);

    var _app = application_get_position(); // [x1, y1, x2, y2] in window pixels
    var _win_x = _app[0] + (_wx - _vx) / _vw * (_app[2] - _app[0]);
    var _win_y = _app[1] + (_wy - _vy) / _vh * (_app[3] - _app[1]);

    var _gx = _win_x * display_get_gui_width() / max(1, window_get_width());
    var _gy = _win_y * display_get_gui_height() / max(1, window_get_height());
    return [_gx, _gy];
}

/// @function scr_mouse_to_world()
/// @description Exact inverse of scr_world_to_gui for the mouse: window mouse position -> world,
/// using the camera view as it is *right now*. Unlike mouse_x/mouse_y (computed at the start of
/// the frame from the previous view), this stays aligned with what is drawn this frame even while
/// the smoothed camera is panning or zooming.
function scr_mouse_to_world() {
    var _cam = view_camera[0];
    var _app = application_get_position(); // [x1, y1, x2, y2] in window pixels
    var _rx = (window_mouse_get_x() - _app[0]) / max(1, _app[2] - _app[0]);
    var _ry = (window_mouse_get_y() - _app[1]) / max(1, _app[3] - _app[1]);
    return [
        camera_get_view_x(_cam) + _rx * camera_get_view_width(_cam),
        camera_get_view_y(_cam) + _ry * camera_get_view_height(_cam)
    ];
}
