/// Spawn one lowest-tier Stuff, then re-arm
if (global.game_over) exit;
var _type = global.stuff_order[0];
scr_stuff_spawn(_type, x, y);

alarm[0] = spawn_delay * room_speed;
