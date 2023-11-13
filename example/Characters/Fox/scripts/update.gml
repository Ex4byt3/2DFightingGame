if (state == PS_ROLL_BACKWARD || state == PS_ROLL_FORWARD || state == PS_TECH_GROUND || state == PS_TECH_FORWARD || state == PS_TECH_BACKWARD || state == PS_PARRY) {
    if (state_timer == 0) {
        sound_play(sound_get("shoulder_press"));
    }
}

if (state == PS_DASH_START || state == PS_DASH_TURN) {
    if (state_timer == 0) {
        if (spr_dir = 1) {
            sound_play(sound_get("stick_tap_r"));
        } else {
            sound_play(sound_get("stick_tap_l"));
        }
    }
}

if (state == PS_DASH_STOP) {
    if (state_timer == 3) {
        sound_play(sound_get("stick_release"));
    }
}

if (state == PS_DASH_START && !right_down && !left_down) {
    if (state_timer == 6) {
        sound_play(sound_get("stick_release"));
    }
}

if (state == PS_AIR_DODGE && state_timer = 3) {
    sound_play(sound_get("fox_airdodge"))
}

if (state == PS_DOUBLE_JUMP && state_timer == 0) {
    sound_play(sound_get("fox_normal"))
}

if !free {
    dspecial_used_in_air = false;
}

//rune activation
if runesUpdated {
    user_event(0);
}

//thot deletion
if (!thot_script_ran) {
    with (oPlayer) {
        if (url = 2374761944 && get_player_stocks( player ) > 0 && get_gameplay_time() > 90) {
            set_player_stocks( player, 1 );
            x = room_width * 2 * -spr_dir;
            other.thot_detected = true;
        }
    }

    if thot_detected {
        thot_script_ran = true;
        sound_play(sound_get( "begone_thot" ));
        thot_detected = false;
    }
}


