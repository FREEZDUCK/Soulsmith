/// Ending screen overlay: shown once (see Step) when global.gold exceeds the win threshold
depth = -1000; // draw above the rest of the Play room's Draw GUI content

fnt_title = font_bold; // native font resource: crisp at its own pixel size
fnt_button = font_bold; // native font resource: crisp at its own pixel size

spr_panel = sprite_add("assets/sprites/ui/panels/mono.png", 1, false, false, 0, 0);
var _ns = sprite_nineslice_create();
_ns.enabled = true;
_ns.left = 4;
_ns.top = 4;
_ns.right = 4;
_ns.bottom = 4;
sprite_set_nineslice(spr_panel, _ns);

button_w = 280;
button_h = 56;

active = false;
defeated = false; // true: show "Defeat" instead of "Victory"
// New run (this object only exists in the Play room): without this, gold, the victory latch and
// selections carried over from the previous run after "Return to Title" -> "Start Game"
global.game_over = false;
global.gold = global.start_gold;
global.ending_triggered = false;
global.selected_fabric = noone;
global.selected_unit_info = noone;
global.controlled_unit = noone;
global.hovered_stuff = noone;
global.hovered_unit = noone;
hovered = false;
