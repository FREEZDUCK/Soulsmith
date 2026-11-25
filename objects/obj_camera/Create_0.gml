/// Smooth WASD camera with mouse-wheel zoom, base resolution 460x270
base_w = 460;
base_h = 270;

zoom = 1;
target_zoom = 1;
min_zoom = 0.5;
max_zoom = 2.5;

x_pos = 0;
y_pos = 0;
target_x = 0;
target_y = 0;

move_speed = 240; // world pixels per second at zoom 1

view_enabled = true;
view_visible[0] = true;

cam = camera_create();
camera_set_view_size(cam, base_w * zoom, base_h * zoom);
camera_set_view_pos(cam, x_pos - (base_w * zoom) / 2, y_pos - (base_h * zoom) / 2);
view_camera[0] = cam;
