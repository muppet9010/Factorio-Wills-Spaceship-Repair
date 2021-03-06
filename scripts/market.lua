local Market = {}
local Logging = require("utility/logging")
local Utils = require("utility/utils")

function Market.CreateGlobals()
    global.Market = global.Market or {}
end

function Market.OnStartup()
    if global.Market.marketEntity == nil then
        global.Market.marketEntity = Market.CreateMarketEntity()
        if global.Market.marketEntity == nil then
            return
        end
    end
    Market.PopulateMarketItems(global.Market.marketEntity)
    if (remote.interfaces["item_delivery_pod"] == nil or remote.interfaces["item_delivery_pod"]["call_crash_ship"] == nil) and global.Market.coinBoxEntity == nil then
        global.Market.coinBoxEntity = Market.CreateCoinBoxEntity()
        if global.Market.coinBoxEntity == nil then
            return
        end
    end
end

function Market.CreateMarketEntity()
    local nearSpawnRandomSpot = {
        x = math.random(-20, 20),
        y = math.random(-20, 20)
    }
    local pos = Utils.GetValidPositionForEntityNearPosition("market", global.surface, nearSpawnRandomSpot, 20, 5)
    if pos == nil then
        Logging.Log("ERROR: No valid position for market at spawn found")
        return nil
    end
    local entity = global.surface.create_entity {name = "market", position = pos, force = "player", raise_built = true}
    if entity == nil then
        Logging.Log("ERROR: Market at spawn failed to create at valid position")
        return nil
    end
    entity.destructible = false
    return entity
end

function Market.CreateCoinBoxEntity()
    local nearSpawnRandomSpot = {
        x = math.random(-20, 20),
        y = math.random(-20, 20)
    }
    local pos = Utils.GetValidPositionForEntityNearPosition("logistic-chest-passive-provider", global.surface, nearSpawnRandomSpot, 20, 5)
    if pos == nil then
        Logging.Log("ERROR: No valid position for Coin Box at spawn found")
        return nil
    end
    local entity = global.surface.create_entity {name = "logistic-chest-passive-provider", position = pos, force = "player", raise_built = true}
    if entity == nil then
        Logging.Log("ERROR: Coin Box at spawn failed to create at valid position")
        return nil
    end
    entity.destructible = false
    entity.minable = false
    return entity
end

function Market.PopulateMarketItems(market)
    market.clear_market_items()
    market.add_market_item {price = {{"coin", 210}}, offer = {type = "give-item", item = "modular-armor"}}
    market.add_market_item {price = {{"coin", 1300}}, offer = {type = "give-item", item = "power-armor"}}
    market.add_market_item {price = {{"wills_spaceship_repair-wooden_coin_chest", 16}}, offer = {type = "give-item", item = "power-armor-mk2"}}
    market.add_market_item {price = {{"coin", 40}}, offer = {type = "give-item", item = "solar-panel-equipment"}}
    market.add_market_item {price = {{"coin", 6400}}, offer = {type = "give-item", item = "fusion-reactor-equipment"}}
    market.add_market_item {price = {{"wills_spaceship_repair-wooden_coin_chest", 6}, {"coin", 400}}, offer = {type = "give-item", item = "fusion-reactor-equipment"}}
    market.add_market_item {price = {{"coin", 40}}, offer = {type = "give-item", item = "energy-shield-equipment"}}
    market.add_market_item {price = {{"coin", 585}}, offer = {type = "give-item", item = "energy-shield-mk2-equipment"}}
    market.add_market_item {price = {{"coin", 30}}, offer = {type = "give-item", item = "battery-equipment"}}
    market.add_market_item {price = {{"coin", 830}}, offer = {type = "give-item", item = "battery-mk2-equipment"}}
    market.add_market_item {price = {{"coin", 1100}}, offer = {type = "give-item", item = "personal-laser-defense-equipment"}}
    market.add_market_item {price = {{"coin", 520}}, offer = {type = "give-item", item = "exoskeleton-equipment"}}
    market.add_market_item {price = {{"coin", 250}}, offer = {type = "give-item", item = "personal-roboport-equipment"}}
    market.add_market_item {price = {{"coin", 4400}}, offer = {type = "give-item", item = "personal-roboport-mk2-equipment"}}
    market.add_market_item {price = {{"wills_spaceship_repair-wooden_coin_chest", 4}, {"coin", 400}}, offer = {type = "give-item", item = "personal-roboport-mk2-equipment"}}
    market.add_market_item {price = {{"coin", 40}}, offer = {type = "give-item", item = "night-vision-equipment"}}
    market.add_market_item {price = {{"coin", 40}}, offer = {type = "give-item", item = "belt-immunity-equipment"}}
    market.add_market_item {price = {{"coin", 20}}, offer = {type = "give-item", item = "construction-robot"}}
    market.add_market_item {price = {{"coin", 20}}, offer = {type = "give-item", item = "logistic-chest-storage"}}
    market.add_market_item {price = {{"coin", 300}}, offer = {type = "give-item", item = "roboport"}}
end

return Market