//trummel support
if trummelcodecneeded{
    trummelcodec = 17;
    trummelcodecmax = 14;
    trummelcodecsprite1 = sprite_get("trummelcodec");
    trummelcodecsprite2 = sprite_get("idle");
    
    if (trummelcodec_id.currentcodecline == 1 && trummelcodec_id.codectimer2 == 1) {
        if (trummelcodec_id.codecindex == 14) {
            sound_play(sound_get("fox_trummel_codec"));
        } else if (trummelcodec_id.codecindex == 12) {
            sound_play(sound_get("fox_dsmash"));
        }
    }
    
    var page = 0;

    //Page 0
    trummelcodecspeaker[page] = 1;
    trummelcodecexpression[page] = 0;

    trummelcodecline[page,1] = "Is that Fox McCloud? He";
    trummelcodecline[page,2] = "looks a bit off...";
    trummelcodecline[page,3] = "";
    trummelcodecline[page,4] = "...wait a minute!";
    page++;

    //Page 1
    trummelcodecspeaker[page] = 2;
    trummelcodecexpression[page] = 0;

    trummelcodecline[page,1] = "lord help us";
    trummelcodecline[page,2] = "";
    trummelcodecline[page,3] = "";
    trummelcodecline[page,4] = "";
    page++;
    
    //Page 2
    trummelcodecspeaker[page] = 0;
    trummelcodecexpression[page] = 0;

    trummelcodecline[page,1] = "That's 100% Accurate Fox,";
    trummelcodecline[page,2] = "a Melee character turned";
    trummelcodecline[page,3] = "into an overpowered";
    trummelcodecline[page,4] = "monster.";
    page++;
    
    //Page 3
    trummelcodecspeaker[page] = 0;
    trummelcodecexpresssion[page] = 0;
    
    trummelcodecline[page,1] = "To him, you're just";
    trummelcodecline[page,2] = "punching bags.";
    trummelcodecline[page,3] = "";
    trummelcodecline[page,4] = "";
    page++;
    
    //Page 4
    trummelcodecspeaker[page] = 1;
    trummelcodecexpression[page] = 4;

    trummelcodecline[page,1] = "Thanks for the";
    trummelcodecline[page,2] = "encouraging words...";
    trummelcodecline[page,3] = "";
    trummelcodecline[page,4] = "";
    page++;
    
    //Page 5
    trummelcodecspeaker[page] = 0;
    trummelcodecexpression[page] = 0;

    trummelcodecline[page,1] = "To be fair, there are";
    trummelcodecline[page,2] = "worse characters you ";
    trummelcodecline[page,3] = "could be fighting. Ever";
    trummelcodecline[page,4] = "met Golden Ronald?";
    page++;
    
    //Page 6
    trummelcodecspeaker[page] = 1;
    trummelcodecexpression[page] = 2;

    trummelcodecline[page,1] = "It doesn't matter which";
    trummelcodecline[page,2] = "OP character it is, they'll";
    trummelcodecline[page,3] = "beat me to a pulp";
    trummelcodecline[page,4] = "anyway...";
    page++;
    
    //Page 7
    trummelcodecspeaker[page] = 0;
    trummelcodecexpression[page] = 0;

    trummelcodecline[page,1] = "Maybe not. If you keep ";
    trummelcodecline[page,2] = "your cool and be careful,";
    trummelcodecline[page,3] = "you might have a chance.";
    trummelcodecline[page,4] = "";
    page++;
    
    //Page 8
    trummelcodecspeaker[page] = 0;
    trummelcodecexpression[page] = 0;

    trummelcodecline[page,1] = "Use mostly ranged";
    trummelcodecline[page,2] = "attacks and make good";
    trummelcodecline[page,3] = "use of clouds.";
    trummelcodecline[page,4] = "";
    page++;
    
    //Page 9
    trummelcodecspeaker[page] = 0;
    trummelcodecexpression[page] = 0;

    trummelcodecline[page,1] = "Remember that you can";
    trummelcodecline[page,2] = "control yourself in the";
    trummelcodecline[page,3] = "air more easily than he";
    trummelcodecline[page,4] = "can.";
    page++;
    
    
    //Page 10
    trummelcodecspeaker[page] = 0;
    trummelcodecexpression[page] = 0;

    trummelcodecline[page,1] = "Also, avoid eye contact";
    trummelcodecline[page,2] = "at all costs.";
    trummelcodecline[page,3] = "";
    trummelcodecline[page,4] = "";
    page++;
    
    //Page 11
    trummelcodecspeaker[page] = 1;
    trummelcodecexpression[page] = 5;

    trummelcodecline[page,1] = "What? But we've been";
    trummelcodecline[page,2] = "looking at him this";
    trummelcodecline[page,3] = "whole time!";
    trummelcodecline[page,4] = "";
    page++;
    
    //Page 12
    trummelcodecspeaker[page] = 3;
    trummelcodecexpression[page] = 0;

    trummelcodecline[page,1] = "!!!";
    trummelcodecline[page,2] = "";
    trummelcodecline[page,3] = "";
    trummelcodecline[page,4] = "";
    page++;
    
    //Page 13
    trummelcodecspeaker[page] = 1;
    trummelcodecexpression[page] = 5;

    trummelcodecline[page,1] = "MUNO, IT'S LOOKING AT US!";
    trummelcodecline[page,2] = "HELP!!";
    trummelcodecline[page,3] = "";
    trummelcodecline[page,4] = "";
    page++;
    
    //Page 14
    trummelcodecspeaker[page] = 3;
    trummelcodecexpression[page] = 1;

    trummelcodecline[page,1] = "TOORRRIIIIYYYAAAAAHHH!";
    trummelcodecline[page,2] = "";
    trummelcodecline[page,3] = "";
    trummelcodecline[page,4] = "";
    page++;
}

