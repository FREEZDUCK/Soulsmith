/// Shared projectile travel/lifetime logic (see objects/proj_arrow, objects/proj_fireball).
/// Must be spawned via scr_projectile_spawn(type, x, y, target, damage): it homes toward
/// target's live position and deals damage the instant it reaches it. Children call
/// event_inherited() first, then set their own sprite/fly_speed/max_life/face_direction and
/// override on_hit()/on_timeout()/update_exploding() for their specific behaviour.
/// fly_speed (not speed) -- "speed" is GameMaker's built-in motion variable and would make the
/// engine auto-move the instance via hspeed/vspeed (direction defaults to 0) on top of the
/// manual x/y movement below.
target = noone;
damage = 0;
fly_speed = 200;
max_life = 5;    // seconds of flight before giving up even without a hit
life_timer = 0;
dir = 0;         // current travel heading, kept once target is gone or out of range
face_direction = false; // true: image_angle follows dir (e.g. the Arrow); false: ignored (e.g. the Fireball)
state = "flying";

// aim_offset_y: the projectile flies at (target.y + aim_offset_y) instead of the target's feet, and
// is spawned that much higher too, so a sprite drawn around its centre still looks like it flies
// at body height (fireball); 0 for sprites whose origin already sits where they should be.
aim_offset_y = 0;

// free_flight: fired by the player at a direction, not only at a target (see scr_projectile_spawn).
// It keeps flying along dir when there is no target (or the target is gone) and damages the first
// living Enemy it runs into.
free_flight = false;
anim_prev_index = 0;

/// Called exactly once, the instant the projectile reaches its target. Default: just disappear.
on_hit = function() {
    instance_destroy();
};

/// Called once if max_life elapses without ever reaching the target. Default: just disappear.
on_timeout = function() {
    instance_destroy();
};

/// Called every step once state == "exploding" (see proj_fireball); no-op unless overridden.
update_exploding = function() {
};
