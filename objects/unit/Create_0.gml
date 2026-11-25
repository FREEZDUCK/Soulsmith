/// Unit must be initialized via scr_unit_spawn(unit_key, x, y). Properties are entirely
/// data-driven from data/unit.json, so new Units/stats never require touching this object.
unit_key = "";
data = undefined;
unit_name = "";
hp = 0;
max_hp = 0;
move_speed = 0;
skills = [];     // skill id strings; no execution behaviour implemented yet
colour = c_white;

target_x = x;
target_y = y;
has_target = false;

// Smooth movement (see scr_combatant_move): current velocity in px/s, plus the smoothed
// push-apart vector used by scr_combatant_separate
vx = 0;
vy = 0;
arrive_tolerance = 5; // px: a move order counts as done once this close (see scr_combatant_move)
sep_x = 0;
sep_y = 0;

// True while following a player move order (right-click / formation). Such an order is never
// hijacked by auto-chasing a nearby Enemy and is only finished by actually arriving (or by
// giving up after being physically stuck, see Step_0 stuck_timer).
order_active = false;
stuck_timer = 0;

// Idle chatter (see Step_0 / Draw_64): chat_text is the line currently shown in the speech bubble
// for chat_life seconds; a partner's answer waits in chat_reply for chat_reply_delay seconds.
chat_text = "";
chat_life = 0;
chat_reply = "";
chat_reply_delay = 0;
chat_timer = random_range(4, 10); // seconds of idling until the next chat attempt

selected = false;

// Lock (L key, see obj_unit_select_ui): a locked Unit holds its post at (lock_x, lock_y). It still
// fights whatever comes in range, but never chases an Enemy, ignores move orders, never makes way
// for other Units (they walk around it, see scr_unit_avoid_locked) and is not pushed apart by
// them. Knockback still moves it; once it is no longer fighting it walks back to its post.
locked = false;
lock_x = x;
lock_y = y;

// Engage order (see scr_unit_aggro_scale): role_tier 0 = tanker, 1 = melee, 2 = ranged. When an
// Enemy is spotted (own_aggro) the Units around are called (aggro), and they march out tanker ->
// melee -> ranged: a Unit never runs ahead of the lower-tier Units marching on the same fight.
role_tier = 1;
own_aggro = false;     // this Unit itself has an Enemy within detect_range
aggro_target = noone;  // that Enemy
aggro = false;         // own_aggro, or called by a nearby Unit that has one
speed_scale = 1;       // share of move_speed it may use this step (engage-order throttle)

// Direct control (SPACE on a single selected Unit, see scr_unit_control_step): controlled = the
// player drives it; guarding = shield up (right mouse, Tanker): every hit is blocked;
// ctrl_attacking = a player-triggered swing/shot is playing.
controlled = false;
guarding = false;
ctrl_attacking = false;

// Kiting (ranged Units, see scr_combatant_kite)
kiting = false;
kite_timer = 0;
kite_cd = 0;

// Walking around locked Units (see scr_unit_avoid_locked): which one, and on which side
avoid_id = noone;
avoid_sign = 1;

// Seconds the small HP bar is still shown under this Unit after a hit (see scr_combatant_take_damage)
hp_bar_timer = 0;

/// Locks this Unit on its current spot, or releases it (see the L key in obj_unit_select_ui)
set_locked = function(_lock) {
    locked = _lock;
    has_target = false;
    order_active = false;
    stuck_timer = 0;
    avoid_id = noone;
    if (_lock) {
        lock_x = x;
        lock_y = y;
        chat_text = "";
        chat_life = 0;
        chat_reply = "";
    }
};

/// Gives this Unit a move order to (_tx, _ty); cancels any speech bubble.
give_move_order = function(_tx, _ty) {
    if (locked) return; // a locked Unit stays on its post, whatever it is told
    target_x = _tx;
    target_y = _ty;
    has_target = true;
    order_active = true;
    stuck_timer = 0;
    chat_text = "";
    chat_life = 0;
    chat_reply = "";
};

// Combat (see data/unit.json): attack_state lets a Unit's attack animation use a different
// suffix than "attack" (e.g. the Archer's spr_archer_shoot). attack_frame is the exact frame of
// that animation (0-based) at which the hit actually lands (see scr_combat_try_attack);
// attack_fired tracks whether this loop of the animation has already landed its hit, reset on
// every loop and on every fresh state change (see scr_combatant_set_state). block_chance is 0
// for every Unit except the Tanker, whose spr_tanker_blocking gives it a chance to block a hit
// for free.
attack_damage = 0;
attack_range = 0;
attack_cooldown = 1;
attack_state = "attack";
attack_frame = 0;
attack_fired = false;
block_chance = 0;
attacking = false;

// "" deals attack_damage instantly on hit; otherwise the type of projectile (see
// scr_projectile_spawn) fired instead, e.g. the Archer's "arrow" or the Magician's "fireball"
// (named projectile_type, not projectile, since "projectile" is the parent object's own name)
projectile_type = "";

// How far a Unit notices a nearby Enemy and marches to engage it, even without a move order
// (set in initialize() to 5x attack_range; see objects/unit/Step_0.gml)
detect_range = 0;

// Animation state machine: idle/walk/attack reflect movement/combat automatically, while
// hurt/blocking/die are entered via take_hurt()/block()/die() and play once before returning
// (see Step/End Step). Shared with Enemy via scr_combatant_* (see scripts).
state = "idle";
anim_prev_index = 0;
hurt_timer = 0; // seconds left showing the (single-frame) hurt sprite, see scr_combatant_set_state
death_timer = 1; // seconds the corpse lingers on its last die frame before being removed

set_state = function(_state) {
    scr_combatant_set_state(id, unit_key, _state);
};

// No enemies/combat exist yet: these just switch art. Future combat code calls them directly.
take_hurt = function() {
    if (state != "die") set_state("hurt");
};

block = function() {
    if (state != "die") set_state("blocking");
};

die = function() {
    set_state("die");
};

take_damage = function(_amount, _source_x, _source_y) {
    scr_combatant_take_damage(id, _amount, _source_x, _source_y);
};

initialize = function() {
    data = global.unit_data[$ unit_key];
    unit_name = data.name;
    hp = data.hp;
    max_hp = data.hp;
    move_speed = data.move_speed;
    skills = variable_struct_exists(data, "skills") ? data.skills : [];

    attack_damage = variable_struct_exists(data, "attack_damage") ? data.attack_damage : 0;
    attack_range = variable_struct_exists(data, "attack_range") ? data.attack_range : 0;
    attack_cooldown = variable_struct_exists(data, "attack_cooldown") ? data.attack_cooldown : 1;
    attack_state = variable_struct_exists(data, "attack_state") ? data.attack_state : "attack";
    attack_frame = variable_struct_exists(data, "attack_frame") ? data.attack_frame : 0;
    block_chance = variable_struct_exists(data, "block_chance") ? data.block_chance : 0;
    projectile_type = variable_struct_exists(data, "projectile") ? data.projectile : "";
    attack_fired = false;
    attacking = false;
    detect_range = attack_range * 5;
    role_tier = scr_unit_role_tier(data);

    var _rgb = variable_struct_exists(data, "colour") ? data.colour : [255, 255, 255];
    colour = make_colour_rgb(_rgb[0], _rgb[1], _rgb[2]);

    sprite_index = -1;
    state = "";
    set_state("idle");
    depth = scr_depth_from_y(y, DEPTH_BASE_UNIT);
};
