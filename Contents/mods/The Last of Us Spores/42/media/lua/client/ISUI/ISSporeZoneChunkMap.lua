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
    self:drawTextureScaled(self.texture, 0 , 0, self.new_w, self.new_h, 1, 1, 1, 1)
    if not self.limitedUserMode then
        self:drawText("Noise map inspector",100,0,1,1,1,1, UIFont.Large) -- You can put it in render() too
    end
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
    local limitedUserMode = self.limitedUserMode

    --- TEXTURES ---

    local uiSize,quit_x,quit_y,quit_w,quit_h
    local grid_corner_UI = self.grid_corner_UI
    if limitedUserMode then
        uiSize = grid_corner_UI.grid_size
        local quit_button = self.quit_button
        quit_x = quit_button.x
        quit_y = quit_button.y
        quit_w = quit_button.w
        quit_h = quit_button.h
    else
        uiSize = 500
        quit_x = 0
        quit_y = 0
        quit_w = BUTTON_WDT
        quit_h = BUTTON_HGT
    end

    --- CREATE GRID MAP VIEW ---
    self.mapPanel = TLOU_Spores.GridMapSporeZone:new(grid_corner_UI.x, grid_corner_UI.y, uiSize, self.maxMapRange, limitedUserMode)
	self.mapPanel:initialise();
	self.mapPanel:instantiate();
	self.mapPanel:setAnchorLeft(false);
	self.mapPanel:setAnchorRight(true);
	self:addChild(self.mapPanel)

    --- CLOSE BUTTON ---
    local _, closeButton = ISDebugUtils.addButton(self,"close",quit_x,quit_y, quit_w,quit_h, "Close", ISSporeZoneChunkMap.onClickClose)
    self.closeButton = closeButton

    if limitedUserMode then
        closeButton.backgroundColor.a = 0
        closeButton.borderColor = {r=1, g=0, b=0, a=1}
        closeButton.title = nil
    end

    if not limitedUserMode then
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
end

function ISSporeZoneChunkMap:new(x, y, maxMapRange, limitedUserMode, scanner)
    local width = 550
    local height = limitedUserMode and 550 or 700

    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self


    -- textures
    if scanner then
        local textureBackground = TLOU_Spores.SCANNERS_UI_TEXTURE[scanner:getFullType()]

        -- get texture
        local texture = textureBackground.texture
        o.texture = texture
        o.texture_w = texture:getWidth()
        o.texture_h = texture:getHeight()

        -- define new UI size limits
        o.new_w = 300
        local ratio = o.new_w / o.texture_w
        o.ratio = ratio
        o.new_h = math.floor(o.texture_h * ratio)

        -- grid coordinates
        local corner_1 = textureBackground.grid_corner_1
        local corner_2 = textureBackground.grid_corner_2
        local grid_corner_UI = {x = corner_1.x * ratio, y = corner_1.y * ratio}
        grid_corner_UI.grid_size = ((corner_2.x - corner_1.x) + (corner_2.y - corner_1.y)) * ratio / 2
        o.grid_corner_UI = grid_corner_UI

        -- quit button coordinates
        local quit_button_1 = textureBackground.quit_button_corner_1
        local quit_button_2 = textureBackground.quit_button_corner_2
        o.quit_button = {x = quit_button_1.x * ratio, y = quit_button_1.y * ratio, w = (quit_button_2.x - quit_button_1.x) * ratio, h = (quit_button_2.y - quit_button_1.y) * ratio}

        -- window size
        o.width = o.new_w
        o.height = o.new_h
    end

    -- parameters
    -- o.ChunkSizeInSquares = IsoChunkMap.ChunkSizeInSquares
    o.title = getText("Spore zone manager")
	o.moveWithMouse = true
	-- o:setResizable(true)

    o.maxMapRange = maxMapRange
    o.limitedUserMode = limitedUserMode

    if limitedUserMode then
        o.borderColor = {r=0.4, g=0.4, b=0.4, a=0}
        o.backgroundColor = {r=0, g=0, b=0, a=0}
    else
        o.backgroundColor.a = 0
    end

    return o
end