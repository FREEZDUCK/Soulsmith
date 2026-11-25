/// Shared Unit/Enemy velocity-based movement. Instead of teleporting move_speed pixels per step,
/// each combatant owns a velocity (vx, vy, px/s) that eases toward the desired velocity with a
/// frame-rate independent lerp, so starting, stopping, turning and knockback all look smooth.

// How fast velocity closes in on the desired velocity while moving (per second). Higher = snappier.
// 6 means ~63% of the way there after 1/6 s.
#macro COMBATANT_ACCEL_RATE 6

// How fast velocity bleeds off while standing still, attacking, stunned or dying (per second).
#macro COMBATANT_STOP_RATE 9

// A Unit starts easing off this many pixels before its move-order destination, so it glides in
// instead of stopping dead. Enemies chase at full speed (they stop when they reach attack range).
#macro COMBATANT_ARRIVE_RADIUS 24

// Multiplier on the Unit/Enemy push-apart (see scr_combatant_separate).
#macro COMBATANT_SEPARATE_STRENGTH 0.5

/// @function scr_combatant_move(inst, target_x, target_y, arrive_radius)
/// @description Accelerates inst toward (target_x, target_y) at inst.move_speed (px/s) and moves
/// it by its current velocity. arrive_radius > 0 slows it down on approach. Returns true on the
/// step it reaches the target (position is snapped onto it and velocity is cleared).
function scr_combatant_move(_inst, _tx, _ty, _arrive_radius) {
    var _dt = delta_time / 1000000;
    var _dist = point_distance(_inst.x, _inst.y, _tx, _ty);

    // speed_scale (optional, 0..1): a Unit that must not overtake the Units engaging ahead of it
    // (see scr_unit_aggro_scale) walks slower instead of running past them
    var _desired_speed = _inst.move_speed;
    if (variable_instance_exists(_inst, "speed_scale")) _desired_speed *= _inst.speed_scale;
    if (_arrive_radius > 0) {
        // Never drop below 20% of top speed, otherwise the last few pixels would take forever
        _desired_speed *= clamp(_dist / _arrive_radius, 0.2, 1);
    }

    var _dir = point_direction(_inst.x, _inst.y, _tx, _ty);
    var _k = 1 - exp(-COMBATANT_ACCEL_RATE * _dt);
    _inst.vx = lerp(_inst.vx, lengthdir_x(_desired_speed, _dir), _k);
    _inst.vy = lerp(_inst.vy, lengthdir_y(_desired_speed, _dir), _k);

    var _step = point_distance(0, 0, _inst.vx, _inst.vy) * _dt;
    // "Close enough" counts as arrived (inst.arrive_tolerance, 0.5px if unset): being pixel-perfect
    // is impossible once push-apart nudges Units around, and chasing it makes them jitter forever
    var _tol = variable_instance_exists(_inst, "arrive_tolerance") ? _inst.arrive_tolerance : 0.5;
    if (_dist <= max(_step, _tol)) {
        if (_dist <= _step) {
            _inst.x = _tx;
            _inst.y = _ty;
        }
        _inst.vx = 0;
        _inst.vy = 0;
        return true;
    }

    _inst.x += _inst.vx * _dt;
    _inst.y += _inst.vy * _dt;
    return false;
}

/// @function scr_combatant_coast(inst)
/// @description Called whenever inst is NOT being driven toward a target (idle, attacking, hurt,
/// dying): velocity eases to zero instead of stopping dead, and any knockback impulse slides out.
function scr_combatant_coast(_inst) {
    var _dt = delta_time / 1000000;
    var _k = 1 - exp(-COMBATANT_STOP_RATE * _dt);
    _inst.vx = lerp(_inst.vx, 0, _k);
    _inst.vy = lerp(_inst.vy, 0, _k);
    if (abs(_inst.vx) < 0.05 && abs(_inst.vy) < 0.05) {
        _inst.vx = 0;
        _inst.vy = 0;
    }
    _inst.x += _inst.vx * _dt;
    _inst.y += _inst.vy * _dt;
}

// Kiting: a ranged Unit/Enemy that an opponent gets closer to than KITE_MIN_FRAC * its attack range
// backs away (at full speed, still facing the opponent) until it is KITE_MAX_FRAC * range away,
// then shoots again. It gives up after KITE_MAX_TIME seconds (cornered / outrun) and stands its
// ground for KITE_COOLDOWN seconds before it may kite again.
#macro KITE_MIN_FRAC 0.45
#macro KITE_MAX_FRAC 0.8
#macro KITE_MAX_TIME 1.6
#macro KITE_COOLDOWN 1.5

/// @function scr_combatant_kite(inst, target, attack_range)
/// @description Returns true (and moves inst away from target) while inst is kiting this step.
/// Needs inst.kiting / kite_timer / kite_cd.
function scr_combatant_kite(_inst, _tgt, _range) {
    var _dt = delta_time / 1000000;
    if (_inst.kite_cd > 0) _inst.kite_cd -= _dt;

    var _d = point_distance(_inst.x, _inst.y, _tgt.x, _tgt.y);
    if (!_inst.kiting) {
        if (_d < _range * KITE_MIN_FRAC && _inst.kite_cd <= 0) {
            _inst.kiting = true;
            _inst.kite_timer = 0;
        }
    } else {
        _inst.kite_timer += _dt;
        if (_d >= _range * KITE_MAX_FRAC) {
            _inst.kiting = false;
        } else if (_inst.kite_timer > KITE_MAX_TIME) {
            _inst.kiting = false;
            _inst.kite_cd = KITE_COOLDOWN;
        }
    }
    if (!_inst.kiting) return false;

    var _dir = point_direction(_tgt.x, _tgt.y, _inst.x, _inst.y);
    scr_combatant_move(_inst, _inst.x + lengthdir_x(80, _dir), _inst.y + lengthdir_y(80, _dir), 0);
    _inst.image_xscale = (_tgt.x < _inst.x) ? -1 : 1; // keeps facing the opponent
    return true;
}
