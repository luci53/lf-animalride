Config = {}

Config.SaddleItem = 'saddle'
Config.SaddleTime = 5000


Config.AnimalBaseSpeed = 2.0 -- Base walking speed
Config.AnimalRunSpeed = 5.0  -- Base running/sprinting speed


Config.BuffItems = {
    SpeedBoostDuration = 60000, -- in milliseconds (60 seconds)
    InvincibilityDuration = 60000, -- in milliseconds (60 seconds)
    SpeedMultiplier = 1.8, -- How much faster the animal gets (1.8 = 80% faster)
}

Config.RidablePeds = {
    `a_c_horse`,
    `a_c_cow`,
    `a_c_boar`,
}

Config.SpawnItems = {
    ['cow_whistle'] = { model = `a_c_cow`, label = 'Cow' },
    ['boar_caller'] = { model = `a_c_boar`, label = 'Boar' },
}

Config.Locale = {
    saddle_animal = 'Saddle Animal',
    mount_animal = 'Mount Animal',
    release_animal = 'Release Animal',
    saddling_progress = 'Saddling Animal...',
    saddled_success = 'You successfully saddled the animal.',
    saddling_cancelled = 'Saddling cancelled.',
    no_saddle = 'You need a saddle to do this.',
    animal_released = 'You released the animal and got your saddle back.',
    already_have_animal = 'You already have an animal companion.',
    spawn_failed = 'Could not find a safe place for the animal to spawn.',
    spawn_success = 'Your animal has arrived!',
    item_returned = 'Your item was returned to you.',
    no_animal_to_buff = 'You do not have an active animal to use this on.',
    buff_already_active = 'Your animal already has a similar effect active.',
    speed_buff_applied = 'Your animal feels much faster!',
    speed_buff_worn_off = 'The stimulant has worn off.',
    invincibility_applied = 'Your animal\'s hide feels like iron!',
    invincibility_worn_off = 'The apple\'s magic has faded.',

}
