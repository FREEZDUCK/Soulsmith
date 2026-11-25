/// Frame-scoped input/UI state + shared particle system for Fabric upgrades
global.ui_hover = false;
global.click_consumed = false;
global.hovered_stuff = noone;
global.hovered_unit = noone;

// Alt+Enter fullscreen toggle latch: one toggle per Enter press (ignores key auto-repeat)
fullscreen_latched = false;

// Native-resolution GUI; re-applied in Step whenever the window size changes
scr_set_display();
display_last_w = window_get_width();
display_last_h = window_get_height();

if (!variable_global_exists("psystem") || !part_system_exists(global.psystem)) global.psystem = part_system_create();
if (!variable_global_exists("pt_firework") || !part_type_exists(global.pt_firework)) global.pt_firework = part_type_create();
part_type_shape(global.pt_firework, pt_shape_star);
part_type_size(global.pt_firework, 0.15, 0.35, 0, 0);
part_type_colour3(global.pt_firework, c_yellow, c_red, c_white);
part_type_alpha3(global.pt_firework, 1, 0.8, 0);
part_type_speed(global.pt_firework, 1, 3, 0, 0);
part_type_direction(global.pt_firework, 0, 360, 0, 0);
part_type_gravity(global.pt_firework, 0.05, 90);
part_type_life(global.pt_firework, 20, 40);
part_type_blend(global.pt_firework, true);

// Background music for this room (title song / in-game song; see scr_bgm)
scr_bgm_for_room();
