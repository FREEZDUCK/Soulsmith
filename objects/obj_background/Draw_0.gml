/// Tile grass across the current camera view, with one tile of margin
var _cam = view_camera[0];
var _vx = camera_get_view_x(_cam);
var _vy = camera_get_view_y(_cam);
var _vw = camera_get_view_width(_cam);
var _vh = camera_get_view_height(_cam);

var _start_x = floor(_vx / tile_w) * tile_w - tile_w;
var _start_y = floor(_vy / tile_h) * tile_h - tile_h;
var _end_x = _vx + _vw + tile_w;
var _end_y = _vy + _vh + tile_h;

for (var _yy = _start_y; _yy < _end_y; _yy += tile_h) {
    for (var _xx = _start_x; _xx < _end_x; _xx += tile_w) {
        draw_sprite(spr, 0, _xx, _yy);
    }
}
