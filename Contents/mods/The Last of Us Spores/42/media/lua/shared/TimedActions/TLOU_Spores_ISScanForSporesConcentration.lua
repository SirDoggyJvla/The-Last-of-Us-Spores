--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Defines the timed action of replacing the battery of the InfectionScanner.

]]--
--[[ ================================================ ]]--

require "TimedActions/ISBaseTimedAction"

TLOU_Spores_ISScanForSporesConcentration = ISBaseTimedAction:derive("TLOU_Spores_ISScanForSporesConcentration")

--- CACHING
--- -- module
local TLOU_Spores = require "TLOU_Spores_module"

-- randomness
local GENERAL_RANDOM = newrandom()

function TLOU_Spores_ISScanForSporesConcentration:isValid()
	-- local scanner = self.scanner
	-- return scanner:getUseDelta() > 0 and scanner:isActivated()
	return true
end

function TLOU_Spores_ISScanForSporesConcentration:waitToStart()
	return false
end

function TLOU_Spores_ISScanForSporesConcentration:update()
	if os.time() - self.real_time < 1.4 then return end

	self:forceComplete()
end

function TLOU_Spores_ISScanForSporesConcentration:start()
	local character = self.character

	-- play sound of the scanner (automatically synced)
	character:getEmitter():playSound('SporesScanner_run')
	addSound(nil, character:getX(), character:getY(), character:getZ(), 7, 7)
end

function TLOU_Spores_ISScanForSporesConcentration:stop()
	ISBaseTimedAction.stop(self);
end

function TLOU_Spores_ISScanForSporesConcentration:perform()
	local character = self.character
	local scanner = self.scanner

	local square = character:getSquare()
    if not square then return end

    local chunk = square:getChunk()
    if not chunk then return end

	local spore_concentration = TLOU_Spores.GetChunkSporeConcentration(chunk)

	local concentrationPrecision = self.concentrationPrecision
	local reading = spore_concentration + GENERAL_RANDOM:random(-concentrationPrecision,concentrationPrecision)
	reading = math.max(0,math.min(100,reading))
	character:addLineChatElement(string.format(getText("IGUI_TLOU_Spores_ConcentrationReadings"),reading))

	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function TLOU_Spores_ISScanForSporesConcentration:new(character,scanner,real_time,concentrationPrecision)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.stopOnWalk = false
	o.stopOnRun = true
	o.maxTime = -1

	-- custom fields
	o.real_time = real_time
	o.scanner = scanner
	o.concentrationPrecision = concentrationPrecision

	return o
end
