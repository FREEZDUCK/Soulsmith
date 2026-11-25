/// Fireball: fired by the Magician and the Lizard Dragon. Animates while traveling; the instant
/// it lands a hit, or after max_life seconds with no hit, it switches to spr_proj_fireball_explode
/// and disappears once that explosion animation finishes one full loop.
event_inherited();
sprite_index = spr_proj_fireball;
image_speed = 1;
fly_speed = 180;
max_life = 5; // "if it does not hit anything within 5 seconds ... it must play the explode animation"
face_direction = true; // the sprite is drawn facing right (tail to the left): rotate it to the flight direction
// The sprite's origin was its bottom edge, which makes a rotating fireball swing around a point far
// below the ball: put the origin on the ball itself (content sits around x 15, y 21 of 32) and
// lift the whole flight 10px so it still looks like it flies at body height.
sprite_set_offset(spr_proj_fireball, 16, 21);
aim_offset_y = -10;
// The explosion sprite keeps drawing where it always did (bottom edge on the target's feet) even
// though the projectile now sits 10px higher
sprite_set_offset(spr_proj_fireball_explode, 16, 22);

var _explode = function() {
    state = "exploding";
    image_angle = 0; // the explosion is not rotated
    sprite_index = spr_proj_fireball_explode;
    image_index = 0;
    anim_prev_index = 0;
    image_speed = 1;
};
on_hit = _explode;
on_timeout = _explode;

update_exploding = function() {
    // One full loop of the explosion animation (image_index wrapping back to 0) means it's done.
    if (image_index < anim_prev_index) {
        instance_destroy();
        return;
    }
    anim_prev_index = image_index;
};
