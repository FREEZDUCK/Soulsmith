/// @function scr_fabric_apply_level(inst, level_data, key)
/// @description Applies all variables (except "cost") from level_data[key] onto inst
function scr_fabric_apply_level(_inst, _level_data, _key) {
    var _values = variable_struct_get(_level_data, _key);
    var _names = variable_struct_get_names(_values);
    for (var _i = 0; _i < array_length(_names); _i++) {
        var _n = _names[_i];
        if (_n != "cost") {
            variable_instance_set(_inst, _n, variable_struct_get(_values, _n));
        }
    }
}


/// @function scr_fabric_footprint(inst)
/// @description Placement footprint of a Fabric as [left, top, w, h]: its real (scaled) sprite size
/// rounded up to the 16px placement grid, centered on (x, y). Same rule the placement ghost uses.
function scr_fabric_footprint(_inst) {
    var _grid = 16;
    var _w = ceil(sprite_get_width(_inst.sprite_index) * abs(_inst.image_xscale) / _grid - 0.0001) * _grid;
    var _h = ceil(sprite_get_height(_inst.sprite_index) * abs(_inst.image_yscale) / _grid - 0.0001) * _grid;
    return [_inst.x - _w / 2, _inst.y - _h / 2, _w, _h];
}

/// @function scr_fabric_area_free(left, top, w, h, ignore)
/// @description True if the rectangle overlaps no Fabric footprint (the `ignore` instance is skipped)
function scr_fabric_area_free(_left, _top, _w, _h, _ignore) {
    with (fabric) {
        if (id == _ignore) continue;
        var _fp = scr_fabric_footprint(id);
        var _overlap = !((_left + _w <= _fp[0]) || (_left >= _fp[0] + _fp[2]) || (_top + _h <= _fp[1]) || (_top >= _fp[1] + _fp[3]));
        if (_overlap) return false;
    }
    return true;
}
