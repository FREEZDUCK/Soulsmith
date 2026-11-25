/// One-shot hurt/shout animations return to idle/walk/attack once they loop back to frame 0;
/// the die animation instead freezes on its last frame, then the corpse is removed after
/// death_timer (see scr_combatant_update_anim).
if (hp_bar_timer > 0) hp_bar_timer -= delta_time / 1000000;

scr_combatant_update_anim(id, enemy_key, attacking ? attack_state : (has_target ? "walk" : "idle"));

if (state == "die") {
    if (image_speed == 0) {
        death_timer -= delta_time / 1000000;
        if (death_timer <= 0) instance_destroy();
    }
} else {
    /// Top-down depth sorting, shared with the Unit band so they interleave correctly on screen
    depth = scr_depth_from_y(y, DEPTH_BASE_UNIT);
}
