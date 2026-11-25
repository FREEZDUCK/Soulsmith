/// @function scr_comma_number(num)
/// @description Formats a number with commas every three digits
function scr_comma_number(_num) {
    var _n = floor(_num);
    var _str = string(_n);
    var _out = "";
    var _len = string_length(_str);
    var _count = 0;
    for (var _i = _len; _i >= 1; _i--) {
        _out = string_char_at(_str, _i) + _out;
        _count++;
        if ((_count mod 3 == 0) && (_i > 1)) {
            _out = "," + _out;
        }
    }
    return _out;
}
