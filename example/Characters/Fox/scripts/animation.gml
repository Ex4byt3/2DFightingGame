switch (state){
    case PS_IDLE:
    case PS_RESPAWN:
    case PS_SPAWN:
        image_index = floor(image_number*state_timer/(image_number*6.5));
    break;
    
    case PS_WALK:
        image_index = floor(image_number*state_timer/(image_number*5));
    break;
}

var stage_data = "";
stage_data = string_copy(string(get_stage_data(SD_ID)), string_length(string(get_stage_data(SD_ID)))-9, 10);

if (stage_data == 2463834240) {
    if (grabbing_ledge) {
        sprite_index = sprite_get("ledge");
    }
}