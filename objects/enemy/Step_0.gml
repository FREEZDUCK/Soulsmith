/// A dying Enemy takes no further actions; its corpse is cleaned up in End Step (Step_2.gml)
if (global.game_over) exit;
if (state == "die") exit;

/// Soft push-apart from every other Unit/Enemy (see scr_combatant_separate), kept active even
/// while hurt so stunned Enemies don't become a permanent obstacle for others.
scr_combatant_separate(id);

/// A hurt Enemy is briefly knocked back and stunned (see scr_combatant_take_damage): no actions,
/// no movement, until hurt_timer runs out (see scr_combatant_update_anim, called from Step_2).
/// It still coasts, so the knockback impulse slides out smoothly.
if (state == "hurt") {
    scr_combatant_coast(id);
    exit;
}

var _dt = delta_time / 1000000;

/// Shout: raptor-type enemies periodically summon Lizardmen around themselves
if (shout_cooldown > 0) {
    shout_timer -= _dt;
    if (shout_timer <= 0) {
        shout_timer = shout_cooldown;
        set_state("shout");
        for (var _i = 0; _i < shout_count; _i++) {
            var _ang = random(360);
            scr_enemy_spawn("lizardman", x + lengthdir_x(shout_radius, _ang), y + lengthdir_y(shout_radius, _ang));
        }
    }
}

/// Target priority: always prioritize the nearest Unit first (in melee range, then chase it
/// within detect_range) and only turn to the Core once no Unit is being tracked at all
var _unit_target = scr_combat_find_nearest(x, y, unit);
var _dist_unit = (_unit_target != noone) ? point_distance(x, y, _unit_target.x, _unit_target.y) : infinity;
var _core = instance_find(fabric_core, 0);
var _dist_core = (_core != noone) ? point_distance(x, y, _core.x, _core.y) : infinity;

// Dual melee/ranged enemies (e.g. the Lizard Dragon) can engage out to whichever profile
// reaches farther; which profile actually fires is decided below, once the real distance to
// whatever target was picked is known.
var _engage_range = max(attack_range, ranged_attack_range);

var _attack_target = noone;
var _attack_dist = 0;
attacking = false;
if (_unit_target != noone && _dist_unit <= _engage_range) {
    attacking = true;
    _attack_target = _unit_target;
    _attack_dist = _dist_unit;
} else if (_unit_target != noone && _dist_unit <= detect_range) {
    target_x = _unit_target.x;
    target_y = _unit_target.y;
    has_target = true;
} else if (_core != noone && _dist_core <= _engage_range) {
    attacking = true;
    _attack_target = _core;
    _attack_dist = _dist_core;
} else if (_core != noone) {
    target_x = _core.x;
    target_y = _core.y;
    has_target = true;
} else {
    has_target = false;
}

// Melee unless the target is beyond melee attack_range but still within ranged_attack_range
var _use_ranged = attacking && ranged_attack_range > 0 && _attack_dist > attack_range;
var _active_state = _use_ranged ? ranged_attack_state : attack_state;
var _active_frame = _use_ranged ? ranged_attack_frame : attack_frame;
var _active_damage = _use_ranged ? ranged_attack_damage : attack_damage;
var _active_projectile = _use_ranged ? ranged_projectile : projectile_type;

// Kiting: an enemy with a real ranged attack (ranged_attack_range >= 50, e.g. the Lizard Dragon)
// backs away from a Unit that got too close and shoots from its ideal distance instead.
var _kiting = false;
if (attacking && _attack_target != noone && _attack_target.object_index == unit && ranged_attack_range >= 50) {
    _kiting = scr_combatant_kite(id, _attack_target, ranged_attack_range);
} else {
    kiting = false;
}

// Idle/Walk/Attack tracks movement/combat, but never interrupts a transient shout animation
// ("hurt" already exited above). Switched before scr_combat_try_attack so a freshly entered
// swing's image_index starts at 0 instead of carrying over the previous sprite's frame.
if (state != "shout") {
    set_state(_kiting ? "walk" : (attacking ? _active_state : (has_target ? "walk" : "idle")));
}

if (_kiting) {
    // already moved by scr_combatant_kite
} else if (attacking && state == _active_state) {
    /// Deals damage (or fires a projectile) exactly once per animation loop, the instant it
    /// reaches frame (see data/enemy.json, scr_combat_try_attack)
    scr_combat_try_attack(id, _attack_target, _active_damage, _active_frame, _active_projectile);
    scr_combatant_coast(id); // planted while attacking: velocity eases to zero
} else if (has_target) {
    /// Chase the current target with velocity-based smoothing (see scr_combatant_move):
    /// accelerates up to move_speed px/s at full speed (no arrival easing -- Enemies stop by
    /// reaching attack range instead).

    // Face the direction of horizontal travel; sprites are drawn facing right by default.
    if (target_x < x - 1) {
        image_xscale = -1;
    } else if (target_x > x + 1) {
        image_xscale = 1;
    }

    scr_combatant_move(id, target_x, target_y, 0);
} else {
    scr_combatant_coast(id);
}

if (hp <= 0 && state != "die") die();
