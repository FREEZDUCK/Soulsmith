/// @function scr_combatant_set_state(inst, sprite_prefix, state)
/// @description Shared Unit/Enemy animation-state switch: resolves spr_<sprite_prefix>_<state>,
/// falling back to a placeholder square if that state has no art yet (see scr_make_square_sprite).
/// "hurt" locks inst for a fixed HURT_STUN_DURATION (counted down in scr_combatant_update_anim)
/// rather than relying on image_index wrap-around, since every hurt sprite in this project is a
/// single still frame and can never signal completion that way. Resets attack_fired so a freshly
/// (re)entered attack animation can always land its hit (see scr_combat_try_attack).
#macro HURT_STUN_DURATION 0.1
function scr_combatant_set_state(_inst, _sprite_prefix, _state) {
    if (_inst.state == _state) return;
    _inst.state = _state;

    var _sprite_name = "spr_" + _sprite_prefix + "_" + _state;
    var _spr = asset_get_index(_sprite_name);
    if (_spr != -1 && sprite_exists(_spr)) {
        _inst.sprite_index = _spr;
    } else if (!sprite_exists(_inst.sprite_index)) {
        _inst.sprite_index = scr_make_square_sprite(_inst.colour, 16);
        sprite_set_offset(_inst.sprite_index, sprite_get_width(_inst.sprite_index) div 2, sprite_get_height(_inst.sprite_index));
    }

    _inst.image_index = 0;
    _inst.image_speed = 1;
    _inst.attack_fired = false;
    if (_state == "hurt") {
        _inst.hurt_timer = HURT_STUN_DURATION;
    }
    _inst.anim_prev_index = 0;
}
