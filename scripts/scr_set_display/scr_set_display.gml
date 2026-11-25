/// Reference GUI size: the windowed game window (scale 1 = original UI size)
#macro GUI_BASE_W 1366
#macro GUI_BASE_H 768

/// @function scr_set_display()
/// @description Maps the GUI layer 1:1 onto the real window pixels, so Draw GUI text
/// (e.g. font_basic) renders at its native pixel size with no scaling/distortion.
/// GUI coordinates then equal window coordinates; scr_world_to_gui accounts for the
/// letterboxed application surface. Call at startup and whenever the window size changes
/// (obj_io_reset does this automatically, including after the Alt+Enter toggle).
function scr_set_display() {
    if (window_get_width() <= 0 || window_get_height() <= 0) return; // minimised
    display_set_gui_maximise(1, 1, 0, 0);
}

/// @function scr_gui_scale()
/// @description Uniform scale for UI that must keep the same visual size relative to the
/// window (Gold UI, TAB construction panel): exactly 1 in the 1366x768 window, larger in
/// fullscreen. Such UI is laid out in base units and drawn under scr_gui_scale_begin/end.
function scr_gui_scale() {
    var _s = min(display_get_gui_width() / GUI_BASE_W, display_get_gui_height() / GUI_BASE_H);
    return (_s > 0) ? _s : 1;
}

/// @function scr_gui_scale_begin(scale)
/// @description Scales all following GUI drawing (sprites, nine-slices, text) uniformly from
/// the GUI origin. Must be paired with scr_gui_scale_end().
function scr_gui_scale_begin(_s) {
    matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, _s, _s, 1));
}

/// @function scr_gui_scale_end()
function scr_gui_scale_end() {
    matrix_set(matrix_world, matrix_build_identity());
}


/// @function scr_ui_markup_strip(str)
/// @description Removes [b]...[/b] highlight tags (used by data/stuff.json descriptions)
function scr_ui_markup_strip(_s) {
    _s = string_replace_all(_s, "[b]", "");
    _s = string_replace_all(_s, "[/b]", "");
    return _s;
}

/// @function scr_ui_draw_markup(x, y, str, colour, highlight_colour)
/// @description Draws one line of text; text between [b] and [/b] is drawn in highlight_colour
function scr_ui_draw_markup(_x, _y, _s, _col, _hi) {
    var _cx = _x;
    var _bold = false;
    while (string_length(_s) > 0) {
        var _p_open = string_pos("[b]", _s);
        var _p_close = string_pos("[/b]", _s);
        var _p = 0;
        var _tag_len = 0;
        var _next_bold = _bold;
        if (_p_open > 0 && (_p_close == 0 || _p_open < _p_close)) {
            _p = _p_open;
            _tag_len = 3;
            _next_bold = true;
        } else if (_p_close > 0) {
            _p = _p_close;
            _tag_len = 4;
            _next_bold = false;
        }
        var _seg = (_p > 0) ? string_copy(_s, 1, _p - 1) : _s;
        draw_set_colour(_bold ? _hi : _col);
        draw_text(_cx, _y, _seg);
        _cx += string_width(_seg);
        if (_p == 0) break;
        _s = string_delete(_s, 1, _p - 1 + _tag_len);
        _bold = _next_bold;
    }
}

