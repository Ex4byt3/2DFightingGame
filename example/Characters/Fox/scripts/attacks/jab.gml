set_attack_value(AT_JAB, AG_SPRITE, sprite_get("jab"));
set_attack_value(AT_JAB, AG_NUM_WINDOWS, 5);
set_attack_value(AT_JAB, AG_HURTBOX_SPRITE, sprite_get("jab_hurt"));

set_window_value(AT_JAB, 1, AG_WINDOW_TYPE, 1);
set_window_value(AT_JAB, 1, AG_WINDOW_LENGTH, 20);
set_window_value(AT_JAB, 1, AG_WINDOW_ANIM_FRAMES, 1);
set_window_value(AT_JAB, 1, AG_WINDOW_HAS_SFX, 1);
set_window_value(AT_JAB, 1, AG_WINDOW_SFX, sound_get("fox_grab"));

set_window_value(AT_JAB, 2, AG_WINDOW_TYPE, 1);
set_window_value(AT_JAB, 2, AG_WINDOW_LENGTH, 16);
set_window_value(AT_JAB, 2, AG_WINDOW_ANIM_FRAMES, 4);
set_window_value(AT_JAB, 2, AG_WINDOW_ANIM_FRAME_START, 1);
set_window_value(AT_JAB, 2, AG_WINDOW_HAS_SFX, 1);
set_window_value(AT_JAB, 2, AG_WINDOW_SFX, sound_get("fox_laser_load"));
set_window_value(AT_JAB, 2, AG_WINDOW_SFX_FRAME, 12);

set_window_value(AT_JAB, 3, AG_WINDOW_TYPE, 1);
set_window_value(AT_JAB, 3, AG_WINDOW_LENGTH, 5);
set_window_value(AT_JAB, 3, AG_WINDOW_ANIM_FRAMES, 1);
set_window_value(AT_JAB, 3, AG_WINDOW_ANIM_FRAME_START, 4);
set_window_value(AT_JAB, 3, AG_WINDOW_HAS_SFX, 1);
set_window_value(AT_JAB, 3, AG_WINDOW_SFX, sound_get("fox_laser"));

set_window_value(AT_JAB, 4, AG_WINDOW_TYPE, 1);
set_window_value(AT_JAB, 4, AG_WINDOW_LENGTH, 5);
set_window_value(AT_JAB, 4, AG_WINDOW_ANIM_FRAMES, 1);
set_window_value(AT_JAB, 4, AG_WINDOW_ANIM_FRAME_START, 4);
set_window_value(AT_JAB, 4, AG_WINDOW_HAS_SFX, 1);
set_window_value(AT_JAB, 4, AG_WINDOW_SFX, sound_get("fox_laser"));

set_window_value(AT_JAB, 5, AG_WINDOW_TYPE, 1);
set_window_value(AT_JAB, 5, AG_WINDOW_LENGTH, 5);
set_window_value(AT_JAB, 5, AG_WINDOW_ANIM_FRAMES, 1);
set_window_value(AT_JAB, 5, AG_WINDOW_ANIM_FRAME_START, 4);
set_window_value(AT_JAB, 5, AG_WINDOW_HAS_SFX, 1);
set_window_value(AT_JAB, 5, AG_WINDOW_SFX, sound_get("fox_laser"));

set_num_hitboxes(AT_JAB, 5);

set_hitbox_value(AT_JAB, 1, HG_PARENT_HITBOX, 1);
set_hitbox_value(AT_JAB, 1, HG_HITBOX_TYPE, 1);
set_hitbox_value(AT_JAB, 1, HG_HITBOX_GROUP, -1);
set_hitbox_value(AT_JAB, 1, HG_WINDOW, 1);
set_hitbox_value(AT_JAB, 1, HG_WINDOW_CREATION_FRAME, 1);
set_hitbox_value(AT_JAB, 1, HG_LIFETIME, 3);
set_hitbox_value(AT_JAB, 1, HG_HITBOX_X, 40);
set_hitbox_value(AT_JAB, 1, HG_HITBOX_Y, -35);
set_hitbox_value(AT_JAB, 1, HG_WIDTH, 85);
set_hitbox_value(AT_JAB, 1, HG_HEIGHT, 85);
set_hitbox_value(AT_JAB, 1, HG_PRIORITY, 10);
set_hitbox_value(AT_JAB, 1, HG_DAMAGE, 0);
set_hitbox_value(AT_JAB, 1, HG_ANGLE, 90);
set_hitbox_value(AT_JAB, 1, HG_BASE_KNOCKBACK, 5);
set_hitbox_value(AT_JAB, 1, HG_BASE_HITPAUSE, 14);
set_hitbox_value(AT_JAB, 1, HG_EXTRA_HITPAUSE, 0);
set_hitbox_value(AT_JAB, 1, HG_SDI_MULTIPLIER, 0);;
set_hitbox_value(AT_JAB, 1, HG_TECHABLE, 1);

