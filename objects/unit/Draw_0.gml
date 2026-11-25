/// 1px drop shadow (same style as Stuff/Fabric) and selection outline, then the square itself
if (sprite_exists(sprite_index)) {
    shader_set(shd_fabric_shadow);
    draw_sprite_ext(sprite_index, image_index, x, y + 1, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
    shader_reset();
}

if (selected) {
    // draw_sprite() ignores image_xscale/yscale/angle, so a flipped Unit's outline would be
    // drawn unflipped and no longer match its (mirrored) body; draw_sprite_ext() keeps them in sync.
    shader_set(shd_white_silhouette);
    draw_sprite_ext(sprite_index, image_index, x - 1, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
    draw_sprite_ext(sprite_index, image_index, x + 1, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
    draw_sprite_ext(sprite_index, image_index, x, y - 1, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
    draw_sprite_ext(sprite_index, image_index, x, y + 1, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
    shader_reset();
}

// Hit-flash: the whole sprite turns solid white for as long as "hurt" plays (see
// scr_combatant_set_state/hurt_timer), instead of its normal colours.
if (state == "hurt") {
    shader_set(shd_white_silhouette);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
    shader_reset();
} else {
    draw_self();
}

// Lock marker: a little padlock above a locked Unit
if (locked && state != "die") {
    var _lx = round(x);
    var _ly = round(bbox_top) - 9;
    draw_set_colour(c_black);
    draw_rectangle(_lx - 3, _ly - 2, _lx + 3, _ly + 6, false);
    draw_set_colour(make_colour_rgb(255, 215, 70));
    draw_rectangle(_lx - 2, _ly + 2, _lx + 2, _ly + 5, false); // body
    draw_rectangle(_lx - 2, _ly - 1, _lx - 2, _ly + 1, false); // shackle
    draw_rectangle(_lx + 2, _ly - 1, _lx + 2, _ly + 1, false);
    draw_rectangle(_lx - 1, _ly - 1, _lx + 1, _ly - 1, false);
    draw_set_colour(c_white);
}

// Small HP bar for a few seconds after taking damage
scr_combatant_draw_hpbar(id, make_colour_rgb(80, 200, 90));
