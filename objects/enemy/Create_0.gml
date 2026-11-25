/// Enemy must be initialized via scr_enemy_spawn(enemy_key, x, y). Properties are entirely
/// data-driven from data/enemy.json, so new enemy types/stats never require touching this
/// object. Mirrors objects/unit (same animation-state machine and combat, via scr_combatant_*
/// and scr_combat_*), but AI-driven: it chases a nearby Unit or otherwise marches on the Core.
enemy_key = "";
data = undefined;
enemy_name = "";
hp = 0;
max_hp = 0;
move_speed = 0;
skills = [];
colour = c_white;

target_x = x;
target_y = y;
has_target = false;

// Smooth movement (see scr_combatant_move): current velocity in px/s, plus the smoothed
// push-apart vector used by scr_combatant_separate
vx = 0;
vy = 0;
sep_x = 0;
sep_y = 0;

// attack_frame is the exact frame of the attack animation (0-based) at which the hit actually
// lands (see scr_combat_try_attack); attack_fired tracks whether this loop of the animation has
// already landed its hit, reset on every loop and on every fresh state change (see
// scr_combatant_set_state).
attack_damage = 0;
attack_range = 0;
attack_cooldown = 1;
attack_state = "attack";
attack_frame = 0;
attack_fired = false;
attacking = false;
detect_range = 0;

// "" deals attack_damage instantly on hit; otherwise the type of projectile (see
// scr_projectile_spawn) fired instead, e.g. the Lizard Dragon's ranged "fireball"
// (named projectile_type, not projectile, since "projectile" is the parent object's own name)
projectile_type = "";

// Optional second (ranged) attack profile for dual melee/ranged enemies (e.g. the Lizard
// Dragon): used instead of the profile above whenever the target is beyond attack_range but
// still within ranged_attack_range. Disabled (ranged_attack_range stays 0) unless
// data/enemy.json sets it, so every other (melee-only) enemy is unaffected.
ranged_attack_damage = 0;
ranged_attack_range = 0;
ranged_attack_state = "attack";
ranged_attack_frame = 0;
ranged_projectile = "";

// Raptor-type "Shout": every shout_cooldown seconds, summon shout_count Lizardmen around
// itself. shout_cooldown is 0 (disabled) unless data/enemy.json sets it for this enemy_key.
shout_cooldown = 0;
shout_count = 0;
shout_radius = 0;
shout_timer = 0;

// Units can be locked in place (see objects/unit); an Enemy never is, but scr_combatant_separate
// checks the flag on both sides. hp_bar_timer: seconds the small HP bar is still shown after a hit.
locked = false;
guarding = false;
hp_bar_timer = 0;

// Kiting (enemies with a ranged attack, see scr_combatant_kite)
kiting = false;
kite_timer = 0;
kite_cd = 0;

state = "idle";
anim_prev_index = 0;
hurt_timer = 0; // seconds left showing the (single-frame) hurt sprite, see scr_combatant_set_state
death_timer = 1; // seconds the corpse lingers on its last die frame before being removed

set_state = function(_state) {
    scr_combatant_set_state(id, enemy_key, _state);
};

take_hurt = function() {
    if (state != "die") set_state("hurt");
};

die = function() {
    set_state("die");
};

take_damage = function(_amount, _source_x, _source_y) {
    scr_combatant_take_damage(id, _amount, _source_x, _source_y);
};

initialize = function() {
    data = global.enemy_data[$ enemy_key];
    enemy_name = data.name;
    hp = data.hp;
    max_hp = data.hp;
    move_speed = data.move_speed;
    skills = variable_struct_exists(data, "skills") ? data.skills : [];

    attack_damage = variable_struct_exists(data, "attack_damage") ? data.attack_damage : 0;
    attack_range = variable_struct_exists(data, "attack_range") ? data.attack_range : 0;
    attack_cooldown = variable_struct_exists(data, "attack_cooldown") ? data.attack_cooldown : 1;
    attack_state = variable_struct_exists(data, "attack_state") ? data.attack_state : "attack";
    attack_frame = variable_struct_exists(data, "attack_frame") ? data.attack_frame : 0;
    detect_range = variable_struct_exists(data, "detect_range") ? data.detect_range : 0;
    projectile_type = variable_struct_exists(data, "projectile") ? data.projectile : "";
    attack_fired = false;
    attacking = false;

    ranged_attack_damage = variable_struct_exists(data, "ranged_attack_damage") ? data.ranged_attack_damage : 0;
    ranged_attack_range = variable_struct_exists(data, "ranged_attack_range") ? data.ranged_attack_range : 0;
    ranged_attack_state = variable_struct_exists(data, "ranged_attack_state") ? data.ranged_attack_state : "attack";
    ranged_attack_frame = variable_struct_exists(data, "ranged_attack_frame") ? data.ranged_attack_frame : 0;
    ranged_projectile = variable_struct_exists(data, "ranged_projectile") ? data.ranged_projectile : "";

    shout_cooldown = variable_struct_exists(data, "shout_cooldown") ? data.shout_cooldown : 0;
    shout_count = variable_struct_exists(data, "shout_count") ? data.shout_count : 0;
    shout_radius = variable_struct_exists(data, "shout_radius") ? data.shout_radius : 0;
    shout_timer = shout_cooldown;

    var _rgb = variable_struct_exists(data, "colour") ? data.colour : [255, 255, 255];
    colour = make_colour_rgb(_rgb[0], _rgb[1], _rgb[2]);

    target_x = x;
    target_y = y;
    has_target = false;

    sprite_index = -1;
    state = "";
    set_state("idle");
    depth = scr_depth_from_y(y, DEPTH_BASE_UNIT);
};
