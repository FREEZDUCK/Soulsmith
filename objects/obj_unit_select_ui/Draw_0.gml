/// Live selection-box rectangle while drag-selecting Units, drawn in world space so it
/// pans/zooms with the camera exactly like the Units it is selecting.
/// Curved-formation preview (shift + right-drag): the curve itself plus a marker per slot.
if (formation_active && array_length(formation_slots) > 0) {
    var _fs = formation_slots;
    var _fn = array_length(_fs);
    var _fcol = make_colour_rgb(120, 220, 255);
    draw_set_colour(_fcol);
    draw_set_alpha(0.55);
    for (var _i = 0; _i < _fn - 1; _i++) {
        // two offset lines make a 2px-thick curve
        draw_line(_fs[_i].x, _fs[_i].y, _fs[_i + 1].x, _fs[_i + 1].y);
        draw_line(_fs[_i].x, _fs[_i].y + 1, _fs[_i + 1].x, _fs[_i + 1].y + 1);
    }
    draw_set_alpha(1);
    for (var _i = 0; _i < _fn; _i++) {
        var _px = round(_fs[_i].x);
        var _py = round(_fs[_i].y);
        draw_set_colour(c_black);
        draw_circle(_px, _py, 5, false);
        draw_set_colour((_i == _fn - 1) ? c_white : _fcol); // head (at the mouse) is highlighted
        draw_circle(_px, _py, 3, false);
    }
    draw_set_colour(c_white);
}

if (!dragging) exit;

var _x1 = min(drag_start_x, drag_cur_x);
var _x2 = max(drag_start_x, drag_cur_x);
var _y1 = min(drag_start_y, drag_cur_y);
var _y2 = max(drag_start_y, drag_cur_y);

draw_set_colour(c_yellow);
draw_set_alpha(0.12);
draw_rectangle(_x1, _y1, _x2, _y2, false);
draw_set_alpha(1);
draw_rectangle(_x1, _y1, _x2, _y2, true);
draw_set_colour(c_white);
