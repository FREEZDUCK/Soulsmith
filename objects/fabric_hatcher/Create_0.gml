/// Hatcher: accepts one Stuff item, hatches it into a Unit after `hatch_time` seconds.
/// `hatch_time` comes from data/fabric.json via the parent's level system (apply_level).
event_inherited();
fabric_type = "hatcher";
init_fabric();
ui_colour = make_colour_rgb(220, 140, 80);

stored = noone;  // the single Stuff instance currently hatching, or noone
progress = 0;    // 0..1

/// Assigns a Stuff to the hatching slot. Rejects when occupied or already stored elsewhere.
try_store = function(_inst) {
    if (!instance_exists(_inst)) return false;
    if (_inst.stored_in != noone) return false;
    if (stored != noone) return false;

    stored = _inst;
    progress = 0;
    with (_inst) {
        stored_in = other.id;
        held = false;
        visible = false; // normal world rendering hidden; the Hatcher draws it
    }
    return true;
};

/// Takes a Stuff back out of the Hatcher and restores it as a normal world object
release = function(_inst) {
    if (stored == _inst) {
        stored = noone;
        progress = 0;
    }
    if (instance_exists(_inst)) {
        with (_inst) {
            stored_in = noone;
            visible = true;
        }
    }
};

/// Removing the Hatcher gives its Stuff back to the world instead of leaving it hidden forever
on_removed = function() {
    if (stored != noone && instance_exists(stored)) release(stored);
};

/// Extra lines for the Fabric info panel
get_info_lines = function() {
    if (stored == noone || !instance_exists(stored)) {
        return [{ text: "Drop Stuff here to Hatch", col: c_gray }];
    }
    return [{ label: "Hatching " + stored.name, bar: progress, text: string(floor(progress * 100)) + "%", col: c_orange }];
};
