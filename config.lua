-- =====================================================================
--  lf-animalride | Configuration
-- ---------------------------------------------------------------------
--  Tame or summon rideable animals, ride them, buff them, and have them
--  follow you. Multi-framework (QBox / QBCore / ESX) with auto-detect.
-- =====================================================================

Config = {}

-- ---------------------------------------------------------------------
--  Framework & inventory
-- ---------------------------------------------------------------------
-- 'auto' detects qbx_core > qb-core > es_extended.
Config.Framework = 'auto' -- 'auto' | 'qbx' | 'qb' | 'esx'

-- 'auto' uses ox_inventory if present, else the framework's own inventory.
Config.Inventory = 'auto' -- 'auto' | 'ox' | 'qb' | 'esx'

Config.Debug = false

-- ---------------------------------------------------------------------
--  Taming
-- ---------------------------------------------------------------------
Config.SaddleItem = 'saddle'
Config.SaddleTime = 5000 -- ms, progress bar duration when saddling a wild animal

-- ---------------------------------------------------------------------
--  Movement
-- ---------------------------------------------------------------------
Config.Movement = {
    baseSpeed = 2.0, -- walking speed
    runSpeed  = 5.0, -- sprint speed (hold Shift)
    turnSpeed = 2.0, -- how sharply the animal turns
}

-- ---------------------------------------------------------------------
--  Stamina (sprinting drains it; it regenerates while not sprinting)
-- ---------------------------------------------------------------------
Config.Stamina = {
    enabled = true,
    max     = 100.0,
    drain   = 18.0, -- per second while sprinting
    regen   = 12.0, -- per second otherwise
    showBar = true, -- draw a small stamina bar while riding
}

-- ---------------------------------------------------------------------
--  Buff items
-- ---------------------------------------------------------------------
Config.Buffs = {
    speed = {
        item       = 'animal_stimulant',
        multiplier = 1.8, -- 1.8 = +80% speed
        duration   = 60,  -- seconds
    },
    invincibility = {
        item     = 'ironhide_apple',
        duration = 60, -- seconds
    },
}

-- ---------------------------------------------------------------------
--  Call companion (teleports/recalls your animal to you)
-- ---------------------------------------------------------------------
Config.Call = {
    enabled          = true,
    command          = 'callanimal',
    key              = 'G',    -- default keybind (players can rebind in settings)
    teleportDistance = 60.0,   -- if further than this, the animal is teleported near you
}

-- ---------------------------------------------------------------------
--  Animals
-- ---------------------------------------------------------------------
--  Each animal:
--    model     -> ped model (backtick hash or string)
--    label     -> shown in notifications
--    spawnItem -> item that summons it (omit for tame-only animals)
--    seat      -> mount attachment override (defaults to Config.DefaultSeat)
--
--  GTA V has no base-game horse; add an addon horse model here if you run one.
-- ---------------------------------------------------------------------
Config.Animals = {
    cow = {
        model     = `a_c_cow`,
        label     = 'Cow',
        spawnItem = 'cow_whistle',
    },
    boar = {
        model     = `a_c_boar`,
        label     = 'Boar',
        spawnItem = 'boar_caller',
    },
    -- Example addon horse (requires a streamed `a_c_horse` ped):
    -- horse = { model = `a_c_horse`, label = 'Horse', spawnItem = 'horse_whistle',
    --           seat = { bone = 0, x = 0.0, y = -0.05, z = 0.25, heading = 0.0 } },
}

-- Extra models that can be tamed with a saddle but have no spawn item.
Config.ExtraTameable = {
    -- `a_c_pig`,
}

-- Default mount attachment (player sitting on the animal's back).
Config.DefaultSeat = {
    bone    = 24816, -- spine bone
    x       = 0.0,
    y       = 0.0,
    z       = 0.2,
    heading = -90.0,
    anim    = { dict = 'amb@prop_human_seat_chair@male@generic@base', name = 'base' },
}

-- ---------------------------------------------------------------------
--  Locale
-- ---------------------------------------------------------------------
Config.Locale = {
    saddle_animal        = 'Saddle Animal',
    mount_animal         = 'Mount Animal',
    release_animal       = 'Release Animal',
    saddling_progress    = 'Saddling Animal...',
    saddled_success      = 'You successfully saddled the animal.',
    saddling_cancelled   = 'Saddling cancelled.',
    no_saddle            = 'You need a saddle to do this.',
    animal_released      = 'You released the animal.',
    saddle_returned      = 'You got your saddle back.',
    already_have_animal  = 'You already have an animal companion.',
    spawn_failed         = 'Could not find a safe place for the animal to spawn.',
    spawn_success        = 'Your animal has arrived!',
    no_active_animal     = 'You do not have an active animal.',
    buff_already_active  = 'Your animal already has that effect active.',
    speed_buff_applied   = 'Your animal feels much faster!',
    speed_buff_worn_off  = 'The stimulant has worn off.',
    invincibility_applied = "Your animal's hide feels like iron!",
    invincibility_worn_off = "The apple's magic has faded.",
    stamina_depleted     = 'Your animal is exhausted and needs to rest.',
    animal_coming        = 'Your animal is on its way.',
    animal_recalled      = 'You whistle and your animal appears.',
    animal_died          = 'Your animal companion has died.',
}
