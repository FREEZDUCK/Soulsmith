/// @function scr_bgm_play(sound)
/// @description Starts looping background music. Does nothing if that track is already playing
/// (so reloading a room never restarts it); any other BGM is stopped first.
function scr_bgm_play(_snd) {
    if (!variable_global_exists("bgm_sound")) {
        global.bgm_sound = noone;
        global.bgm_handle = -1;
    }
    if (global.bgm_sound == _snd && audio_is_playing(global.bgm_handle)) return;

    if (global.bgm_handle != -1) audio_stop_sound(global.bgm_handle);
    global.bgm_sound = _snd;
    // Loudness is set on the Sound asset itself (volume field); change it there to retune
    global.bgm_handle = audio_play_sound(_snd, 10, true);
}

/// @function scr_bgm_for_room()
/// @description Picks the BGM for the current room: Title screen song, or the in-game song in Play
function scr_bgm_for_room() {
    if (room == TitleScreen) scr_bgm_play(snd_title_bgm);
    else if (room == Play) scr_bgm_play(snd_ingame_bgm);
}
