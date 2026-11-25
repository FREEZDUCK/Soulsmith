/// @function scr_capitalize(str)
function scr_capitalize(_n) {
    if (string_length(_n) == 0) return _n;
    return string_upper(string_char_at(_n, 1)) + string_delete(_n, 1, 1);
}
