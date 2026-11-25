/// @function scr_json_load(path)
/// @description Loads and parses a JSON file from disk into a struct
function scr_json_load(_path) {
    if (!file_exists(_path)) {
        show_debug_message("scr_json_load: file not found - " + _path);
        return {};
    }
    var _buffer = buffer_load(_path);
    var _text = buffer_read(_buffer, buffer_text);
    buffer_delete(_buffer);
    return json_parse(_text);
}
