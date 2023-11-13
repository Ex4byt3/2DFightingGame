//B - Reversals
if (attack == AT_NSPECIAL || attack == AT_FSPECIAL || attack == AT_DSPECIAL){
    trigger_b_reverse();
}

if (attack == AT_NSPECIAL){
    if (window == 2 || window == 3 || window == 4) {
        if (nspecial_in_air != free && runeB) {
            set_state(PS_LANDING_LAG);
        }
    }
    
    if (window == 4){
        if (special_pressed){
            window = 2;
            window_timer = 0;
        }
    }
}

if (attack == AT_FSPECIAL){
    if (window == 2){
        if (special_pressed){
            window = 3;
            window_timer = 0;
            destroy_hitboxes();
        }
    }
    can_fast_fall = false;
}

if (attack == AT_USPECIAL) {
    
    can_fast_fall = false;
    
    if (window == 1 && window_timer == 1) {
        sprite_change_offset("uspecial", 64, 94);
    }
    
    if (window == 2 && window_timer == 1 && hitpause == false)  {
        sound_play( sound_get( "fox_fire2" ) );

        sprite_change_offset("uspecial", 64, 64);
        
        fire_ang = 90;
        
        if (joy_pad_idle == false) {
            fire_ang = joy_dir;
        }
        
        set_window_value(AT_USPECIAL, 2, AG_WINDOW_HSPEED, (12 * cos(degtorad(fire_ang)) ) * spr_dir);
        set_window_value(AT_USPECIAL, 2, AG_WINDOW_VSPEED, (-12 * sin(degtorad(fire_ang)) ));
        
        spr_angle = fire_ang - 90;
    }

    if (window == 2) {
        can_wall_jump = true;
    }
}

if (attack == AT_DSPECIAL){
    
    if (special_down && window = 2) {
        window_timer = 1;
    }
    
    can_jump = true;
    can_fast_fall = false;
    can_move = false;
}

if (attack == AT_JAB) {
    if (window == 1 && has_hit_player == true && hitpause == false) {
        window = 2;
        window_timer = 0;
    }
    
    if (window == 1 && window_timer == get_window_value(AT_JAB, 1, AG_WINDOW_LENGTH) && has_hit_player == false) {
        iasa_script();
        set_state(PS_IDLE);
    }
}

if (attack == AT_FAIR) {
    if (window == 2 && window_timer == get_window_value(AT_FAIR, 1, AG_WINDOW_LENGTH)) {
        attack_end();
        window = 1;
        window_timer = 1;
    }
    
    if (hitpause == false) {
        can_jump = true;
        can_special = true;
    }
    
}

if (attack == 49) { // final smash
    can_fast_fall = false;
    invincible = true;

    if (window == 3) {
        if (window_timer == 1) {
            sprite_change_offset("finalsmash", 34, 200);
            y = -(get_stage_data( SD_TOP_BLASTZONE ) + 100)
            max_muda_timer = 6
            muda_timer = max_muda_timer;
        } else if (window_timer >= get_window_value( attack, window, AG_WINDOW_LENGTH )) {
            window_timer = 2;
        }

        if !free {
            window++;
            window_timer = 0;
        }

        if (down_down) {
            set_window_value(49, 3, AG_WINDOW_VSPEED, 30);
            fall_through = true;
        } else {
            set_window_value(49, 3, AG_WINDOW_VSPEED, 20);
            fall_through = false;
        }
    } else if (window == 4) {
        if (window_timer == 1) {
            shake_camera(20, 8);
        }
    } else if (window == 5) {
        if (muda_timer == max_muda_timer && window_timer == 1) {
            sound_play(sound_get( "fox_trummel_codec" ));
        }

        if !hitpause {
            if (window_timer == 3) {
                sound_play(asset_get("sfx_shovel_hit_heavy2"), false, noone, 0.75, 1);
            } else if (window_timer == 7) {
                sound_play(asset_get("sfx_shovel_hit_med1"), false, noone, 0.75, 1);
            }
        }
        
        if (window_timer == 3 || window_timer == 7) {
            shake_camera(8, 3);
        }

        if (muda_timer > 0 && window_timer >= get_window_value( attack, window, AG_WINDOW_LENGTH )) {
            muda_timer--;
            window_timer = 0;
        }
    } else if (window == 6) {
        if (window_timer == 1 && !hitpause) {
            sprite_change_offset("finalsmash", 34, 62);
            y -= 138;

            spawn_hit_fx( x - 64, y + 58, 143 );
            spawn_hit_fx( x, y + 70, 143 );
            spawn_hit_fx( x + 64, y + 58, 143 );

            set_state(PS_PRATFALL);
        }
    }
}