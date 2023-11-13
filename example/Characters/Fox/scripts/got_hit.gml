var hit_hard_sounds = ["fox_fly_fast1", "fox_fly_fast2"];
var hit_sounds = ["fox_fly1", "fox_fly2"];

if (basicKnockbackFormula() > 50) {
    if (basicKnockbackFormula() > 120) {
        sound_play(sound_get( hit_hard_sounds[random_func( 1, 2, true )] ));
    } else if (random_func( 0, 1, true ) == 0) {
        sound_play(sound_get( hit_sounds[random_func( 1, 2, true )] ));
    }
}



#define basicKnockbackFormula
return enemy_hitboxID.kb_value + (enemy_hitboxID.kb_scale * get_player_damage( player ));