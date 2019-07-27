local Utils = require("utility/utils")
local Constants = require("constants")
local StaticData = {}

StaticData.Orders = {}
StaticData.Orders.slotStates = {
    waitingCapacityTech = {
        name = "waitingCapacityTech",
        timer = nil,
        color = Constants.Colors.white,
        sortValue = 1
    },
    waitingDrydock = {
        name = "waitingDrydock",
        timer = nil,
        color = Constants.Colors.white,
        sortValue = 2
    },
    waitingOrderDecryptionStart = {
        name = "waitingOrderDecryptionStart",
        timer = nil,
        color = Constants.Colors.white,
        sortValue = 3
    },
    waitingOrderDecryptionEnd = {
        name = "waitingOrderDecryptionEnd",
        timer = nil,
        color = Constants.Colors.white,
        sortValue = 4
    },
    waitingItem = {
        name = "waitingItem",
        timer = (60 * 60 * 60 * 6),
        color = Constants.Colors.white,
        sortValue = 5
    },
    waitingCustomerDepart = {
        name = "waitingCustomerDepart",
        timer = (60 * 60 * 10),
        color = Constants.Colors.white,
        sortValue = 0
    },
    orderFailed = {
        name = "orderFailed",
        timer = (60 * 60 * 5),
        color = Constants.Colors.white,
        sortValue = -1
    }
}
StaticData.Orders.timeBonus = {
    [(60 * 60 * 30)] = {modifierPercent = 10, guiColor = Constants.Colors.green},
    [(60 * 60 * 60 * 2)] = {modifierPercent = 0, guiColor = Constants.Colors.yellow},
    [(60 * 60 * 60 * 4)] = {modifierPercent = -10, guiColor = Constants.Colors.orange},
    [(60 * 60 * 60 * 6)] = {modifierPercent = -20, guiColor = Constants.Colors.red}
}
StaticData.Orders.shipParts = {
    ["wills_spaceship_repair-hull_component"] = {
        name = "wills_spaceship_repair-hull_component",
        value = 325000,
        chance = 0,
        multiplePerOrder = {
            {items = 1, chance = 0.6},
            {items = 2, chance = 0.3},
            {items = 3, chance = 0.1}
        }
    },
    ["wills_spaceship_repair-spaceship_thruster"] = {
        name = "wills_spaceship_repair-spaceship_thruster",
        value = 865000,
        chance = 0,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-fuel_cell"] = {
        name = "wills_spaceship_repair-fuel_cell",
        value = 301000,
        chance = 0,
        multiplePerOrder = {
            {items = 1, chance = 0.6},
            {items = 2, chance = 0.3},
            {items = 3, chance = 0.1}
        }
    },
    ["wills_spaceship_repair-fusion_reactor"] = {
        name = "wills_spaceship_repair-fusion_reactor",
        value = 1222000,
        chance = 0,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-life_support"] = {
        name = "wills_spaceship_repair-life_support",
        value = 453000,
        chance = 0,
        multiplePerOrder = {
            {items = 1, chance = 0.6},
            {items = 2, chance = 0.3},
            {items = 3, chance = 0.1}
        }
    },
    ["wills_spaceship_repair-command_systems"] = {
        name = "wills_spaceship_repair-command_systems",
        value = 1480000,
        chance = 0,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-point_defence_ammo"] = {
        name = "wills_spaceship_repair-point_defence_ammo",
        value = 457000,
        chance = 0,
        multiplePerOrder = {
            {items = 1, chance = 0.6},
            {items = 2, chance = 0.3},
            {items = 3, chance = 0.1}
        }
    },
    ["wills_spaceship_repair-point_defence_weapons"] = {
        name = "wills_spaceship_repair-point_defence_weapons",
        value = 649000,
        chance = 0,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-main_weapon_system"] = {
        name = "wills_spaceship_repair-main_weapon_system",
        value = 998000,
        chance = 0,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-shit_ton_of_science"] = {
        name = "wills_spaceship_repair-shit_ton_of_science",
        value = 1721000,
        chance = 0,
        multiplePerOrder = false
    }
}
local totalValue = 0
for _, part in pairs(StaticData.Orders.shipParts) do
    local value = part.value
    if part.multiplePerOrder ~= false then
        local multiplier = 0
        for _, itemChances in ipairs(part.multiplePerOrder) do
            multiplier = multiplier + (itemChances.items * itemChances.chance)
        end
        value = value * multiplier
    end
    part.chance = value
	totalValue = totalValue + value
end
for _, part in pairs(StaticData.Orders.shipParts) do
	part.chance = totalValue / part.chance
end
Utils.NormalisedChanceList(StaticData.Orders.shipParts, "chance")
log(serpent.block(StaticData.Orders.shipParts))

StaticData.Financials = {}
StaticData.Financials.coinCapsules = {
    ["wills_spaceship_repair-wooden_coin_chest_delivery_capsule"] = {
        name = "wills_spaceship_repair-wooden_coin_chest_delivery_capsule",
        value = 1000
    },
    ["wills_spaceship_repair-iron_coin_chest_delivery_capsule"] = {
        name = "wills_spaceship_repair-iron_coin_chest_delivery_capsule",
        value = 10000
    },
    ["wills_spaceship_repair-steel_coin_chest_delivery_capsule"] = {
        name = "wills_spaceship_repair-steel_coin_chest_delivery_capsule",
        value = 100000
    }
}

return StaticData
