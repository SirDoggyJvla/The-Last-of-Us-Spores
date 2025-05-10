--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Handles the spore UI overlay of TLOU Spores.

]]--
--[[ ================================================ ]]--

--- CACHING
-- module
local TLOU_Spores = require "TLOU_Spores_module"
require "TLOU_Spores_tools"

-- screen dimensions
local screenWidth = getCore():getScreenWidth() -- Get the screen resolution
local screenHeight = getCore():getScreenHeight() -- Get the screen resolution

-- randomness
local GENERAL_RANDOM = newrandom()

-- texture drawing
local DrawTexture = UIManager.DrawTexture


TLOU_Spores.OnPreUIDraw = function()
    if isGamePaused() then return end

    -- verify player exists
    local client_player = getPlayer()
    if not client_player then return end

    -- get player mod data
    local player_modData = client_player:getModData().TLOU_Spores

    -- check player is in spores
    local inSpores = player_modData["inSpores"]
    local nearSpores = not inSpores and player_modData["nearSpores"]

    -- skip if no UI and no spores around
    local Active_Spores_Overlay = TLOU_Spores.Active_Spores_Overlay
    if not Active_Spores_Overlay and not inSpores and not nearSpores then return end

    -- determine current spore status
    local currentSporesStatus = tostring(inSpores) .. tostring(nearSpores )

    -- if there was a change, then update next overlay status
    if TLOU_Spores.previousSporesStatus ~= currentSporesStatus or not Active_Spores_Overlay then
        TLOU_Spores.previousSporesStatus = currentSporesStatus

        -- not point having the overlay existing and doing all the other checks and updates
        if not inSpores and not nearSpores then
            TLOU_Spores.Active_Spores_Overlay = nil
            return
        end

        Active_Spores_Overlay = TLOU_Spores.InitializeSporesOverlay(inSpores, nearSpores, Active_Spores_Overlay)
    end

    -- TLOU_Spores.previousSporesStatus = currentSporesStatus


    -- update overlays
    TLOU_Spores.UpdateAllSporesOverlays(Active_Spores_Overlay)
end

local ALPHA_SPEED = 0.005

TLOU_Spores.UpdateOverlayLayer = function(layer,inactive,movementMultiplier)
    -- init default values
    local alpha = layer.alpha
    local alpha_value = alpha.value
    local direction = alpha.direction

    -- if inactive, then decrease alpha until reach 0
    if inactive then
        -- decrease alpha
        if alpha_value > 0 then
            alpha_value = alpha_value - ALPHA_SPEED
        elseif direction and direction ~= 1 then
            -- do that for later when the UI is active again to be able to increase
            alpha.direction = 1
        end

        alpha.value = alpha_value

    -- else oscillate alpha
    elseif direction then
        -- calculate new alpha value
        alpha_value = alpha_value + direction * ALPHA_SPEED

        -- if reached limit, then change direction
        if direction > 0 and alpha_value > alpha.limitMax then
            alpha_value = alpha.limitMax
            alpha.direction = -1
        elseif direction < 0 and alpha_value < alpha.limitMin then
            alpha_value = alpha.limitMin
            alpha.direction = 1
        end

        alpha.value = alpha_value

    -- else increase alpha until reach 1
    elseif alpha_value < 1 then
        alpha_value = alpha_value + ALPHA_SPEED
        if alpha_value > 1 then
            alpha_value = 1
        end
        alpha.value = alpha_value

    end


    -- update movement
    local movement = layer.movement
    local offsetX = 0
    local offsetY = 0
    if movement and movementMultiplier then
        -- local omega = movement.omega
        local amplitude = movement.amplitude
        -- local x_dir = movement.x_dir
        -- local y_dir = movement.y_dir

        local currentTime = os.time()
        local omega_offset = movement.omega_offset
        local s_x = amplitude * math.sin(movement.omega_x * currentTime - omega_offset) + amplitude * math.sin(movement.omega_x/2 * currentTime - omega_offset) + amplitude * math.sin(movement.omega_x/4 * currentTime - omega_offset)
        local s_y = amplitude * math.sin(movement.omega_y * currentTime - omega_offset) + amplitude * math.sin(movement.omega_x/2 * currentTime - omega_offset) + amplitude * math.sin(movement.omega_x/4 * currentTime - omega_offset)

        offsetX = s_x * movementMultiplier
        offsetY = s_y * movementMultiplier
    end

    -- don't draw if alpha_value is 0
    if alpha_value > 0 then
        -- update texture
        local texture = layer.texture
        DrawTexture(texture, offsetX, offsetY, screenWidth, screenHeight, alpha_value)
    end
end


local OVERLAYS_KEYS = TLOU_Spores.PARTICLE_LAYERS

