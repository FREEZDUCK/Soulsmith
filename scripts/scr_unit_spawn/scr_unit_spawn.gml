/// @function scr_unit_spawn(unit_key, x, y)
/// @description Spawns a unit instance of the given data/unit.json type at a world position
function scr_unit_spawn(_unit_key, _x, _y) {
    var _inst = instance_create_layer(_x, _y, "Instances", unit);
    _inst.unit_key = _unit_key;
    _inst.initialize();
    return _inst;
}
