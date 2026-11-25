/// @function scr_unit_make_way(mover)
/// @description Idle Units standing on `mover`'s path to its destination (or on the destination
/// itself) get a short move order to the side, so a marching Unit is never blocked by someone
/// who is doing nothing. Units that are moving, fighting or dying are left alone.
function scr_unit_make_way(_m) {
    var _dist = point_distance(_m.x, _m.y, _m.target_x, _m.target_y);
    if (_dist < 1) return;
    var _dx = (_m.target_x - _m.x) / _dist;
    var _dy = (_m.target_y - _m.y) / _dist;
    var _reach = min(_dist, 44) + 12; // look-ahead along the path
    var _clear = 30;                  // lateral distance a blocker is moved to (clear of the path)

    with (unit) {
        if (id == _m || locked || state != "idle" || has_target || attacking) continue;
        var _rx = x - _m.x;
        var _ry = y - _m.y;
        var _along = _rx * _dx + _ry * _dy;
        if (_along < -6 || _along > _reach) continue;
        var _side = -_rx * _dy + _ry * _dx; // signed lateral offset from the path
        if (abs(_side) > 24) continue;

        var _sgn = (_side == 0) ? choose(-1, 1) : sign(_side);
        var _shift = _sgn * (_clear - abs(_side));
        give_move_order(x - _dy * _shift, y + _dx * _shift);
    }
}

/// @function scr_unit_chat_pick()
/// @description Returns a random [line, reply] pair for two idle Units chatting.
function scr_unit_chat_pick() {
    static _pairs = [
        ["Nice day, isn't it?", "Too quiet, if you ask me."],
        ["You hungry?", "Always."],
        ["Think they'll come soon?", "Let them."],
        ["My feet hurt.", "You never walk anywhere."],
        ["Did you sharpen your blade?", "Twice. Relax."],
        ["Any news from the front?", "Nothing good."],
        ["I miss home.", "Same, buddy."],
        ["Got any snacks?", "Only crumbs."],
        ["Stay sharp out there.", "Always do."],
        ["Who's on watch tonight?", "Not me!"],
        ["I had a weird dream.", "Tell me later."],
        ["Is it just me or...", "...it's just you."]
    ];
    return _pairs[irandom(array_length(_pairs) - 1)];
}


// ---------------------------------------------------------------------------------------------
// Engage order (tanker -> melee -> ranged) and Lock avoidance
// ---------------------------------------------------------------------------------------------

// A Unit that spots an Enemy calls every free Unit within this many px to the fight too
#macro AGGRO_CALL_RADIUS 320
// A Unit that is ahead of a lower-tier Unit marching on the same fight slows down the further it
// gets ahead of it (full speed at no lead, AGGRO_MIN_SCALE once it leads by AGGRO_ORDER_ZONE px)
#macro AGGRO_ORDER_ZONE 14
#macro AGGRO_MIN_SCALE 0.35
// A locked Unit pushed this far (px) off its post walks back once it is not fighting
#macro LOCK_RETURN_DIST 8

/// @function scr_unit_role_tier(data)
/// @description Engage-order tier of a Unit type: 0 = tanker, 1 = melee, 2 = ranged. data.role
/// ("tanker" / "melee" / "ranged") in data/unit.json overrides the automatic guess: a Unit with
/// block_chance or the "taunt" skill is a tanker, a long attack_range (>= 50) means ranged.
function scr_unit_role_tier(_data) {
    if (variable_struct_exists(_data, "role")) {
        if (_data.role == "tanker") return 0;
        if (_data.role == "ranged") return 2;
        return 1;
    }
    var _skills = variable_struct_exists(_data, "skills") ? _data.skills : [];
    if ((variable_struct_exists(_data, "block_chance") && _data.block_chance > 0) || array_contains(_skills, "taunt")) return 0;
    if (variable_struct_exists(_data, "attack_range") && _data.attack_range >= 50) return 2;
    return 1;
}

/// @function scr_unit_alert_target(me)
/// @description The Enemy `me` is called to fight: the one that the nearest Unit (within
/// AGGRO_CALL_RADIUS) which has spotted an Enemy by itself is engaging. noone if nobody called.
function scr_unit_alert_target(_me) {
    var _best = noone;
    var _best_d = AGGRO_CALL_RADIUS;
    with (unit) {
        if (id == _me || state == "die" || !own_aggro) continue;
        if (!instance_exists(aggro_target)) continue;
        var _d = point_distance(x, y, _me.x, _me.y);
        if (_d < _best_d) {
            _best_d = _d;
            _best = aggro_target;
        }
    }
    return _best;
}

