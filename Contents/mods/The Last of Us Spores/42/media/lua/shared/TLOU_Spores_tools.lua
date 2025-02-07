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
local DoggyAPI = require "DoggyAPI_module"
local DoggyAPI_NOISEMAP = DoggyAPI.NOISEMAP
local DoggyAPI_FINDERS = DoggyAPI.FINDERS
local DoggyAPI_WORLD = DoggyAPI.WORLD

-- random
local GENERAL_RANDOM = newrandom()

-- debug mode
local isDebug = isDebugEnabled()

-- noise map
local SEEDS = TLOU_Spores.SEEDS


--[[ ================================================ ]]--
--- BUILDING IDENTIFICATION ---
--[[ ================================================ ]]--

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
        local roomID = DoggyAPI_WORLD.GetRoomID(roomDef)

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

TLOU_Spores.IsSquareSporeZone = function(square)
    local room = square:getRoom()
    if not room then return false end

    local roomDef = room:getRoomDef()
    if not roomDef then return false end

    -- get room ID
    local roomID = DoggyAPI_WORLD.GetRoomID(roomDef)
    local MODDATA_SPORES_ROOMS = ModData.getOrCreate("TLOU_Spores_rooms")

    -- check if room has spores
    return MODDATA_SPORES_ROOMS[roomID]
end



--[[ ================================================ ]]--
--- SPORE ZONE SETTER ---
--[[ ================================================ ]]--

TLOU_Spores.GetChunkSporeConcentration = function(chunk)
    -- get building spore map concentration
    local noiseValue = DoggyAPI_NOISEMAP.getNoiseValue(
        chunk.wx, chunk.wy,
        TLOU_Spores.NOISE_MAP_SCALE,
        TLOU_Spores.MINIMUM_NOISE_VECTOR_VALUE,TLOU_Spores.MAXIMUM_NOISE_VECTOR_VALUE,
        SEEDS.x_seed,SEEDS.y_seed,SEEDS.offset_seed
    )

    -- threshold can be decided by user in sandbox options
    local spore_concentration = noiseValue - TLOU_Spores.NOISE_SPORE_THRESHOLD

    return spore_concentration
end

TLOU_Spores.GetBuildingSporeConcentration = function(x_bID,y_bID,z_bID)
    local square = getSquare(x_bID,y_bID,z_bID)
    local chunk = square:getChunk()
    local spore_concentration = TLOU_Spores.GetChunkSporeConcentration(chunk)

    return spore_concentration
end

---Used to roll for spore zones in the building based on the world noise map.
---@param buildingDef any
---@param bID any
TLOU_Spores.RollForSpores = function(buildingDef,bID)
    -- get building spore map concentration
    local spore_concentration = TLOU_Spores.GetBuildingSporeConcentration(bID.x_bID,bID.y_bID,bID.z_bID)
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
    local MODDATA_SPORES_ROOMS = ModData.getOrCreate("TLOU_Spores_rooms")

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






--[[ ================================================ ]]--
--- HANDLE CHARACTER IN SPORE ZONE ---
--[[ ================================================ ]]--

TLOU_Spores.CheckInSpores = function(character)
    -- access the player room
    local roomDef = character:getCurrentRoomDef()

    -- check if in spores
    local inSpores = false
    if roomDef then
        -- get room ID
        local roomID = DoggyAPI_WORLD.GetRoomID(roomDef)
        local MODDATA_SPORES_ROOMS = ModData.getOrCreate("TLOU_Spores_rooms")

        -- check if room has spores
        inSpores = MODDATA_SPORES_ROOMS[roomID]
    end

    return inSpores
end

TLOU_Spores.UpdateInSpores = function(character)
    local character_modData = character:getModData().TLOU_Spores
    if not character_modData then
        character:getModData().TLOU_Spores = {}
        character_modData = character:getModData().TLOU_Spores
    end

    -- check if in spores
    local inSporesPreviously = character_modData["inSpores"]
    local inSporesNow = TLOU_Spores.CheckInSpores(character)

    if inSporesNow then
        if inSporesPreviously then
            return TLOU_Spores.CharacterIsInSpores(character,character_modData)
        else
            return TLOU_Spores.CharacterEntersSpores(character,character_modData)
        end
    elseif inSporesPreviously then
        return TLOU_Spores.CharacterExitSpores(character,character_modData)
    end

    -- nil because spores are not a thing for the player rn
    return nil, nil
