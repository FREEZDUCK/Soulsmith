/// @function scr_combat_find_nearest(x, y, obj)
/// @description Nearest living instance of obj to (x, y), skipping anything mid-death animation
/// (state == "die"). Returns noone if obj has no living instances.
function scr_combat_find_nearest(_x, _y, _obj) {
    var _best = noone;
    var _best_dist = infinity;
    with (_obj) {
        if (variable_instance_exists(id, "state") && state == "die") continue;
        var _d = point_distance(_x, _y, x, y);
        if (_d < _best_dist) {
            _best_dist = _d;
            _best = id;
        }
    }
    return _best;
}
