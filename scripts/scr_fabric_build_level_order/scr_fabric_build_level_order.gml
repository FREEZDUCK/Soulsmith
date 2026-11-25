/// @function scr_fabric_build_level_order(level_data)
/// @description Returns an ordered array of level keys: ["init", "2", "3", ..., "max"]
function scr_fabric_build_level_order(_level_data) {
    var _names = variable_struct_get_names(_level_data);
    var _numeric_keys = [];
    var _numeric_vals = [];
    for (var _i = 0; _i < array_length(_names); _i++) {
        var _n = _names[_i];
        if (_n != "init" && _n != "max") {
            array_push(_numeric_keys, _n);
            array_push(_numeric_vals, real(_n));
        }
    }

    // insertion sort, keeping keys in sync with their numeric value
    for (var _i = 1; _i < array_length(_numeric_vals); _i++) {
        var _v = _numeric_vals[_i];
        var _k = _numeric_keys[_i];
        var _j = _i - 1;
        while (_j >= 0 && _numeric_vals[_j] > _v) {
            _numeric_vals[_j + 1] = _numeric_vals[_j];
            _numeric_keys[_j + 1] = _numeric_keys[_j];
            _j--;
        }
        _numeric_vals[_j + 1] = _v;
        _numeric_keys[_j + 1] = _k;
    }

    var _order = ["init"];
    for (var _i = 0; _i < array_length(_numeric_keys); _i++) {
        array_push(_order, _numeric_keys[_i]);
    }
    if (variable_struct_exists(_level_data, "max")) {
        array_push(_order, "max");
    }
    return _order;
}
