local Map = {}
local Events = require("utility/events")
local Utils = require("utility/utils")
local Logging = require("utility/logging")

local REGIONSIZE = 2496
local REGIONEDGEMARGINTILES = 512
local REGIONEDGELENGTHCHUNKS = REGIONSIZE / 32
local PLACEMENTRADIUS = 20

local debugLogging = false
--TODO: remove chunks generated if they aren't needed after both silo and coins placed. to avoid low evo biters remaining.
function Map.OnStartup()
    global.Map = global.map or {}
    global.Map.regions = global.Map.regions or {}

    if global.Map.spawnCoinMachine3Entity == nil then
        global.Map.spawnCoinMachine3Entity = Map.CreateSpawnCoin3MachineEntity()
        if global.Map.spawnCoinMachine3Entity == nil then
            return
        end
    end

    Map.OnLoad()
end

function Map.OnLoad()
    Events.RegisterHandler(defines.events.on_chunk_generated, "Map", Map.OnChunkGenerated)
    Events.RegisterHandler(defines.events.on_entity_died, "Map", Map.OnMaybeRocketSiloDiedDestroyed)
    Events.RegisterHandler(defines.events.script_raised_destroy, "Map", Map.OnMaybeRocketSiloDiedDestroyed)
    Events.RegisterScheduledEventType("Map.ScheduledMakeSiloAtPosition", Map.ScheduledMakeSiloAtPosition)
end

function Map.CreateSpawnCoin3MachineEntity()
    local pos = Utils.GetValidPositionForEntityNearPosition("wills_spaceship_repair-steel_coin_chest_assembling_machine", global.surface, {0, 0}, 20, 5)
    if pos == nil then
        Logging.Log("ERROR: No valid coin machine at spawn position found")
        return nil
    end
    local entity = global.surface.create_entity {name = "wills_spaceship_repair-steel_coin_chest_assembling_machine", position = pos, force = "player"}
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
    Map.TestSiloChunkGenerated(region, chunkPos)
end

function Map.GetRegionForChunkPos(chunkPos)
    local regionPos = {x = math.floor(chunkPos.x / REGIONEDGELENGTHCHUNKS), y = math.floor(chunkPos.y / REGIONEDGELENGTHCHUNKS)}
    local regionPosString = Utils.FormatPositionTableToString(regionPos)
    return global.Map.regions[regionPosString]
end

function Map.GenerateRegionForChunk(chunkPos)
    local regionPos = {x = math.floor(chunkPos.x / REGIONEDGELENGTHCHUNKS), y = math.floor(chunkPos.y / REGIONEDGELENGTHCHUNKS)}
    local regionPosString = Utils.FormatPositionTableToString(regionPos)
    local regionTopLeftChunk = {x = regionPos.x * REGIONEDGELENGTHCHUNKS, y = regionPos.y * REGIONEDGELENGTHCHUNKS}
    local regionTopLeftPos = Utils.GetLeftTopTilePositionForChunkPosition(regionTopLeftChunk)
    local regionInnerArea = {
        left_top = {
            x = regionTopLeftPos.x + REGIONEDGEMARGINTILES,
            y = regionTopLeftPos.y + REGIONEDGEMARGINTILES
        },
        right_bottom = {
            x = regionTopLeftPos.x + REGIONSIZE - REGIONEDGEMARGINTILES,
            y = regionTopLeftPos.y + REGIONSIZE - REGIONEDGEMARGINTILES
        }
    }
    local region = {
        index = regionPosString,
        regionPos = regionPos,
        regionInnerArea = regionInnerArea,
        TestSilo = {attempts = 0},
        siloPosition = nil
    }
    global.Map.regions[regionPosString] = region
    Logging.LogPrint("GenerateRegion: " .. regionPosString, debugLogging)
    Map.GenerateTestSiloPosition(region)
    return region
end

