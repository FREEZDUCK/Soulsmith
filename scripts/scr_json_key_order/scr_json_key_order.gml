/// @function scr_json_key_order(path)
/// @description Returns the top-level object keys of a JSON file in the exact order they are
/// written in the file. (json_parse structs do not preserve key order, so
/// variable_struct_get_names() returns them in an arbitrary order.)
function scr_json_key_order(_path) {
    var _keys = [];
    if (!file_exists(_path)) {
        show_debug_message("scr_json_key_order: file not found - " + _path);
        return _keys;
    }
    var _buffer = buffer_load(_path);
    var _text = buffer_read(_buffer, buffer_text);
    buffer_delete(_buffer);

    var _len = string_length(_text);
    var _depth = 0;          // {} / [] nesting level
    var _in_str = false;
    var _escaped = false;
    var _str = "";           // current string literal contents
    var _pending = undefined; // last top-level string, becomes a key if followed by ':'

    for (var _i = 1; _i <= _len; _i++) {
        var _c = string_char_at(_text, _i);

        if (_in_str) {
            if (_escaped) {
                _escaped = false;
                _str += _c;
            } else if (_c == "\\") {
                _escaped = true;
            } else if (_c == "\"") {
                _in_str = false;
                if (_depth == 1) _pending = _str;
            } else {
                _str += _c;
            }
            continue;
        }

        if (_c == " " || _c == "\t" || _c == "\n" || _c == "\r") continue;

        if (_c == "\"") {
            _in_str = true;
            _str = "";
            continue;
        }

        if (_c == ":" && !is_undefined(_pending)) {
            array_push(_keys, _pending);
        }
        _pending = undefined;

        if (_c == "{" || _c == "[") _depth++;
        else if (_c == "}" || _c == "]") _depth--;
    }
    return _keys;
}
