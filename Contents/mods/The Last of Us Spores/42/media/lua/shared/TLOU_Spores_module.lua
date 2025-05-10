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
    --- CONFIGS ---
    CONFIGS = {}, -- will be populated by the mod options

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

    --- MAP GENERATION ---
    CHECK_COORDINATES = {},

    --- PLAYER STATE ---
    PLAYER_STATE = {},

    --- SPORE OVERLAY ---
    OVERLAY_OPTIONS = {
        ["yellow"] = {
            main_path = "media/ui/SporeOverlay/yellow/SporeOverlay_main_yellow.png",
            particles_big = {
                path = "media/ui/SporeOverlay/yellow/SporeOverlay_particles_yellow_big_%d.png",
                limitMin = 0.5,
                limitMax = 1,
                omega_x = math.pi*1,
                omega_y = math.pi*0.5,
                amplitude = 3,
            },
            particles_medium = {
                path = "media/ui/SporeOverlay/yellow/SporeOverlay_particles_yellow_medium_%d.png",
                limitMin = 0.5,
                limitMax = 1,
                omega_x = math.pi*2,
                omega_y = math.pi*1.5,
                amplitude = 6,
            },
            particles_small = {
                path = "media/ui/SporeOverlay/yellow/SporeOverlay_particles_yellow_small_%d.png",
                limitMin = 0.5,
                limitMax = 1,
                omega_x = math.pi*3,
                omega_y = math.pi*2.5,
                amplitude = 10,
            },
            particles_medium_fliped = {
                path = "media/ui/SporeOverlay/yellow/SporeOverlay_particles_yellow_medium_fliped_%d.png",
                limitMin = 0.5,
                limitMax = 1,
                omega_x = math.pi*2,
                omega_y = math.pi*1.5,
                amplitude = 6,
            },
            particles_small_fliped = {
                path = "media/ui/SporeOverlay/yellow/SporeOverlay_particles_yellow_small_fliped_%d.png",
                limitMin = 0.5,
                limitMax = 1,
                omega_x = math.pi*3,
                omega_y = math.pi*2.5,
                amplitude = 10,
            },
        },
        ["white"] = {
            main_path = "media/ui/SporeOverlay/white/SporeOverlay_main_white.png",
            particles_big = {
                path = "media/ui/SporeOverlay/white/SporeOverlay_particles_white_big_%d.png",
                limitMin = 0.5,
                limitMax = 1,
                omega_x = math.pi*1,
                omega_y = math.pi*0.5,
                amplitude = 3,
            },
            particles_medium = {
                path = "media/ui/SporeOverlay/white/SporeOverlay_particles_white_medium_%d.png",
                limitMin = 0.5,
                limitMax = 1,
                omega_x = math.pi*2,
                omega_y = math.pi*1.5,
                amplitude = 6,
            },
            particles_small = {
                path = "media/ui/SporeOverlay/white/SporeOverlay_particles_white_small_%d.png",
                limitMin = 0.5,
                limitMax = 1,
                omega_x = math.pi*3,
                omega_y = math.pi*2.5,
                amplitude = 10,
            },
            particles_medium_fliped = {
                path = "media/ui/SporeOverlay/white/SporeOverlay_particles_white_medium_fliped_%d.png",
                limitMin = 0.5,
                limitMax = 1,
                omega_x = math.pi*2,
                omega_y = math.pi*1.5,
                amplitude = 6,
            },
            particles_small_fliped = {
                path = "media/ui/SporeOverlay/white/SporeOverlay_particles_white_small_fliped_%d.png",
                limitMin = 0.5,
                limitMax = 1,
                omega_x = math.pi*3,
                omega_y = math.pi*2.5,
                amplitude = 10,
            },
        },
    },
    PARTICLE_LAYERS = table.newarray({
        "particles_big",
        "particles_medium",
        "particles_small",
        "particles_medium_fliped",
        "particles_small_fliped",
    }),


    --- DEBUGING ---
    DEBUG = {
        highlightSquaresBoolean = false,
    },
}

-- add battery handling for every scanners, done here in-case other outside scanners are added
local BatteryHandler = require "DoggyTools/BatteryHandler"
for scannerFullType, _ in pairs(TLOU_Spores.SCANNERS_ITEMS) do
    BatteryHandler.AddBatteryItem(scannerFullType)
end



--[[ ================================================ ]]--
--- LOADING CHUNK ---
--[[ ================================================ ]]--

---Whenever a new chunk gets loaded in
---@param chunk any
TLOU_Spores.LoadNewChunk = function(chunk)
    -- check 4 squares in the chunk, which should be more than enough to catch any building
    local SQUARE_SKIP_DISTANCE = TLOU_Spores.SQUARE_SKIP_DISTANCE
    local CHUNK_MIN_LEVEL,CHUNK_MAX_LEVEL = chunk:getMinLevel(),chunk:getMaxLevel()
    local CHECK_COORDINATES = TLOU_Spores.CHECK_COORDINATES
    for i_x = 0, 7, SQUARE_SKIP_DISTANCE do
        for i_y = 0, 7, SQUARE_SKIP_DISTANCE do
            for i_z = CHUNK_MIN_LEVEL, CHUNK_MAX_LEVEL do
                table.insert(CHECK_COORDINATES, {chunk=chunk,x=i_x,y=i_y,z=i_z})
            end
        end
    end
end



return TLOU_Spores