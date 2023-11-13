set_attack_value(AT_DAIR, AG_CATEGORY, 1);
set_attack_value(AT_DAIR, AG_SPRITE, sprite_get("dair"));
set_attack_value(AT_DAIR, AG_NUM_WINDOWS, 2);
set_attack_value(AT_DAIR, AG_HAS_LANDING_LAG, 1);
set_attack_value(AT_DAIR, AG_LANDING_LAG, 4);
set_attack_value(AT_DAIR, AG_HURTBOX_SPRITE, sprite_get("dair_hurt"));

set_window_value(AT_DAIR, 1, AG_WINDOW_TYPE, 1);
set_window_value(AT_DAIR, 1, AG_WINDOW_LENGTH, 8);
set_window_value(AT_DAIR, 1, AG_WINDOW_ANIM_FRAMES, 4);
set_window_value(AT_DAIR, 1, AG_WINDOW_HAS_SFX, 1);
set_window_value(AT_DAIR, 1, AG_WINDOW_SFX, sound_get("fox_dair"));
set_window_value(AT_DAIR, 1, AG_WINDOW_SFX_FRAME, 1);

set_window_value(AT_DAIR, 2, AG_WINDOW_TYPE, 1);
set_window_value(AT_DAIR, 2, AG_WINDOW_LENGTH, 8);
set_window_value(AT_DAIR, 2, AG_WINDOW_ANIM_FRAMES, 4);

set_num_hitboxes(AT_DAIR,7);

set_hitbox_value(AT_DAIR, 1, HG_PARENT_HITBOX, 1);
set_hitbox_value(AT_DAIR, 1, HG_HITBOX_TYPE, 1);
set_hitbox_value(AT_DAIR, 1, HG_WINDOW, 1);
set_hitbox_value(AT_DAIR, 1, HG_WINDOW_CREATION_FRAME, 1);
set_hitbox_value(AT_DAIR, 1, HG_LIFETIME, 2);
set_hitbox_value(AT_DAIR, 1, HG_HITBOX_X, 20);
set_hitbox_value(AT_DAIR, 1, HG_HITBOX_Y, -14);
set_hitbox_value(AT_DAIR, 1, HG_WIDTH, 60);
set_hitbox_value(AT_DAIR, 1, HG_HEIGHT, 75);
set_hitbox_value(AT_DAIR, 1, HG_SHAPE, 0);
set_hitbox_value(AT_DAIR, 1, HG_PRIORITY, 10);
set_hitbox_value(AT_DAIR, 1, HG_DAMAGE, 1);
set_hitbox_value(AT_DAIR, 1, HG_ANGLE, 290);
set_hitbox_value(AT_DAIR, 1, HG_BASE_KNOCKBACK, 3);
set_hitbox_value(AT_DAIR, 1, HG_KNOCKBACK_SCALING, 0);
set_hitbox_value(AT_DAIR, 1, HG_BASE_HITPAUSE, 2);
set_hitbox_value(AT_DAIR, 1, HG_HITPAUSE_SCALING, 0.1);
set_hitbox_value(AT_DAIR, 1, HG_HITSTUN_MULTIPLIER, 1.5);
set_hitbox_value(AT_DAIR, 1, HG_HIT_SFX, asset_get("sfx_blow_weak1"));
//set_hitbox_value(AT_DAIR, 1, HG_ANGLE_FLIPPER, 10);
//set_hitbox_value(AT_DAIR, 1, HG_TECHABLE, 1);

set_hitbox_value(AT_DAIR, 2, HG_PARENT_HITBOX, 1);
set_hitbox_value(AT_DAIR, 2, HG_HITBOX_TYPE, 1);
set_hitbox_value(AT_DAIR, 2, HG_WINDOW, 1);
set_hitbox_value(AT_DAIR, 2, HG_WINDOW_CREATION_FRAME, 3);
set_hitbox_value(AT_DAIR, 2, HG_LIFETIME, 2);
set_hitbox_value(AT_DAIR, 2, HG_HITBOX_X, 20);
set_hitbox_value(AT_DAIR, 2, HG_HITBOX_Y, -14);
set_hitbox_value(AT_DAIR, 2, HG_HITBOX_GROUP, 1);

set_hitbox_value(AT_DAIR, 3, HG_PARENT_HITBOX, 1);
set_hitbox_value(AT_DAIR, 3, HG_HITBOX_TYPE, 1);
set_hitbox_value(AT_DAIR, 3, HG_WINDOW, 1);
set_hitbox_value(AT_DAIR, 3, HG_WINDOW_CREATION_FRAME, 5);
set_hitbox_value(AT_DAIR, 3, HG_LIFETIME, 2);
set_hitbox_value(AT_DAIR, 3, HG_HITBOX_X, 20);
set_hitbox_value(AT_DAIR, 3, HG_HITBOX_Y, -14);
set_hitbox_value(AT_DAIR, 3, HG_HITBOX_GROUP, 2);

