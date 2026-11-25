/// Click a Fabric to select it, click empty ground to deselect, E to upgrade
/// Priority Stuff > Unit > Fabric: a click on a Stuff or a Unit is left unconsumed for that
/// instance (each handles it in its own controller) and never selects a Fabric underneath it.
var _stuff_under_mouse = (global.hovered_stuff != noone && instance_exists(global.hovered_stuff));
var _unit_under_mouse = (global.hovered_unit != noone && instance_exists(global.hovered_unit));

if ((_stuff_under_mouse || _unit_under_mouse) && !global.ui_hover && !global.click_consumed && mouse_check_button_pressed(mb_left)) {
    global.selected_fabric = noone;
} else if (!global.ui_hover && !global.click_consumed && mouse_check_button_pressed(mb_left)) {
    var _wx = mouse_x;
    var _wy = mouse_y;
    var _found = noone;
    var _best_depth = infinity;

    with (fabric) {
        if (_wx >= bbox_left && _wx <= bbox_right && _wy >= bbox_top && _wy <= bbox_bottom) {
            if (depth < _best_depth) {
                _best_depth = depth;
                _found = id;
            }
        }
    }

    global.selected_fabric = _found;
    global.click_consumed = true;
}

if (global.selected_fabric != noone && instance_exists(global.selected_fabric)) {
    if (keyboard_check_pressed(ord("E"))) {
        global.selected_fabric.upgrade();
    }

    /// X removes the selected Fabric. The Core can never be removed.
    if (keyboard_check_pressed(ord("X")) && global.selected_fabric.fabric_type != "core") {
        var _target = global.selected_fabric;
        global.selected_fabric = noone;
        _target.on_removed();
        with (_target) instance_destroy();
    }
}
