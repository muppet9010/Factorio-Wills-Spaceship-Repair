local Map = {}
local Events = require("utility/events")
local Utils = require("utility/utils")
local Logging = require("utility/logging")
local EventScheduler = require("utility/event-scheduler")
local Constants = require("constants")

local desiredRegionSize = 2500
Map.regionEdgeLengthChunks = math.floor(desiredRegionSize / 32)
Map.regionSize = Map.regionEdgeLengthChunks * 32
Map.regionEdgeMarginTiles = math.floor(Map.regionEdgeLengthChunks / 5) * 32
Map.placementAccuracyRadius = 20
Map.entityTypeDetails = {
    silo = {
        entryName = "Silo",
        testEntryName = "TestSilo",
        destructable = true,
        minable = false
    },
    coinMachine = {
        entryName = "CoinMachine",
        testEntryName = "TestCoinMachine",
        destructable = false,
        minable = false
    }
}
Map.coinMachineChance = {
    "wills_spaceship_repair-wooden_coin_chest_assembling_machine",
    "wills_spaceship_repair-wooden_coin_chest_assembling_machine",
    "wills_spaceship_repair-wooden_coin_chest_assembling_machine",
    "wills_spaceship_repair-iron_coin_chest_assembling_machine"
}

local debugLogging = false

function Map.CreateGlobals()
    global.Map = global.Map or {}
    global.Map.regions = global.Map.regions or {}
    global.Map.playerRocketSiloTextIds = global.Map.playerRocketSiloTextIds or {}
end

function Map.OnStartup()
    if global.Map.spawnCoinMachine3Entity == nil then
        global.Map.spawnCoinMachine3Entity = Map.CreateSpawnCoin3MachineEntity()
        if global.Map.spawnCoinMachine3Entity == nil then
            return
        end
    end
end

function Map.OnLoad()
    Events.RegisterHandler(defines.events.on_chunk_generated, "Map", Map.OnChunkGenerated)
    Events.RegisterHandler(defines.events.on_entity_died, "Map", Map.OnMaybeRocketSiloDiedDestroyed)
    Events.RegisterHandler(defines.events.script_raised_destroy, "Map", Map.OnMaybeRocketSiloDiedDestroyed)
    EventScheduler.RegisterScheduledEventType("Map.ScheduledMakeSiloAtPosition", Map.ScheduledMakeSiloAtPosition)
    local rocketSiloStageEventId = remote.call("RocketSiloCon", "get_on_silo_stage_finished")
    Events.RegisterEvent(rocketSiloStageEventId)
    Events.RegisterHandler(rocketSiloStageEventId, "Map", Map.OnRocketSiloEntityPlaced)
    Events.RegisterHandler(defines.events.on_selected_entity_changed, "Map", Map.OnPlayerSelectedEntityChanged)
end

function Map.CreateSpawnCoin3MachineEntity()
    local nearSpawnRandomSpot = {
        x = math.random(-20, 20),
        y = math.random(-20, 20)
    }
    local pos = Utils.GetValidPositionForEntityNearPosition("wills_spaceship_repair-steel_coin_chest_assembling_machine", global.surface, nearSpawnRandomSpot, 20, 5)
    if pos == nil then
        Logging.Log("ERROR: No valid coin machine at spawn position found")
        return nil
    end
    local entity = global.surface.create_entity {name = "wills_spaceship_repair-steel_coin_chest_assembling_machine", position = pos, force = "player", raise_built = true}
    if entity == nil then
        Logging.Log("ERROR: Coin machine at spawn failed to create at valid position")
        return nil
    end
    entity.destructible = false
    return entity
end

function Map.OnChunkGenerated(event)
    local area = event.area
    local chunkPos = Utils.GetChunkPositionForTilePosition(area.left_top)
    Logging.Log("OnChunkGenerated: " .. Logging.PositionToString(chunkPos), debugLogging)
    local region = Map.GetRegionForChunkPos(chunkPos)
    if region == nil then
        region = Map.GenerateRegionForChunk(chunkPos)
    end
    Map.TestEntityChunkGenerated(region, chunkPos, Map.entityTypeDetails["silo"])
    Map.TestEntityChunkGenerated(region, chunkPos, Map.entityTypeDetails["coinMachine"])
