--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Core file of TLOU Spores.

]]--
--[[ ================================================ ]]--

--- CACHING
-- module
local TLOU_Spores = require "TLOU_Spores_module"
require "TLOU_Spores_tools"

-- coordinates to check
local CHECK_COORDINATES = {}

-- debug mode
local isDebug = isDebugEnabled()

-- game loaded caching
local MODDATA_SPORES_CHUNKS
local MODDATA_SPORES_BUILDINGS
local MODDATA_SPORES_SEEDS
local MODDATA_SPORES_ROOMS

---Used to cache some stuff on startup
TLOU_Spores.OnInitGlobalModData = function()
    --- PERSISTENT DATA
    MODDATA_SPORES_SEEDS = MODDATA_SPORES_SEEDS or ModData.getOrCreate("TLOU_Spores_seeds")

    -- we can skip it since if this doesn't pass it's because OnNewGame didn't happen and it will set those values
    if MODDATA_SPORES_SEEDS["x_seed"] then
        TLOU_Spores.SEEDS.x_seed = MODDATA_SPORES_SEEDS["x_seed"]
        TLOU_Spores.SEEDS.y_seed = MODDATA_SPORES_SEEDS["y_seed"]
        TLOU_Spores.SEEDS.other_seed = MODDATA_SPORES_SEEDS["other_seed"]
    end

    --- SCALE
    --- the value the user gives is in tiles, so we need to divide it by 8 to get the correct scale
    local scale = SandboxVars.TLOU_Spores.NoiseMapScale/8
    scale = scale - scale%1 -- no point having a float
    TLOU_Spores.NOISE_MAP_SCALE = scale
end

---Used to initialize the seeds for this map, either by user input or randomness.
TLOU_Spores.OnNewGame  = function()
    MODDATA_SPORES_SEEDS = MODDATA_SPORES_SEEDS or ModData.getOrCreate("TLOU_Spores_seeds")

    --- USER SEED
    if SandboxVars.TLOU_Spores.CustomSeeds then
        MODDATA_SPORES_SEEDS["x_seed"] = SandboxVars.TLOU_Spores.x_seed
        MODDATA_SPORES_SEEDS["y_seed"] = SandboxVars.TLOU_Spores.y_seed
        MODDATA_SPORES_SEEDS["other_seed"] = SandboxVars.TLOU_Spores.other_seed

    --- GENERATE RANDOM SEEDS
    else
        local random = newrandom()
        MODDATA_SPORES_SEEDS["x_seed"] = random:random(50000,500000)
        MODDATA_SPORES_SEEDS["y_seed"] = random:random(50000,500000)
        MODDATA_SPORES_SEEDS["other_seed"] = random:random(50000,500000)
    end

    -- init mod data loads before OnNewGame, so load these here
    TLOU_Spores.SEEDS.x_seed = MODDATA_SPORES_SEEDS["x_seed"]
    TLOU_Spores.SEEDS.y_seed = MODDATA_SPORES_SEEDS["y_seed"]
    TLOU_Spores.SEEDS.other_seed = MODDATA_SPORES_SEEDS["other_seed"]
end



--[[ ================================================ ]]--
--- LOADING CHUNK ---
--[[ ================================================ ]]--

---Check which chunk needs to be loaded
---@param chunk any
TLOU_Spores.LoadChunk = function(chunk)
    MODDATA_SPORES_CHUNKS = MODDATA_SPORES_CHUNKS or ModData.getOrCreate("TLOU_Spores_chunks")

    -- verify chunk wasn't already loaded
    local chunkID = tostring(chunk.wx).."x"..tostring(chunk.wy)
    if MODDATA_SPORES_CHUNKS[chunkID] then return end

    -- check 4 squares in the chunk, which should be more than enough to catch any building
    local SQUARE_SKIP_DISTANCE = TLOU_Spores.SQUARE_SKIP_DISTANCE
    for i_x = 0, 7, SQUARE_SKIP_DISTANCE do
        for i_y = 0, 7, SQUARE_SKIP_DISTANCE do
            for i_z = chunk:getMinLevel(), chunk:getMaxLevel() do
                table.insert(CHECK_COORDINATES, {chunk=chunk,x=i_x,y=i_y,z=i_z})

                -- TLOU_Spores.OnTick(0) -- used for debugging to force load quickly
                MODDATA_SPORES_CHUNKS[chunkID] = true -- don't check that chunk anymore
            end
        end
    end
end

TLOU_Spores.OnTick = function(ticks)

    -- check for player in spore zone
    if ticks%10 == 0 then -- check not too often

        -- access the player room
        local roomDef = getPlayer():getCurrentRoomDef()
        if roomDef then
            local roomID = TLOU_Spores.GetRoomID(roomDef)
            MODDATA_SPORES_ROOMS = MODDATA_SPORES_ROOMS or ModData.getOrCreate("TLOU_Spores_rooms")

            -- check if player is in a spore zone
            local inSporeZone = MODDATA_SPORES_ROOMS[roomID]
        end
    end

    -- no coordinates to check
    if #CHECK_COORDINATES == 0 then return end

    -- next square to check
    local next_coordinate_check = CHECK_COORDINATES[1]
    local chunk = next_coordinate_check.chunk
    local x = next_coordinate_check.x
    local y = next_coordinate_check.y
    local z = next_coordinate_check.z

    repeat -- used to break instead of return
        -- access square
        local square = chunk:getGridSquare(x, y, z)
        if not square then break end

        -- access building
        local building = square:getBuilding()
        if not building then break end

        MODDATA_SPORES_BUILDINGS = MODDATA_SPORES_BUILDINGS or ModData.getOrCreate("TLOU_Spores_buildings")

        -- check if building was generated for spores
        local buildingDef = building:getDef()
        local x_bID,y_bID,z_bID = TLOU_Spores.getBuildingID(buildingDef)
        local buildingID = x_bID.."x"..y_bID.."x"..z_bID
        if MODDATA_SPORES_BUILDINGS[buildingID] then break end

        MODDATA_SPORES_BUILDINGS[buildingID] = true


        TLOU_Spores.RollForSpores(buildingDef,{x_bID = x_bID,y_bID = y_bID,z_bID = z_bID,buildingID = buildingID})
    until true

    -- remove entry from table
    table.remove(CHECK_COORDINATES, 1)
end

TLOU_Spores.OnSave = function()
    CHECK_COORDINATES = {}
end