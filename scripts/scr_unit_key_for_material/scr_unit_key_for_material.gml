/// @function scr_unit_key_for_material(material)
/// @description Looks up which data/unit.json key hatches from a given Stuff material, via the
/// global.unit_by_material table built from each Unit's "material" field (see RoomCreationCode).
/// Returns "" if no Unit is defined for that material, so new materials/Units can be added in
/// data alone without touching this lookup.
function scr_unit_key_for_material(_material) {
    return variable_struct_exists(global.unit_by_material, _material) ? global.unit_by_material[$ _material] : "";
}
