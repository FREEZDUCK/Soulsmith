/// Curved line formation (shift + right-click drag, see obj_unit_select_ui).
/// The mouse leaves a trail; the formation curve is the stretch of that trail, measured back from
/// the mouse, whose length is proportional to the number of selected Units -- like a snake
/// following the cursor. Units stand at evenly spaced points along it.

/// @function scr_formation_curve(trail, count, spacing)
/// @description Returns an array of `count` {x, y} slots, ordered from the curve's tail to its head
/// (the head is the last trail point = the mouse). The curve's length is (count - 1) * spacing.
/// If the trail is still shorter than that, the tail is extended straight backwards along the
/// direction the mouse started moving (or to the left when it has not moved yet).
function scr_formation_curve(_trail, _count, _spacing) {
    var _n = array_length(_trail);
    var _slots = [];
    if (_n == 0 || _count <= 0) return _slots;

    var _head = _trail[_n - 1];
    if (_count == 1) {
        array_push(_slots, { x: _head.x, y: _head.y });
        return _slots;
    }

    var _need = (_count - 1) * _spacing;

    // 1) walk back from the head collecting points until `_need` length is covered
    var _pts = [ { x: _head.x, y: _head.y } ]; // head -> tail order
    var _len = 0;
    for (var _i = _n - 2; _i >= 0 && _len < _need; _i--) {
        var _p = _trail[_i];
        var _q = _pts[array_length(_pts) - 1];
        var _d = point_distance(_q.x, _q.y, _p.x, _p.y);
        if (_d < 0.001) continue;
        if (_len + _d >= _need) {
            var _t = (_need - _len) / _d; // cut inside this segment
            array_push(_pts, { x: _q.x + (_p.x - _q.x) * _t, y: _q.y + (_p.y - _q.y) * _t });
            _len = _need;
        } else {
            array_push(_pts, { x: _p.x, y: _p.y });
            _len += _d;
        }
    }

    // 2) trail too short: extend the tail straight back
    if (_len < _need) {
        var _m = array_length(_pts);
        var _tail = _pts[_m - 1];
        var _dx = -1;
        var _dy = 0;
        if (_m >= 2) {
            var _pr = _pts[_m - 2];
            var _dd = point_distance(_pr.x, _pr.y, _tail.x, _tail.y);
            if (_dd > 0.001) {
                _dx = (_tail.x - _pr.x) / _dd;
                _dy = (_tail.y - _pr.y) / _dd;
            }
        }
        array_push(_pts, { x: _tail.x + _dx * (_need - _len), y: _tail.y + _dy * (_need - _len) });
    }

    // 3) round the corners (Chaikin, endpoints pinned) so the curve is smooth, not a zig-zag
    for (var _it = 0; _it < 2; _it++) {
        var _m2 = array_length(_pts);
        if (_m2 < 3) break;
        var _sm = [ _pts[0] ];
        for (var _i = 0; _i < _m2 - 1; _i++) {
            var _a = _pts[_i];
            var _b = _pts[_i + 1];
            if (_i > 0) array_push(_sm, { x: _a.x * 0.75 + _b.x * 0.25, y: _a.y * 0.75 + _b.y * 0.25 });
            if (_i < _m2 - 2) array_push(_sm, { x: _a.x * 0.25 + _b.x * 0.75, y: _a.y * 0.25 + _b.y * 0.75 });
        }
        array_push(_sm, _pts[_m2 - 1]);
        _pts = _sm;
    }

    // 4) resample at `_count` evenly spaced points by arc length (smoothing shortens it slightly)
    var _m3 = array_length(_pts);
    var _total = 0;
    for (var _i = 0; _i < _m3 - 1; _i++) {
        _total += point_distance(_pts[_i].x, _pts[_i].y, _pts[_i + 1].x, _pts[_i + 1].y);
    }
    var _seg = 0;
    var _seg_start = 0;
    var _seg_len = point_distance(_pts[0].x, _pts[0].y, _pts[1].x, _pts[1].y);
    for (var _k = 0; _k < _count; _k++) {
        var _target = _total * _k / (_count - 1); // k=0 head ... k=count-1 tail
        while (_seg < _m3 - 2 && _seg_start + _seg_len < _target) {
            _seg_start += _seg_len;
            _seg++;
            _seg_len = point_distance(_pts[_seg].x, _pts[_seg].y, _pts[_seg + 1].x, _pts[_seg + 1].y);
        }
        var _f = (_seg_len > 0.0001) ? clamp((_target - _seg_start) / _seg_len, 0, 1) : 0;
        array_push(_slots, {
            x: _pts[_seg].x + (_pts[_seg + 1].x - _pts[_seg].x) * _f,
            y: _pts[_seg].y + (_pts[_seg + 1].y - _pts[_seg].y) * _f
        });
    }
    var _rev = [];
    for (var _k = array_length(_slots) - 1; _k >= 0; _k--) array_push(_rev, _slots[_k]); // tail -> head
    return _rev;
}

/// @function scr_formation_assign(units, slots)
/// @description Pairs Units with slots so orders don't cross: Units are ranked by their position
/// along the curve's tail->head axis and matched to the slots in order.
/// Returns nothing; gives each Unit a move order to its slot.
function scr_formation_assign(_units, _slots) {
    var _n = min(array_length(_units), array_length(_slots));
    if (_n <= 0) return;
    var _ax = _slots[_n - 1].x - _slots[0].x;
    var _ay = _slots[_n - 1].y - _slots[0].y;
    var _al = point_distance(0, 0, _ax, _ay);
    if (_al < 0.001) { _ax = 1; _ay = 0; } else { _ax /= _al; _ay /= _al; }

    var _ranked = [];
    for (var _i = 0; _i < array_length(_units); _i++) {
        var _u = _units[_i];
        array_push(_ranked, { inst: _u, k: _u.x * _ax + _u.y * _ay });
    }
    array_sort(_ranked, function(_a, _b) { return _a.k - _b.k; });

    for (var _i = 0; _i < _n; _i++) {
        var _u = _ranked[_i].inst;
        _u.give_move_order(_slots[_i].x, _slots[_i].y);
    }
}
