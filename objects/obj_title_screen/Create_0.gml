/// Title screen: logo + Start Game / Settings / Exit Game buttons
fnt_button = font_bold; // native font resource: crisp at its own pixel size
fnt_version = font_bold; // native font resource: crisp at its own pixel size

spr_logo = sprite_add("assets/sprites/ui/logo.png", 1, false, false, 0, 0);
spr_panel = sprite_add("assets/sprites/ui/panels/mono.png", 1, false, false, 0, 0);
var _ns = sprite_nineslice_create();
_ns.enabled = true;
_ns.left = 4;
_ns.top = 4;
_ns.right = 4;
_ns.bottom = 4;
sprite_set_nineslice(spr_panel, _ns);

// Laid out in base (1366x768) units, same convention as the rest of the UI (see scr_gui_scale)
logo_scale = 3;
logo_w = sprite_get_width(spr_logo) * logo_scale;
logo_h = sprite_get_height(spr_logo) * logo_scale;
logo_top = GUI_BASE_H * 0.16;

button_w = 280;
button_h = 56;
button_gap = 18;
buttons_top = logo_top + logo_h + 50;

buttons = [
    { label: "Start Game", action: "start" },
    { label: "Settings",   action: "settings" },
    { label: "Exit Game",  action: "exit" },
];

hovered_index = -1;
