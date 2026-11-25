/// Drag/drop, selling (single or bulk via selection), Furnace placement,
/// and soft repulsion from overlapping Stuff. Each Stuff item is independent:
/// it can never be merged into another or split apart.
var _is_hovered = (global.hovered_stuff == id);

if (_is_hovered && !global.ui_hover && !global.click_consumed) {
    if (mouse_check_button_pressed(mb_left)) {
        // Defensive: release from whatever currently owns this Stuff, if anything. In practice
        // this never fires -- the Furnace never takes ownership of Stuff (see
        // fabric_furnace/Step_0.gml), and Stuff owned by a Hatcher can't reach here since
        // obj_stuff_select_ui excludes it from hover/selection entirely once hatching.
        if (stored_in != noone && instance_exists(stored_in)) {
            stored_in.release(id);
        }
        held = true;
        hold_offset_x = x - mouse_x;
        hold_offset_y = y - mouse_y;
        global.click_consumed = true;

        // Grabbing a Stuff that is part of a multi-selection drags the whole selection together:
        // every other selected Stuff gets its own hold_offset from this same mouse position, so
        // they all translate by the same amount each frame instead of converging on the cursor.
        if (selected) {
            var _self = id;
            with (stuff) {
                if (selected && id != _self) {
                    if (stored_in != noone && instance_exists(stored_in)) {
                        stored_in.release(id);
                    }
                    held = true;
                    hold_offset_x = x - mouse_x;
                    hold_offset_y = y - mouse_y;
                }
            }
        }
    } else if (keyboard_check_pressed(ord("Q"))) {
        if (selected) {
            // Hovering a selected Stuff sells every selected Stuff at once
            with (stuff) {
                if (selected) {
                    global.gold += value;
                    instance_destroy();
                }
            }
        } else {
            global.gold += value;
            instance_destroy();
        }
        exit;
    }
}

if (held) {
    x = mouse_x + hold_offset_x;
    y = mouse_y + hold_offset_y;
    if (mouse_check_button_released(mb_left)) {
        held = false;
        // Dropped while hovering a Hatcher: assign to its hatching slot (rejected if occupied).
        // Dropping on a Furnace needs no special handling: Stuff just heats up automatically
        // while physically touching it (see fabric_furnace/Step_0.gml).
        var _hatcher = instance_position(mouse_x, mouse_y, fabric_hatcher);
        if (_hatcher != noone) {
            _hatcher.try_store(id);
        }
    }
}

// Stored Stuff is positioned by its Furnace: no repulsion
if (stored_in != noone) {
    if (instance_exists(stored_in)) exit;
    // Furnace no longer exists: return to the world
    stored_in = noone;
    visible = true;
    image_xscale = 1;
    image_yscale = 1;
}

if (!held) {
    // Soft repulsion so independent Stuff items naturally spread apart instead of overlapping
    var _push_x = 0;
    var _push_y = 0;
    var _list = ds_list_create();
    var _count = instance_place_list(x, y, stuff, _list, false);
    for (var _i = 0; _i < _count; _i++) {
        var _other = _list[| _i];
        if (_other == id || _other.held || _other.stored_in != noone) continue;

        var _dx = x - _other.x;
        var _dy = y - _other.y;
        var _dist = sqrt(_dx * _dx + _dy * _dy);

        if (_dist == 0) {
            var _ang = random(360);
            _dx = dcos(_ang);
            _dy = dsin(_ang);
        } else {
            _dx /= _dist;
            _dy /= _dist;
        }

        _dx += random_range(-0.01, 0.01);
        _dy += random_range(-0.01, 0.01);

        var _repulsion = power(1.0 / 1.20, _dist + 0.1);
        _push_x += _dx * _repulsion;
        _push_y += _dy * _repulsion;
    }
    ds_list_destroy(_list);
    x += _push_x;
    y += _push_y;
}
