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
local DoggyAPI = require "DoggyAPI_module"
local DoggyAPI_WORLD = DoggyAPI.WORLD

-- coordinates to check
local CHECK_COORDINATES = {}

-- game loaded caching
local MODDATA_SPORES_BUILDINGS
local MODDATA_SPORES_SEEDS

---Used to cache some stuff on startup
TLOU_Spores.OnInitGlobalModData = function()
    -- reset mod data to current save
    MODDATA_SPORES_BUILDINGS = ModData.getOrCreate("TLOU_Spores_buildings")

    --- PERSISTENT DATA
    MODDATA_SPORES_SEEDS = MODDATA_SPORES_SEEDS or ModData.getOrCreate("TLOU_Spores_seeds")

    -- we can skip it since if this doesn't pass it's because OnNewGame didn't happen and it will set those values
    if MODDATA_SPORES_SEEDS["x_seed"] then
        TLOU_Spores.SEEDS.x_seed = MODDATA_SPORES_SEEDS["x_seed"]
        TLOU_Spores.SEEDS.y_seed = MODDATA_SPORES_SEEDS["y_seed"]
        TLOU_Spores.SEEDS.offset_seed = MODDATA_SPORES_SEEDS["offset_seed"]
    end

    --- SCALE
    --- the value the user gives is in tiles, so we need to divide it by 8 to get the correct scale
    local scale = SandboxVars.TLOU_Spores.NoiseMapScale/8
    scale = scale - scale%1 -- no point having a float
    TLOU_Spores.NOISE_MAP_SCALE = scale


    --- SANDBOX OPTIONS

    -- these below is for compatibility with mods that add new scanners
    -- doesn't take into account the case where no sandbox option is given for the new scanners
    local SANDBOX_OPTIONS_SETUP = TLOU_Spores.SANDBOX_OPTIONS_SETUP

    -- map
    for itemFullType,option in pairs(SANDBOX_OPTIONS_SETUP.MAP) do
        local value = SandboxVars.TLOU_Spores[option]
        TLOU_Spores.SCANNERS_VALID_FOR_MAP[itemFullType] = value ~= 0 and value or nil
    end

    -- Spore detector
    for itemFullType,option in pairs(SANDBOX_OPTIONS_SETUP.SPORE_DETECTOR) do
        local value = SandboxVars.TLOU_Spores[option]
        TLOU_Spores.SCANNERS_VALID_FOR_SPORE_DETECTION[itemFullType] = value ~= 0 and value or nil
    end

    -- concentration readings
    for itemFullType,option in pairs(SANDBOX_OPTIONS_SETUP.CONCENTRATION_READING) do
        local value = SandboxVars.TLOU_Spores[option]
        TLOU_Spores.SCANNERS_VALID_FOR_CONCENTRATION_READINGS[itemFullType] = value ~= -1 and value or nil
    end
end

TLOU_Spores.OnSave = function()
    CHECK_COORDINATES = {}
end

---Used to initialize the seeds for this map, either by user input or randomness.
TLOU_Spores.OnNewGame = function()
    MODDATA_SPORES_SEEDS = MODDATA_SPORES_SEEDS or ModData.getOrCreate("TLOU_Spores_seeds")

    --- USER SEED
    if SandboxVars.TLOU_Spores.CustomSeeds then
        MODDATA_SPORES_SEEDS["x_seed"] = SandboxVars.TLOU_Spores.x_seed
        MODDATA_SPORES_SEEDS["y_seed"] = SandboxVars.TLOU_Spores.y_seed
        MODDATA_SPORES_SEEDS["offset_seed"] = SandboxVars.TLOU_Spores.offset_seed

    --- GENERATE RANDOM SEEDS
    else
        local random = newrandom()
        MODDATA_SPORES_SEEDS["x_seed"] = random:random(50000,500000)
        MODDATA_SPORES_SEEDS["y_seed"] = random:random(50000,500000)
        MODDATA_SPORES_SEEDS["offset_seed"] = random:random(50000,500000)
    end

    -- init mod data loads before OnNewGame, so load these here
    TLOU_Spores.SEEDS.x_seed = MODDATA_SPORES_SEEDS["x_seed"]
    TLOU_Spores.SEEDS.y_seed = MODDATA_SPORES_SEEDS["y_seed"]
    TLOU_Spores.SEEDS.offset_seed = MODDATA_SPORES_SEEDS["offset_seed"]
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
    for i_x = 0, 7, SQUARE_SKIP_DISTANCE do
        for i_y = 0, 7, SQUARE_SKIP_DISTANCE do
            for i_z = CHUNK_MIN_LEVEL, CHUNK_MAX_LEVEL do
                table.insert(CHECK_COORDINATES, {chunk=chunk,x=i_x,y=i_y,z=i_z})
            end
        end
    end
end

