/// @function scr_combatant_separate(inst)
/// @description Shared Unit/Enemy soft push-apart so no two Units/Enemies (on either side) ever
/// stack on top of each other, mirroring Stuff's own repulsion (see objects/stuff/Step_0.gml).
/// Checks both the unit and enemy object types, skipping corpses (state == "die"), so living
/// combatants always separate from every other living combatant regardless of side.
function scr_combatant_separate(_inst) {
    var _x = _inst.x;
    var _y = _inst.y;
    var _push_x = 0;
    var _push_y = 0;

    var _types = [unit, enemy];
    for (var _t = 0; _t < array_length(_types); _t++) {
        var _list = ds_list_create();
        var _count = instance_place_list(_x, _y, _types[_t], _list, false);
        for (var _i = 0; _i < _count; _i++) {
            var _other = _list[| _i];
            if (_other == _inst || _other.state == "die") continue;

            var _dx = _x - _other.x;
            var _dy = _y - _other.y;
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
            // A locked Unit never yields (see Unit's set_locked), so whoever bumps into it gets
            // the full push instead of sharing it
            if (_other.locked) _repulsion *= 2;
            _push_x += _dx * _repulsion;
            _push_y += _dy * _repulsion;
        }
        ds_list_destroy(_list);
    }

    // Scaled down (movement speeds are half what they were) and low-pass filtered so crowds
    // ease apart instead of jittering. sep_x/sep_y live on the Unit/Enemy (see their Create).
    // A locked Unit holds its ground: it is never pushed apart by anyone.
    if (_inst.locked) {
        _inst.sep_x = 0;
        _inst.sep_y = 0;
        return;
    }
    _inst.sep_x = lerp(_inst.sep_x, _push_x * COMBATANT_SEPARATE_STRENGTH, 0.3);
    _inst.sep_y = lerp(_inst.sep_y, _push_y * COMBATANT_SEPARATE_STRENGTH, 0.3);
    _inst.x += _inst.sep_x;
    _inst.y += _inst.sep_y;
}
