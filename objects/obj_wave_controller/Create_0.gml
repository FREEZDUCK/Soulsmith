/// A new wave of enemies starts every wave_interval seconds; auto-placed once in the Play room.
/// Also owns the Next Wave countdown UI (Draw GUI) and the F3 debug enemy-spawn hotkey (Step).
fnt_bold = font_bold; // native font resource: crisp at its own pixel size
spr_panel = sprite_add("assets/sprites/ui/panels/mono.png", 1, false, false, 0, 0);
var _ns = sprite_nineslice_create();
_ns.enabled = true;
_ns.left = 4;
_ns.top = 4;
_ns.right = 4;
_ns.bottom = 4;
sprite_set_nineslice(spr_panel, _ns);

wave_number = 0;
wave_interval = 5 * 60; // 5 minutes

alarm[0] = wave_interval * room_speed;
