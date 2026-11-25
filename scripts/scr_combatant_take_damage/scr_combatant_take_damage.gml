/// @function scr_combatant_take_damage(inst, amount, source_x, source_y)
/// @description Shared Unit/Enemy damage resolution: a Unit with a positive block_chance (e.g.
/// the Tanker) may block the hit entirely (spr_<key>_blocking, no damage), otherwise hp is
/// reduced and the hurt/die animation plays. A surviving hit also knocks inst back a short,
/// fixed distance straight away from (source_x, source_y), the attacker's position.
#macro HURT_KNOCKBACK_DIST 8

// Small HP bar shown under a Unit/Enemy after it took damage (see scr_combatant_draw_hpbar)
#macro HP_BAR_SHOW_TIME 3   // seconds it stays visible after the last hit
#macro HP_BAR_W 20          // px
#macro HP_BAR_H 5           // px
function scr_combatant_take_damage(_inst, _amount, _source_x, _source_y) {
    if (_inst.state == "die") return;

    if (_inst.guarding || (variable_instance_exists(_inst, "block_chance") && _inst.block_chance > 0 && random(1) < _inst.block_chance)) {
        _inst.block();
        return;
    }

    _inst.hp -= _amount;
    _inst.hp_bar_timer = HP_BAR_SHOW_TIME; // small HP bar under the Unit/Enemy for a while
    if (_inst.hp <= 0) {
        _inst.die();
    } else {
        var _dir = point_direction(_source_x, _source_y, _inst.x, _inst.y);
        // Velocity impulse (see scr_combatant_move): it bleeds off at COMBATANT_STOP_RATE, so the
        // total slide is HURT_KNOCKBACK_DIST pixels instead of an instant jump.
        var _kb_speed = HURT_KNOCKBACK_DIST * COMBATANT_STOP_RATE;
        _inst.vx += lengthdir_x(_kb_speed, _dir);
        _inst.vy += lengthdir_y(_kb_speed, _dir);
        _inst.take_hurt();
    }
}

/// @function scr_combatant_draw_hpbar(inst, colour)
/// @description Small world-space HP bar just under a Unit/Enemy (same bar style as the Hatcher's
/// progress bar). Only visible while hp_bar_timer (set on every hit, counted down in End Step)
/// is running; fades out over its last 0.4 s and never shows on a corpse. Call from Draw.
function scr_combatant_draw_hpbar(_inst, _col) {
    if (_inst.hp_bar_timer <= 0 || _inst.state == "die" || _inst.hp <= 0) return;
    var _a = draw_get_alpha();
    draw_set_alpha(_a * clamp(_inst.hp_bar_timer / 0.4, 0, 1));
    var _x1 = round(_inst.x - HP_BAR_W / 2);
    var _y1 = round(_inst.bbox_bottom) + 2;
    scr_ui_draw_bar(_x1, _y1, _x1 + HP_BAR_W - 1, _y1 + HP_BAR_H - 1, _inst.hp / max(1, _inst.max_hp), _col, 0);
    draw_set_alpha(_a);
}
