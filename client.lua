local keepHashStored = nil -- Start with no zone stored initially

CreateThread(function()
    -- Wait until the player is in the session
    repeat Wait(5000) until LocalPlayer.state.IsInSession
    --print("[DEBUG] Player is in session.")

    -- Main loop to check the player's zone
    while true do
        Citizen.Wait(6000) -- Check every 6 seconds to reduce performance impact

        local player = PlayerPedId()
        local x, y, z = table.unpack(GetEntityCoords(player))
        local zone = nil
        --print(string.format("[DEBUG] Checking zone at coordinates: x=%.2f, y=%.2f, z=%.2f", x, y, z))

        -- Iterate through all zone types using the existing config
        for _, zoneConfig in ipairs(ConfigZones) do
            local currentZoneHash = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, zoneConfig.typeId)
            if currentZoneHash and currentZoneHash == zoneConfig.hashDec then
                zone = currentZoneHash
                --print(string.format("[DEBUG] Zone match found: %s (hash: %s)", zoneConfig.name, zone))
                break -- Exit the loop after finding the first match
            end
        end

        -- If the zone has changed, update `keepHashStored` and call the alert function
        if keepHashStored ~= zone then
            --print(string.format("[DEBUG] Zone changed from %s to %s.", tostring(keepHashStored), tostring(zone)))
            keepHashStored = zone
            drawZoneSprite(zone) -- Pass the found zone to the draw function
        end
    end
end)

function drawZoneSprite(zone)
    local player = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(player))
    --print("[DEBUG] Drawing sprite for current zone.")

    -- Variables to store the detected zone's data
    local displayZone = nil

    -- Iterate through all zones to find the first matching zone
    for _, zoneConfig in ipairs(ConfigZones) do
        local currentZoneHash = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, zoneConfig.typeId)
        if currentZoneHash and currentZoneHash == zoneConfig.hashDec then
            ----print(string.format("[DEBUG] Found matching zone: %s (typeId: %d)", zoneConfig.name, zoneConfig.typeId))

            if zoneConfig.typeId == 1 then
                displayZone = zoneConfig -- Match for towns
            elseif zoneConfig.typeId == 2 then
                displayZone = zoneConfig -- Match for lakes
            elseif zoneConfig.typeId == 3 then
                displayZone = zoneConfig -- Match for rivers
            elseif zoneConfig.typeId == 5 then
                displayZone = zoneConfig -- Match for swamps
            elseif zoneConfig.typeId == 6 then
                displayZone = zoneConfig -- Match for oceans
            elseif zoneConfig.typeId == 7 then
                displayZone = zoneConfig -- Match for creeks
            elseif zoneConfig.typeId == 8 then
                displayZone = zoneConfig -- Match for ponds
            elseif zoneConfig.typeId == 10 then
                displayZone = zoneConfig -- Match for districts
            elseif zoneConfig.typeId == 11 then
                displayZone = zoneConfig -- Match for text_printed
            elseif zoneConfig.typeId == 12 then
                displayZone = zoneConfig -- Match for text_written
            end
            break -- Exit the loop after finding the first match
        end
    end

    if displayZone then
        --print(string.format("[DEBUG] Displaying zone: %s (texture: %s)", displayZone.name, displayZone.textureName))
    else
        --print("[DEBUG] No matching zone found to display.")
    end

    -- Check if we have a display zone and prepare texture data if available
    if displayZone and displayZone.textureName then
        local textureData = {
            textureDict = "feed_location",
            textureName = displayZone.textureName,
            x = 0.5, -- Horizontal position (centered)
            y = 0.1, -- Vertical position (top)
            width = 0.201, -- Width of the sprite
            height = 0.101, -- Height of the sprite
            rotation = 0.0, -- No rotation
            r = 255, -- Full red
            g = 255, -- Full green
            b = 255, -- Full blue
            a = 200, -- Full opacity
        }

        -- Draw the sprite for 4 seconds
        local startTime = GetGameTimer()
        while GetGameTimer() - startTime < 6000 do
            Citizen.Wait(0)
            DrawSpriteOnScreen(textureData)
        end
    end
end

-- Function to load and draw sprite
function DrawSpriteOnScreen(data)
    ----print(string.format("[DEBUG] Drawing sprite: Dict=%s, Name=%s", data.textureDict, data.textureName))
    if not HasStreamedTextureDictLoaded(data.textureDict) then
        --print("[DEBUG] Requesting texture dictionary:", data.textureDict)
        RequestStreamedTextureDict(data.textureDict, false)
        while not HasStreamedTextureDictLoaded(data.textureDict) do
            Citizen.Wait(0) -- Wait until texture is loaded
        end
        ----print("[DEBUG] Texture dictionary loaded:", data.textureDict)
    end

    -- Draw background texture
    DrawSprite(data.textureDict, "hud_location_bg", 0.5, 0.1, 0.251, 0.151, 0.0, 0, 0, 0, 255, true)
    -- Draw main zone texture
    DrawSprite(data.textureDict, data.textureName, data.x, data.y, data.width, data.height, data.rotation, data.r, data.g, data.b, data.a, true)
    ----print("[DEBUG] Sprite drawn successfully.")
end

RegisterCommand("bcczoneinfo", function(source, args, rawCommand)
    --print("[DEBUG] Manual command 'bcczoneinfo' triggered.")
    drawZoneSprite()
end)
