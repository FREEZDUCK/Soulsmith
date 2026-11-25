/// @function scr_pretty_var_name(name)
/// @description Converts a snake_case variable name into "Title Case"
function scr_pretty_var_name(_n) {
    var _parts = string_split(_n, "_");
    var _out = "";
    for (var _i = 0; _i < array_length(_parts); _i++) {
        var _p = _parts[_i];
        if (string_length(_p) == 0) continue;
        _out += scr_capitalize(_p);
        if (_i < array_length(_parts) - 1) _out += " ";
    }
    return _out;
}
