/// Drag-selection box for Units (marquee select, like the Windows desktop), plus a right-click
/// move command for whatever Units are currently selected.
/// Click+drag on empty ground (no Stuff or UI under the mouse) to multi-select; a near-zero-size
/// drag is treated as a plain click, selecting the single Unit under the cursor (or clearing the
/// selection over empty ground). Selection priority is Stuff > Unit > Fabric: a click directly on
/// a Unit always starts the click/drag here even over a Fabric's footprint, but a click on empty
/// ground that only overlaps a Fabric is left unconsumed for obj_fabric_select_ui. Runs in normal
/// Step, after Begin Step has set global.hovered_stuff/global.hovered_unit for this frame and
/// after panels have refreshed global.click_consumed/ui_hover for this frame.
/// SPACE: take direct control of the ONE selected Unit (camera locks on it, WASD / left click /
/// right click drive it, see scr_unit_control_step); SPACE again releases it. If it dies, control
/// ends by itself. While a Unit is possessed, selection / move orders below are switched off.
if (global.controlled_unit != noone && (!instance_exists(global.controlled_unit) || global.controlled_unit.state == "die")) {
    scr_unit_control_release(global.controlled_unit);
    global.controlled_unit = noone;
}
if (keyboard_check_pressed(vk_space)) {
    if (instance_exists(global.controlled_unit)) {
        scr_unit_control_release(global.controlled_unit);
        global.controlled_unit = noone;
    } else {
        var _cands = [];
        with (unit) {
            if (selected && state != "die") array_push(_cands, id);
        }
        if (array_length(_cands) == 1) {
            dragging = false;
            formation_active = false;
            formation_trail = [];
            formation_slots = [];
            scr_unit_control_enter(_cands[0]);
        }
    }
}
if (instance_exists(global.controlled_unit)) exit;

if (!dragging) {
    if (!global.ui_hover && global.hovered_stuff == noone && mouse_check_button_pressed(mb_left)) {
        var _wx = mouse_x;
        var _wy = mouse_y;
        var _picked = instance_position(_wx, _wy, unit);

        var _over_fabric = false;
        if (_picked == noone) {
            with (fabric) {
                if (_wx >= bbox_left && _wx <= bbox_right && _wy >= bbox_top && _wy <= bbox_bottom) {
                    _over_fabric = true;
                }
            }
        }

        if (_picked != noone || !_over_fabric) {
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

    if (mouse_check_button_released(mb_left)) {
        var _is_click = (point_distance(drag_start_x, drag_start_y, drag_cur_x, drag_cur_y) < 4);

        if (_is_click) {
            var _picked = instance_position(drag_start_x, drag_start_y, unit);
            with (unit) {
                selected = (id == _picked);
            }
            // A plain click shows that single Unit's info panel (see Draw_64); clicking empty
            // ground hides it.
            global.selected_unit_info = _picked;
        } else {
            var _x1 = min(drag_start_x, drag_cur_x);
            var _x2 = max(drag_start_x, drag_cur_x);
            var _y1 = min(drag_start_y, drag_cur_y);
            var _y2 = max(drag_start_y, drag_cur_y);
            with (unit) {
                selected = bbox_right >= _x1 && bbox_left <= _x2 && bbox_bottom >= _y1 && bbox_top <= _y2;
            }
            // A marquee drag selects a group for move orders; the info panel only shows a
            // single Unit's info, so hide it.
            global.selected_unit_info = noone;
        }

        dragging = false;
    }
}

// Shift + right-click and HOLD, then move the mouse: a curve whose length is proportional to the
// number of selected Units follows the cursor (it is the stretch of the mouse trail behind the
// cursor, see scr_formation_curve). Releasing sends the selected Units to evenly spaced spots on
// that curve. Releasing without dragging is just a plain move order to that spot.
// Plain right-click (no Shift): move order, see move_selected_to() in Create_0.
if (!formation_active) {
    if (!global.ui_hover && mouse_check_button_pressed(mb_right)) {
        if (keyboard_check(vk_shift)) {
            formation_active = true;
            formation_trail = [ { x: mouse_x, y: mouse_y } ];
            formation_slots = [];
        } else {
            move_selected_to(mouse_x, mouse_y);
        }
    }
} else {
    var _sel_units = [];
    with (unit) {
        if (selected && state != "die" && !locked) array_push(_sel_units, id);
    }
    var _cnt = array_length(_sel_units);

    // extend the trail whenever the mouse has moved a few pixels
    var _last = formation_trail[array_length(formation_trail) - 1];
    if (point_distance(_last.x, _last.y, mouse_x, mouse_y) >= 6) {
        array_push(formation_trail, { x: mouse_x, y: mouse_y });
        // keep the trail bounded: drop points far behind anything the curve can still use
        var _keep = (_cnt + 2) * formation_spacing * 2;
        var _acc = 0;
        var _cut = 0;
        for (var _i = array_length(formation_trail) - 1; _i > 0; _i--) {
            var _a = formation_trail[_i];
            var _b = formation_trail[_i - 1];
            _acc += point_distance(_a.x, _a.y, _b.x, _b.y);
            if (_acc > _keep) { _cut = _i - 1; break; }
        }
        if (_cut > 0) array_delete(formation_trail, 0, _cut);
    }

    // the head always tracks the cursor exactly, even between recorded trail points
    var _live_trail = array_concat(formation_trail, [ { x: mouse_x, y: mouse_y } ]);
    formation_slots = scr_formation_curve(_live_trail, _cnt, formation_spacing);

    if (mouse_check_button_released(mb_right)) {
        var _start = formation_trail[0];
        var _dragged = (array_length(formation_trail) > 1) || point_distance(_start.x, _start.y, mouse_x, mouse_y) >= 8;
        if (_cnt > 0) {
            if (_dragged) scr_formation_assign(_sel_units, formation_slots);
            else move_selected_to(mouse_x, mouse_y);
        }
        formation_active = false;
        formation_trail = [];
        formation_slots = [];
    }
}

/// L: lock / unlock the selected Units. If any selected Unit is not locked yet, all of them are
/// locked on their current spot; if they are all locked already, all of them are released.
/// (A locked Unit holds its post: see locked / set_locked in objects/unit/Create_0.gml.)
if (keyboard_check_pressed(ord("L"))) {
    var _lock_sel = [];
    with (unit) {
        if (selected && state != "die") array_push(_lock_sel, id);
    }
    var _any_unlocked = false;
    for (var _i = 0; _i < array_length(_lock_sel); _i++) {
        if (!_lock_sel[_i].locked) _any_unlocked = true;
    }
    for (var _i = 0; _i < array_length(_lock_sel); _i++) {
        _lock_sel[_i].set_locked(_any_unlocked);
    }
}