end

TLOU_Spores.CharacterIsInSpores = function(character,character_modData)
    character_modData = character_modData or character:getModData().TLOU_Spores

    local bodyDamage = character:getBodyDamage()

    -- verify if player's protection is enough
    -- print(character:isProtectedFromToxic())
    if character:getCorpseSicknessDefense() >= 100 or character:isProtectedFromToxic() then
        -- reset timer if present
        if character_modData["sporeTimer"] then
            character_modData["sporeTimer"] = nil
        end
        return true, nil
    end

    -- get the time delta
    local timer = character_modData["sporeTimer"]
    if not timer then
        timer = getGametimeTimestamp()/60
        character_modData["sporeTimer"] = timer
    end
    local timeDelta = getGametimeTimestamp()/60 - timer

    -- infected if too long in spores
    if not bodyDamage:IsInfected() and not character_modData["infectedBySpores"] then
        if timeDelta >= SandboxVars.TLOU_Spores.MaximumTimeInSpores then
            character:addLineChatElement("Infected by spores")
            bodyDamage:setInfected(true)
            bodyDamage:setInfectionMortalityDuration(SandboxVars.TLOU_Spores.SporesInfectionStrength/60)
            character_modData["infectedBySpores"] = true
        end
    end

    -- update health status
    if not bodyDamage:isHasACold() then
        bodyDamage:setHasACold(true)
        bodyDamage:setColdStrength(80)
        bodyDamage:setTimeToSneezeOrCough(0)
    end

    -- DEBUGING
    if not character_modData["previousTime"] then
        character_modData["previousTime"] = timeDelta
    else
        if character_modData["previousTime"] ~= timeDelta then
            character_modData["previousTime"] = timeDelta
            print("In spores: "..tostring(timeDelta))
        end
    end

    return true, timeDelta
end

TLOU_Spores.CharacterEntersSpores = function(character,character_modData)
    print("Enter spores")
    character_modData = character_modData or character:getModData().TLOU_Spores

    -- initialize in spores
    character_modData["inSpores"] = true
    character_modData["sporeTimer"] = getGametimeTimestamp()/60

    local bodyDamage = character:getBodyDamage()

    character_modData["originaHealthStatus"] = {
        hasACold = bodyDamage:isHasACold(),
    }

    return TLOU_Spores.CharacterIsInSpores(character,character_modData)
end

TLOU_Spores.CharacterExitSpores = function(character,character_modData)
    print("Exit spores")
    character_modData = character_modData or character:getModData().TLOU_Spores

    -- reinitialize in spores
    character_modData["sporeTimer"] = nil
    character_modData["inSpores"] = nil

    -- false for the character exiting spores
    return false, nil
end







--[[ ================================================ ]]--
--- SPORE SCANNER ---
--[[ ================================================ ]]--

---Test function to recursively find scanners in the inventory.
---@param item InventoryItem
---@return any
TLOU_Spores.isScanner = function(item)
	return TLOU_Spores.SCANNERS_VALID_FOR_SPORE_DETECTION[item:getFullType()] ~= nil
end

---Used to show the spore concentration map.
---@param mapRange integer
---@param scanner InventoryItem
TLOU_Spores.ShowSporeConcentrationMap = function(mapRange, scanner)
    local x = getCore():getScreenWidth()*0.25 -- Get the screen resolution
    local y = getCore():getScreenHeight()*0.10 -- Get the screen resolution

    TLOU_Spores.iSSporeZoneChunkMap = TLOU_Spores.ISSporeZoneChunkMap:new(x, y, mapRange, true, scanner)
    TLOU_Spores.iSSporeZoneChunkMap:initialise()
    TLOU_Spores.iSSporeZoneChunkMap:addToUIManager()
end

---Used to get spore concentration readings.
---@param player any
---@param scanner any
---@param concentrationPrecision any
TLOU_Spores.StartSporeConcentrationReadings = function(player, scanner, concentrationPrecision)
    ISTimedActionQueue.add(TLOU_Spores_ISScanForSporesConcentration:new(player,scanner,os.time(),concentrationPrecision))
