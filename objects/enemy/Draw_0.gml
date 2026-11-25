/// 1px drop shadow (same style as Unit/Stuff/Fabric), then the sprite itself. Hit-flash: the
/// whole sprite turns solid white for as long as "hurt" plays (see
/// scr_combatant_set_state/hurt_timer), instead of its normal colours.
if (sprite_exists(sprite_index)) {
    shader_set(shd_fabric_shadow);
    draw_sprite_ext(sprite_index, image_index, x, y + 1, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
    shader_reset();
}

if (state == "hurt") {
    shader_set(shd_white_silhouette);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
    shader_reset();
} else {
    draw_self();
}

// Small HP bar for a few seconds after taking damage
scr_combatant_draw_hpbar(id, make_colour_rgb(220, 70, 70));
