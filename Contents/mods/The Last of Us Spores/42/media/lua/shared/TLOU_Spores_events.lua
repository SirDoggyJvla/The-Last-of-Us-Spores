--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Events of TLOU Spores.

]]--
--[[ ================================================ ]]--

-- module
local TLOU_Spores = require "TLOU_Spores_module"
require "TLOU_Spores"
require "TLOU_Spores_UI"

-- game starting
Events.OnInitGlobalModData.Add(TLOU_Spores.OnInitGlobalModData)

-- existing a save
Events.OnSave.Add(TLOU_Spores.OnSave)

-- new save
Events.OnNewGame.Add(TLOU_Spores.OnNewGame)

-- new character created
Events.OnCreatePlayer.Add(TLOU_Spores.OnCreatePlayer)

-- new chunk getting loaded in
local LoadNewChunk = require "DoggyEvents/LoadNewChunk"
LoadNewChunk.Event:addListener(TLOU_Spores.LoadNewChunk)

-- every ticks
Events.OnTick.Add(TLOU_Spores.OnTick)

-- clicking scanner
Events.OnFillInventoryObjectContextMenu.Add(TLOU_Spores.OnFillInventoryObjectContextMenu)

-- UI handler
Events.OnPreUIDraw.Add(TLOU_Spores.OnPreUIDraw)

if isDebugEnabled() then
    -- debug
    require "TLOU_Spores_debug"

    Events.OnFillWorldObjectContextMenu.Add(TLOU_Spores.DEBUG.OnFillWorldObjectContextMenu)

    Events.OnPostRender.Add(TLOU_Spores.DEBUG.RenderHighLights)

    Events.OnKeyPressed.Add(TLOU_Spores.DEBUG.OnKeyPressed)
    Events.OnObjectLeftMouseButtonDown.Add(TLOU_Spores.DEBUG.OnObjectLeftMouseButtonDown)
end