function Map.GenerateTestSiloPosition(region)
    region.TestSilo.attempts = region.TestSilo.attempts + 1
    Logging.LogPrint("GenerateTestSiloPosition: " .. region.index .. "  -  attempt: " .. region.TestSilo.attempts, debugLogging)
    if region.TestSilo.attempts >= 100 then
        Logging.LogPrint("ERROR: Failed to find rocket silo position after 100 attempts in region: " .. region.index)
        return
    end
    local testSiloEntity = game.entity_prototypes["wills_spaceship_repair-rocket_silo_place_test"]
    local testSiloPos = {
        x = math.random(region.regionInnerArea.left_top.x, region.regionInnerArea.right_bottom.x),
        y = math.random(region.regionInnerArea.left_top.y, region.regionInnerArea.right_bottom.y)
    }
    region.TestSilo.pos = testSiloPos
    local testSiloFootprint = Utils.ApplyBoundingBoxToPosition(testSiloPos, testSiloEntity.collision_box)
    local testSiloPlacementArea = {
        left_top = Utils.ApplyOffsetToPosition(testSiloFootprint.left_top, {x = -PLACEMENTRADIUS, y = -PLACEMENTRADIUS}),
        right_bottom = Utils.ApplyOffsetToPosition(testSiloFootprint.right_bottom, {x = PLACEMENTRADIUS, y = PLACEMENTRADIUS})
    }
    local chunkArea = {
        left_top = Utils.GetChunkPositionForTilePosition(testSiloPlacementArea.left_top),
        right_bottom = Utils.GetChunkPositionForTilePosition(testSiloPlacementArea.right_bottom)
    }
    local chunksToCheck = Utils.CalculateTilesUnderPositionedBoundingBox(chunkArea)
    local chunksNeeded = {}
    for _, chunk in pairs(chunksToCheck) do
        if not global.surface.is_chunk_generated(chunk) then
            global.surface.request_to_generate_chunks(Utils.GetLeftTopTilePositionForChunkPosition(chunk), 0)
            local chunkPosString = Utils.FormatPositionTableToString(chunk)
            chunksNeeded[chunkPosString] = chunkPosString
            Logging.Log("silo requested chunk generation: " .. chunkPosString, debugLogging)
        end
    end
    region.TestSilo.chunksNeedGenerating = chunksNeeded
end

function Map.TestSiloChunkGenerated(region, chunkPos)
    if region.siloPosition ~= nil then
        return
    end
    local chunkPosString = Utils.FormatPositionTableToString(chunkPos)
    if region.TestSilo.chunksNeedGenerating[chunkPosString] ~= nil then
        region.TestSilo.chunksNeedGenerating[chunkPosString] = nil
    else
        return
    end
    if Utils.GetTableNonNilLength(region.TestSilo.chunksNeedGenerating) > 0 then
        return
    end

    Logging.LogPrint("region has all requested chunks generated: " .. region.index, debugLogging)
    local pos = Utils.GetValidPositionForEntityNearPosition("wills_spaceship_repair-rocket_silo_place_test", global.surface, region.TestSilo.pos, PLACEMENTRADIUS, 1)
    if pos == nil then
        Logging.LogPrint("region test silo position invalid: " .. region.index, debugLogging)
        Map.GenerateTestSiloPosition(region)
        return
    end
    Map.MakeSiloAtPosition(region, region.TestSilo.pos)
end

function Map.MakeSiloAtPosition(region, position)
    local siloPrototype = game.entity_prototypes["wills_spaceship_repair-rocket_silo_place_test"]
    local siloFootprint = Utils.ApplyBoundingBoxToPosition(position, siloPrototype.collision_box)
    Utils.KillAllObjectsInArea(global.surface, siloFootprint)

    local entity = global.surface.create_entity {name = "rsc-silo-stage1", position = position, force = "player"}
    if entity == nil then
        Logging.LogPrint("ERROR: Failed to place rocket silo in a valid position for region: " .. region.index)
        return
    end
    Logging.LogPrint("region silo created: " .. region.index, debugLogging)
    region.siloPosition = position
end

function Map.ScheduledMakeSiloAtPosition(event)
    Map.MakeSiloAtPosition(event.region, event.position)
end

function Map.OnMaybeRocketSiloDiedDestroyed(event)
    local entity = event.entity
    if entity.name ~= "rocket-silo" and not string.find(entity.name, "rsc-silo-stage", 0, true) then
        return
    end
    local pos = entity.position
    Logging.LogPrint("Rocket silo (" .. entity.name .. ") destroyed: " .. Logging.PositionToString(pos), debugLogging)
    local region = Map.GetRegionForChunkPos(Utils.GetChunkPositionForTilePosition(pos))
    if region ~= nil then
        Logging.LogPrint("Rocket silo scheduled for recreation", debugLogging)
        Events.ScheduleEvent(nil, "Map.ScheduledMakeSiloAtPosition", region.index, {region = region, position = region.siloPosition})
    end
end

return Map
