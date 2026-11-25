/// Draw order: 1px drop shadow, selection outline (if selected), then the sprite itself
if (sprite_exists(sprite_index)) {
    // Silhouette shifted 1px down; the sprite drawn last covers all but the bottom 1px band
    shader_set(shd_fabric_shadow);
    draw_sprite_ext(sprite_index, image_index, x, y + 1, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
    shader_reset();
}

if (global.selected_fabric == id) {
    shader_set(shd_white_silhouette);
    // Must use the instance's current scale, otherwise an upgraded (enlarged) Furnace gets a
    // 1x-sized outline that is completely hidden behind the real sprite
    draw_sprite_ext(sprite_index, image_index, x - 1, y, image_xscale, image_yscale, image_angle, c_white, 1);
    draw_sprite_ext(sprite_index, image_index, x + 1, y, image_xscale, image_yscale, image_angle, c_white, 1);
    draw_sprite_ext(sprite_index, image_index, x, y - 1, image_xscale, image_yscale, image_angle, c_white, 1);
    draw_sprite_ext(sprite_index, image_index, x, y + 1, image_xscale, image_yscale, image_angle, c_white, 1);
    shader_reset();
}

draw_self();

draw_overlay();
