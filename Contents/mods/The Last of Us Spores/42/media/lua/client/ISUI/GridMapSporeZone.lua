--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

GridMapSporeZone file of TLOU Spores. Used to show a map of spore zones.

]]--
--[[ ================================================ ]]--

--- REQUIREMENTS
local TLOU_Spores = require "TLOU_Spores_module"
local DoggyAPI = require "DoggyAPI_module"
local DoggyAPI_NOISEMAP = DoggyAPI.NOISEMAP

-- vanilla
require "ISUI/ISPanel"

--- CACHING
-- noise map
local SEEDS = TLOU_Spores.SEEDS

TLOU_Spores.GridMapSporeZone = ISUIElement:derive("GridMapSporeZone")
local GridMapSporeZone = TLOU_Spores.GridMapSporeZone

function GridMapSporeZone:initialise()
    ISPanel.initialise(self);
    self:create();
end

function GridMapSporeZone:prerender() -- Call before render, it's for harder stuff that need init, ect
    local player = getPlayer()
    local chunk = player:getChunk()
    if not chunk then return end

    -- get dimensions
    local center_wx = self.center_wx
    local center_wy = self.center_wy
    local scale = self.scale
	local corner_x = self.corner_x
	local corner_y = self.corner_y

	-- get offset
    local offsetX = self.offsetX
	offsetX = offsetX - offsetX % 1
    local offsetY = self.offsetY
	offsetY = offsetY - offsetY % 1

    -- get min and max grid chunks
    local min_wx = center_wx - scale + offsetX
    local max_wx = center_wx + scale + offsetX
    local min_wy = center_wy - scale + offsetY
    local max_wy = center_wy + scale + offsetY

	local total_size = self.total_size
    local size = total_size/(scale*2+1)

	-- cache spore table
    local sporeZones = self.sporeZones
	local grid = self.gridBoolean.selected[1]

	-- spore colors
	local sporeColor = self.sporeColor
	local sporeColorR = sporeColor.r
	local sporeColorG = sporeColor.g
	local sporeColorB = sporeColor.b

	-- noise map parameters
	local NOISE_MAP_SCALE = self.NOISE_MAP_SCALE
	local MINIMUM_NOISE_VECTOR_VALUE = self.MINIMUM_NOISE_VECTOR_VALUE
	local MAXIMUM_NOISE_VECTOR_VALUE = self.MAXIMUM_NOISE_VECTOR_VALUE

    local x = corner_x
    for wx = min_wx, max_wx do
        local y = corner_y
        for wy = min_wy, max_wy do
            local chunkData = sporeZones[wx] and sporeZones[wx][wy]
            if chunkData then
				local spore_concentration = chunkData.spore_concentration
				if spore_concentration > 0 then
                	self:drawRect(x, y, size, size, spore_concentration, sporeColorR, sporeColorG, sporeColorB)
				end
            else
                self:populateSporeZones(wx,wy, NOISE_MAP_SCALE, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE)
            end

            y = y + size
        end

		-- draw grid
		if grid then
			if x ~= corner_x then
				self:drawRectBorder(x,corner_y,0,total_size,0.2,1,1,1)
			end
			local x2y = x - corner_x + corner_y
			if x2y ~= corner_y then
				self:drawRectBorder(corner_x,x2y,total_size,0,0.2,1,1,1)
			end
		end

        x = x + size
    end


    -- draw player chunk
    local player_chunk = player:getChunk()
    local player_wx = player_chunk.wx
    local player_wy = player_chunk.wy
    if player_wx >= min_wx and player_wx <= max_wx and player_wy >= min_wy and player_wy <= max_wy then
        local x = corner_x + (player_wx - min_wx) * size
        local y = corner_y + (player_wy - min_wy) * size
        self:drawRectBorder(x, y, size, size, 1, 1, 0, 0)
    end

    self:drawRectBorder(corner_x, corner_y, total_size, total_size, 1, 1, 1, 1)
end

function GridMapSporeZone:render() -- Use to render text and other
end



