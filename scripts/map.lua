local Map = {}
local Events = require("utility/events")
local Utils = require("utility/utils")

local regionSize = 2496
local regionEdgeMargin = 512
local regionChunkSide = 2496 / 32

Map.OnStartup = function()
    global.Map = global.map or {}
    global.Map.regions = global.Map.regions or {}

    if global.Map.spawnCoinMachine3Entity == nil then
        global.Map.spawnCoinMachine3Entity = Map.CreateSpawnCoin3MachineEntity(game.surfaces[1], {0, 0}, 20)
        if global.Map.spawnCoinMachine3Entity == nil then
            Logging.LogPrint("ERROR: Failed to create coin machine 3 near spawn")
        end
    end

    Map.OnLoad()
end

Map.OnLoad = function()
    Events.RegisterHandler(defines.events.on_chunk_generated, "Map", Map.OnChunkGenerated)
end

Map.CreateSpawnCoin3MachineEntity = function(surface, centerPos, radius)
    local pos
    while pos == nil do
        pos = surface.find_non_colliding_position("wills_spaceship_repair-steel_coin_chest_assembling_machine", centerPos, radius, 1, true)
        radius = radius * 2
    end
    local entity = surface.create_entity {name = "wills_spaceship_repair-steel_coin_chest_assembling_machine", position = pos, force = "player"}
    if entity ~= nil then
        entity.destructible = false
    end
    return entity
end

Map.OnChunkGenerated = function(event)
    local area = event.area
    local chunkPos = {x = math.floor(area.left_top.x / 32), y = math.floor(area.left_top.y / 32)}
    local region = Map.GetRegionForChunkPos(chunkPos)
    if region == nil then
        region = Map.GenerateRegionForChunk(chunkPos)
    end
end

Map.GetRegionForChunkPos = function(chunkPos)
    local regionPos = {x = math.floor(chunkPos.x / regionChunkSide), y = math.floor(chunkPos.y / regionChunkSide)}
    local regionPosString = Utils.FormatPositionTableToString(regionPos)
    return global.Map.regions[regionPosString]
end

Map.GenerateRegionForChunk = function(chunkPos)
    local regionPos = {x = math.floor(chunkPos.x / regionChunkSide), y = math.floor(chunkPos.y / regionChunkSide)}
    local regionPosString = Utils.FormatPositionTableToString(regionPos)
    local siloPosition = Map.FindSuitableLandForEntityInBoundingBox("") WRONG WRONG WRONG
    local region = {
        index = regionPosString,
        regionPos = regionPos,
        siloPosition = siloPosition
    }
    global.Map.regions[regionPosString] = region
    return region
end

Map.FindSuitableLandForEntityInBoundingBox(entity)
    return {x=0, y=0}
end

return Map
