/// Stuff must be initialized via scr_stuff_spawn(type, x, y)
stuff_type = "";
data = undefined;
name = "";
melt_tem = 0;
value = 0;
tem = 0;

held = false;
hold_offset_x = 0;
hold_offset_y = 0;

stored_in = noone;      // Hatcher instance holding this Stuff (hidden from the world while stored)
selected = false;       // part of the current drag-selection box

furnace_heat_time = 0;  // seconds of accumulated Furnace contact; see fabric_furnace/Step_0.gml

initialize = function() {
    data = global.stuff_data[$ stuff_type];
    name = data.name;
    melt_tem = data.melt_tem;
    value = data.value;
    tem = 0;
    if (sprite_exists(sprite_index)) sprite_delete(sprite_index); // free the previous tier's sprite on transform
    sprite_index = sprite_add("assets/sprites/stuff/" + stuff_type + ".png", 1, false, false, 0, 0);
    // Middle Center origin: keeps outline and bbox (hover) aligned with (x, y)
    sprite_set_offset(sprite_index, sprite_get_width(sprite_index) div 2, sprite_get_height(sprite_index) div 2);
    image_speed = 0;
    depth = scr_depth_from_y(y, DEPTH_BASE_STUFF);
};