TLOU_Spores.UpdateAllSporesOverlays = function(Active_Spores_Overlay)
    local movementMultiplier
    if TLOU_Spores.CONFIGS["OverlayMovement"] then
        -- retrieve movement modifiers
        local player = getPlayer()
        local endurance = player:getStats():getEndurance()

        local enduranceMultiplier = endurance > 0.5 and 0.1
            or endurance < 0.25 and 0.5
            or 0.3

        -- local speedMultiplier = not player:isPlayerMoving() and 0.2
        --     or player:IsRunning() and 1
        --     or player:isForceSprint() and 2
        --     or 0.5

        local speedMultiplier = not player:isPlayerMoving() and 0.1
            or player:IsRunning() and 1
            or player:isForceSprint() and 2
            or player:getMovementSpeed() < 0.008 and 0.2 or 0.5

        -- math.max
        movementMultiplier = enduranceMultiplier > speedMultiplier and enduranceMultiplier or speedMultiplier
    end

    -- update main overlay
    local main = Active_Spores_Overlay.main
    TLOU_Spores.UpdateOverlayLayer(main,main.inactive)

    -- update particles overlay
    for i = 1,#OVERLAYS_KEYS do repeat
        local overlayKey = OVERLAYS_KEYS[i]
        local overlay = Active_Spores_Overlay[overlayKey]
        local inactive = overlay.inactive

        for j = 1,#overlay.layers do
            TLOU_Spores.UpdateOverlayLayer(overlay.layers[j],inactive, movementMultiplier)
        end
    until true end
end

TLOU_Spores.CreateLayer = function(particleData,i)
    local omega_x = particleData.omega_x + GENERAL_RANDOM:random(-0.2,0.2)
    local omega_y = particleData.omega_y + GENERAL_RANDOM:random(-0.2,0.2)

    return {
        texture = getTexture(particleData.path:format(i)),
        alpha = {
            value = 0,
            direction = 1,
            limitMin = 0.5,
            limitMax = 1,
        },
        movement = {
            amplitude = particleData.amplitude,
            omega_x = omega_x,
            omega_y = omega_y,
            omega_offset = (omega_x + omega_y)*i/18,
        }
    }
end

TLOU_Spores.GenerateOverlay = function(inSpores,_nearSpores)
    local modOptionChoice = TLOU_Spores.UNIQUE_OVERLAY_COLORS[TLOU_Spores.CONFIGS["OverlayColor"]]
    local userOverlayChoice = TLOU_Spores.OVERLAY_OPTIONS[modOptionChoice]

    local overlays = {
        particles_small = {
            layers = table.newarray(),
            inactive = not _nearSpores,
        },
        particles_small_fliped = {
            layers = table.newarray(),
            inactive = not _nearSpores,
        },
        particles_medium = {
            layers = table.newarray(),
            inactive = _nearSpores and _nearSpores > 1,
        },
        particles_medium_fliped = {
            layers = table.newarray(),
            inactive = _nearSpores and _nearSpores > 1,
        },
        particles_big = {
            layers = table.newarray(),
            inactive = not inSpores,
        },
        main = {
            texture = getTexture(userOverlayChoice.main_path),
            alpha = {
                value = 0,
            },
            inactive = not inSpores,
        },
        start_time = os.time(),
    }

    for i = 1,#TLOU_Spores.PARTICLE_LAYERS do
        local overlayKey = TLOU_Spores.PARTICLE_LAYERS[i]
        local overlay = overlays[overlayKey]
        local particleData = userOverlayChoice[overlayKey]
        for j = 1,9 do
            local layer = TLOU_Spores.CreateLayer(particleData,j)
            table.insert(overlay.layers,layer)
        end
    end

    return overlays
end

TLOU_Spores.InitializeSporesOverlay = function(_inSpores,_nearSpores,Active_Spores_Overlay)
    if Active_Spores_Overlay then
        -- makes main overlay inactive when not in spores
        local main_overlay = Active_Spores_Overlay.main
        local particles_big = Active_Spores_Overlay.particles_big
        if not _inSpores then
            if not main_overlay.inactive then
                main_overlay.inactive = true
            end

            if not particles_big.inactive then
                particles_big.inactive = true
            end
        else
            if main_overlay.inactive then
                main_overlay.inactive = false
            end

            if particles_big.inactive then
                particles_big.inactive = false
            end
        end

        -- handle particle overlays
        local particles_small = Active_Spores_Overlay.particles_small
        local particles_medium = Active_Spores_Overlay.particles_medium
        if _nearSpores == nil then
            if not particles_medium.inactive then
                particles_medium.inactive = true
            end

            if not particles_small.inactive then
                particles_small.inactive = true
            end
        else
            if not _nearSpores or _nearSpores < 2 then
                if particles_medium.inactive then
                    particles_medium.inactive = false
                end
            elseif not particles_medium.inactive then
                particles_medium.inactive = true
            end

            if particles_small.inactive then
                particles_small.inactive = false
            end
        end
    else
        TLOU_Spores.Active_Spores_Overlay = TLOU_Spores.GenerateOverlay(_inSpores,_nearSpores)
        Active_Spores_Overlay = TLOU_Spores.Active_Spores_Overlay
    end

    Active_Spores_Overlay = TLOU_Spores.Active_Spores_Overlay or {
        layers = table.newarray(),
    }

    TLOU_Spores.Active_Spores_Overlay = Active_Spores_Overlay

    return Active_Spores_Overlay
end