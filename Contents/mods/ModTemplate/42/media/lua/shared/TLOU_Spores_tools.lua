--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Tools file of TLOU Spores.

]]--
--[[ ================================================ ]]--

--- CACHING
-- module
local TLOU_Spores = require "TLOU_Spores_module"

-- random
local GENERAL_RANDOM = newrandom()

-- debug mode
local isDebug = isDebugEnabled()

-- mod data
local MODDATA_SPORES_ROOMS



--[[ ================================================ ]]--
--- BUILDING IDENTIFICATION ---
--[[ ================================================ ]]--

---Used to get a persistent identification of a building.
---@param buildingDef BuildingDef
---@return integer
---@return integer
---@return integer
TLOU_Spores.getBuildingID = function(buildingDef)
    -- get a X and Y coordinate
    local x_bID = buildingDef:getX()
    local y_bID = buildingDef:getY()

    -- get a Z coordinate
    local firstRoom = buildingDef:getFirstRoom()
    local z_bID = firstRoom and firstRoom:getZ() or 0

    return x_bID,y_bID,z_bID
end

---Retrieves the room ID based on its coordinates x,y,z.
---@param roomDef RoomDef
---@return string
TLOU_Spores.GetRoomID = function(roomDef)
    return roomDef:getX().."x"..roomDef:getY().."x"..roomDef:getZ()
end

---Used to get a list of rooms in a building and their coordinates.
---@param roomDefs ArrayList
---@return table
---@return table
TLOU_Spores.MapBuildingRooms = function(roomDefs)
    local roomIDs = {}
    local mappedRooms = {}
    for roomIndex = 0,roomDefs:size() - 1 do repeat
        -- get a random square in the room which is free
        local roomDef =  roomDefs:get(roomIndex)
        local square = roomDef:getIsoRoom():getRandomFreeSquare()
        if not square or square:HasStairs() then break end

        -- get room ID
        local roomID = TLOU_Spores.GetRoomID(roomDef)

        -- register the room
        table.insert(roomIDs,roomID)
        table.insert(mappedRooms,{x=square:getX(),y=square:getY(),z=square:getZ()*3})
    until true end
    return roomIDs,mappedRooms
end


---Used to get the next closest room to the source room. Bases itself on the 
---room randomly chosen square in the rooms and their distance to the source room square.
---@param roomIDs table
---@param mappedRooms table
---@param sporeRooms table
---@param numberOf_rooms integer
---@param source_x integer
---@param source_y integer
---@param source_z integer
---@return string
---@return integer
TLOU_Spores.GetNextClosestRoom = function(
    roomIDs,
    mappedRooms,
    sporeRooms,
    numberOf_rooms,
    source_x,source_y,source_z
)

    -- find nearest room to source room
    local closestRoomID,closestDistance,closestRoomIndex
    for roomIndex = 1,numberOf_rooms do repeat
        local roomID = roomIDs[roomIndex]
        if sporeRooms[roomID] then break end -- skip if already in sporeRooms

        local coordinates = mappedRooms[roomIndex]

        -- get distance
        local room_x,room_y,room_z = coordinates.x,coordinates.y,coordinates.z
        local distance = (source_x - room_x)^2 + (source_y - room_y)^2 + (source_z - room_z)^2

        -- pass conditions
        if not closestRoomID or distance < closestDistance then
            closestRoomID = roomID
            closestDistance = distance
            closestRoomIndex = roomIndex
        end
    until true end

    return closestRoomID,closestRoomIndex
end



--[[ ================================================ ]]--
--- SPORE ZONE SETTER ---
--[[ ================================================ ]]--

