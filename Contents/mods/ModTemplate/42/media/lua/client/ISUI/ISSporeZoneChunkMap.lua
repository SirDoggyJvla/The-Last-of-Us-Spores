--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

UI for spore noise map file of TLOU Spores.

]]--
--[[ ================================================ ]]--


--- CACHING
-- module
local TLOU_Spores = require "TLOU_Spores_module"

-- ui
local UI_BORDER_SPACING = 10
local BUTTON_WDT = 75
local BUTTON_HGT = getTextManager():getFontHeight(UIFont.Small) + 2 * 4



--- REQUIREMENTS
require "ISUI/ISPanel"

TLOU_Spores.ISSporeZoneChunkMap = ISPanel:derive("ISSporeZoneChunkMap")
local ISSporeZoneChunkMap = TLOU_Spores.ISSporeZoneChunkMap


--[[ ================================================ ]]--
--- BUTTONS AND SLIDERS ---
--[[ ================================================ ]]--

function ISSporeZoneChunkMap:onClickClose() self:close() end

function ISSporeZoneChunkMap:onNoiseThresholdSliderChange(_newval, _slider)
    if _newval == self.NOISE_SPORE_THRESHOLD then return end
    self.mapPanel.NOISE_SPORE_THRESHOLD = _newval
    if _slider.valueLabel then
		_slider.valueLabel:setName(ISDebugUtils.printval(_newval,3));
	end
    self.mapPanel.sporeZones = {}
end

function ISSporeZoneChunkMap:onNoiseScaleSliderChange(_newval, _slider)
    if _newval == self.NOISE_MAP_SCALE then return end
    self.mapPanel.NOISE_MAP_SCALE = _newval
    if _slider.valueLabel then
        _slider.valueLabel:setName(ISDebugUtils.printval(_newval,3));
    end
    self.mapPanel.sporeZones = {}
end

function ISSporeZoneChunkMap:onMinimumNoiseVectorValueSliderChange(_newval, _slider)
    if _newval == self.MINIMUM_NOISE_VECTOR_VALUE then return end
    self.mapPanel.MINIMUM_NOISE_VECTOR_VALUE = _newval
    if _slider.valueLabel then
        _slider.valueLabel:setName(ISDebugUtils.printval(_newval,3));
    end
    self.mapPanel.sporeZones = {}
end

function ISSporeZoneChunkMap:onMaximumNoiseVectorValueSliderChange(_newval, _slider)
    if _newval == self.MAXIMUM_NOISE_VECTOR_VALUE then return end
    self.mapPanel.MAXIMUM_NOISE_VECTOR_VALUE = _newval
    if _slider.valueLabel then
        _slider.valueLabel:setName(ISDebugUtils.printval(_newval,3));
    end
    self.mapPanel.sporeZones = {}
end


---Add a slider which is normalized.
---@param id string
---@param name string
---@param x integer
---@param y integer
---@param min number
---@param max number
---@param step number
---@param shift number
---@param default number
---@param sliderChangeFct function
function ISSporeZoneChunkMap:addSlider(id,name,x,y,min,max,step,shift,default,sliderChangeFct)
    local font = UIFont.Small

    _,self.maximumNoiseVectorValueSliderTitle = ISDebugUtils.addLabel(self,id,x,y,getText(name)..": ", font, true)
    _,self.maximumNoiseVectorValueSliderLabel = ISDebugUtils.addLabel(self,id,x+175,y,tostring(default), font, false)
    _,self.maximumNoiseVectorValueSlider = ISDebugUtils.addSlider(self, "maximumNoiseVectorValue", self.maximumNoiseVectorValueSliderLabel:getRight() + UI_BORDER_SPACING, y, 200, BUTTON_HGT, sliderChangeFct)
    self.maximumNoiseVectorValueSlider.pretext = "Maximum noise vector value: "
    self.maximumNoiseVectorValueSlider.valueLabel = self.maximumNoiseVectorValueSliderLabel
    self.maximumNoiseVectorValueSlider:setValues(min, max, step, shift, true)
    self.maximumNoiseVectorValueSlider.currentValue = default
