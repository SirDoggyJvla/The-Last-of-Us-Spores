--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Noise map tools of TLOU Spores. Used to calculate a linear interpolation function.

]]--
--[[ ================================================ ]]--

--- CACHING
-- module
local TLOU_Spores = require "TLOU_Spores_module"

-- random
local NOISEMAP_RANDOM = newrandom()

-- seeds
local SEEDS = TLOU_Spores.SEEDS
local X_SEED,Y_SEED,OTHER_SEED


-- Random gradient generator (deterministic using math.randomseed)
---@param x integer
---@param y integer
---@return table
TLOU_Spores.randomGradient = function(x, y, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE)
    X_SEED = X_SEED or SEEDS.x_seed
    Y_SEED = Y_SEED or SEEDS.y_seed
    OTHER_SEED = OTHER_SEED or SEEDS.other_seed

    local seed = x * X_SEED + y * Y_SEED + OTHER_SEED
    NOISEMAP_RANDOM:seed(seed)
    return { -- Random vector
        NOISEMAP_RANDOM:random(MINIMUM_NOISE_VECTOR_VALUE,MAXIMUM_NOISE_VECTOR_VALUE) * 2 - 1,
        NOISEMAP_RANDOM:random(MINIMUM_NOISE_VECTOR_VALUE,MAXIMUM_NOISE_VECTOR_VALUE) * 2 - 1
    }
end

-- Dot product of gradient and distance vector
---@param ix integer
---@param iy integer
---@param x integer
---@param y integer
---@return number
TLOU_Spores.dotGridGradient = function(ix, iy, x, y, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE)
    local gradient = TLOU_Spores.randomGradient(ix, iy, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE)
    return (x - ix) * gradient[1] + (y - iy) * gradient[2]
end

-- Perlin-style 2D noise at specific coordinates
---@param x integer
---@param y integer
---@return number
TLOU_Spores.getNoiseValue = function(x, y,NOISE_MAP_SCALE, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE)
    --- default parameters
    NOISE_MAP_SCALE = NOISE_MAP_SCALE or TLOU_Spores.NOISE_MAP_SCALE
    MINIMUM_NOISE_VECTOR_VALUE = MINIMUM_NOISE_VECTOR_VALUE or TLOU_Spores.MINIMUM_NOISE_VECTOR_VALUE
    MAXIMUM_NOISE_VECTOR_VALUE = MAXIMUM_NOISE_VECTOR_VALUE or TLOU_Spores.MAXIMUM_NOISE_VECTOR_VALUE

    local scaledX = x / NOISE_MAP_SCALE
    local scaledY = y / NOISE_MAP_SCALE

    -- Grid cell coordinates
    local x0 = scaledX - scaledX%1
    local x1 = x0 + 1
    local y0 = scaledY - scaledY%1
    local y1 = y0 + 1

    -- Compute noise values at each corner
    local n00 = TLOU_Spores.dotGridGradient(x0, y0, scaledX, scaledY, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE)
    local n10 = TLOU_Spores.dotGridGradient(x1, y0, scaledX, scaledY, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE)
    local n01 = TLOU_Spores.dotGridGradient(x0, y1, scaledX, scaledY, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE)
    local n11 = TLOU_Spores.dotGridGradient(x1, y1, scaledX, scaledY, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE)

    -- Interpolate noise values
    local sx = scaledX - x0
    local sy = scaledY - y0
    local nx0 = n00 + (n10 - n00) * sx
    local nx1 = n01 + (n11 - n01) * sx
    local value = nx0 + (nx1 - nx0) * sy

    -- Normalize to [0, 1] (optional)
    return (value + 1) / 2
end

