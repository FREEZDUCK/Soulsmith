/// World-space placement preview: translucent ghost + 16x16 footprint grid
if (placement_mode && sprite_exists(placement_sprite)) {
    // Re-center on the mouse with the view being drawn right now (exact even if the camera
    // stepped after this object this frame); the footprint keeps its size from Step.
    var _mouse_world = scr_mouse_to_world();
    placement_x = _mouse_world[0];
    placement_y = _mouse_world[1];
    placement_left = placement_x - placement_w / 2;
    placement_top = placement_y - placement_h / 2;

    var _color = placement_valid ? c_lime : c_red;

    draw_set_alpha(0.5);
    draw_sprite_ext(placement_sprite, 0, placement_x, placement_y, 1, 1, 0, _color, 1);
    draw_set_alpha(1);

    draw_set_colour(_color);
    var _grid = 16;
    for (var _gx = placement_left; _gx <= placement_left + placement_w; _gx += _grid) {
        draw_line(_gx, placement_top, _gx, placement_top + placement_h);
    }
    for (var _gy = placement_top; _gy <= placement_top + placement_h; _gy += _grid) {
        draw_line(placement_left, _gy, placement_left + placement_w, _gy);
    }
    draw_set_colour(c_white);
}
