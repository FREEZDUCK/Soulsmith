/// @function scr_combat_try_attack(inst, target, damage, frame, projectile)
/// @description Shared Unit/Enemy attack resolution. Must only be called while inst's sprite is
/// already showing its attack_state animation (see unit/enemy Step_0, which switches state
/// before calling this): faces the target and lands the hit exactly once per loop of that
/// animation, the instant it reaches frame, never more than once per loop. attack_fired is reset
/// whenever the loop wraps back to frame 0, and also whenever the attack animation is freshly
/// (re)entered (see scr_combatant_set_state). damage/frame are passed explicitly (rather than
/// read from inst directly) so a dual melee/ranged attacker (e.g. the Lizard Dragon) can pick
/// whichever profile applies this step. projectile is "" for an instant melee hit, or a type
/// understood by scr_projectile_spawn ("arrow"/"fireball") to fire a travelling projectile that
/// deals the damage itself on arrival instead.
function scr_combat_try_attack(_inst, _target, _damage, _frame, _projectile) {
    _inst.image_xscale = (_target.x < _inst.x) ? -1 : 1;

    if (_inst.image_index < _inst.anim_prev_index) {
        _inst.attack_fired = false;
    }

    if (!_inst.attack_fired && _inst.image_index >= _frame) {
        _inst.attack_fired = true;
        if (!is_undefined(_projectile) && _projectile != "") {
            scr_projectile_spawn(_projectile, _inst.x, _inst.y, _target, _damage);
        } else if (variable_instance_exists(_target, "take_damage")) {
            _target.take_damage(_damage, _inst.x, _inst.y);
        }
    }
}