---Used to roll for spore zones in the building based on the world noise map.
---@param buildingDef any
---@param bID any
TLOU_Spores.RollForSpores = function(buildingDef,bID)
    -- get building spore map concentration
    local wx,wy = bID.x_bID,bID.y_bID
    TLOU_Spores.NOISE_MAP_SCALE = 25
    local noiseValue = TLOU_Spores.getNoiseValue(wx, wy)
    TLOU_Spores.NOISE_SPORE_THRESHOLD = 0.5
    TLOU_Spores.MINIMUM_PERCENTAGE_OF_ROOMS_WITH_SPORES = 0.2
    local spore_concentration = noiseValue - TLOU_Spores.NOISE_SPORE_THRESHOLD
    spore_concentration = 1

    -- threshold can be decided by user in sandbox options
    if spore_concentration <= 0 then return end

    -- get number of rooms
    local roomDefs = buildingDef:getRooms()
    local numberOf_rooms = roomDefs:size()
    if numberOf_rooms <= 0 then return end

    -- calculate percentage of rooms that will have spores
    local numberOf_spored_rooms = math.ceil(numberOf_rooms * spore_concentration)
    if numberOf_spored_rooms > numberOf_rooms then numberOf_spored_rooms = numberOf_rooms end

    -- verify the minimum amount of spores rooms is respected to have a spore zone
    if numberOf_spored_rooms < numberOf_rooms * TLOU_Spores.MINIMUM_PERCENTAGE_OF_ROOMS_WITH_SPORES then return end

    -- get rooms
    local roomIDs,mappedRooms = TLOU_Spores.MapBuildingRooms(roomDefs)

    -- update room number to take into account randomly chosen squares that were not valid
    numberOf_rooms = #roomIDs
    if numberOf_rooms <= 0 then return end

    -- get source room
    local sourceRoomIndex = GENERAL_RANDOM:random(1,numberOf_rooms)
    local sourceRoomID = roomIDs[sourceRoomIndex]

    -- mod data
    MODDATA_SPORES_ROOMS = MODDATA_SPORES_ROOMS or ModData.getOrCreate("TLOU_Spores_rooms")

    -- get source room coordinates
    local source_coordinates = mappedRooms[sourceRoomIndex]
    local source_x,source_y,source_z = source_coordinates.x,source_coordinates.y,source_coordinates.z

    -- register the source room as a spore zone
    local sporeRooms = {
        [sourceRoomID] = source_coordinates, -- origin point
    }
    MODDATA_SPORES_ROOMS[sourceRoomID] = true

    -- get the closest rooms to the source room to create spore zones
    local sporeRoomCount = 1
    while sporeRoomCount < numberOf_spored_rooms do
        local closestRoomID,closestRoomIndex = TLOU_Spores.GetNextClosestRoom(
            roomIDs,
            mappedRooms,
            sporeRooms,
            numberOf_rooms,
            source_x,source_y,source_z
        )

        sporeRooms[closestRoomID] = mappedRooms[closestRoomIndex]
        sporeRoomCount = sporeRoomCount + 1

        MODDATA_SPORES_ROOMS[closestRoomID] = true
    end

    local typeWeight = {
        MUSHROOM_BIG = 3,
        MUSHROOM_SMALL = 5,
        -- SMALL_MARK = 5,
        BODY = 1,
    }

    local totalChance = 0
    local types = {}
    for k,v in pairs(typeWeight) do
        totalChance = totalChance + v
        table.insert(types,k)
    end

    for roomID,coordinates in pairs(sporeRooms) do repeat
        local square = getSquare(coordinates.x,coordinates.y,coordinates.z)
        if not square then break end

        local isoRoom = square:getRoom()
        if not isoRoom then break end

        local squares = isoRoom:getSquares()
        for i = 0,squares:size() - 1 do repeat
            local square = squares:get(i)
            if square:isFreeWallSquare() then
                local direction = TLOU_Spores.GetWallDirection(square)
                if not direction then break end

                local tileTypes = TLOU_Spores.FRESH_SPORE_TILES[direction]
                local rand = GENERAL_RANDOM:random(1,totalChance)
                local currentChance = 0
                local chosenType
                for j = 1, #types do
                    local type = types[j]
                    currentChance = currentChance + typeWeight[type]
                    if rand <= currentChance then
                        chosenType = type
                        break
                    end
                end

                if not chosenType then break end

                local possibleTiles = tileTypes[chosenType]
                local choiceTile = possibleTiles[GENERAL_RANDOM:random(1,#possibleTiles)]

                local isoObject = IsoObject.new(getCell(), square, choiceTile)
                square:AddTileObject(isoObject)

                TLOU_Spores.DEBUG.AddHighlightSquare(square,{r=0,g=1,b=0,a=1})

            elseif square:isWallSquare() then
                if true then break end
                local direction = TLOU_Spores.GetWallDirection(square)
                if not direction then break end

                local possibleTiles = TLOU_Spores.FRESH_SPORE_TILES[direction].SMALL_MARK
                local choiceTile = possibleTiles[GENERAL_RANDOM:random(1,#possibleTiles)]

                local isoObject = IsoObject.new(getCell(), square, choiceTile)
                square:AddTileObject(isoObject)

                TLOU_Spores.DEBUG.AddHighlightSquare(square,{r=1,g=1,b=0,a=1})
            end
        until true end

        for i = 1,10 do
            local wallSquare = isoRoom:getRandomWallSquare()
            TLOU_Spores.DEBUG.AddHighlightSquare(wallSquare,{r=0,g=1,b=0,a=1})
        end

    until true end


end


TLOU_Spores.GetWallDirection = function(square)
    local objects = square:getObjects()
    local direction
    for i = 0, objects:size() - 1 do
        -- get sprite
        local sprite = objects:get(i):getSprite()
        if sprite then
            local properties = sprite:getProperties()

            direction = properties:Is("WallN") and "WALLS_NORTH"
                or properties:Is("WallW") and "WALLS_WEST"
                or properties:Is("WallNW") and newrandom():random(0,1) == 1 and ("WALLS_NORTH" or "WALLS_WEST")

            if direction then break end
        end
    end

    return direction
end

