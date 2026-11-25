/// Drag-selection box: click+drag on empty ground (no Stuff, no Fabric, no UI under the
/// mouse) to multi-select Stuff, like the marquee select box on the Windows desktop.
/// Runs in normal Step, after Begin Step has set global.hovered_stuff for this frame and
/// after obj_io_reset/panels have refreshed global.click_consumed/ui_hover for this frame.
if (!dragging) {
    if (!global.ui_hover && global.hovered_stuff == noone && mouse_check_button_pressed(mb_left)) {
        var _wx = mouse_x;
        var _wy = mouse_y;
        var _over_fabric = false;
        with (fabric) {
            if (_wx >= bbox_left && _wx <= bbox_right && _wy >= bbox_top && _wy <= bbox_bottom) {
                _over_fabric = true;
            }
        }

        if (!_over_fabric) {
            dragging = true;
            drag_start_x = _wx;
            drag_start_y = _wy;
            drag_cur_x = _wx;
            drag_cur_y = _wy;
            global.click_consumed = true;
        }
    }
} else {
    drag_cur_x = mouse_x;
    drag_cur_y = mouse_y;
    global.click_consumed = true;

    if (mouse_check_button_released(mb_left)) {
        var _x1 = min(drag_start_x, drag_cur_x);
        var _x2 = max(drag_start_x, drag_cur_x);
        var _y1 = min(drag_start_y, drag_cur_y);
        var _y2 = max(drag_start_y, drag_cur_y);
        // A near-zero-size drag counts as a plain click: clear the selection instead of
        // selecting whatever tiny area the box happens to cover
        var _is_click = (point_distance(drag_start_x, drag_start_y, drag_cur_x, drag_cur_y) < 4);

        with (stuff) {
            // Stuff owned by a Hatcher is consumed permanently: never let it join a selection,
            // so it can't be dragged or sold in bulk either.
            var _hatcher_owned = (stored_in != noone && instance_exists(stored_in) && stored_in.object_index == fabric_hatcher);
            selected = !_is_click && !_hatcher_owned && bbox_right >= _x1 && bbox_left <= _x2 && bbox_bottom >= _y1 && bbox_top <= _y2;
        }

        dragging = false;
    }
}
