/// Determine the topmost Unit instance under the mouse cursor (world space)
/// Runs in Begin Step so every Step-event click handler (e.g. Fabric selection) already knows
/// whether a Unit is under the mouse this frame: interaction priority Stuff > Unit > Fabric.
var _wx = mouse_x;
var _wy = mouse_y;
var _best = noone;
var _best_depth = infinity;

with (unit) {
    if (_wx >= bbox_left && _wx <= bbox_right && _wy >= bbox_top && _wy <= bbox_bottom) {
        if (depth < _best_depth) {
            _best_depth = depth;
            _best = id;
        }
    }
}

global.hovered_unit = _best;
