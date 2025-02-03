--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Module of TLOU Spores.

]]--
--[[ ================================================ ]]--

local TLOU_Spores = {
    --- CHUNKS ---
    SQUARE_SKIP_DISTANCE = 4,

    --- TILES ---
    FRESH_SPORE_TILES = {
        WALLS_WEST = {
            MUSHROOM_BIG = {
                "kokoz_ptlourp_spore_33",
            },
            MUSHROOM_SMALL = {
                "kokoz_ptlourp_spore_40",
                "kokoz_ptlourp_spore_42",
            },
            SMALL_MARK = {
                "kokoz_ptlourp_spore_51",
                "kokoz_ptlourp_spore_49",
            },
            BODY = {
                "kokoz_ptlourp_spore_0", -- body clinging to wall
                "kokoz_ptlourp_spore_2", -- body clinging to wall
                "kokoz_ptlourp_spore_25", -- body with mushrooms growing side on wall
                "kokoz_ptlourp_spore_27", -- body side on wall
                "kokoz_ptlourp_spore_16", -- body back to wall
                "kokoz_ptlourp_spore_8", -- body back to wall
            },
        },
        WALLS_NORTH = {
            MUSHROOM_BIG = {
                "kokoz_ptlourp_spore_32",
            },
            MUSHROOM_SMALL = {
                "kokoz_ptlourp_spore_41",
                "kokoz_ptlourp_spore_43",
            },
            SMALL_MARK = {
                "kokoz_ptlourp_spore_50",
                "kokoz_ptlourp_spore_48",
            },
            BODY = {
                "kokoz_ptlourp_spore_1", -- body clinging to wall
                "kokoz_ptlourp_spore_3", -- body clinging to wall
                "kokoz_ptlourp_spore_24", -- body with mushrooms growing side on wall
                "kokoz_ptlourp_spore_26", -- body side on wall
                "kokoz_ptlourp_spore_9", -- body back to wall
                "kokoz_ptlourp_spore_17", -- body back to wall
            },
        },
    },

    DRY_SPORE_TILES = {
        WALLS_WEST = {
            MUSHROOM_BIG = {
                "kokoz_ptlourp_spore_35",
            },
            MUSHROOM_SMALL = {
                "kokoz_ptlourp_spore_44",
                "kokoz_ptlourp_spore_46",
            },
            SMALL_MARK = {
                "kokoz_ptlourp_spore_55",
                "kokoz_ptlourp_spore_53",
            },
            BODY = {
                "kokoz_ptlourp_spore_4", -- body clinging to wall
                "kokoz_ptlourp_spore_29", -- body with mushrooms growing side on wall
                "kokoz_ptlourp_spore_31", -- body side on wall
                "kokoz_ptlourp_spore_18", -- body back to wall
                "kokoz_ptlourp_spore_10", -- body back to wall
            },
        },
        WALLS_NORTH = {
            MUSHROOM_BIG = {
                "kokoz_ptlourp_spore_34",
            },
            MUSHROOM_SMALL = {
                "kokoz_ptlourp_spore_45",
                "kokoz_ptlourp_spore_47",
            },
            SMALL_MARK = {
                "kokoz_ptlourp_spore_52",
                "kokoz_ptlourp_spore_54",
            },
            BODY = {
                "kokoz_ptlourp_spore_5", -- body clinging to wall
                "kokoz_ptlourp_spore_28", -- body with mushrooms growing side on wall
                "kokoz_ptlourp_spore_30", -- body side on wall
                "kokoz_ptlourp_spore_19", -- body back to wall
                "kokoz_ptlourp_spore_11", -- body back to wall
            },
        },
    },

    --- SCANNERS ---
    SCANNERS_VALID_FOR_SPORE_DETECTION = {
        ["TLOU.SporesScanner_PremiumCivilian"] = 7,
        ["TLOU.SporesScanner_ValutechMilitary"] = 20,
    },

    --- NOISE MAP ---
    SEEDS = {},
    NOISE_MAP_SCALE = 25,
    NOISE_SPORE_THRESHOLD = 0.5,
    MINIMUM_PERCENTAGE_OF_ROOMS_WITH_SPORES = 0.2,
    MINIMUM_NOISE_VECTOR_VALUE = -5,
    MAXIMUM_NOISE_VECTOR_VALUE = 5,

    --- PLAYER STATE ---
    PLAYER_STATE = {},

    --- DEBUGING ---
    DEBUG = {
        highlightSquaresBoolean = false,
    },
}

return TLOU_Spores