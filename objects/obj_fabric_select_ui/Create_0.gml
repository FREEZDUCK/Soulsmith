/// Fabric click-selection + info/upgrade panel
fnt_regular = font_bold; // native font resource: crisp at its own pixel size
fnt_bold = font_bold; // native font resource: crisp at its own pixel size
spr_panel = sprite_add("assets/sprites/ui/panels/mono.png", 1, false, false, 0, 0);
var _ns = sprite_nineslice_create();
_ns.enabled = true;
_ns.left = 4;
_ns.top = 4;
_ns.right = 4;
_ns.bottom = 4;
sprite_set_nineslice(spr_panel, _ns);
