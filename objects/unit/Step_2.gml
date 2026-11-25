/// One-shot hurt/blocking animations return to idle/walk/attack once they loop back to frame 0;
/// the die animation instead freezes on its last frame, then the corpse is removed after
/// death_timer (see scr_combatant_update_anim).
if (hp_bar_timer > 0) hp_bar_timer -= delta_time / 1000000;

if (guarding && state == "blocking") {
    // shield held up: the blocking animation plays once, then holds its last frame
    if (image_index < anim_prev_index) {
        image_index = image_number - 1;
        image_speed = 0;
    }
    anim_prev_index = image_index;
} else scr_combatant_update_anim(id, unit_key, attacking ? attack_state : (has_target ? "walk" : "idle"));

if (state == "die") {
    if (image_speed == 0) {
        death_timer -= delta_time / 1000000;
        if (death_timer <= 0) instance_destroy();
    }
} else {
    /// Top-down depth sorting inside the Unit band (always in front of Stuff and Fabric),
    /// updated after this step's movement
    depth = scr_depth_from_y(y, DEPTH_BASE_UNIT);
}