end


TLOU_Spores.ScanForSpores = function(ticks)
    local client_player = getPlayer()

    -- cache emitters
    local emitter = client_player:getEmitter()
    local sporeZoneDetectorEmitter1 = emitter:isPlaying('SporesScanner_SporeZone1')
    local sporeZoneDetectorEmitter2 = emitter:isPlaying('SporesScanner_SporeZone2')

    -- we don't need to do any check if any of these emitters are playing
    if sporeZoneDetectorEmitter1 or sporeZoneDetectorEmitter2 then return end

    -- only update every n seconds minimum sound time
    local lastCheck = TLOU_Spores.lastCheck
    local current_time = os.time()
    if not lastCheck then TLOU_Spores.lastCheck = current_time return end
    if current_time - lastCheck < 0.38 then return end
    TLOU_Spores.lastCheck = current_time

    -- retrieve the first scanner
    local inventory = client_player:getInventory()
    local scanners = ArrayList.new()
    inventory:getAllEvalRecurse(TLOU_Spores.isScanner,scanners)
    local scannersAmount = scanners:size()

    -- skip if no scanner found
    if scannersAmount <= 0 then return end

    -- retrieve the best scanner
    local scanner
    local maxRadius = 0
    for i = 0, scannersAmount - 1 do repeat
        -- verify that scanner is activated and charged
        local temp_scanner = scanners:get(i)
        if not temp_scanner:isActivated() or temp_scanner:getUseDelta() == 0 then break end

        -- check if scanner is valid to detect (attached or in hands)
        local primaryItem = client_player:getPrimaryHandItem()
        local secondaryItem = client_player:getSecondaryHandItem()
        if temp_scanner:getAttachedSlotType() or primaryItem and primaryItem == temp_scanner or secondaryItem and secondaryItem == temp_scanner then
            -- detection radius
            local radius = TLOU_Spores.SCANNERS_VALID_FOR_SPORE_DETECTION[temp_scanner:getFullType()]

            -- update best scanner choice
            scanner = maxRadius < radius and scanner or temp_scanner
        end
    until true end

    -- skip if no scanner found
    if not scanner then return end




    --- IN BUILDING ---

    if TLOU_Spores.CheckInSpores(client_player) then
        emitter:playSound('SporesScanner_SporeZone2')
        addSound(nil, client_player:getX(), client_player:getY(), client_player:getZ(), 7, 7)
        return
    end



    --- CLOSE TO A SPORE ZONE ---

    -- detection radius
    local radius = TLOU_Spores.SCANNERS_VALID_FOR_SPORE_DETECTION[scanner:getFullType()]

    -- get player coordinates
    local p_x = client_player:getX()
    local p_y = client_player:getY()
    local p_z = client_player:getZ()

    -- makes sure the code doesn't do weird shit when at the world height limit
    -- to check a floor above and below
    local min_h = p_z - 1
    min_h = min_h < 0 and 0 or min_h > 7 and 7 or min_h
    local max_h = p_z + 1
    max_h = max_h < 0 and 0 or max_h > 7 and 7 or max_h

    -- retrieve nearest spore zone square
    local _,dist = DoggyAPI_FINDERS.FindNearestValidSquare(p_x,p_y,radius,min_h,max_h,DoggyAPI_FINDERS.CIRCULAR_OUTWARD_DIRECTIONS,TLOU_Spores.IsSquareSporeZone)

    -- check if something is detected
    if dist then
        -- check if should bip
        local lastBip = TLOU_Spores.lastBip
        local shouldBip = true
        if lastBip then
            local bipTime = lastBip.time
            local diffTime = current_time - bipTime
            dist = dist - dist%1
            local timeToBip = math.log(dist)^2/2
            if diffTime < timeToBip then
                shouldBip = false
            end
        end

        if shouldBip then
            emitter:playSound('SporesScanner_SporeZone1')
            addSound(nil, client_player:getX(), client_player:getY(), client_player:getZ(), 7, 7)
            TLOU_Spores.lastBip = {time = current_time, dist = dist}
        end
    elseif TLOU_Spores.lastBip then
        TLOU_Spores.lastBip = nil
    end
end

