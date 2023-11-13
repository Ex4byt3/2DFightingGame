if (state == PS_ATTACK_AIR || state == PS_ATTACK_GROUND) {
    if (attack == 49 && window >= 3) { // final smash
        draw_sprite_ext(sprite_get("landmaster"), -1, x, y, spr_dir, 1, 0, c_white, 1);
    }
}