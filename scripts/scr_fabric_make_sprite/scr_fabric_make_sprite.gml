/// @function scr_fabric_make_sprite(fabric_type, info)
/// @description Returns a usable sprite for a Fabric type: the native spr_fabric_furnace resource
/// for the Furnace (nine-slice applied in objects/fabric_furnace/Create_0.gml so it can grow on
/// upgrade without distorting its border), real art if assets/sprites/fabric/<fabric_type>.png
/// exists, otherwise a solid-coloured placeholder square (info.placeholder_colour as an [r,g,b]
/// array, defaulting to white) so types without art yet (e.g. the Hatcher) still work.
/// Loaded/generated sprites are cached per type, so placing/removing Fabrics never leaks sprites.
function scr_fabric_make_sprite(_fabric_type, _info) {
    if (_fabric_type == "furnace") {
        return spr_fabric_furnace;
    }

    if (!variable_global_exists("fabric_sprite_cache")) global.fabric_sprite_cache = {};
    if (variable_struct_exists(global.fabric_sprite_cache, _fabric_type)) {
        var _cached = variable_struct_get(global.fabric_sprite_cache, _fabric_type);
        if (sprite_exists(_cached)) return _cached;
    }

    var _spr;
    var _path = "assets/sprites/fabric/" + _fabric_type + ".png";
    if (file_exists(_path)) {
        _spr = sprite_add(_path, 1, false, false, 0, 0);
    } else {
        var _rgb = (!is_undefined(_info) && variable_struct_exists(_info, "placeholder_colour")) ? _info.placeholder_colour : [255, 255, 255];
        _spr = scr_make_square_sprite(make_colour_rgb(_rgb[0], _rgb[1], _rgb[2]), 32);
    }
    variable_struct_set(global.fabric_sprite_cache, _fabric_type, _spr);
    return _spr;
}
