/// Determine the topmost Stuff instance under the mouse cursor (world space)
/// Runs in Begin Step so every Step-event click handler (e.g. Fabric selection)
/// already knows whether a Stuff is under the mouse: interaction priority Stuff > Fabric.
var _wx = mouse_x;
var _wy = mouse_y;
var _best = noone;
var _best_depth = infinity;

with (stuff) {
    // Stuff owned by a Hatcher is consumed permanently: skip it so it can never be hovered,
    // picked up, or sold, and clicks fall through to the Hatcher/Fabric underneath it.
    if (stored_in != noone && instance_exists(stored_in) && stored_in.object_index == fabric_hatcher) continue;

    if (_wx >= bbox_left && _wx <= bbox_right && _wy >= bbox_top && _wy <= bbox_bottom) {
        if (depth < _best_depth) {
            _best_depth = depth;
            _best = id;
        }
    }
}

global.hovered_stuff = _best;
