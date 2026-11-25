/// Unit selection + movement controller (see Step_0 for the drag-select box and the
/// right-click move command; see Draw_64 for the clicked Unit's info panel)
dragging = false;
drag_start_x = 0;
drag_start_y = 0;
drag_cur_x = 0;
drag_cur_y = 0;

// Shift + right-click drag: curved line formation (see Step_0 / Draw_0, scr_formation_curve)
formation_active = false;
formation_trail = [];     // mouse trail in world space, oldest first
formation_slots = [];     // current preview slots (tail -> head)
formation_spacing = 28;   // px between neighbouring Units on the curve (~ a Unit's width)

/// Plain right-click move: command every selected Unit to move to (_tx, _ty). Each Unit gets its OWN
/// slot in a compact formation around the point (center-out, nearest Units take the inner slots),
/// so a group never fights over one single point and grinds against each other on arrival.
move_selected_to = function(_tx, _ty) {
    var _sel = [];
    with (unit) {
        if (selected && state != "die" && !locked) {
            array_push(_sel, { inst: id, d: point_distance(x, y, _tx, _ty) });
        }
    }

    var _n = array_length(_sel);
    if (_n <= 0) return;

    // Slot spacing roughly matches a Unit's collision box, offset every other row (hex-like)
    var _dx = 28;
    var _dy = 24;
    var _span = ceil(sqrt(_n)) + 2;
    var _slots = [];
    for (var _r = -_span; _r <= _span; _r++) {
        for (var _c = -_span; _c <= _span; _c++) {
            var _sx = _c * _dx + ((_r & 1) ? _dx / 2 : 0);
            var _sy = _r * _dy;
            array_push(_slots, { x: _sx, y: _sy, d: _sx * _sx + _sy * _sy });
        }
    }
    array_sort(_slots, function(_a, _b) { return _a.d - _b.d; });
    array_sort(_sel, function(_a, _b) { return _a.d - _b.d; });

    for (var _i = 0; _i < _n; _i++) {
        var _u = _sel[_i].inst;
        _u.give_move_order(_tx + _slots[_i].x, _ty + _slots[_i].y);
    }
};

fnt_regular = font_bold; // native font resource: crisp at its own pixel size
spr_panel = sprite_add("assets/sprites/ui/panels/mono.png", 1, false, false, 0, 0);
var _ns = sprite_nineslice_create();
_ns.enabled = true;
_ns.left = 4;
_ns.top = 4;
_ns.right = 4;
_ns.bottom = 4;
sprite_set_nineslice(spr_panel, _ns);
