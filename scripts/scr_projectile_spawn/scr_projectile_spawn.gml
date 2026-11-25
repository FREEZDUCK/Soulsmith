/// @function scr_projectile_spawn(type, x, y, target, damage, [dir])
/// @description Spawns a projectile ("arrow" or "fireball") from (x, y) that homes toward target
/// and deals damage the instant it reaches it (see objects/projectile, proj_arrow, proj_fireball)
function scr_projectile_spawn(_type, _x, _y, _target, _damage, _dir = undefined) {
    var _obj = (_type == "fireball") ? proj_fireball : proj_arrow;
    var _inst = instance_create_layer(_x, _y, "Instances", _obj);
    _inst.target = _target;
    _inst.damage = _damage;
    _inst.y += _inst.aim_offset_y;
    // dir given (player-fired shot): it flies that way even with no target, hitting the first
    // Enemy in its path (see objects/projectile free_flight)
    if (!is_undefined(_dir)) {
        _inst.dir = _dir;
        _inst.free_flight = true;
    }
    return _inst;
}
