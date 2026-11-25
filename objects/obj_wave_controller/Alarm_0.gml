/// Spawn one wave of enemies around the Core, then re-arm for the next wave
wave_number += 1;
scr_wave_spawn(wave_number);

alarm[0] = wave_interval * room_speed;
