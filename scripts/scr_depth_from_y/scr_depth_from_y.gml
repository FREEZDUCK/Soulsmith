/// Depth bands (lower depth = drawn later = in front):
///   Unit   band [-7499, -1]    (base -3750) -> always in front of every Stuff and Fabric
///   placement ghost / controllers ............ 0
///   Stuff  band [1, 7499]      (base 3750)  -> always in front of every Fabric
///   Fabric band [7501, 14999]  (base 11250)
///   obj_background ........................... 15000, room Background layer 15100
/// Inside each band, higher Y draws in front; exact ordering holds for -3749 <= y <= 3749.
#macro DEPTH_BASE_UNIT -3750
#macro DEPTH_BASE_STUFF 3750
#macro DEPTH_BASE_FABRIC 11250
#macro DEPTH_BAND_HALF 3749

/// @function scr_depth_from_y(y, base)
/// @description Top-down Y sorting inside a category band: base is DEPTH_BASE_STUFF or DEPTH_BASE_FABRIC.
function scr_depth_from_y(_y, _base) {
    return _base + clamp(-round(_y), -DEPTH_BAND_HALF, DEPTH_BAND_HALF);
}
