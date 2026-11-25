/// Sliding bottom panel with a horizontally-scrollable list of purchasable Fabrics.
/// Laid out in base (1366x768) units and scaled by scr_gui_scale(), so it keeps the same
/// visual size in windowed and fullscreen modes (Step uses the same units for hit-testing).
if (slide <= 0.01) exit;

var _s = scr_gui_scale();
scr_gui_scale_begin(_s);

var _gw = display_get_gui_width() / _s;
var _gh = display_get_gui_height() / _s;
var _panel_y = round(_gh - panel_h * slide);
var _mouse_gui_x = device_mouse_x_to_gui(0) / _s;
var _mouse_gui_y = device_mouse_y_to_gui(0) / _s;

draw_sprite_stretched(spr_panel, 0, 0, _panel_y, _gw, panel_h);

draw_set_font(fnt_regular);

var _entry_y = round(_panel_y + (panel_h - entry_h) / 2);
var _cur_x = entry_pad - scroll_x;

for (var _i = 0; _i < array_length(purchasable); _i++) {
    var _p = purchasable[_i];
    var _ex = round(_cur_x);

    if (_ex + entry_w >= 0 && _ex <= _gw) {
        var _can_afford = (global.gold >= _p.cost);
        var _hovered = open && _mouse_gui_x >= _ex && _mouse_gui_x <= _ex + entry_w && _mouse_gui_y >= _entry_y && _mouse_gui_y <= _entry_y + entry_h;

        draw_sprite_stretched_ext(spr_panel, 0, _ex, _entry_y, entry_w, entry_h, (_hovered && _can_afford) ? c_white : c_ltgray, _can_afford ? 1 : 0.6);

        var _cx = _ex + entry_w / 2;
        draw_sprite_ext(_p.sprite, 0, round(_cx), _entry_y + 26, 1, 1, 0, c_white, _can_afford ? 1 : 0.45);

        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_colour((_hovered && _can_afford) ? c_yellow : (_can_afford ? c_white : c_gray));
        draw_text(round(_cx), _entry_y + 50, scr_capitalize(_p.key));
        draw_set_colour(_can_afford ? c_lime : c_red);
        draw_text(round(_cx), _entry_y + 76, scr_comma_number(_p.cost) + "G");
    }

    _cur_x += entry_w + entry_pad;
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);

scr_gui_scale_end();
