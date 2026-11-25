/// Automatically take ownership of any free-standing Stuff that touches the Hatcher's actual
/// bounding area (bbox-based, so it works regardless of the Stuff's sprite size, position or
/// origin) -- no manual drop needed. Once stored it is owned by the Hatcher (hidden, excluded
/// from hover/selection in obj_stuff_select_ui) and cannot be taken back out manually.
if (stored == noone) {
    var _candidates = ds_list_create();
    var _n = instance_place_list(x, y, stuff, _candidates, false);
    for (var _i = 0; _i < _n; _i++) {
        var _c = _candidates[| _i];
        if (_c.stored_in == noone && !_c.held && try_store(_c)) break;
    }
    ds_list_destroy(_candidates);
}

/// Accumulate hatching progress while a Stuff is stored, then consume it and spawn the Unit
/// matching its material (data/unit.json, via global.unit_by_material)
if (stored == noone || !instance_exists(stored)) {
    stored = noone;
    progress = 0;
    exit;
}

var _dt = delta_time / 1000000;
progress += _dt / max(0.01, hatch_time);

if (progress >= 1) {
    var _unit_key = scr_unit_key_for_material(stored.stuff_type);
    if (_unit_key != "") {
        scr_unit_spawn(_unit_key, x, y);
    }

    instance_destroy(stored);
    stored = noone;
    progress = 0;
}