set_hitbox_value(AT_JAB, 2, HG_PARENT_HITBOX, 2);
set_hitbox_value(AT_JAB, 2, HG_HITBOX_TYPE, 1);
set_hitbox_value(AT_JAB, 2, HG_HITBOX_GROUP, -1);
set_hitbox_value(AT_JAB, 2, HG_WINDOW, 2);
set_hitbox_value(AT_JAB, 2, HG_WINDOW_CREATION_FRAME, 0);
set_hitbox_value(AT_JAB, 2, HG_LIFETIME, 3);
set_hitbox_value(AT_JAB, 2, HG_HITBOX_X, 40);
set_hitbox_value(AT_JAB, 2, HG_HITBOX_Y, -35);
set_hitbox_value(AT_JAB, 2, HG_WIDTH, 85);
set_hitbox_value(AT_JAB, 2, HG_HEIGHT, 85);
set_hitbox_value(AT_JAB, 2, HG_PRIORITY, 10);
set_hitbox_value(AT_JAB, 2, HG_DAMAGE, 8);
set_hitbox_value(AT_JAB, 2, HG_ANGLE, 90);
set_hitbox_value(AT_JAB, 2, HG_BASE_KNOCKBACK, 12);
set_hitbox_value(AT_JAB, 2, HG_VISUAL_EFFECT_X_OFFSET, 32);
set_hitbox_value(AT_JAB, 2, HG_VISUAL_EFFECT_Y_OFFSET, -10);
set_hitbox_value(AT_JAB, 2, HG_HIT_SFX, sound_get("fox_throw"));
set_hitbox_value(AT_JAB, 2, HG_ANGLE_FLIPPER, 6);

set_hitbox_value(AT_JAB, 3, HG_PARENT_HITBOX, 3);
set_hitbox_value(AT_JAB, 3, HG_HITBOX_TYPE, 2);
set_hitbox_value(AT_JAB, 3, HG_WINDOW, 3);
set_hitbox_value(AT_JAB, 3, HG_WINDOW_CREATION_FRAME, 1);
set_hitbox_value(AT_JAB, 3, HG_LIFETIME, 30);
set_hitbox_value(AT_JAB, 3, HG_HITBOX_X, -44);
set_hitbox_value(AT_JAB, 3, HG_HITBOX_Y, -146);
set_hitbox_value(AT_JAB, 3, HG_HITBOX_GROUP, 2);
set_hitbox_value(AT_JAB, 3, HG_WIDTH, 120);
set_hitbox_value(AT_JAB, 3, HG_HEIGHT, 60);
set_hitbox_value(AT_JAB, 3, HG_PRIORITY, 10);
set_hitbox_value(AT_JAB, 3, HG_DAMAGE, 3);
set_hitbox_value(AT_JAB, 3, HG_ANGLE, 50);
set_hitbox_value(AT_JAB, 3, HG_VISUAL_EFFECT_Y_OFFSET, -16);
set_hitbox_value(AT_JAB, 3, HG_HITSTUN_MULTIPLIER, -1);
set_hitbox_value(AT_JAB, 3, HG_PROJECTILE_SPRITE, sprite_get("jab_proj"));
set_hitbox_value(AT_JAB, 3, HG_PROJECTILE_MASK, sprite_get("jab_proj_mask"));
set_hitbox_value(AT_JAB, 3, HG_PROJECTILE_ANIM_SPEED, .2);
set_hitbox_value(AT_JAB, 3, HG_PROJECTILE_VSPEED, -18);

set_hitbox_value(AT_JAB, 4, HG_PARENT_HITBOX, 3);
set_hitbox_value(AT_JAB, 4, HG_HITBOX_TYPE, 2);
set_hitbox_value(AT_JAB, 4, HG_WINDOW, 4);
set_hitbox_value(AT_JAB, 4, HG_WINDOW_CREATION_FRAME, 1);
set_hitbox_value(AT_JAB, 4, HG_LIFETIME, 30);
set_hitbox_value(AT_JAB, 4, HG_HITBOX_X, -44);
set_hitbox_value(AT_JAB, 4, HG_HITBOX_Y, -146);
set_hitbox_value(AT_JAB, 4, HG_HITBOX_GROUP, 3);

set_hitbox_value(AT_JAB, 5, HG_PARENT_HITBOX, 3);
set_hitbox_value(AT_JAB, 5, HG_HITBOX_TYPE, 2);
set_hitbox_value(AT_JAB, 5, HG_WINDOW, 5);
set_hitbox_value(AT_JAB, 5, HG_WINDOW_CREATION_FRAME, 1);
set_hitbox_value(AT_JAB, 5, HG_LIFETIME, 30);
set_hitbox_value(AT_JAB, 5, HG_HITBOX_X, -44);
set_hitbox_value(AT_JAB, 5, HG_HITBOX_Y, -146);
set_hitbox_value(AT_JAB, 5, HG_HITBOX_GROUP, 4);