/// Furnace: heats every Stuff instance touching its bounding area by `fire_power` per second.
/// `fire_power` comes from data/fabric.json via the parent's level system (apply_level).
/// Stuff is never stored, hidden, moved, or owned -- it stays a completely normal, fully
/// visible and interactive world object for as long as it is in contact.
event_inherited();
fabric_type = "furnace";
init_fabric();
ui_colour = make_colour_rgb(255, 150, 60);

// Nine-Slice: spr_fabric_furnace (24x24) carries its own nine-slice margins (set in the IDE), so
// the Furnace can grow on upgrade without distorting its border. Do not override them here.

/// Size multiplier per upgrade level (was 1.5); Nine-Slice keeps the border undistorted.
upgrade_scale = 1.3;

on_upgraded = function() {
    image_xscale *= upgrade_scale;
    image_yscale *= upgrade_scale;
};

/// The grown Furnace must not overlap any other Fabric: check the footprint it WOULD have
/// after the upgrade (centered on the same x, y) against every other Fabric.
can_upgrade = function() {
    var _grid = 16;
    var _w = ceil(sprite_get_width(sprite_index) * abs(image_xscale) * upgrade_scale / _grid - 0.0001) * _grid;
    var _h = ceil(sprite_get_height(sprite_index) * abs(image_yscale) * upgrade_scale / _grid - 0.0001) * _grid;
    return scr_fabric_area_free(x - _w / 2, y - _h / 2, _w, _h, id);
};

heating_count = 0; // how many Stuff instances are touching right now (for the info panel)

/// Temperature gained per second of contact = fire_power * heat_per_power. The melt_tem values
/// in data/stuff.json are balanced around 10 (Furnace Lv1 = fire_power 1 = 10 tem/s).
heat_per_power = 10;

/// Extra lines for the Fabric info panel
get_info_lines = function() {
    var _lines = ["Heating : " + string(heating_count) + " Stuff"];
    if (!is_max_level() && !can_upgrade()) array_push(_lines, { text: "No space to upgrade", col: c_red });
    return _lines;
};
