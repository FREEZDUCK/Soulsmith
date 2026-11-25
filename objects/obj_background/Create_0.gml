/// Infinite seamless-tiled Play Room background
depth = 15000;

// Push the room's tiled Background layer (editor depth 100) behind the Y-sorted
// Stuff/Fabric depth bands [1, 14999] (see scr_depth_from_y) so it can never cover world objects.
var _bg_layer = layer_get_id("Background");
if (_bg_layer != -1) {
    layer_depth(_bg_layer, depth + 100);
}
spr = sprite_add("assets/sprites/grass.png", 1, false, false, 0, 0);
tile_w = sprite_get_width(spr);
tile_h = sprite_get_height(spr);
