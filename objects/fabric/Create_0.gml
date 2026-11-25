/// Parent Fabric: common data/level/upgrade/shadow logic.
/// Child objects must call event_inherited() FIRST, then set fabric_type, then call init_fabric().
/// (Setting fabric_type before event_inherited() gets overwritten by the line below.)
fabric_type = "";
data = undefined;
level_data = undefined;
level_order = [];
level_idx = 0;
ui_colour = c_white; // accent colour of the info panel header (children override after init_fabric)

apply_level = function(_key) {
    scr_fabric_apply_level(id, level_data, _key);
};

init_fabric = function() {
    data = global.fabric_data[$ fabric_type];
    level_data = data.level_data;
    level_order = scr_fabric_build_level_order(level_data);
    level_idx = 0;
    apply_level(level_order[0]);
    sprite_index = scr_fabric_make_sprite(fabric_type, data.info);
    // Middle Center origin: keeps placement grid, outline, rotation and bbox centered on (x, y)
    sprite_set_offset(sprite_index, sprite_get_width(sprite_index) div 2, sprite_get_height(sprite_index) div 2);
    image_speed = 0;
    depth = scr_depth_from_y(y, DEPTH_BASE_FABRIC);
};

is_max_level = function() {
    return (level_idx >= array_length(level_order) - 1);
};

get_display_level = function() {
    var _key = level_order[level_idx];
    if (_key == "init") return 1;
    if (_key == "max") {
        var _highest = 1;
        for (var _i = 0; _i < array_length(level_order); _i++) {
            var _k = level_order[_i];
            if (_k != "init" && _k != "max") {
                _highest = max(_highest, real(_k));
            }
        }
        return _highest + 1;
    }
    return real(_key);
};

get_next_level_values = function() {
    if (is_max_level()) return undefined;
    return variable_struct_get(level_data, level_order[level_idx + 1]);
};

get_upgrade_cost = function() {
    var _next = get_next_level_values();
    if (is_undefined(_next)) return 0;
    return variable_struct_exists(_next, "cost") ? _next.cost : 0;
};

/// Extra info-panel lines for this Fabric type (children such as fabric_furnace override this)
get_info_lines = function() {
    return [];
};

/// Extra per-type reaction to a successful upgrade (children such as fabric_furnace override this)
on_upgraded = function() {
};

/// Whether the upgrade may happen right now, e.g. enough free space (fabric_furnace overrides this)
can_upgrade = function() {
    return true;
};

/// Called right before the player removes this Fabric (X key); children release what they hold
on_removed = function() {
};

/// Extra world-space drawing on top of the sprite (the Core's health bar); no-op by default
draw_overlay = function() {
};

upgrade = function() {
    if (is_max_level()) return false;
    var _cost = get_upgrade_cost();
    if (global.gold < _cost) return false;
    if (!can_upgrade()) return false;
    global.gold -= _cost;
    level_idx += 1;
    apply_level(level_order[level_idx]);
    on_upgraded();
    part_particles_create(global.psystem, x, y, global.pt_firework, 24);
    return true;
};
