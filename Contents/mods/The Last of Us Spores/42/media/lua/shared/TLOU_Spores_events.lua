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

-- custom events
local DoggyAPI = require "DoggyAPI_module"
local EVENTS = DoggyAPI.EVENTS

require "DoggyAPI_LoadNewChunk"

-- game starting
Events.OnInitGlobalModData.Add(TLOU_Spores.OnInitGlobalModData)

-- new save
Events.OnNewGame.Add(TLOU_Spores.OnNewGame)

-- new chunk getting loaded in
EVENTS.LoadNewChunk:addListener(TLOU_Spores.LoadNewChunk)

-- every ticks
Events.OnTick.Add(TLOU_Spores.OnTick)

-- existing a save
Events.OnSave.Add(TLOU_Spores.OnSave)

if isDebugEnabled() then
    -- debug
    require "TLOU_Spores_debug"

    Events.OnFillWorldObjectContextMenu.Add(TLOU_Spores.DEBUG.OnFillWorldObjectContextMenu)

    Events.OnPostRender.Add(TLOU_Spores.DEBUG.RenderHighLights)

    Events.OnKeyPressed.Add(TLOU_Spores.DEBUG.OnKeyPressed)
    Events.OnObjectLeftMouseButtonDown.Add(TLOU_Spores.DEBUG.OnObjectLeftMouseButtonDown)
end