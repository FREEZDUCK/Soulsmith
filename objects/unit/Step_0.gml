if (global.game_over) exit; // Core destroyed: the fight is over
/// A dying Unit takes no further actions (it just coasts to a stop); its corpse is cleaned up in
/// End Step (Step_2.gml)
if (state == "die") {
    scr_combatant_coast(id);
    exit;
}

/// Soft push-apart from every other Unit/Enemy (see scr_combatant_separate), kept active even
/// while hurt so stunned Units don't become a permanent obstacle for others.
scr_combatant_separate(id);

/// A hurt Unit is briefly knocked back and stunned (see scr_combatant_take_damage): no actions,
/// no movement, until hurt_timer runs out (see scr_combatant_update_anim, called from Step_2).
/// It still coasts, so the knockback impulse slides out smoothly.
if (state == "hurt") {
    scr_combatant_coast(id);
    exit;
}

var _dt = delta_time / 1000000;
speed_scale = 1;

/// Possessed by the player: no AI at all (see scr_unit_control_step)
if (controlled) {
    scr_unit_control_step(id, _dt);
    if (hp <= 0 && state != "die") die();
    exit;
}

/// Combat: auto-attack the nearest living Enemy within attack_range (holding the Unit in place
/// for the step instead of advancing toward its move order); if none is in range but one is
/// within detect_range, march toward it instead of waiting for a move order, overriding any
/// pending one for the step.
var _enemy_target = scr_combat_find_nearest(x, y, enemy);
var _dist_enemy = (_enemy_target != noone) ? point_distance(x, y, _enemy_target.x, _enemy_target.y) : infinity;

attacking = (_enemy_target != noone && attack_range > 0 && _dist_enemy <= attack_range);

/// Aggro: this Unit spotted an Enemy by itself (own_aggro), or is called to the fight by a nearby
/// Unit that did (scr_unit_alert_target). _chase is the Enemy it would march on.
own_aggro = (_enemy_target != noone && detect_range > 0 && _dist_enemy <= detect_range);
aggro_target = own_aggro ? _enemy_target : noone;
var _chase = own_aggro ? _enemy_target : scr_unit_alert_target(id);
aggro = (_chase != noone);

if (locked) {
    /// Locked: never leaves its post to chase. Fighting in range still works; once it is no longer
    /// fighting and was pushed off its post (knockback, ...) it walks back.
    if (attacking) {
        has_target = false;
    } else if (point_distance(x, y, lock_x, lock_y) > LOCK_RETURN_DIST) {
        target_x = lock_x;
        target_y = lock_y;
        has_target = true;
        order_active = false;
    }
} else if (!order_active && !attacking && _chase != noone) {
    /// Engage order: tanker -> melee -> ranged (scr_unit_aggro_scale). A Unit that is ahead of the
    /// lower-tier Units marching on the same fight just walks slower, so the line forms naturally.
    speed_scale = scr_unit_aggro_scale(id, _chase.x, _chase.y);
    target_x = _chase.x;
    target_y = _chase.y;
    has_target = true;
} else if (!order_active && !attacking) {
    /// Nothing to fight: stay right where it is (no walking on to the last known Enemy position)
    has_target = false;
}

/// Kiting: a ranged Unit backs away from an Enemy that got too close, then shoots again
/// (see scr_combatant_kite). Not while locked or following a move order.
var _kiting = false;
if (role_tier == 2 && !locked && !order_active && _enemy_target != noone && attack_range > 0 && _dist_enemy <= attack_range) {
    _kiting = scr_combatant_kite(id, _enemy_target, attack_range);
} else {
    kiting = false;
}

