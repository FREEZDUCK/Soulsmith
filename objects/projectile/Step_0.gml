/// Fly toward `target`'s live position until close enough to land the hit, or out of time.
/// Once exploding (see proj_fireball), movement/hit/timeout are all skipped -- only the child's
/// update_exploding() runs, watching for its one-shot animation to finish.
if (state == "exploding") {
    update_exploding();
    exit;
}

var _dt = delta_time / 1000000;
life_timer += _dt;
var _step = fly_speed * _dt;

if (free_flight && !instance_exists(target)) {
    // no (more) target: hit the first living Enemy whose body the projectile touches
    var _hit = noone;
    with (enemy) {
        if (state == "die") continue;
        if (other.x >= bbox_left && other.x <= bbox_right && other.y >= bbox_top && other.y <= bbox_bottom) {
            _hit = id;
            break;
        }
    }
    if (_hit != noone) {
        _hit.take_damage(damage, x, y);
        on_hit();
        exit;
    }
}

if (instance_exists(target)) {
    var _ty = target.y + aim_offset_y;
    dir = point_direction(x, y, target.x, _ty);
    if (point_distance(x, y, target.x, _ty) <= max(_step, 6)) {
        x = target.x;
        y = _ty;
        if (variable_instance_exists(target, "take_damage")) {
            target.take_damage(damage, x, y);
        }
        on_hit();
        exit;
    }
}

if (face_direction) image_angle = dir;
x += lengthdir_x(_step, dir);
y += lengthdir_y(_step, dir);

if (life_timer >= max_life) on_timeout();
