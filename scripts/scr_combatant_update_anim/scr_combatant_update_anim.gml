/// @function scr_combatant_update_anim(inst, sprite_prefix, resume_state)
/// @description Call once per End Step. "hurt" resumes to resume_state when hurt_timer runs out
/// (set in scr_combatant_set_state); every hurt sprite is a single still frame, so it cannot
/// signal completion via image_index wrap-around the way the multi-frame blocking/shout
/// animations do. die instead freezes on its last frame.
function scr_combatant_update_anim(_inst, _sprite_prefix, _resume_state) {
    var _state = _inst.state;
    if (_state == "hurt") {
        _inst.hurt_timer -= delta_time / 1000000;
        if (_inst.hurt_timer <= 0) {
            scr_combatant_set_state(_inst, _sprite_prefix, _resume_state);
        }
    } else if ((_state == "blocking" || _state == "shout") && _inst.image_index < _inst.anim_prev_index) {
        scr_combatant_set_state(_inst, _sprite_prefix, _resume_state);
    } else if (_state == "die" && _inst.image_index < _inst.anim_prev_index) {
        _inst.image_index = _inst.image_number - 1;
        _inst.image_speed = 0;
    }
    _inst.anim_prev_index = _inst.image_index;
}