/// Idle chatter: a Unit that is doing nothing sometimes says a line to a nearby idle Unit, who
/// answers a moment later (speech bubbles are drawn in Draw_64). Any movement/combat cancels it.
if (chat_life > 0) {
    chat_life -= _dt;
    if (chat_life <= 0) chat_text = "";
}
if (chat_reply != "") {
    chat_reply_delay -= _dt;
    if (chat_reply_delay <= 0) {
        chat_text = chat_reply;
        chat_life = 2.6;
        chat_reply = "";
    }
}
var _idle_now = (!has_target && !attacking && !aggro && state == "idle");
if (!_idle_now) {
    chat_text = "";
    chat_life = 0;
    chat_reply = "";
} else if (chat_life <= 0 && chat_reply == "") {
    chat_timer -= _dt;
    if (chat_timer <= 0) {
        chat_timer = random_range(20, 40);
		var _roll = (random(1) < 0.05); // 5% 확률
        var _self = id;
        var _pal = noone;
        var _best = 110; // px: only chat with Units that are close by
        with (unit) {
            if (id != _self && state == "idle" && !has_target && !attacking && chat_life <= 0 && chat_reply == "") {
                var _d = point_distance(x, y, _self.x, _self.y);
                if (_d < _best) {
                    _best = _d;
                    _pal = id;
                }
            }
        }
        if (_roll && _pal != noone) {
            var _pair = scr_unit_chat_pick();
            chat_text = _pair[0];
            chat_life = 2.6;
            if (_pal.x != x) image_xscale = (_pal.x > x) ? 1 : -1;
            _pal.chat_reply = _pair[1];
            _pal.chat_reply_delay = 1.7;
            _pal.chat_timer = max(_pal.chat_timer, 8);
            if (_pal.x != x) _pal.image_xscale = (_pal.x > x) ? -1 : 1;
        }
    }
}

// Idle/Walk/Attack tracks movement/combat, but never interrupts a transient blocking animation
// ("hurt" already exited above). Switched before scr_combat_try_attack so a freshly entered
// swing's image_index starts at 0 instead of carrying over the previous sprite's frame.
if (state != "blocking") {
    set_state(_kiting ? "walk" : (attacking ? attack_state : (has_target ? "walk" : "idle")));
}

if (_kiting) {
    // already moved by scr_combatant_kite
} else if (attacking && state == attack_state) {
    /// Deals attack_damage exactly once per animation loop, the instant it reaches attack_frame
    /// (see data/unit.json, scr_combat_try_attack)
    scr_combat_try_attack(id, _enemy_target, attack_damage, attack_frame, projectile_type);
    scr_combatant_coast(id); // planted while swinging: velocity eases to zero
} else if (has_target) {
    /// Move toward the commanded destination with velocity-based smoothing (see
    /// scr_combatant_move): accelerates up to move_speed px/s and eases off near the destination,
    /// independently of every other Unit (see obj_unit_select_ui for the drag-select box and
    /// right-click move order)

    // Face the direction of horizontal travel; sprites are drawn facing right by default.
    // Purely vertical movement (|dx| <= 1) keeps the current facing.
    if (target_x < x - 1) {
        image_xscale = -1;
    } else if (target_x > x + 1) {
        image_xscale = 1;
    }

    // Idle Units never step aside; we walk around locked ones (scr_unit_avoid_locked) and
    // the soft push-apart handles the rest
    var _wp = scr_unit_avoid_locked(id, target_x, target_y);

    if (_wp[2]) {
        scr_combatant_move(id, _wp[0], _wp[1], 0); // side-step waypoint: never counts as arriving
    } else if (scr_combatant_move(id, target_x, target_y, COMBATANT_ARRIVE_RADIUS)) {
        has_target = false;
        order_active = false;
        stuck_timer = 0;
    } else {
        // Physically stuck right next to the destination (e.g. wedged in a crowd)? After a moment
        // accept "close enough" so the Unit doesn't grind there forever. Far from the destination
        // it keeps trying: blockers get out of the way instead.
        var _moved = point_distance(x, y, xprevious, yprevious) / max(0.0001, _dt);
        if (_moved < move_speed * speed_scale * 0.15 && point_distance(x, y, target_x, target_y) < 40) {
            stuck_timer += _dt;
            if (stuck_timer > 1.5) {
                has_target = false;
                order_active = false;
                stuck_timer = 0;
            }
        } else {
            stuck_timer = 0;
        }
    }
} else {
    scr_combatant_coast(id);
}

if (hp <= 0 && state != "die") die();