set_hitbox_value(AT_DAIR, 4, HG_PARENT_HITBOX, 1);
set_hitbox_value(AT_DAIR, 4, HG_HITBOX_TYPE, 1);
set_hitbox_value(AT_DAIR, 4, HG_WINDOW, 1);
set_hitbox_value(AT_DAIR, 4, HG_WINDOW_CREATION_FRAME, 7);
set_hitbox_value(AT_DAIR, 4, HG_LIFETIME, 2);
set_hitbox_value(AT_DAIR, 4, HG_HITBOX_X, 20);
set_hitbox_value(AT_DAIR, 4, HG_HITBOX_Y, -14);
set_hitbox_value(AT_DAIR, 4, HG_HITBOX_GROUP, 3);

set_hitbox_value(AT_DAIR, 5, HG_PARENT_HITBOX, 1);
set_hitbox_value(AT_DAIR, 5, HG_HITBOX_TYPE, 1);
set_hitbox_value(AT_DAIR, 5, HG_WINDOW, 2);
set_hitbox_value(AT_DAIR, 5, HG_WINDOW_CREATION_FRAME, 1);
set_hitbox_value(AT_DAIR, 5, HG_LIFETIME, 2);
set_hitbox_value(AT_DAIR, 5, HG_HITBOX_X, 20);
set_hitbox_value(AT_DAIR, 5, HG_HITBOX_Y, -14);
set_hitbox_value(AT_DAIR, 5, HG_HITBOX_GROUP, 4);

set_hitbox_value(AT_DAIR, 6, HG_PARENT_HITBOX, 1);
set_hitbox_value(AT_DAIR, 6, HG_HITBOX_TYPE, 1);
set_hitbox_value(AT_DAIR, 6, HG_WINDOW, 2);
set_hitbox_value(AT_DAIR, 6, HG_WINDOW_CREATION_FRAME, 3);
set_hitbox_value(AT_DAIR, 6, HG_LIFETIME, 2);
set_hitbox_value(AT_DAIR, 6, HG_HITBOX_X, 20);
set_hitbox_value(AT_DAIR, 6, HG_HITBOX_Y, -14);
set_hitbox_value(AT_DAIR, 6, HG_HITBOX_GROUP, 5);

set_hitbox_value(AT_DAIR, 7, HG_PARENT_HITBOX, 7);
set_hitbox_value(AT_DAIR, 7, HG_HITBOX_TYPE, 1);
set_hitbox_value(AT_DAIR, 7, HG_WINDOW, 2);
set_hitbox_value(AT_DAIR, 7, HG_WINDOW_CREATION_FRAME, 5);
set_hitbox_value(AT_DAIR, 7, HG_LIFETIME, 2);
set_hitbox_value(AT_DAIR, 7, HG_HITBOX_X, 20);
set_hitbox_value(AT_DAIR, 7, HG_HITBOX_Y, -14);
set_hitbox_value(AT_DAIR, 7, HG_WIDTH, 60);
set_hitbox_value(AT_DAIR, 7, HG_HEIGHT, 75);
set_hitbox_value(AT_DAIR, 7, HG_SHAPE, 0);
set_hitbox_value(AT_DAIR, 7, HG_PRIORITY, 10);
set_hitbox_value(AT_DAIR, 7, HG_DAMAGE, 4);
set_hitbox_value(AT_DAIR, 7, HG_ANGLE, 45);
set_hitbox_value(AT_DAIR, 7, HG_BASE_KNOCKBACK, 8);
set_hitbox_value(AT_DAIR, 7, HG_KNOCKBACK_SCALING, 0.2);
set_hitbox_value(AT_DAIR, 7, HG_BASE_HITPAUSE, 10);
set_hitbox_value(AT_DAIR, 7, HG_HITPAUSE_SCALING, 0.2);
set_hitbox_value(AT_DAIR, 7, HG_HITBOX_GROUP, 7);
set_hitbox_value(AT_DAIR, 7, HG_HITSTUN_MULTIPLIER, 1.5);
set_hitbox_value(AT_DAIR, 7, HG_HIT_SFX, asset_get("sfx_blow_medium1"));
set_hitbox_value(AT_DAIR, 7, HG_TECHABLE, 1);