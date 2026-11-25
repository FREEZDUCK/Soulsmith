/// Transform into the next-stage Stuff once its temperature reaches melt_tem (data/stuff.json),
/// in the tier order given by global.stuff_order. The final tier's melt_tem is non-numeric
/// (e.g. "GOD"), so it never transforms further.
if (is_real(melt_tem) && tem >= melt_tem) {
    var _order = global.stuff_order;
    var _idx = -1;
    for (var _i = 0; _i < array_length(_order); _i++) {
        if (_order[_i] == stuff_type) {
            _idx = _i;
            break;
        }
    }
    if (_idx != -1 && _idx + 1 < array_length(_order)) {
        stuff_type = _order[_idx + 1];
        initialize();
    }
}

/// Top-down depth sorting inside the Stuff band (always in front of Fabric),
/// updated after this step's movement (drag/repulsion)
depth = scr_depth_from_y(y, DEPTH_BASE_STUFF);
