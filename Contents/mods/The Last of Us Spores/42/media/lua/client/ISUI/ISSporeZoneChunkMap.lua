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



function ISSporeZoneChunkMap:zoomIn()
    self.mapPanel:onMouseWheel(-1,true)
end

function ISSporeZoneChunkMap:zoomOut()
    self.mapPanel:onMouseWheel(1,true)
end


--[[ ================================================ ]]--
--- RENDERING ---
--[[ ================================================ ]]--

function ISSporeZoneChunkMap:prerender() -- Call before render, it's for harder stuff that need init, ect
    ISPanel.prerender(self)
    if not self.limitedUserMode then
        self:drawText("Spore concentration noise map inspector",100,0,1,1,1,1, UIFont.Large) -- You can put it in render() too
    else
        self:drawTextureScaled(self.texture, 0 , 0, self.new_w, self.new_h, 1, 1, 1, 1)
    end

    -- close UI if scanner is not charged
    local scanner = self.scanner
    if not scanner:isActivated() or scanner:getCurrentUsesFloat() <= 0 then
        self:close()
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

    --- CLOSE BUTTON ---

    -- define coordinates and dimensions
    local quit_button = self.quit_button
    local quit_x = limitedUserMode and quit_button.x or 0
    local quit_y = limitedUserMode and quit_button.y or 0
    local quit_w = limitedUserMode and quit_button.w or BUTTON_WDT
    local quit_h = limitedUserMode and quit_button.h or BUTTON_HGT

    -- create button
    local _, closeButton = ISDebugUtils.addButton(self,"close",quit_x,quit_y, quit_w,quit_h, "Close", ISSporeZoneChunkMap.onClickClose)
    self.closeButton = closeButton

    if limitedUserMode then
        -- make button partially visible
        closeButton.backgroundColor.a = 0
        closeButton.borderColor = {r=1, g=0, b=0, a=1}
        closeButton.title = nil
    end




    --- CREATE GRID MAP VIEW ---

    local grid_corner_UI = self.grid_corner_UI
    local uiSize = limitedUserMode and grid_corner_UI.grid_size or 500
    local grid_x = limitedUserMode and grid_corner_UI.x or 25
    local grid_y = limitedUserMode and grid_corner_UI.y or BUTTON_HGT + UI_BORDER_SPACING

    self.mapPanel = TLOU_Spores.GridMapSporeZone:new(grid_x, grid_y, uiSize, self.maxMapRange, limitedUserMode)
	self.mapPanel:initialise();
	self.mapPanel:instantiate();
	self.mapPanel:setAnchorLeft(false);
	self.mapPanel:setAnchorRight(true);
	self:addChild(self.mapPanel)




    --- NOISE MAP TOOLS
    if not limitedUserMode then
        --- NOISE THRESHOLD SLIDER ---
        self:addSlider("noiseThreshold","Noise threshold",x,y,0,1,0.1,0.1,TLOU_Spores.NOISE_SPORE_THRESHOLD,ISSporeZoneChunkMap.onNoiseThresholdSliderChange)

        --- NOISE SCALE SLIDER ---
        self:addSlider("noiseScale","Noise scale",x,y + BUTTON_HGT + UI_BORDER_SPACING,0,100,1,1,TLOU_Spores.NOISE_MAP_SCALE,ISSporeZoneChunkMap.onNoiseScaleSliderChange)

        --- MINIMUM NOISE VECTOR VALUE SLIDER ---
        self:addSlider("minimumNoiseVectorValue","Minimum noise vector value",x,y + BUTTON_HGT*2 + UI_BORDER_SPACING*2,-5,5,1,1,TLOU_Spores.MINIMUM_NOISE_VECTOR_VALUE,ISSporeZoneChunkMap.onMinimumNoiseVectorValueSliderChange)

        --- MAXIMUM NOISE VECTOR VALUE SLIDER ---
        self:addSlider("maximumNoiseVectorValue","Maximum noise vector value",x,y + BUTTON_HGT*3 + UI_BORDER_SPACING*3,-5,5,1,1,TLOU_Spores.MAXIMUM_NOISE_VECTOR_VALUE,ISSporeZoneChunkMap.onMaximumNoiseVectorValueSliderChange)


        -- --- GRID BOOLEAN ---
        -- self.mapPanel.gridBoolean = ISTickBox:new(450,5, 200, BUTTON_HGT,"Grid: ",self)
        -- self.mapPanel.gridBoolean:initialise()
        -- self:addChild(self.mapPanel.gridBoolean)
        -- self.mapPanel.gridBoolean:addOption(getText("Grid: "));
        -- self.mapPanel.gridBoolean.selected[1] = true



    --- LIMITED USER MODE ---
    else
        -- make close button partially visible
        closeButton.backgroundColor.a = 0
        closeButton.borderColor = {r=1, g=1, b=1, a=1}
        closeButton.title = nil


        --- ZOOM BUTTONS

        -- zoom in button
        local zoom_in_button = self.zoom_in_button
        local zoom_in_x = limitedUserMode and zoom_in_button.x or 0
        local zoom_in_y = limitedUserMode and zoom_in_button.y or BUTTON_HGT + UI_BORDER_SPACING
        local zoom_in_w = limitedUserMode and zoom_in_button.w or BUTTON_WDT
        local zoom_in_h = limitedUserMode and zoom_in_button.h or BUTTON_HGT

        -- create button
        local _, zoomInButton = ISDebugUtils.addButton(self,"zoomIn",zoom_in_x,zoom_in_y, zoom_in_w,zoom_in_h, "+", self.zoomIn)
        self.zoomInButton = zoomInButton

        zoomInButton.backgroundColor.a = 0
        zoomInButton.borderColor = {r=1, g=1, b=1, a=1}
        zoomInButton.title = nil

        -- zoom out button
        local zoom_out_button = self.zoom_out_button
        local zoom_out_x = limitedUserMode and zoom_out_button.x or 0
        local zoom_out_y = limitedUserMode and zoom_out_button.y or BUTTON_HGT*2 + UI_BORDER_SPACING*2
        local zoom_out_w = limitedUserMode and zoom_out_button.w or BUTTON_WDT
        local zoom_out_h = limitedUserMode and zoom_out_button.h or BUTTON_HGT

        -- create button
        local _, zoomOutButton = ISDebugUtils.addButton(self,"zoomOut",zoom_out_x,zoom_out_y, zoom_out_w,zoom_out_h, "-", self.zoomOut)
        self.zoomOutButton = zoomOutButton

        zoomOutButton.backgroundColor.a = 0
        zoomOutButton.borderColor = {r=1, g=1, b=1, a=1}
        zoomOutButton.title = nil

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


        -- zoom in button coordinates
        local zoom_in_button_1 = textureBackground.zoom_in_button_corner_1
        local zoom_in_button_2 = textureBackground.zoom_in_button_corner_2
        o.zoom_in_button = {x = zoom_in_button_1.x * ratio, y = zoom_in_button_1.y * ratio, w = (zoom_in_button_2.x - zoom_in_button_1.x) * ratio, h = (zoom_in_button_2.y - zoom_in_button_1.y) * ratio}

        -- zoom out button coordinates
        local zoom_out_button_1 = textureBackground.zoom_out_button_corner_1
        local zoom_out_button_2 = textureBackground.zoom_out_button_corner_2
        o.zoom_out_button = {x = zoom_out_button_1.x * ratio, y = zoom_out_button_1.y * ratio, w = (zoom_out_button_2.x - zoom_out_button_1.x) * ratio, h = (zoom_out_button_2.y - zoom_out_button_1.y) * ratio}

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
    o.scanner = scanner

    if limitedUserMode then
        o.borderColor = {r=0.4, g=0.4, b=0.4, a=0}
        o.backgroundColor = {r=0, g=0, b=0, a=0}
    else
        o.backgroundColor.a = 0.8
    end

    return o
end