end


--[[ ================================================ ]]--
--- RENDERING ---
--[[ ================================================ ]]--

function ISSporeZoneChunkMap:prerender() -- Call before render, it's for harder stuff that need init, ect
    ISPanel.prerender(self)
    self:drawText("Noise map inspector",100,0,1,1,1,1, UIFont.Large) -- You can put it in render() too


end

function ISSporeZoneChunkMap:render() -- Use to render text and other
end






--[[ ================================================ ]]--
--- UI CREATION ---
--[[ ================================================ ]]--

function ISSporeZoneChunkMap:initialise()
    ISPanel.initialise(self)
    self:create()
end

function ISSporeZoneChunkMap:create() -- Use to make the elements
    local x,y = 80,550

    --- CREATE GRID MAP VIEW ---
    self.mapPanel = TLOU_Spores.GridMapSporeZone:new(25, 40, 500, 500)
	self.mapPanel:initialise();
	self.mapPanel:instantiate();
	self.mapPanel:setAnchorLeft(false);
	self.mapPanel:setAnchorRight(true);
	self:addChild(self.mapPanel)

    --- CLOSE BUTTON ---
    local _, closeButton = ISDebugUtils.addButton(self,"close",0,0, BUTTON_WDT,BUTTON_HGT, "Close", ISSporeZoneChunkMap.onClickClose)
    self.closeButton = closeButton

    --- NOISE THRESHOLD SLIDER ---
    self:addSlider("noiseThreshold","Noise threshold",x,y,0,1,0.1,0.1,TLOU_Spores.NOISE_SPORE_THRESHOLD,ISSporeZoneChunkMap.onNoiseThresholdSliderChange)

    --- NOISE SCALE SLIDER ---
    self:addSlider("noiseScale","Noise scale",x,y + BUTTON_HGT + UI_BORDER_SPACING,0,100,1,1,TLOU_Spores.NOISE_MAP_SCALE,ISSporeZoneChunkMap.onNoiseScaleSliderChange)

    --- MINIMUM NOISE VECTOR VALUE SLIDER ---
    self:addSlider("minimumNoiseVectorValue","Minimum noise vector value",x,y + BUTTON_HGT*2 + UI_BORDER_SPACING*2,-5,5,1,1,TLOU_Spores.MINIMUM_NOISE_VECTOR_VALUE,ISSporeZoneChunkMap.onMinimumNoiseVectorValueSliderChange)

    --- MAXIMUM NOISE VECTOR VALUE SLIDER ---
    self:addSlider("maximumNoiseVectorValue","Maximum noise vector value",x,y + BUTTON_HGT*3 + UI_BORDER_SPACING*3,-5,5,1,1,TLOU_Spores.MAXIMUM_NOISE_VECTOR_VALUE,ISSporeZoneChunkMap.onMaximumNoiseVectorValueSliderChange)

    --- GRID BOOLEAN ---
    self.mapPanel.gridBoolean = ISTickBox:new(400,5, 200, BUTTON_HGT,"Grid: ",self)
    self.mapPanel.gridBoolean:initialise()
	self:addChild(self.mapPanel.gridBoolean)
    self.mapPanel.gridBoolean:addOption(getText("Grid: "));
    self.mapPanel.gridBoolean.selected[1] = true
end

function ISSporeZoneChunkMap:new(x, y)
    local width = 550
    local height = 700

    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    self.width = width
    self.height = height

    -- parameters
    -- o.ChunkSizeInSquares = IsoChunkMap.ChunkSizeInSquares
    o.title = getText("Spore zone manager")
	o.moveWithMouse = true
	-- o:setResizable(true)
    o.backgroundColor.a = 0.8

    return o
end