--[[ ================================================ ]]--
--- RETRIEVE SPORE ZONES ---
--[[ ================================================ ]]--

function GridMapSporeZone:populateSporeZones(wx, wy, NOISE_MAP_SCALE, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE)
	local sporeZones = self.sporeZones
    -- get building spore map concentration
    local noiseValue = DoggyAPI_NOISEMAP.getNoiseValue(
        wx, wy,
        NOISE_MAP_SCALE,
        MINIMUM_NOISE_VECTOR_VALUE,MAXIMUM_NOISE_VECTOR_VALUE,
        SEEDS.x_seed,SEEDS.y_seed,SEEDS.offset_seed
    )
    sporeZones[wx] = sporeZones[wx] or {}
    -- get concentration
    local spore_concentration = noiseValue - self.NOISE_SPORE_THRESHOLD
    local sporeZone = spore_concentration > 0

    sporeZones[wx][wy] = {
        noiseValue = noiseValue,
        sporeZone = sporeZone,
        spore_concentration = spore_concentration,
    }
end

function GridMapSporeZone:redefineCenterPoint()
	local player = getPlayer()
	if player then
		local player_chunk = player:getChunk()
		self.center_wx = player_chunk.wx
		self.center_wy = player_chunk.wy
	else
		self.center_wx = 100
		self.center_wy = 100
	end
end



--[[ ================================================ ]]--
--- DRAGGING ON MAP ---
--[[ ================================================ ]]--

function GridMapSporeZone:onMouseDown(x, y)
	self.dragging = true
	self.dragMoved = false
	self.dragStartX = x
	self.dragStartY = y
	self.start_offsetX = self.offsetX
	self.start_offsetY = self.offsetY
	return true
end

function GridMapSporeZone:onMouseMove(dx, dy)
	if self.dragging then
		local mouseX = self:getMouseX()
		local mouseY = self:getMouseY()
		local size = self.total_size/(self.scale*2+1)
		dx = (mouseX - self.dragStartX) / size
		dy = (mouseY - self.dragStartY) / size
		self.offsetX = self.start_offsetX - dx
		self.offsetY = self.start_offsetY - dy
	end

	return true
end

function GridMapSporeZone:onMouseMoveOutside(dx, dy)
	return self:onMouseMove(dx, dy)
end

function GridMapSporeZone:onMouseUp(x, y)
	self.dragging = false
	return true
end

function GridMapSporeZone:onMouseUpOutside(x, y)
	self.dragging = false
	return true
end

function GridMapSporeZone:onMouseDoubleClick(x, y)
	self.offsetX = 0
	self.offsetY = 0
	self:redefineCenterPoint()
end

function GridMapSporeZone:onMouseWheel(del)
	self.scale = math.max(self.scale + del,0)
	return true
end




--[[ ================================================ ]]--
--- UI CREATION ---
--[[ ================================================ ]]--

function GridMapSporeZone:create() -- Use to make the elements
	--- UI POSITIONS ---
	self.total_size = 500
	self.corner_x = 0
	self.corner_y = 0

	--- DEFAULT COLORS ---
	self.sporeColor = {r=1,g=0.80,b=0}

	--- SPORE ZONE ---
	self.sporeZones = {}
	self.offsetX = 0
	self.offsetY = 0
	self.scale = 10
	self.NOISE_SPORE_THRESHOLD = TLOU_Spores.NOISE_SPORE_THRESHOLD
	self.NOISE_MAP_SCALE = TLOU_Spores.NOISE_MAP_SCALE
	self.MINIMUM_NOISE_VECTOR_VALUE = TLOU_Spores.MINIMUM_NOISE_VECTOR_VALUE
	self.MAXIMUM_NOISE_VECTOR_VALUE = TLOU_Spores.MAXIMUM_NOISE_VECTOR_VALUE

	--- GET DEFAULT MAP COORDINATES ---
	self:redefineCenterPoint()
end

function GridMapSporeZone:new(x, y, width, height)
    local o = {};
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    return o;
end