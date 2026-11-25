/// @function scr_wave_spawn(wave_number)
/// @description Spawns one wave of enemies in a ring around the Core (data/enemy.json types,
/// weighted by spawn_weight); each marches inward on its own once initialized. Enemy count
/// scales with wave_number so later waves are larger.
function scr_wave_spawn(_wave_number) {
    var _core = instance_find(fabric_core, 0);
    if (_core == noone) return;

    var _keys = variable_struct_get_names(global.enemy_data);
    var _total_weight = 0;
    for (var _i = 0; _i < array_length(_keys); _i++) {
        var _entry = variable_struct_get(global.enemy_data, _keys[_i]);
        _total_weight += variable_struct_exists(_entry, "spawn_weight") ? _entry.spawn_weight : 1;
    }

    var _count = 3 + _wave_number * 2;
    var _spawn_radius = 700;

    for (var _i = 0; _i < _count; _i++) {
        var _roll = random(_total_weight);
        var _key = _keys[0];
        for (var _j = 0; _j < array_length(_keys); _j++) {
            var _entry = variable_struct_get(global.enemy_data, _keys[_j]);
            var _w = variable_struct_exists(_entry, "spawn_weight") ? _entry.spawn_weight : 1;
            if (_roll < _w) {
                _key = _keys[_j];
                break;
            }
            _roll -= _w;
        }

        var _ang = random(360);
        var _sx = _core.x + lengthdir_x(_spawn_radius, _ang);
        var _sy = _core.y + lengthdir_y(_spawn_radius, _ang);
        scr_enemy_spawn(_key, _sx, _sy);
    }
}
