/// Tracks which Stuff instance is hovered, and draws its info panel
fnt_regular = font_bold; // native font resource: crisp at its own pixel size
spr_panel = sprite_add("assets/sprites/ui/panels/mono.png", 1, false, false, 0, 0);
var _ns = sprite_nineslice_create();
_ns.enabled = true;
_ns.left = 4;
_ns.top = 4;
_ns.right = 4;
_ns.bottom = 4;
sprite_set_nineslice(spr_panel, _ns);

// Drag-selection box (world space), click+drag on empty ground to multi-select Stuff
dragging = false;
drag_start_x = 0;
drag_start_y = 0;
drag_cur_x = 0;
drag_cur_y = 0;
