/// Debugging: F3 spawns one random enemy type (data/enemy.json) at the mouse's world position
if (keyboard_check_pressed(vk_f3)) {
    var _keys = variable_struct_get_names(global.enemy_data);
    if (array_length(_keys) > 0) {
        var _key = _keys[irandom(array_length(_keys) - 1)];
        scr_enemy_spawn(_key, mouse_x, mouse_y);
    }
}

/// Debugging: F2 spawns one random Unit type (data/unit.json) at the mouse's world position
if (keyboard_check_pressed(vk_f2)) {
    var _ukeys = variable_struct_get_names(global.unit_data);
    if (array_length(_ukeys) > 0) {
        var _ukey = _ukeys[irandom(array_length(_ukeys) - 1)];
        scr_unit_spawn(_ukey, mouse_x, mouse_y);
    }
}