/// @function scr_ui_info_panel(gx, gy, alt_gx, title, title_colour, badge, rows, hints)
/// @description Shared info panel (Fabric / Stuff / Unit), drawn in Draw GUI next to an object.
/// (gx, gy) is the object's anchor in raw GUI pixels (the panel opens to its right); alt_gx is the
/// anchor used instead when the panel would run off the right edge (it then opens to the left).
/// All coordinates are rounded to whole pixels so the pixel font never gets blurry.
/// rows: array of
///   "text"                                    plain line
///   { text, col }                             coloured line
///   { label, value, value_col, nxt }          label left, value right (nxt: "value > nxt")
///   { label, bar, text, col }                 label + text, with a 0..1 progress bar underneath
///   { desc }                                  description, "\n" splits lines, [b]..[/b] highlights
///   { sep: true }                             section gap with a thin divider line
/// hints: array of [key, text] pairs, e.g. [["E", "Upgrade"], ["X", "Remove"]]
function scr_ui_info_panel(_gx, _gy, _alt_gx, _title, _title_col, _badge, _rows, _hints) {
    var _s = scr_gui_scale();
    var _gw = display_get_gui_width() / _s;
    var _gh = display_get_gui_height() / _s;
    var _ox = _gx / _s;
    var _oy = _gy / _s;
    var _alt_ox = _alt_gx / _s;

    var _pad = 8;
    var _lh = 26;
    var _gap = 16;
    var _col_label = make_colour_rgb(160, 165, 180);
    var _col_hint = make_colour_rgb(120, 125, 140);
    var _col_line = make_colour_rgb(60, 65, 80);

    scr_gui_scale_begin(_s);
    draw_set_font(font_bold);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    // ---- measure ----
    var _has_badge = (is_string(_badge) && _badge != "");
    var _inner_w = string_width(_title) + (_has_badge ? _gap + string_width(_badge) : 0);
    var _body_h = 0;
    var _heights = [];
    for (var _i = 0; _i < array_length(_rows); _i++) {
        var _r = _rows[_i];
        var _rw = 0;
        var _rh = _lh;
        if (is_string(_r)) {
            _rw = string_width(_r);
        } else if (variable_struct_exists(_r, "sep")) {
            _rh = 16; // section gap (a thin divider line is drawn in the middle)
        } else if (variable_struct_exists(_r, "desc")) {
            var _lines = string_split(_r.desc, "\n");
            _rh = _lh * array_length(_lines);
            for (var _j = 0; _j < array_length(_lines); _j++) {
                _rw = max(_rw, string_width(scr_ui_markup_strip(_lines[_j])));
            }
        } else if (variable_struct_exists(_r, "bar")) {
            _rw = max(200, string_width(_r.label) + _gap + string_width(_r.text));
            _rh = _lh + 12;
        } else if (variable_struct_exists(_r, "label")) {
            _rw = string_width(_r.label) + _gap + string_width(_r.value);
            if (variable_struct_exists(_r, "nxt")) _rw += string_width(" > " + _r.nxt);
        } else {
            _rw = string_width(_r.text);
        }
        if (!(!is_string(_r) && variable_struct_exists(_r, "sep"))) _rh += 6; // breathing room between rows
        array_push(_heights, _rh);
        _body_h += _rh;
        _inner_w = max(_inner_w, _rw);
    }

    var _hint_w = 0;
    for (var _i = 0; _i < array_length(_hints); _i++) {
        _hint_w += string_width("[" + _hints[_i][0] + "] " + _hints[_i][1]) + ((_i > 0) ? 18 : 0);
    }
    _inner_w = max(_inner_w, _hint_w);

    var _head_h = _lh + 6;
    var _hint_h = (array_length(_hints) > 0) ? (_lh + 8) : 0;
    var _w = _inner_w + _pad * 2;
    var _h = _pad + _head_h + 4 + _body_h + _hint_h + _pad;

    // ---- position (whole pixels, kept on screen) ----
    var _x = round(_ox + 12);
    if (_x + _w > _gw - 4) _x = round(_alt_ox - 12 - _w);
    _x = max(4, _x);
    var _y = round(clamp(_oy - 12, 4, max(4, _gh - _h - 4)));

    // ---- panel ----
    draw_set_alpha(0.4);
    draw_set_colour(c_black);
    draw_rectangle(_x + 3, _y + 3, _x + _w + 2, _y + _h + 2, false);
    draw_set_alpha(1);

    if (variable_global_exists("spr_ui_panel") && sprite_exists(global.spr_ui_panel)) {
        draw_sprite_stretched_ext(global.spr_ui_panel, 0, _x, _y, _w, _h, c_white, 0.96);
    } else {
        draw_set_colour(c_black);
        draw_rectangle(_x, _y, _x + _w, _y + _h, false);
        draw_set_colour(c_white);
        draw_rectangle(_x, _y, _x + _w, _y + _h, true);
    }

    // header: tinted band + accent line + title (+ badge on the right)
    var _head_bottom = _y + _pad + _head_h;
    draw_set_colour(merge_colour(c_black, _title_col, 0.35));
    draw_rectangle(_x + 1, _y + 1, _x + _w - 2, _head_bottom - 1, false);
    draw_set_colour(_title_col);
    draw_rectangle(_x + 1, _head_bottom, _x + _w - 2, _head_bottom, false);
    draw_text(_x + _pad, _y + _pad + 2, _title);
    if (_has_badge) {
        draw_set_halign(fa_right);
        draw_set_colour(c_white);
        draw_text(_x + _w - _pad, _y + _pad + 2, _badge);
        draw_set_halign(fa_left);
    }

    // ---- rows ----
    var _yy = _head_bottom + 4;
    var _rx = _x + _w - _pad;
    for (var _i = 0; _i < array_length(_rows); _i++) {
        var _r = _rows[_i];
        if (is_string(_r)) {
            draw_set_colour(c_white);
            draw_text(_x + _pad, _yy, _r);
        } else if (variable_struct_exists(_r, "sep")) {
            draw_set_colour(_col_line);
            draw_rectangle(_x + _pad, _yy + 7, _x + _w - _pad - 1, _yy + 7, false);
        } else if (variable_struct_exists(_r, "desc")) {
            var _lines = string_split(_r.desc, "\n");
            for (var _j = 0; _j < array_length(_lines); _j++) {
                scr_ui_draw_markup(_x + _pad, _yy + _j * _lh, _lines[_j], _col_label, c_yellow);
            }
        } else if (variable_struct_exists(_r, "bar")) {
            var _bcol = variable_struct_exists(_r, "col") ? _r.col : c_lime;
            draw_set_colour(_col_label);
            draw_text(_x + _pad, _yy, _r.label);
            draw_set_halign(fa_right);
            draw_set_colour(c_white);
            draw_text(_rx, _yy, _r.text);
            draw_set_halign(fa_left);

            scr_ui_draw_bar(_x + _pad, _yy + _lh - 1, _x + _pad + _inner_w - 1, _yy + _lh + 8, _r.bar, _bcol, 10);
        } else if (variable_struct_exists(_r, "label")) {
            var _vcol = variable_struct_exists(_r, "value_col") ? _r.value_col : c_white;
            draw_set_colour(_col_label);
            draw_text(_x + _pad, _yy, _r.label);
            draw_set_halign(fa_right);
            if (variable_struct_exists(_r, "nxt")) {
                var _nw = string_width(_r.nxt);
                var _aw = string_width(" > ");
                draw_set_colour(c_lime);
                draw_text(_rx, _yy, _r.nxt);
                draw_set_colour(_col_hint);
                draw_text(_rx - _nw, _yy, " > ");
                draw_set_colour(_vcol);
                draw_text(_rx - _nw - _aw, _yy, _r.value);
            } else {
                draw_set_colour(_vcol);
                draw_text(_rx, _yy, _r.value);
            }
            draw_set_halign(fa_left);
        } else {
            draw_set_colour(variable_struct_exists(_r, "col") ? _r.col : c_white);
            draw_text(_x + _pad, _yy, _r.text);
        }
        _yy += _heights[_i];
    }

    // ---- key hints ----
    if (array_length(_hints) > 0) {
        draw_set_colour(_col_line);
        draw_rectangle(_x + _pad, _yy + 2, _x + _w - _pad - 1, _yy + 2, false);
        var _hx = _x + _pad;
        var _hy = _yy + 6;
        for (var _i = 0; _i < array_length(_hints); _i++) {
            var _key = "[" + _hints[_i][0] + "]";
            var _txt = " " + _hints[_i][1];
            draw_set_colour(c_yellow);
            draw_text(_hx, _hy, _key);
            _hx += string_width(_key);
            draw_set_colour(_col_hint);
            draw_text(_hx, _hy, _txt);
            _hx += string_width(_txt) + 18;
        }
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    scr_gui_scale_end();
}


/// @function scr_ui_draw_bar(x1, y1, x2, y2, frac, col, [ticks])
/// @description Shared progress/HP bar (info panels + the Hatcher's world bar). Inclusive pixel
/// rectangle (x1,y1)-(x2,y2), whole pixels only so it stays crisp. Look: dark outline with clipped
/// corners, inset dark track, fill with a lighter top / darker bottom shade plus a gloss line, a
/// bright leading edge, and optional faint divider ticks (ticks = number of segments, 0/undefined = none).
function scr_ui_draw_bar(_x1, _y1, _x2, _y2, _frac, _col, _ticks = 0) {
    _x1 = round(_x1); _y1 = round(_y1); _x2 = round(_x2); _y2 = round(_y2);
    _frac = clamp(_frac, 0, 1);
    var _w = _x2 - _x1 + 1;
    var _h = _y2 - _y1 + 1;
    if (_w < 5 || _h < 4) return;

    var _a = draw_get_alpha();
    var _c = draw_get_colour();

    // outline (corners clipped by 1px for a soft, rounded look)
    var _outline = make_colour_rgb(10, 11, 16);
    draw_set_colour(_outline);
    draw_rectangle(_x1 + 1, _y1, _x2 - 1, _y1, false);
    draw_rectangle(_x1 + 1, _y2, _x2 - 1, _y2, false);
    draw_rectangle(_x1, _y1 + 1, _x1, _y2 - 1, false);
    draw_rectangle(_x2, _y1 + 1, _x2, _y2 - 1, false);

    // inner area
    var _ix1 = _x1 + 1;
    var _iy1 = _y1 + 1;
    var _ix2 = _x2 - 1;
    var _iy2 = _y2 - 1;
    var _iw = _ix2 - _ix1 + 1;
    var _ih = _iy2 - _iy1 + 1;

    // track: dark body, deeper shade on the top rows (inset look), subtle lift on the bottom row
    draw_set_colour(make_colour_rgb(32, 34, 46));
    draw_rectangle(_ix1, _iy1, _ix2, _iy2, false);
    draw_set_colour(make_colour_rgb(20, 21, 30));
    draw_rectangle(_ix1, _iy1, _ix2, _iy1, false);
    draw_set_colour(make_colour_rgb(44, 47, 62));
    draw_rectangle(_ix1, _iy2, _ix2, _iy2, false);

    // fill
    var _fill = floor(_iw * _frac);
    if (_frac > 0) _fill = max(1, _fill);
    if (_fill > 0) {
        var _fx2 = _ix1 + _fill - 1;
        var _mid = _iy1 + floor(_ih / 2);
        draw_set_colour(merge_colour(_col, c_white, 0.22));   // upper half, lighter
        draw_rectangle(_ix1, _iy1, _fx2, _mid - 1, false);
        draw_set_colour(_col);                                  // lower half, base
        draw_rectangle(_ix1, _mid, _fx2, _iy2 - 1, false);
        draw_set_colour(merge_colour(_col, c_black, 0.35));   // bottom row, shade
        draw_rectangle(_ix1, _iy2, _fx2, _iy2, false);
        draw_set_colour(merge_colour(_col, c_white, 0.6));    // gloss line on the very top
        draw_rectangle(_ix1, _iy1, _fx2, _iy1, false);

        // bright leading edge (only while not full, so a full bar looks clean)
        if (_frac < 1 && _fill > 2) {
            draw_set_colour(merge_colour(_col, c_white, 0.75));
            draw_rectangle(_fx2, _iy1, _fx2, _iy2 - 1, false);
        }
    }

    // divider ticks across the track
    if (_ticks > 1) {
        draw_set_alpha(0.35 * _a);
        draw_set_colour(_outline);
        for (var _t = 1; _t < _ticks; _t++) {
            var _tx = _ix1 + floor(_iw * _t / _ticks);
            draw_rectangle(_tx, _iy1, _tx, _iy2, false);
        }
        draw_set_alpha(_a);
    }

    draw_set_colour(_c);
    draw_set_alpha(_a);
}