TLOU_Spores.OnTick = function(ticks)
    -- update player in spore zone status
    if ticks % 10 == 0 then
        local player = getPlayer()
        if player then
            TLOU_Spores.UpdateInSpores(player)
        end
    end

    -- update the scanners
    TLOU_Spores.ScanForSpores(ticks)

    -- no coordinates to check
    if #CHECK_COORDINATES == 0 then return end

    -- next square to check
    local next_coordinate_check = CHECK_COORDINATES[1]
    local chunk = next_coordinate_check.chunk
    local x = next_coordinate_check.x
    local y = next_coordinate_check.y
    local z = next_coordinate_check.z

    local wrongInitialization,buildingDef
    repeat -- used to break instead of return
        -- access square
        local square = chunk:getGridSquare(x, y, z)
        if not square then break end

        -- access building
        local building = square:getBuilding()
        if not building then break end

        MODDATA_SPORES_BUILDINGS = MODDATA_SPORES_BUILDINGS or ModData.getOrCreate("TLOU_Spores_buildings")

        -- check if building was generated for spores
        buildingDef = building:getDef()
        local x_bID,y_bID,z_bID = DoggyAPI_WORLD.getBuildingID(buildingDef)
        local buildingID = x_bID.."x"..y_bID.."x"..z_bID
        if MODDATA_SPORES_BUILDINGS[buildingID] then break end

        -- we verify the building was successfully identified, if not it needs to be checked later
        wrongInitialization = TLOU_Spores.RollForSpores(buildingDef,{x_bID = x_bID,y_bID = y_bID,z_bID = z_bID,buildingID = buildingID})
        MODDATA_SPORES_BUILDINGS[buildingID] = wrongInitialization
    until true

    -- remove entry from table
    if not wrongInitialization then
        table.remove(CHECK_COORDINATES, 1)
    else
        -- check again later but put last to check other buildings
        table.insert(CHECK_COORDINATES, table.remove(CHECK_COORDINATES, 1))
    end
end

TLOU_Spores.OnFillInventoryObjectContextMenu = function(playerIndex, context, items)
    local player = getSpecificPlayer(playerIndex)
    for i = 1,#items do
		-- retrieve the item
		local item = items[i]
		if not instanceof(item, "InventoryItem") then
            item = item.items[1];
        end


        --- ITEM CAN SCAN ---
        if not TLOU_Spores.SCANNERS_ITEMS[item:getFullType()] then
            return
        end

        local equiped = player:getPrimaryHandItem() == item or player:getSecondaryHandItem() == item
        local activated = item:isActivated()
        local charged  = item:getCurrentUsesFloat() > 0



        --- ITEM CAN HAVE CONCENTRATION READINGS ---

        local concentrationPrecision = TLOU_Spores.SCANNERS_VALID_FOR_CONCENTRATION_READINGS[item:getFullType()]
        if concentrationPrecision then
            local option = context:addOption("Get spore concentration readings", player, TLOU_Spores.StartSporeConcentrationReadings, item, concentrationPrecision)
            if not equiped then
                option.notAvailable = true
                local tooltip = ISWorldObjectContextMenu.addToolTip()
                tooltip.description = getText("Tooltip_SporesScanner_needEquiping")
                option.toolTip = tooltip
            elseif not activated then
                option.notAvailable = true
                local tooltip = ISWorldObjectContextMenu.addToolTip()
                tooltip.description = getText("Tooltip_SporesScanner_needActivating")
                option.toolTip = tooltip
            elseif not charged then
                option.notAvailable = true
                local tooltip = ISWorldObjectContextMenu.addToolTip()
                tooltip.description = getText("Tooltip_SporesScanner_needCharging")
                option.toolTip = tooltip
            else
                local toolTip = ISWorldObjectContextMenu.addToolTip()
                toolTip.description = string.format(getText("Tooltip_SporesScanner_concentrationPrecision"),concentrationPrecision)
                option.toolTip = toolTip
            end
        end


        --- SCANNER HAS MAP ---

        local mapRange = TLOU_Spores.SCANNERS_VALID_FOR_MAP[item:getFullType()]
        if mapRange then
            local option = context:addOption("Show spore concentration map", mapRange, TLOU_Spores.ShowSporeConcentrationMap, item)
            if not equiped then
                option.notAvailable = true
                local tooltip = ISWorldObjectContextMenu.addToolTip()
                tooltip.description = getText("Tooltip_SporesScanner_needEquiping")
                option.toolTip = tooltip
            elseif not activated then
                option.notAvailable = true
                local tooltip = ISWorldObjectContextMenu.addToolTip()
                tooltip.description = getText("Tooltip_SporesScanner_needActivating")
                option.toolTip = tooltip
            elseif not charged then
                option.notAvailable = true
                local tooltip = ISWorldObjectContextMenu.addToolTip()
                tooltip.description = getText("Tooltip_SporesScanner_needCharging")
                option.toolTip = tooltip
            else
                local toolTip = ISWorldObjectContextMenu.addToolTip()
                toolTip.description = string.format(getText("Tooltip_SporesScanner_mapRange"),mapRange)
                option.toolTip = toolTip
            end
        end
    end
end