end

function Map.GetRegionForChunkPos(chunkPos)
    local regionPos = {x = math.floor(chunkPos.x / Map.regionEdgeLengthChunks), y = math.floor(chunkPos.y / Map.regionEdgeLengthChunks)}
    local regionPosString = Utils.FormatPositionTableToString(regionPos)
    return global.Map.regions[regionPosString]
end

function Map.GenerateRegionForChunk(chunkPos)
    local regionPos = {x = math.floor(chunkPos.x / Map.regionEdgeLengthChunks), y = math.floor(chunkPos.y / Map.regionEdgeLengthChunks)}
    local regionPosString = Utils.FormatPositionTableToString(regionPos)
    local regionTopLeftChunk = {x = regionPos.x * Map.regionEdgeLengthChunks, y = regionPos.y * Map.regionEdgeLengthChunks}
    local regionTopLeftPos = Utils.GetLeftTopTilePositionForChunkPosition(regionTopLeftChunk)
    local regionInnerArea = {
        left_top = {
            x = regionTopLeftPos.x + Map.regionEdgeMarginTiles,
            y = regionTopLeftPos.y + Map.regionEdgeMarginTiles
        },
        right_bottom = {
            x = regionTopLeftPos.x + Map.regionSize - Map.regionEdgeMarginTiles,
            y = regionTopLeftPos.y + Map.regionSize - Map.regionEdgeMarginTiles
        }
    }
    local region = {
        index = regionPosString,
        regionPos = regionPos,
        regionInnerArea = regionInnerArea,
        TestSilo = {
            attempts = 0,
            prototypeName = "wills_spaceship_repair-rocket_silo_place_test"
        },
        Silo = {
            position = nil,
            prototypeName = "rsc-silo-stage1"
        },
        TestCoinMachine = {
            attempts = 0,
            prototypeName = "wills_spaceship_repair-coin_machine_place_test"
        },
        CoinMachine = {
            position = nil,
            prototypeName = Map.coinMachineChance[math.random(#Map.coinMachineChance)]
        }
    }
    global.Map.regions[regionPosString] = region
    Logging.LogPrint("GenerateRegion: " .. regionPosString, debugLogging)
    Map.GenerateEntityRandomPosition(region, Map.entityTypeDetails["silo"])
    return region
end

function Map.GenerateEntityRandomPosition(region, entryType)
    local testEntryName = entryType.testEntryName
    local regionTestEntry = region[testEntryName]
    regionTestEntry.attempts = regionTestEntry.attempts + 1
    Logging.LogPrint("GenerateEntityRandomPosition '" .. testEntryName .. "': " .. region.index .. "  -  attempt: " .. regionTestEntry.attempts, debugLogging)
    if regionTestEntry.attempts >= 100 then
        Logging.LogPrint("ERROR: Failed to find '" .. testEntryName .. "' position after 100 attempts in region: " .. region.index)
        return
    end
    local testEntity = game.entity_prototypes[regionTestEntry.prototypeName]
    local testPos
    if testEntryName == "TestSilo" then
        testPos = {
            x = math.random(region.regionInnerArea.left_top.x, region.regionInnerArea.right_bottom.x),
            y = math.random(region.regionInnerArea.left_top.y, region.regionInnerArea.right_bottom.y)
        }
    elseif testEntryName == "TestCoinMachine" then
        local directions = {}
        local northMaxY = region.Silo.position.y - Map.regionEdgeMarginTiles
        if northMaxY > region.regionInnerArea.left_top.y then
            table.insert(directions, "north")
        end
        local southMinY = region.Silo.position.y + Map.regionEdgeMarginTiles
        if southMinY < region.regionInnerArea.right_bottom.y then
            table.insert(directions, "south")
        end
        local eastMinX = region.Silo.position.x + Map.regionEdgeMarginTiles
        if eastMinX < region.regionInnerArea.right_bottom.x then
            table.insert(directions, "east")
        end
        local westMaxX = region.Silo.position.x - Map.regionEdgeMarginTiles
        if westMaxX > region.regionInnerArea.left_top.x then
            table.insert(directions, "west")
        end
        local randomDirection = directions[math.random(#directions)]
        if randomDirection == "north" then
            testPos = {
                x = math.random(region.regionInnerArea.left_top.x, region.regionInnerArea.right_bottom.x),
                y = math.random(region.regionInnerArea.left_top.y, northMaxY)
            }
        elseif randomDirection == "south" then
            testPos = {
                x = math.random(region.regionInnerArea.left_top.x, region.regionInnerArea.right_bottom.x),
                y = math.random(southMinY, region.regionInnerArea.right_bottom.y)
            }
        elseif randomDirection == "east" then
            testPos = {
                x = math.random(eastMinX, region.regionInnerArea.right_bottom.x),
                y = math.random(region.regionInnerArea.left_top.y, region.regionInnerArea.right_bottom.y)
            }
        elseif randomDirection == "west" then
            testPos = {
                x = math.random(region.regionInnerArea.left_top.x, westMaxX),
                y = math.random(region.regionInnerArea.left_top.y, region.regionInnerArea.right_bottom.y)
            }
        end
    end
    regionTestEntry.pos = testPos
    local entityFootprint = Utils.ApplyBoundingBoxToPosition(testPos, testEntity.collision_box)
    local entityPlacementArea = {
        left_top = Utils.ApplyOffsetToPosition(entityFootprint.left_top, {x = -Map.placementAccuracyRadius, y = -Map.placementAccuracyRadius}),
        right_bottom = Utils.ApplyOffsetToPosition(entityFootprint.right_bottom, {x = Map.placementAccuracyRadius, y = Map.placementAccuracyRadius})
    }
    local chunkArea = {
        left_top = Utils.GetChunkPositionForTilePosition(entityPlacementArea.left_top),
        right_bottom = Utils.GetChunkPositionForTilePosition(entityPlacementArea.right_bottom)
    }
    local chunksToCheck = Utils.CalculateTilesUnderPositionedBoundingBox(chunkArea)
    local chunksNeeded = {}
    for _, chunk in ipairs(chunksToCheck) do
        if not global.surface.is_chunk_generated(chunk) then
            global.surface.request_to_generate_chunks(Utils.GetLeftTopTilePositionForChunkPosition(chunk), 0)
            local chunkPosString = Utils.FormatPositionTableToString(chunk)
            chunksNeeded[chunkPosString] = chunkPosString
            Logging.Log("'" .. testEntryName .. "' requested chunk generation: " .. chunkPosString, debugLogging)
        end
    end
    regionTestEntry.chunksNeedGenerating = chunksNeeded
end

function Map.TestEntityChunkGenerated(region, chunkPos, entryType)
    local testEntryName = entryType.testEntryName
    local regionTestEntry = region[testEntryName]
    if region[entryType.entryName].position ~= nil or regionTestEntry.chunksNeedGenerating == nil then
        return
    end
    local chunkPosString = Utils.FormatPositionTableToString(chunkPos)
    if regionTestEntry.chunksNeedGenerating[chunkPosString] ~= nil then
        regionTestEntry.chunksNeedGenerating[chunkPosString] = nil
    else
        return
    end
    if Utils.GetTableNonNilLength(regionTestEntry.chunksNeedGenerating) > 0 then
        return
    end

    Logging.LogPrint("'" .. testEntryName .. "' region has all requested chunks generated: " .. region.index, debugLogging)
    local pos = Utils.GetValidPositionForEntityNearPosition(regionTestEntry.prototypeName, global.surface, regionTestEntry.pos, Map.placementAccuracyRadius, 1)
    if pos == nil then
        Logging.LogPrint("region '" .. testEntryName .. "' no valid position found: " .. region.index, debugLogging)
        Map.GenerateEntityRandomPosition(region, entryType)
        return
    end
    Map.MakeEntityAtPosition(region, pos, entryType)
end

function Map.MakeEntityAtPosition(region, position, entryType)
    local entryName = entryType.entryName
    local regionEntry = region[entryName]
    local entityPrototype = game.entity_prototypes[regionEntry.prototypeName]
    local entityFootprint = Utils.ApplyBoundingBoxToPosition(position, entityPrototype.collision_box)
    Utils.DestroyAllObjectsInArea(global.surface, entityFootprint)

    local entity = global.surface.create_entity {name = regionEntry.prototypeName, position = position, force = "player", raise_built = true}
    if entity == nil then
        Logging.LogPrint("ERROR: Failed to place '" .. entryName .. "' in a valid position for region: " .. region.index)
        return
    end
    entity.destructible = entryType.destructable
    entity.minable = entryType.minable
    Logging.LogPrint("region '" .. entryName .. "' created: " .. region.index, debugLogging)
    regionEntry.position = position
    if entryName == "Silo" then
        Map.GenerateEntityRandomPosition(region, Map.entityTypeDetails["coinMachine"])
    end
end

function Map.ScheduledMakeSiloAtPosition(event)
    Map.MakeEntityAtPosition(event.data.region, event.data.position, Map.entityTypeDetails["silo"])
end

function Map.IsNameARocketSilo(name)
    return name == "rocket-silo" or string.find(name, "rsc-silo-stage", 0, true)
end

function Map.OnMaybeRocketSiloDiedDestroyed(event)
    local entity = event.entity
    if not Map.IsNameARocketSilo(name) then
        return
    end
    local pos = entity.position
    Logging.LogPrint("Rocket silo (" .. entity.name .. ") destroyed: " .. Logging.PositionToString(pos), debugLogging)
    local region = Map.GetRegionForChunkPos(Utils.GetChunkPositionForTilePosition(pos))
    if region ~= nil then
        Logging.LogPrint("Rocket silo scheduled for recreation", debugLogging)
        EventScheduler.ScheduleEvent(nil, "Map.ScheduledMakeSiloAtPosition", region.index, {region = region, position = region.Silo.position})
    end
end

function Map.OnRocketSiloEntityPlaced(event)
    local entity = event.created_entity
    entity.destructible = Map.entityTypeDetails["silo"].destructable
    entity.minable = Map.entityTypeDetails["silo"].minable
end

function Map.OnPlayerSelectedEntityChanged(event)
    local player = game.get_player(event.player_index)
    local siloEntity = player.selected
    if siloEntity == nil or not Map.IsNameARocketSilo(siloEntity.name) then
        local rocketSiloTextIds = global.Map.playerRocketSiloTextIds[player.index]
        if rocketSiloTextIds ~= nil then
            for _, textId in ipairs(rocketSiloTextIds) do
                rendering.destroy(textId)
            end
        end
    else
        Map.PlayerSelectedRocketSilo(player, siloEntity)
    end
end

function Map.PlayerSelectedRocketSilo(player, siloEntity)
    global.Map.playerRocketSiloTextIds[player.index] = {}
    local playerRocketSiloTextIds = global.Map.playerRocketSiloTextIds[player.index]
    local GenerateRocketSiloText = function(text, yOffset)
        return rendering.draw_text {
            text = text,
            target_offset = {0, yOffset},
            surface = siloEntity.surface,
            target = siloEntity,
            color = Constants.Colors.white,
            players = {player.index},
            alignment = "center",
            scale_with_zoom = true
        }
    end
    local siloResultInventory = siloEntity.get_inventory(defines.inventory.rocket_silo_result)
    local yOffsetStep = 1
    if siloResultInventory.is_empty() then
        table.insert(playerRocketSiloTextIds, GenerateRocketSiloText({"message.wills_spaceship_repair-rocket_silo_contents_empty"}, -yOffsetStep))
    else
        local contents = siloResultInventory.get_contents()
        local yOffset = -((Utils.GetTableLength(contents) + 1) / 2) * yOffsetStep
        table.insert(playerRocketSiloTextIds, GenerateRocketSiloText({"message.wills_spaceship_repair-rocket_silo_contents_list"}, yOffset))
        yOffset = yOffset + yOffsetStep
        for contentName, contentCount in pairs(contents) do
            local itemName
            if game.entity_prototypes[contentName] ~= nil then
                itemName = {"entity-name." .. contentName}
            else
                itemName = {"item-name." .. contentName}
            end
            table.insert(playerRocketSiloTextIds, GenerateRocketSiloText({"misc.wills_spaceship_repair-triple", itemName, ": ", Utils.DisplayNumberPretty(contentCount)}, yOffset))
            yOffset = yOffset + yOffsetStep
        end
    end
end

return Map
