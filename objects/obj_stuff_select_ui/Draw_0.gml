/// Live selection-box rectangle while drag-selecting Stuff, drawn in world space so it
/// pans/zooms with the camera exactly like the Stuff it is selecting.
if (!dragging) exit;

var _x1 = min(drag_start_x, drag_cur_x);
var _x2 = max(drag_start_x, drag_cur_x);
var _y1 = min(drag_start_y, drag_cur_y);
var _y2 = max(drag_start_y, drag_cur_y);

draw_set_colour(c_white);
draw_set_alpha(0.15);
draw_rectangle(_x1, _y1, _x2, _y2, false);
draw_set_alpha(1);
draw_rectangle(_x1, _y1, _x2, _y2, true);
