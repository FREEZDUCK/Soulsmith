/// Heat every Stuff instance currently touching the Furnace's actual bounding area (bbox-based,
/// so it works regardless of the Stuff's sprite size, position or origin). Stuff is never
/// stored, hidden, or moved -- it keeps behaving as a completely normal world object; heating
/// simply starts the instant contact begins and stops the instant contact ends.
var _touching = ds_list_create();
var _touch_n = instance_place_list(x, y, stuff, _touching, false);
var _heated = 0;

/// Each touching Stuff has its own accumulator, so it gains exactly `fire_power` once per
/// real second of contact, independent of frame rate.
var _dt = delta_time / 1000000;
for (var _i = 0; _i < _touch_n; _i++) {
    var _inst = _touching[| _i];
    // Stuff owned by a Hatcher is hidden and must not evolve while it hatches
    if (_inst.stored_in != noone) continue;
    _heated++;
    _inst.furnace_heat_time += _dt;
    while (_inst.furnace_heat_time >= 1) {
        _inst.furnace_heat_time -= 1;
        _inst.tem += fire_power * heat_per_power;
    }
}
heating_count = _heated;
ds_list_destroy(_touching);
