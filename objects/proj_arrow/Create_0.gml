/// Arrow: fired by the Archer. Fast, rotates to face its flight direction, and simply
/// disappears the instant it lands its hit (or once it runs out of flight time) -- no explosion.
event_inherited();
sprite_index = spr_proj_arrow;
image_speed = 0;
fly_speed = 320;
max_life = 2; // safety cap in case its target dies or wanders off before it arrives
face_direction = true;
