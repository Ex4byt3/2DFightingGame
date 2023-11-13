var stage_data = "";
stage_data = string_copy(string(get_stage_data(SD_ID)), string_length(string(get_stage_data(SD_ID)))-9, 10);
if (stage_data != 2132275518) {
    if (right_stick_pressed || left_stick_pressed || down_stick_pressed || up_stick_pressed) {
        if (state_timer == 0) {
            sound_play(sound_get("c_stick_flick"));
        }
    } else if (attack_pressed || special_pressed) {
        if (state_timer == 0) {
            sound_play(sound_get("button_y"));
        }
    }
}



if (attack == AT_NSPECIAL) {
    nspecial_in_air = free;
}

if (attack == 49) {
    sprite_change_offset("finalsmash", 34, 62);
    window = 0;
    window_timer = 0;
}

if (attack == AT_FAIR) {
    if (runeM) {
        vsp /= 2;
    }
    clear_button_buffer( PC_JUMP_PRESSED );
}

if (attack == AT_DAIR && runeE) {
    vsp /= 2;
}

if (attack == AT_USPECIAL && runeJ) {
    super_armor = true;
}

if runeD {
    if (attack == AT_DSPECIAL && free && !dspecial_used_in_air) {
        set_window_value(AT_DSPECIAL, 1, AG_WINDOW_VSPEED, -3);
        
        set_window_value(AT_DSPECIAL, 1, AG_WINDOW_CUSTOM_AIR_FRICTION, 0.8);
        set_window_value(AT_DSPECIAL, 2, AG_WINDOW_CUSTOM_AIR_FRICTION, 0.8);
        
        dspecial_used_in_air = true;
    } else {
        set_window_value(AT_DSPECIAL, 1, AG_WINDOW_VSPEED, 0);
        
        set_window_value(AT_DSPECIAL, 1, AG_WINDOW_CUSTOM_AIR_FRICTION, 2);
        set_window_value(AT_DSPECIAL, 2, AG_WINDOW_CUSTOM_AIR_FRICTION, 2);
    }
}