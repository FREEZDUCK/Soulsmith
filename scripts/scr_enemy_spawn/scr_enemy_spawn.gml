/// @function scr_enemy_spawn(enemy_key, x, y)
/// @description Spawns an enemy instance of the given data/enemy.json type at a world position
function scr_enemy_spawn(_enemy_key, _x, _y) {
    var _inst = instance_create_layer(_x, _y, "Instances", enemy);
    _inst.enemy_key = _enemy_key;
    _inst.initialize();
    return _inst;
}
