--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Patch SandboxOptions.lua to connect to the TLOU Spores panel and add new buttons to it.

]]--
--[[ ================================================ ]]--

--- CACHING
-- module
local TLOU_Spores = require "TLOU_Spores_module"
local CustomizeSandboxOptionPanel = require "DoggyTools/CustomizeSandboxOptionPanel"

-- noise map
local iSSporeZoneChunkMap

-- ui size
local UI_BORDER_SPACING = 10
TLOU_Spores.OnCreateSandboxOptions = function(tlou_spores_panel)
    CustomizeSandboxOptionPanel.SetPanelColor(tlou_spores_panel, {r=1,g=0.80,b=0,a=1}, {r=0.05,g=0.8*0.05,b=0,a=1})

    local x,y,width = CustomizeSandboxOptionPanel.GetTotalOptionDimensions(tlou_spores_panel)

    -- add buttons
    local _, button = ISDebugUtils.addButton(tlou_spores_panel,"noiseMapButton",x,y, width,40, getText("Sandbox_TLOU_Spores_NoiseMapButton"),TLOU_Spores.ShowSandboxOptionsNoiseMap)
    button.backgroundColor = {r=1,g=0.80,b=0,a=0.8}
    button.borderColor = {r=1,g=0.80,b=0,a=1}
    button.tooltip = getText("Sandbox_TLOU_Spores_NoiseMapButton_tooltip")

    -- update scrollbar to take into account new button
    CustomizeSandboxOptionPanel.SetScrollBarHeight(tlou_spores_panel,y+40+UI_BORDER_SPACING)
end



local OnCreateSandboxOptions = require "DoggyEvents/OnCreateSandboxOptions"
OnCreateSandboxOptions.addListener(getText("Sandbox_TLOU_Spores"),TLOU_Spores.OnCreateSandboxOptions)






TLOU_Spores.ShowSandboxOptionsNoiseMap = function()
    local x = getCore():getScreenWidth()*0.25 -- Get the screen resolution
    local y = getCore():getScreenHeight()*0.10 -- Get the screen resolution

    iSSporeZoneChunkMap = TLOU_Spores.ISSporeZoneChunkMap:new(x, y,nil,nil,nil,true)
    iSSporeZoneChunkMap:initialise()
    iSSporeZoneChunkMap:addToUIManager()
end