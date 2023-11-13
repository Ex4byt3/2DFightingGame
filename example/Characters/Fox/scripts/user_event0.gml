// RUNE ACTIVATION

//tier 1 runes
if runeA {
    set_hitbox_value(AT_FTILT, 1, HG_ANGLE, 361);
} else {
    reset_hitbox_value(AT_FTILT, 1, HG_ANGLE);
}

if runeB {
    set_window_value(AT_NSPECIAL, 1, AG_WINDOW_LENGTH, 12);
    
    set_window_value(AT_NSPECIAL, 3, AG_WINDOW_LENGTH, 15);
    
    set_hitbox_value(AT_NSPECIAL, 1, HG_FORCE_FLINCH, 1);
    set_hitbox_value(AT_NSPECIAL, 1, HG_BASE_KNOCKBACK, 2);
    set_hitbox_value(AT_NSPECIAL, 1, HG_BASE_HITPAUSE, 3);
    set_hitbox_value(AT_NSPECIAL, 1, HG_HITSTUN_MULTIPLIER, 1.3);
    
} else {
    reset_window_value(AT_NSPECIAL, 1, AG_WINDOW_LENGTH);
    
    reset_window_value(AT_NSPECIAL, 3, AG_WINDOW_LENGTH);
    
    reset_hitbox_value(AT_NSPECIAL, 1, HG_FORCE_FLINCH);
    reset_hitbox_value(AT_NSPECIAL, 1, HG_BASE_KNOCKBACK);
    reset_hitbox_value(AT_NSPECIAL, 1, HG_BASE_HITPAUSE);
    reset_hitbox_value(AT_NSPECIAL, 1, HG_HITSTUN_MULTIPLIER);
}

if runeC {
    max_djumps = 2;
} else {
    max_djumps = 1;
}

if !runeD {
    reset_window_value(AT_DSPECIAL, 1, AG_WINDOW_VSPEED);
    
    reset_window_value(AT_DSPECIAL, 1, AG_WINDOW_CUSTOM_AIR_FRICTION);
    reset_window_value(AT_DSPECIAL, 2, AG_WINDOW_CUSTOM_AIR_FRICTION);
}

if runeE {
    set_attack_value(AT_DAIR, AG_USES_CUSTOM_GRAVITY, 1);
    
    set_window_value(AT_DAIR, 1, AG_WINDOW_CUSTOM_GRAVITY, 0.2);
    
    set_window_value(AT_DAIR, 2, AG_WINDOW_CUSTOM_GRAVITY, 0.2);
} else {
    reset_attack_value(AT_DAIR, AG_USES_CUSTOM_GRAVITY);
}

if runeF {
    set_num_hitboxes(AT_NSPECIAL, 2);
} else {
    set_num_hitboxes(AT_NSPECIAL, 1);
}

//tier 2 runes
if runeG {
    set_hitbox_value(AT_BAIR, 1, HG_ANGLE, 270);
} else {
    reset_hitbox_value(AT_BAIR, 1, HG_ANGLE);
}

if runeH {
    set_hitbox_value(AT_FSPECIAL, 1, HG_ANGLE, 270);
} else {
    reset_hitbox_value(AT_FSPECIAL, 1, HG_ANGLE);
}

if runeI {
    set_hitbox_value(AT_FSPECIAL, 1, HG_EXTRA_HITPAUSE, 35);
    set_hitbox_value(AT_FSPECIAL, 1, HG_VISUAL_EFFECT, 256);
    set_hitbox_value(AT_FSPECIAL, 1, HG_HIT_SFX, asset_get("sfx_clairen_tip_strong"));
} else {
    reset_hitbox_value(AT_FSPECIAL, 1, HG_EXTRA_HITPAUSE);
    reset_hitbox_value(AT_FSPECIAL, 1, HG_VISUAL_EFFECT);
    reset_hitbox_value(AT_FSPECIAL, 1, HG_HIT_SFX);
}

if runeK {
    air_accel = .8;
} else {
    air_accel = .3;
}

//tier 3 runes
if runeL {
    set_hitbox_value(AT_JAB, 2, HG_KNOCKBACK_SCALING, 1.2);
} else {
    reset_hitbox_value(AT_JAB, 2, HG_KNOCKBACK_SCALING);
}
if runeM {
    set_attack_value(AT_FAIR, AG_USES_CUSTOM_GRAVITY, 1);
    
    set_window_value(AT_FAIR, 1, AG_WINDOW_CUSTOM_GRAVITY, 0.2);
    
    set_window_value(AT_FAIR, 2, AG_WINDOW_CUSTOM_GRAVITY, 0.2);
    
    set_hitbox_value(AT_FAIR, 1, HG_ANGLE, 20);
    set_hitbox_value(AT_FAIR, 1, HG_BASE_KNOCKBACK, 9);
} else {
    reset_attack_value(AT_FAIR, AG_USES_CUSTOM_GRAVITY);
    
    reset_hitbox_value(AT_FAIR, 1, HG_ANGLE);
    reset_hitbox_value(AT_FAIR, 1, HG_BASE_KNOCKBACK);
}

if runeN {
    set_window_value(AT_USPECIAL, 1, AG_WINDOW_ANIM_FRAMES, 2);
    set_window_value(AT_USPECIAL, 1, AG_WINDOW_LENGTH, 10);
} else {
    reset_window_value(AT_USPECIAL, 1, AG_WINDOW_ANIM_FRAMES);
    reset_window_value(AT_USPECIAL, 1, AG_WINDOW_LENGTH);
}

if runeO {
    set_num_hitboxes(AT_TAUNT, 1);
} else {
    set_num_hitboxes(AT_TAUNT, 0);
}