/// @function scr_unit_aggro_scale(me, target_x, target_y)
/// @description Engage order: returns 0..1, the share of its move speed `me` may use while
/// marching on the Enemy at (target_x, target_y). A Unit may not run ahead of the lower-tier Units
/// that are marching on the same fight (tanker before melee before ranged): the further ahead of
/// such a Unit it gets, the slower it walks (never below AGGRO_MIN_SCALE, it never stops or turns
/// back). Locked Units, Units with a move order and Units already fighting never slow anyone.
function scr_unit_aggro_scale(_me, _tx, _ty) {
    var _my_d = point_distance(_me.x, _me.y, _tx, _ty);
    var _scale = 1;
    with (unit) {
        if (id == _me || state == "die" || locked || order_active || attacking || !aggro) continue;
        if (role_tier >= _me.role_tier) continue;
        var _lead = point_distance(x, y, _tx, _ty) - _my_d; // > 0: `me` is ahead of this Unit
        if (_lead > 0) _scale = min(_scale, clamp(1 - _lead / AGGRO_ORDER_ZONE, 0, 1));
    }
    return max(_scale, AGGRO_MIN_SCALE);
}

/// @function scr_unit_avoid_locked(mover, target_x, target_y)
/// @description A locked Unit never makes way, so a marching Unit walks around it: returns the
/// point `mover` should head for, a side-step waypoint next to a locked Unit standing on the path,
/// or just (target_x, target_y) when the way is clear. Returns [x, y, is_waypoint].
function scr_unit_avoid_locked(_m, _tx, _ty) {
    var _dist = point_distance(_m.x, _m.y, _tx, _ty);
    if (_dist < 1) return [_tx, _ty, false];
    var _dx = (_tx - _m.x) / _dist;
    var _dy = (_ty - _m.y) / _dist;
    var _reach = min(_dist, 48) + 12;
    var _best = noone;
    var _best_along = infinity;
    var _best_side = 0;

    with (unit) {
        if (id == _m || !locked || state == "die") continue;
        if (point_distance(x, y, _tx, _ty) < 18) continue; // the destination itself: nothing to walk around
        var _rx = x - _m.x;
        var _ry = y - _m.y;
        var _along = _rx * _dx + _ry * _dy;
        if (_along < -4 || _along > _reach) continue;
        var _side = -_rx * _dy + _ry * _dx;
        if (abs(_side) > 22) continue;
        if (_along < _best_along) {
            _best_along = _along;
            _best = id;
            _best_side = _side;
        }
    }

    if (_best == noone) {
        _m.avoid_id = noone;
        return [_tx, _ty, false];
    }

    // Pass on the side with more room, and keep that side while still walking around the same Unit
    var _sgn;
    if (_m.avoid_id == _best) {
        _sgn = _m.avoid_sign;
    } else {
        _sgn = (_best_side == 0) ? choose(-1, 1) : -sign(_best_side);
        _m.avoid_id = _best;
        _m.avoid_sign = _sgn;
    }
    return [_best.x - _dy * _sgn * 32 + _dx * 12, _best.y + _dx * _sgn * 32 + _dy * 12, true];
}


// ---------------------------------------------------------------------------------------------
// Direct control ("possession"): select ONE Unit, press SPACE (see obj_unit_select_ui)
// ---------------------------------------------------------------------------------------------

/// @function scr_unit_control_enter(unit)
/// @description Takes direct control of a Unit: the camera follows it (obj_camera), WASD moves it,
/// left click attacks, right click uses its special (the Tanker's shield). Also closes the build
/// panel on the spot and drops every other selection/panel.
function scr_unit_control_enter(_u) {
    with (_u) {
        controlled = true;
        has_target = false;
        order_active = false;
        stuck_timer = 0;
        ctrl_attacking = false;
        guarding = false;
        chat_text = "";
        chat_life = 0;
        chat_reply = "";
    }
    global.controlled_unit = _u;
    global.selected_unit_info = noone;
    global.selected_fabric = noone;
    if (instance_exists(obj_fabric_purchase_ui)) {
        with (obj_fabric_purchase_ui) {
            open = false;
            placement_mode = false;
            slide = 0;
            over_panel = false;
        }
    }
}

