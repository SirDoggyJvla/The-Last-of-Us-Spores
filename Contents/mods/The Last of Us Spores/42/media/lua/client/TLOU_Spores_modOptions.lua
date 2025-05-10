--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Core of ZomboidForge

]]--
--[[ ================================================ ]]--

-- requirements
local TLOU_Spores = require "TLOU_Spores_module"
local OVERLAY_OPTIONS = TLOU_Spores.OVERLAY_OPTIONS
local CONFIGS = TLOU_Spores.CONFIGS

local options = PZAPI.ModOptions:create("TLOU_Spores", getText("Sandbox_TLOU_Spores"))

--- OVERLAY ---
options:addSeparator()
options:addTitle(getText("IGUI_TLOU_Spores_OverlaySettings"))
options:addDescription(getText("IGUI_TLOU_Spores_OverlaySettings_description"))

-- MOVEMENT
options:addTickBox(
    "OverlayMovement",
    getText("IGUI_TLOU_Spores_OverlaySettings_Movement"),
    true,
    getText("IGUI_TLOU_Spores_OverlaySettings_Movement_tooltip")
)

-- OVERLAY COLORS
local UNIQUE_OVERLAY_COLORS = table.newarray({"yellow"}) -- yellow is the default color, so place it first in the table
for color,_ in pairs(OVERLAY_OPTIONS) do
    if color ~= "yellow" then
        table.insert(UNIQUE_OVERLAY_COLORS,color)
    end
end

TLOU_Spores.UNIQUE_OVERLAY_COLORS = UNIQUE_OVERLAY_COLORS

local comboBox = options:addComboBox("OverlayColor",getText("IGUI_TLOU_Spores_OverlaySettings_Color"),getText("IGUI_TLOU_Spores_OverlaySettings_Color_tooltip"))
comboBox:addItem(getText("IGUI_TLOU_Spores_Colors_"..tostring(UNIQUE_OVERLAY_COLORS[1])),true) -- add first in the list as default
for i = 2,#UNIQUE_OVERLAY_COLORS do
    comboBox:addItem(getText("IGUI_TLOU_Spores_Colors_"..tostring(UNIQUE_OVERLAY_COLORS[i]))) -- add the other options
end



-- This is a helper function that will automatically populate the "config" table.
--- Retrieve each option as: config["ID"]
options.apply = function(self)
    for k,v in pairs(self.dict) do
        if v.type == "multipletickbox" then
            for i=1, #v.values do
                CONFIGS[(k.."_"..tostring(i))] = v:getValue(i)
            end
        elseif v.type ~= "button" then
            CONFIGS[k] = v:getValue()
        end
    end
end

Events.OnMainMenuEnter.Add(function()
    options:apply()
end)