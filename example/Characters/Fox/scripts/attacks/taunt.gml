set_attack_value(AT_TAUNT, AG_SPRITE, sprite_get("taunt"));
set_attack_value(AT_TAUNT, AG_NUM_WINDOWS, 1);
set_attack_value(AT_TAUNT, AG_HAS_LANDING_LAG, 3);
set_attack_value(AT_TAUNT, AG_OFF_LEDGE, 1);
set_attack_value(AT_TAUNT, AG_HURTBOX_SPRITE, asset_get("ex_guy_hurt_box"));


set_window_value(AT_TAUNT, 1, AG_WINDOW_TYPE, 1);
set_window_value(AT_TAUNT, 1, AG_WINDOW_LENGTH, 10);
set_window_value(AT_TAUNT, 1, AG_WINDOW_HAS_SFX, 1);
set_window_value(AT_TAUNT, 1, AG_WINDOW_SFX, sound_get("fox_camawn"));
set_window_value(AT_TAUNT, 1, AG_WINDOW_SFX_FRAME, 0);

set_num_hitboxes(AT_TAUNT, 0);

set_hitbox_value(AT_TAUNT, 1, HG_PARENT_HITBOX, 1);
set_hitbox_value(AT_TAUNT, 1, HG_HITBOX_TYPE, 1 );
set_hitbox_value(AT_TAUNT, 1, HG_WINDOW, 1);
set_hitbox_value(AT_TAUNT, 1, HG_WINDOW_CREATION_FRAME, 1);
set_hitbox_value(AT_TAUNT, 1, HG_LIFETIME, 10);
set_hitbox_value(AT_TAUNT, 1, HG_WIDTH, 75);
set_hitbox_value(AT_TAUNT, 1, HG_HEIGHT, 75);
set_hitbox_value(AT_TAUNT, 1, HG_HITBOX_X, 0);
set_hitbox_value(AT_TAUNT, 1, HG_HITBOX_Y, -32);
set_hitbox_value(AT_TAUNT, 1, HG_SHAPE, 0 );
set_hitbox_value(AT_TAUNT, 1, HG_PRIORITY, 10 );
set_hitbox_value(AT_TAUNT, 1, HG_DAMAGE, 12);
set_hitbox_value(AT_TAUNT, 1, HG_ANGLE, 361);
set_hitbox_value(AT_TAUNT, 1, HG_BASE_KNOCKBACK, 8);
set_hitbox_value(AT_TAUNT, 1, HG_KNOCKBACK_SCALING, 1.2);
set_hitbox_value(AT_TAUNT, 1, HG_BASE_HITPAUSE, 10);
set_hitbox_value(AT_TAUNT, 1, HG_HITPAUSE_SCALING, 1.1);
set_hitbox_value(AT_TAUNT, 1, HG_HITSTUN_MULTIPLIER, 1.1);
set_hitbox_value(AT_TAUNT, 1, HG_ANGLE_FLIPPER, 3 );
set_hitbox_value(AT_TAUNT, 1, HG_HIT_SFX, asset_get("sfx_blow_heavy2"));
set_hitbox_value(AT_TAUNT, 1, HG_EXTRA_CAMERA_SHAKE, 1 );