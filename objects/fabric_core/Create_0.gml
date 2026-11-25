/// The Core: spawns Level 1 Stuff on a timer. Auto-placed at (0,0) in the Play room.
event_inherited();
fabric_type = "core";
init_fabric();
ui_colour = make_colour_rgb(120, 220, 255);

alarm[0] = spawn_delay * room_speed;

// Health: 150 HP from data/fabric.json (core.info.hp). Enemies/projectiles hit it through
// take_damage(), exactly like Units. At 0 HP the game is lost (see obj_ending_screen).
max_hp = variable_struct_exists(data.info, "hp") ? data.info.hp : 150;
hp = max_hp;

take_damage = function(_amount, _source_x, _source_y) {
    if (hp <= 0) return;
    hp = max(0, hp - _amount);
    if (hp <= 0) {
        global.game_over = true;
        alarm[0] = -1; // the dead Core stops spawning Stuff
    }
};

/// Extra info-panel row: current HP
get_info_lines = function() {
    return [{ label: "HP", bar: hp / max_hp, text: string(ceil(hp)) + " / " + string(max_hp), col: make_colour_rgb(220, 70, 70) }];
};

/// Health bar below the Core, only once it has taken damage
draw_overlay = function() {
    if (hp >= max_hp) exit;
    var _bar_w = sprite_get_width(sprite_index) * abs(image_xscale);
    var _bar_h = 6;
    var _bar_x = x - _bar_w / 2;
    var _bar_y = y + sprite_get_height(sprite_index) * abs(image_yscale) / 2 + 6;

    draw_set_colour(c_black);
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);
    draw_set_colour(c_red);
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w * clamp(hp / max_hp, 0, 1), _bar_y + _bar_h, false);
    draw_set_colour(c_white);
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, true);
};
