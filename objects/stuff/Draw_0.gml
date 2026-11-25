/// 1px drop shadow (same style as Fabric), hover/selection outline, then the sprite.
var _is_hovered = (global.hovered_stuff == id);

if (sprite_exists(sprite_index)) {
    shader_set(shd_fabric_shadow);
    draw_sprite_ext(sprite_index, image_index, x, y + 1, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
    shader_reset();
}

if (_is_hovered || selected) {
    shader_set(shd_white_silhouette);
    draw_sprite(sprite_index, image_index, x - 1, y);
    draw_sprite(sprite_index, image_index, x + 1, y);
    draw_sprite(sprite_index, image_index, x, y - 1);
    draw_sprite(sprite_index, image_index, x, y + 1);
    shader_reset();
}

draw_self();