/// @function scr_unit_control_release(unit)
/// @description Gives a possessed Unit back to the AI, staying where it stands (also the new
/// post of a locked Unit).
function scr_unit_control_release(_u) {
    if (!instance_exists(_u)) return;
    with (_u) {
        controlled = false;
        ctrl_attacking = false;
        guarding = false;
        has_target = false;
        lock_x = x;
        lock_y = y;
        if (state != "die") {
            state = "";
            set_state("idle"); // also restores image_speed after a frozen shield pose
        }
    }
}

/// @function scr_unit_control_pick_target(unit, world_x, world_y)
/// @description The living Enemy within the Unit's attack_range that is closest to the cursor
function scr_unit_control_pick_target(_u, _wx, _wy) {
    var _best = noone;
    var _best_d = infinity;
    with (enemy) {
        if (state == "die") continue;
        if (point_distance(x, y, _u.x, _u.y) > _u.attack_range) continue;
        var _d = point_distance(x, y, _wx, _wy);
        if (_d < _best_d) {
            _best_d = _d;
            _best = id;
        }
    }
    return _best;
}

/// @function scr_unit_control_step(unit, dt)
/// @description One Step of a possessed Unit (called from objects/unit Step_0 instead of its AI).
///   WASD ........ move (slowly while shielding)
///   left mouse .. attack toward the cursor (hold to keep attacking); melee hits the Enemy in range
///                 that is closest to the cursor; ranged Units always fire their projectile toward the
///                 cursor (homing onto that Enemy if there is one, else straight on)
///   right mouse . special while held: the Tanker raises its shield and blocks every hit.
///                 Other Units have no special yet (hook: add it to the `_special` section)
function scr_unit_control_step(_u, _dt) {
    with (_u) {
        // not part of the AI's aggro / kiting / chase any more
        own_aggro = false;
        aggro = false;
        aggro_target = noone;
        kiting = false;
        has_target = false;
        order_active = false;
        speed_scale = 1;

        var _m = scr_mouse_to_world();
        var _lmb = mouse_check_button(mb_left);
        var _rmb = mouse_check_button(mb_right);

        if (ctrl_attacking && state != attack_state) ctrl_attacking = false; // interrupted (hurt, ...)

        // ---- _special: right mouse ----
        var _want_guard = (block_chance > 0) && _rmb && !ctrl_attacking;
        if (_want_guard) {
            if (!guarding) {
                guarding = true;
                set_state("blocking");
            }
        } else if (guarding) {
            guarding = false;
            set_state("idle");
        }

        // ---- attack: left mouse ----
        if (!guarding) {
            if (ctrl_attacking) {
                if (image_index < anim_prev_index) { // one swing/shot finished
                    if (_lmb) {
                        attack_fired = false;
                    } else {
                        ctrl_attacking = false;
                        set_state("idle");
                    }
                }
            } else if (_lmb) {
                ctrl_attacking = true;
                set_state(attack_state);
                image_index = 0;
                anim_prev_index = 0;
                attack_fired = false;
            }
        }

        if (ctrl_attacking) {
            image_xscale = (_m[0] < x) ? -1 : 1;
            if (!attack_fired && image_index >= attack_frame) {
                attack_fired = true;
                var _t = scr_unit_control_pick_target(id, _m[0], _m[1]);
                if (projectile_type != "") {
                    // fired even with nothing in range: it flies toward the cursor and hits
                    // the first Enemy it meets (homing onto _t when there is one)
                    scr_projectile_spawn(projectile_type, x, y, _t, attack_damage, point_direction(x, y - 8, _m[0], _m[1]));
                } else if (_t != noone) {
                    _t.take_damage(attack_damage, x, y);
                }
            }
            scr_combatant_coast(id); // planted while swinging
        } else {
            // ---- movement: WASD ----
            var _mx = keyboard_check(ord("D")) - keyboard_check(ord("A"));
            var _my = keyboard_check(ord("S")) - keyboard_check(ord("W"));
            if (_mx != 0 || _my != 0) {
                var _dir = point_direction(0, 0, _mx, _my);
                speed_scale = guarding ? 0.4 : 1;
                scr_combatant_move(id, x + lengthdir_x(100, _dir), y + lengthdir_y(100, _dir), 0);
                if (_mx != 0) image_xscale = _mx;
                if (!guarding && state != "blocking") set_state("walk");
            } else {
                scr_combatant_coast(id);
                if (!guarding && state != "blocking") set_state("idle");
            }
        }
    }
}
