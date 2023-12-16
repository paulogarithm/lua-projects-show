--| https://minecraft.fandom.com/wiki/Enchanting/Levels

local Enchantments = {}

Enchantments.Powers = {

    -- Anything
    unbreaking              = {{5, 25}, {13, 63}, {21, 71}},
    mending                 = {{25, 75}},

    -- Curses
    curse_of_vanishing      = {{25, 50}},
    curse_of_binding        = {{25, 50}},

    -- Armor
    protection              = {{1, 12}, {12, 23}, {23, 34}, {34, 45}},
    fire_protection         = {{10, 18}, {18, 26}, {26, 34}, {34, 42}},
    feather_falling         = {{5, 11}, {11, 17}, {17, 23}, {23, 29}},
    blast_protection        = {{5, 13}, {13, 21}, {21, 29}, {29, 37}},
    projectile_protection   = {{3, 9}, {9, 15}, {15, 21}, {21, 27}},
    respiration             = {{10, 40}, {20, 50}, {30, 60}},
    aqua_affinity           = {{1, 41}},
    thorns                  = {{10, 60}, {30, 70}, {50, 80}},
    depth_strider           = {{10, 25}, {20, 35}, {30, 45}},
    frost_walker            = {{10, 25}, {20, 35}},
    soul_speed              = {{10, 25}, {20, 35}, {30, 45}},
    swift_sneak             = {{25, 75}, {50, 100}, {75, 125}},

    -- Tool
    efficiency              = {{1, 51}, {11, 61}, {21, 36}, {31, 46}, {41, 56}},
    silk_touch              = {{15, 65}},
    fortune                 = {{15, 65}, {24, 74}, {33, 83}}
}

Enchantments.IsTreasure = {"frost_walker", "swift_sneak", "curse_of_binding", "soul_speed", "mending", "curse_of_vanishing"}

Enchantments.Weights = {

    -- Anything
    unbreaking              = 5,
    mending                 = 2,

    -- Curses
    curse_of_vanishing      = 1,
    curse_of_binding        = 1,

    -- Armor
    protection              = 10,
    feather_falling         = 5,
    fire_protection         = 5,
    projectile_protection   = 5,
    blast_protection        = 2,
    respiration             = 2,
    aqua_affinity           = 2,
    depth_strider           = 2,
    frost_walker            = 2,
    thorns                  = 1,
    swift_sneak             = 1,
    soul_speed              = 1,

    -- Tool
    efficiency              = 10,
    fortune                 = 2,
    silk_touch              = 1,
}

Enchantments.TotalWeight = 0
for _, weight in pairs(Enchantments.Weights) do
    Enchantments.TotalWeight = Enchantments.TotalWeight + weight
end

return Enchantments