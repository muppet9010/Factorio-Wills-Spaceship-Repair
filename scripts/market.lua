local Market = {}
local Logging = require("utility/logging")

Market.OnStartup = function()
    if global.marketEntity == nil then
        global.marketEntity = Market.CreateMarketEntity(game.surfaces[1], {0, 0}, 20)
        if global.marketEntity == nil then
            Logging.LogPrint("ERROR: Failed to create market")
        end
        Market.PopulateMarketItems(global.marketEntity)
    end
end

Market.OnLoad = function()
end

Market.CreateMarketEntity = function(surface, centerPos, radius)
    local pos
    while pos == nil do
        pos = surface.find_non_colliding_position("market", centerPos, radius, 1, true)
        radius = radius * 2
    end
    local market = surface.create_entity {name = "market", position = pos, force = "player"}
    if market ~= nil then
        market.destructible = false
    end
    return market
end

Market.PopulateMarketItems = function(market)
    market.add_market_item {price = {{"coin", 200}}, offer = {type = "give-item", item = "modular-armor"}}
    market.add_market_item {price = {{"coin", 1300}}, offer = {type = "give-item", item = "power-armor"}}
    market.add_market_item {price = {{"wills_spaceship_repair-wooden_coin_chest", 1}, {"coin", 300}}, offer = {type = "give-item", item = "power-armor"}}
    market.add_market_item {price = {{"coin", 15000}}, offer = {type = "give-item", item = "power-armor-mk2"}}
    market.add_market_item {price = {{"wills_spaceship_repair-wooden_coin_chest", 15}}, offer = {type = "give-item", item = "power-armor-mk2"}}
    market.add_market_item {price = {{"coin", 40}}, offer = {type = "give-item", item = "solar-panel-equipment"}}
    market.add_market_item {price = {{"coin", 6200}}, offer = {type = "give-item", item = "fusion-reactor-equipment"}}
    market.add_market_item {price = {{"wills_spaceship_repair-wooden_coin_chest", 6}, {"coin", 200}}, offer = {type = "give-item", item = "fusion-reactor-equipment"}}
    market.add_market_item {price = {{"coin", 40}}, offer = {type = "give-item", item = "energy-shield-equipment"}}
    market.add_market_item {price = {{"coin", 5700}}, offer = {type = "give-item", item = "energy-shield-mk2-equipment"}}
    market.add_market_item {price = {{"wills_spaceship_repair-wooden_coin_chest", 5}, {"coin", 700}}, offer = {type = "give-item", item = "energy-shield-mk2-equipment"}}
    market.add_market_item {price = {{"coin", 30}}, offer = {type = "give-item", item = "battery-equipment"}}
    market.add_market_item {price = {{"coin", 750}}, offer = {type = "give-item", item = "battery-mk2-equipment"}}
    market.add_market_item {price = {{"coin", 1000}}, offer = {type = "give-item", item = "personal-laser-defense-equipment"}}
    market.add_market_item {price = {{"wills_spaceship_repair-wooden_coin_chest", 1}}, offer = {type = "give-item", item = "personal-laser-defense-equipment"}}
    market.add_market_item {price = {{"coin", 500}}, offer = {type = "give-item", item = "exoskeleton-equipment"}}
    market.add_market_item {price = {{"coin", 200}}, offer = {type = "give-item", item = "personal-roboport-equipment"}}
    market.add_market_item {price = {{"coin", 4000}}, offer = {type = "give-item", item = "personal-roboport-mk2-equipment"}}
    market.add_market_item {price = {{"wills_spaceship_repair-wooden_coin_chest", 4}}, offer = {type = "give-item", item = "personal-roboport-mk2-equipment"}}
    market.add_market_item {price = {{"coin", 40}}, offer = {type = "give-item", item = "night-vision-equipment"}}
    market.add_market_item {price = {{"coin", 40}}, offer = {type = "give-item", item = "belt-immunity-equipment"}}
    market.add_market_item {price = {{"coin", 20}}, offer = {type = "give-item", item = "construction-robot"}}
    market.add_market_item {price = {{"coin", 20}}, offer = {type = "give-item", item = "logistic-chest-storage"}}
    market.add_market_item {price = {{"coin", 300}}, offer = {type = "give-item", item = "roboport"}}
end

return Market
