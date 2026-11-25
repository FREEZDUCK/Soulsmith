/// @function scr_make_square_sprite(colour, size)
/// @description Procedurally creates a solid-coloured square sprite. Used as a placeholder
/// wherever real art does not exist yet (Units, the Hatcher); swapping in real art later is
/// just a matter of pointing sprite_index at a loaded sprite instead of calling this.
function scr_make_square_sprite(_colour, _size) {
    var _surf = surface_create(_size, _size);
    surface_set_target(_surf);
    draw_clear_alpha(c_black, 0);
    draw_set_colour(_colour);
    draw_rectangle(0, 0, _size - 1, _size - 1, false);
    draw_set_colour(c_white);
    surface_reset_target();
    var _spr = sprite_create_from_surface(_surf, 0, 0, _size, _size, false, false, 0, 0);
    surface_free(_surf);
    return _spr;
}
