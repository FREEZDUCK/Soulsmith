/// @function scr_stuff_spawn(type, x, y)
/// @description Spawns a stuff instance of the given type at a world position
function scr_stuff_spawn(_type, _x, _y) {
    var _inst = instance_create_layer(_x, _y, "Instances", stuff);
    _inst.stuff_type = _type;
    _inst.initialize();
    return _inst;
}
