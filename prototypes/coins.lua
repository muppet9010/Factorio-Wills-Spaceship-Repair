local Constants = require("constants")
local Utils = require("utility/utils")

local coin = data.raw["item"]["coin"]
coin.stack_size = 100
coin.subgroup = "wills_spaceship_repair"
coin.order = "z"
table.remove(coin.flags, Utils.GetTableKeyWithValue(coin, "hidden"))

local rocketSiloTech = data.raw["technology"]["rocket-silo"]
table.insert(rocketSiloTech.effects, {type = "unlock-recipe", recipe = "wills_spaceship_repair-empty_coin_delivery_capsule"})
table.insert(rocketSiloTech.effects, {type = "unlock-recipe", recipe = "wills_spaceship_repair-wooden_coin_chest_delivery_capsule"})
table.insert(rocketSiloTech.effects, {type = "unlock-recipe", recipe = "wills_spaceship_repair-iron_coin_chest_delivery_capsule"})
table.insert(rocketSiloTech.effects, {type = "unlock-recipe", recipe = "wills_spaceship_repair-steel_coin_chest_delivery_capsule"})
for i, effect in ipairs(rocketSiloTech.effects) do
    if effect.type == "unlock-recipe" and effect.recipe == "rocket-silo" then
        table.remove(rocketSiloTech.effects, i)
        break
    end
end

data:extend(
    {
        {
            type = "item",
            name = "wills_spaceship_repair-wooden_coin_chest",
            icon = Constants.AssetModName .. "/graphics/icons/wooden_coin_chest.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            order = "z",
            stack_size = 1
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-wooden_coin_chest",
            energy_required = 30,
            enabled = false,
            hidden = true,
            category = "coins",
            hide_from_stats = true,
            allow_decomposition = false,
            ingredients = {
                {"wooden-chest", 10},
                {"coin", 1000}
            },
            result = "wills_spaceship_repair-wooden_coin_chest",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-iron_coin_chest",
            icon = Constants.AssetModName .. "/graphics/icons/iron_coin_chest.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            order = "z",
            stack_size = 1
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-iron_coin_chest",
            energy_required = 60,
            enabled = false,
            hidden = true,
            category = "coins",
            hide_from_stats = true,
            allow_decomposition = false,
            ingredients = {
                {"iron-chest", 10},
                {"wills_spaceship_repair-wooden_coin_chest", 10}
            },
            result = "wills_spaceship_repair-iron_coin_chest",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-steel_coin_chest",
            icon = Constants.AssetModName .. "/graphics/icons/steel_coin_chest.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            order = "z",
            stack_size = 1
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-steel_coin_chest",
            energy_required = 60,
            enabled = false,
            hidden = true,
            category = "coins",
            hide_from_stats = true,
            allow_decomposition = false,
            ingredients = {
                {"steel-chest", 10},
                {"wills_spaceship_repair-iron_coin_chest", 10}
            },
            result = "wills_spaceship_repair-steel_coin_chest",
            requester_paste_multiplier = 1
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-empty_coin_delivery_capsule",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            hide_from_stats = true,
            ingredients = {
                {"low-density-structure", 100},
                {"solar-panel", 10},
                {"accumulator", 10},
                {"radar", 5},
                {"processing-unit", 10},
                {"rocket-fuel", 50}
            },
            result = "wills_spaceship_repair-empty_coin_delivery_capsule",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-empty_coin_delivery_capsule",
            icon = Constants.AssetModName .. "/graphics/icons/empty_coin_delivery_capsule.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "3000"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-wooden_coin_chest_delivery_capsule",
            energy_required = 10,
            enabled = false,
            category = "crafting",
            hide_from_stats = true,
            ingredients = {
                {"wills_spaceship_repair-empty_coin_delivery_capsule", 1},
                {"wills_spaceship_repair-wooden_coin_chest", 1}
            },
            result = "wills_spaceship_repair-wooden_coin_chest_delivery_capsule",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-wooden_coin_chest_delivery_capsule",
            icon = Constants.AssetModName .. "/graphics/icons/wooden_coin_chest_delivery_capsule.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "3001"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-iron_coin_chest_delivery_capsule",
            energy_required = 10,
            enabled = false,
            category = "crafting",
            hide_from_stats = true,
            ingredients = {
                {"wills_spaceship_repair-empty_coin_delivery_capsule", 1},
                {"wills_spaceship_repair-iron_coin_chest", 1}
            },
            result = "wills_spaceship_repair-iron_coin_chest_delivery_capsule",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-iron_coin_chest_delivery_capsule",
            icon = Constants.AssetModName .. "/graphics/icons/iron_coin_chest_delivery_capsule.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "3002"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-steel_coin_chest_delivery_capsule",
            energy_required = 10,
            enabled = false,
            category = "crafting",
            hide_from_stats = true,
            ingredients = {
                {"wills_spaceship_repair-empty_coin_delivery_capsule", 1},
                {"wills_spaceship_repair-steel_coin_chest", 1}
            },
            result = "wills_spaceship_repair-steel_coin_chest_delivery_capsule",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-steel_coin_chest_delivery_capsule",
            icon = Constants.AssetModName .. "/graphics/icons/steel_coin_chest_delivery_capsule.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "3003"
        }
    }
)
