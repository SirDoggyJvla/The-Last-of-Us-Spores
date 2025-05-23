--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Debuging tools used for TLOU Spores

]]--
--[[ ================================================ ]]--

-- skip non debug clients
if not isDebugEnabled() then return end

-- requirements
local TLOU_Spores = require "TLOU_Spores_module"

-- DoggyAPI
local WorldTools = require "DoggyTools/WorldTools"

--- CACHING
-- player
local client_player = getPlayer()


TLOU_Spores.DEBUG.OnFillWorldObjectContextMenu = function(playerIndex, context, worldObjects, test)
    -- access the first square found
    local worldObject,square
    for i = 1,#worldObjects do
        worldObject = worldObjects[i]
        square = worldObject:getSquare()
        if square then
            break
        end
    end

    -- skip if no square found
    if not square then return end

    -- create the submenu for TLOU Spores debug
    local option = context:addOptionOnTop("TLOU Spores: Debug")
    local subMenu = context:getNew(context)
    context:addSubMenu(option, subMenu)

    option.iconTexture = getTexture("media/ui/spore_icon.png")

    --- ZOMBIE PANNEL ---
    option = subMenu:addOptionOnTop("Highlight squares")
    local menu_SquareHighlight = subMenu:getNew(subMenu)
    context:addSubMenu(option, menu_SquareHighlight)

    --- ACTIVATE SQUARE HIGHLIGHT
    option = menu_SquareHighlight:addOption("Activate square highlight",nil,
    function() TLOU_Spores.DEBUG.highlightSquaresBoolean = TLOU_Spores.SwapBoolean(TLOU_Spores.DEBUG.highlightSquaresBoolean) end)
    subMenu:setOptionChecked(option, TLOU_Spores.DEBUG.highlightSquaresBoolean)

    --- RESET HIGHLIGHT SQUARES ---
    menu_SquareHighlight:addOption("Reset highlighted squares",nil,TLOU_Spores.DEBUG.ResetHighlightSquares)

    -- highlight specific square
    menu_SquareHighlight:addOption("Highlight right clicked square",square,TLOU_Spores.DEBUG.AddHighlightSquare,{r=1,g=1,b=1})

    --- RESET LIST OF SPORE ZONES ---
    subMenu:addOption("Reset spore zones",nil,TLOU_Spores.DEBUG.ResetSporeZones)

    --- SHOW NOISE MAP ---
    subMenu:addOption("Show noise map",nil,TLOU_Spores.DEBUG.ShowNoiseMap)

    --- HIDE NOISE MAP ---
    subMenu:addOption("Hide noise map",nil,function() TLOU_Spores.iSSporeZoneChunkMap:setVisible(false) TLOU_Spores.iSSporeZoneChunkMap:removeFromUIManager() end)

    --- RESET SPORES INFECTION STATUS ---
    subMenu:addOption("Reset spores infection",nil,TLOU_Spores.DEBUG.ResetSporesInfection)

    --- RESET SPORES OVERLAY ---
    subMenu:addOption("Reset spores overlay",nil,TLOU_Spores.DEBUG.ResetSporesOverlay)
end

TLOU_Spores.DEBUG.ResetSporesOverlay = function()
    TLOU_Spores.Active_Spores_Overlay = nil
end

TLOU_Spores.DEBUG.ResetSporeZones = function()
    ModData.remove("DoggyAPI_AlreadyLoadedChunks")
    ModData.remove("TLOU_Spores_buildings")
    ModData.remove("TLOU_Spores_rooms")

    TLOU_Spores.OnInitGlobalModData()
end

TLOU_Spores.DEBUG.ShowNoiseMap = function()
    local x = getCore():getScreenWidth()*0.25 -- Get the screen resolution
    local y = getCore():getScreenHeight()*0.10 -- Get the screen resolution

    TLOU_Spores.iSSporeZoneChunkMap = TLOU_Spores.ISSporeZoneChunkMap:new(x, y)
    TLOU_Spores.iSSporeZoneChunkMap:initialise()
    TLOU_Spores.iSSporeZoneChunkMap:addToUIManager()
end

TLOU_Spores.DEBUG.ResetSporesInfection = function()
    local character = getPlayer()
    local character_modData = character:getModData().TLOU_Spores
    character_modData["infectedBySpores"] = nil
    character_modData["inSpores"] = nil
    character_modData["sporeTimer"] = nil
end

TLOU_Spores.SwapBoolean = function(boolean)
    if boolean then
        return false
    end

    return true
end


--- Based on Rodriguo's work

TLOU_Spores.DEBUG.highlightsSquares = {}

---Add a square to highlight.
---@param square IsoGridSquare
---@param ISColors table
TLOU_Spores.DEBUG.AddHighlightSquare = function(square, ISColors)
    if not square or not ISColors then return end
    table.insert(TLOU_Spores.DEBUG.highlightsSquares, {
        square_x = square:getX(),
        square_y = square:getY(),
        square_z = square:getZ(),
        color = ISColors,
        time = os.time()}
    )
end

TLOU_Spores.DEBUG.OnKeyPressed = function(key)
    if(key == 27) then -- $
    print("pass")
        local building = getPlayer():getBuilding()
        if not building then return end

        local buildingDef = building:getDef()

        TLOU_Spores.RollForSpores(buildingDef,1)
    end
end

TLOU_Spores.DEBUG.OnObjectLeftMouseButtonDown = function(object,x,y)
    if true then return end
    local building = getPlayer():getBuilding()
    if not building then return end

    local buildingDef = building:getDef()
    TLOU_Spores.RollForSpores(buildingDef)
end

---Render squares in the list and remove them based on conditions.
TLOU_Spores.DEBUG.RenderHighLights = function()
    client_player = client_player or getPlayer()
    local highlightsSquares = TLOU_Spores.DEBUG.highlightsSquares
    local size = #highlightsSquares
    if #highlightsSquares == 0 then return end
    for i = size,1,-1 do repeat
        local highlight = highlightsSquares[i]
        -- if highlight.square_z ~= getPlayer():getZ() then break end
        local square = getSquare(highlight.square_x, highlight.square_y, highlight.square_z)
        if square ~= nil and instanceof(square, "IsoGridSquare") then
            local x,y,z = square:getX(), square:getY(), square:getZ()
            local z_p = client_player:getZ()
            local r,g,b = highlight.color.r, highlight.color.g, highlight.color.b

            -- check since how long this square has been highlighted
            local time = os.time() - highlight.time
            if time > 60 then
                -- table.remove(highlightsSquares, i)
            end

            -- calculate alpha
            local r = 0.5
            if z_p > z then
                r = 0.5 - (z_p - z) * 0.5
                if r < 0 then r = 0 end
            elseif z_p < z then
                r = 0.5 + (z - z_p) * 0.5
                if r > 1 then r = 1 end
            end
            g = 0
            b = 0

            local floorSprite = IsoSprite.new()
            floorSprite:LoadFramesNoDirPageSimple('media/ui/FloorTileCursor.png')
            floorSprite:RenderGhostTileColor(x, y, z, r, g, b, 1)

            -- verify if the square should stop blinking
        else
            -- table.remove(highlightsSquares, i)
        end
    until true end
end

TLOU_Spores.DEBUG.ResetHighlightSquares = function()
    TLOU_Spores.DEBUG.highlightsSquares = {}
end


