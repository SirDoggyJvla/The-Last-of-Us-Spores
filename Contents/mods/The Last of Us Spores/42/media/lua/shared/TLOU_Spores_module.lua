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
    SCANNERS_ITEMS = {
        ["TLOU.SporesScanner_PremiumCivilian"] = true,
        ["TLOU.SporesScanner_PremiumMilitary"] = true,
        ["TLOU.SporesScanner_ValutechMilitary"] = true,
        ["TLOU.SporesScanner_PharmahugScientific"] = true,
    },

    -- the values are the scanner range
    SCANNERS_VALID_FOR_SPORE_DETECTION = {},

    -- the values are the map range
    SCANNERS_VALID_FOR_MAP = {},

    -- the values are the scanner precision
    SCANNERS_VALID_FOR_CONCENTRATION_READINGS = {},

    -- scanner map ui settings
    SCANNERS_UI_TEXTURE = {
        ["TLOU.SporesScanner_PremiumMilitary"] = {
            texture = getTexture("media/ui/UI_SporesScanner_PremiumMilitary.png"),
            grid_corner_1 = {x = 200, y = 840}, -- grid coordinates for the map
            grid_corner_2 = {x = 462, y = 1106},

            quit_button_corner_1 = {x = 294, y = 1341}, -- button for quitting the UI
            quit_button_corner_2 = {x = 387, y = 1428},

            zoom_in_button_corner_1 = {x = 309, y = 1618}, -- button for zooming in
            zoom_in_button_corner_2 = {x = 370, y = 1664},

            zoom_out_button_corner_1 = {x = 309, y = 1681}, -- button for zooming out
            zoom_out_button_corner_2 = {x = 370, y = 1726},
        },
    },

    --- SANDBOX OPTIONS ---
    SANDBOX_OPTIONS_SETUP = {
        MAP = {
            ["TLOU.SporesScanner_PremiumMilitary"] = "SporesScanner_PremiumMilitary_Map",
            ["TLOU.SporesScanner_PremiumCivilian"] = "SporesScanner_PremiumCivilian_Map",
            ["TLOU.SporesScanner_ValutechMilitary"] = "SporesScanner_ValutechMilitary_Map",
            ["TLOU.SporesScanner_PharmahugScientific"] = "SporesScanner_PharmahugScientific_Map",
        },
        SPORE_DETECTOR = {
            ["TLOU.SporesScanner_PremiumMilitary"] = "SporesScanner_PremiumMilitary_SporeDetector",
            ["TLOU.SporesScanner_PremiumCivilian"] = "SporesScanner_PremiumCivilian_SporeDetector",
            ["TLOU.SporesScanner_ValutechMilitary"] = "SporesScanner_ValutechMilitary_SporeDetector",
            ["TLOU.SporesScanner_PharmahugScientific"] = "SporesScanner_PharmahugScientific_SporeDetector",
        },
        CONCENTRATION_READING = {
            ["TLOU.SporesScanner_PremiumMilitary"] = "SporesScanner_PremiumMilitary_ConcentrationReading",
            ["TLOU.SporesScanner_PremiumCivilian"] = "SporesScanner_PremiumCivilian_ConcentrationReading",
            ["TLOU.SporesScanner_ValutechMilitary"] = "SporesScanner_ValutechMilitary_ConcentrationReading",
            ["TLOU.SporesScanner_PharmahugScientific"] = "SporesScanner_PharmahugScientific_ConcentrationReading",
        },
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

-- add battery handling for every scanners, done here in-case other outside scanners are added
local BatteryHandler = require "DoggyTools/DoggyAPI_BatteryHandler"
for scannerFullType, _ in pairs(TLOU_Spores.SCANNERS_ITEMS) do
    BatteryHandler.AddBatteryItem(scannerFullType)
end

return TLOU_Spores