//kirby support
if swallowed {
    swallowed = 0;
    var ability_spr = sprite_get("dspecial_kirby");
    var ability_hurt = sprite_get("dspecial_kirby_hurt");
    var ability_sfx = sound_get("fox_shine");
    with enemykirby {
        set_attack_value(AT_EXTRA_3, AG_CATEGORY, 2);
        set_attack_value(AT_EXTRA_3, AG_SPRITE, ability_spr);
        set_attack_value(AT_EXTRA_3, AG_NUM_WINDOWS, 2);
        set_attack_value(AT_EXTRA_3, AG_HAS_LANDING_LAG, 4);
        set_attack_value(AT_EXTRA_3, AG_OFF_LEDGE, 1);
        set_attack_value(AT_EXTRA_3, AG_HURTBOX_SPRITE, ability_hurt);
        set_attack_value(AT_EXTRA_3, AG_USES_CUSTOM_GRAVITY, 1);
        
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_TYPE, 1);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_LENGTH, 3);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_ANIM_FRAMES, 1);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_HSPEED_TYPE, 1);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_VSPEED_TYPE, 1);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_HAS_CUSTOM_FRICTION, 1);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_CUSTOM_AIR_FRICTION, 0.9);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_CUSTOM_GROUND_FRICTION, 0.8);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_HAS_SFX, 1);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_SFX, ability_sfx);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_CUSTOM_GRAVITY, 0.1);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_INVINCIBILITY, 1);
        
        set_window_value(AT_EXTRA_3, 2, AG_WINDOW_TYPE, 1);
        set_window_value(AT_EXTRA_3, 2, AG_WINDOW_LENGTH, 4);
        set_window_value(AT_EXTRA_3, 2, AG_WINDOW_ANIM_FRAMES, 2);
        set_window_value(AT_EXTRA_3, 2, AG_WINDOW_ANIM_FRAME_START, 0);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_HSPEED_TYPE, 0);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_VSPEED_TYPE, 1);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_HAS_CUSTOM_FRICTION, 1);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_CUSTOM_AIR_FRICTION, 2);
        set_window_value(AT_EXTRA_3, 1, AG_WINDOW_CUSTOM_GROUND_FRICTION, 0.8);
        set_window_value(AT_EXTRA_3, 2, AG_WINDOW_CUSTOM_GRAVITY, 0.1);
        set_window_value(AT_EXTRA_3, 2, AG_WINDOW_INVINCIBILITY, 2);
        
        set_num_hitboxes(AT_EXTRA_3, 1);
        
        set_hitbox_value(AT_EXTRA_3, 1, HG_PARENT_HITBOX, 1);
        set_hitbox_value(AT_EXTRA_3, 1, HG_HITBOX_TYPE, 1);
        set_hitbox_value(AT_EXTRA_3, 1, HG_WINDOW, 1);
        set_hitbox_value(AT_EXTRA_3, 1, HG_WINDOW_CREATION_FRAME, 1);
        set_hitbox_value(AT_EXTRA_3, 1, HG_LIFETIME, 3);
        set_hitbox_value(AT_EXTRA_3, 1, HG_HITBOX_Y, -20);
        set_hitbox_value(AT_EXTRA_3, 1, HG_WIDTH, 90);
        set_hitbox_value(AT_EXTRA_3, 1, HG_HEIGHT, 90);
        set_hitbox_value(AT_EXTRA_3, 1, HG_PRIORITY, 1);
        set_hitbox_value(AT_EXTRA_3, 1, HG_DAMAGE, 4);
        set_hitbox_value(AT_EXTRA_3, 1, HG_BASE_KNOCKBACK, 10);
        set_hitbox_value(AT_EXTRA_3, 1, HG_KNOCKBACK_SCALING, .1);
        set_hitbox_value(AT_EXTRA_3, 1, HG_BASE_HITPAUSE, 3);
        set_hitbox_value(AT_EXTRA_3, 1, HG_VISUAL_EFFECT, 20);
        set_hitbox_value(AT_EXTRA_3, 1, HG_EFFECT, 11);
        set_hitbox_value(AT_EXTRA_3, 1, HG_ANGLE_FLIPPER, 6);
        set_hitbox_value(AT_EXTRA_3, 1, HG_EXTRA_HITPAUSE, 10);
        set_hitbox_value(AT_EXTRA_3, 1, HG_TECHABLE, 1);
    }
}

//kirby attack update
if enemykirby != undefined { //if kirby is in a match & swallowed
    with oPlayer { //Run through all players
        if (air_max_speed != 0) {
            og_air_speed = air_max_speed;
        }
        
        if ((state == PS_ATTACK_AIR || state == PS_ATTACK_GROUND) && attack == AT_EXTRA_3) {
            
            can_jump = true;
            can_fast_fall = false;
            can_move = false;
            
            air_max_speed = 0;
            
            if (special_down && window == 2) {
                window_timer = 1;
            }
            
        } else {
            air_max_speed = og_air_speed;
        }
    }
}

//smashville with ledges
var stage_data = "";
stage_data = string_copy(string(get_stage_data(SD_ID)), string_length(string(get_stage_data(SD_ID)))-9, 10);

if (stage_data == 2463834240) {
    if (!grabbing_ledge && !ledge_catch_play_snd) {
        ledge_catch_play_snd = true;
    }

    if (grabbing_ledge && ledge_catch_play_snd) {
        sound_play(sound_get("fox_ledge"));
        sound_play(sound_get("fox_ledge_sfx"));
        ledge_catch_play_snd = false;
    }
}