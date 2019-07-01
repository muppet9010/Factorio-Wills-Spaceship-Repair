local Utils = require("utility/utils")
local StaticData = {}

StaticData.Orders = {}
StaticData.Orders.slotStates = {
    waitingCapacityTech = {
        name = "waitingCapacityTech",
        timer = nil,
        color = {r = 255, g = 255, b = 255, a = 255},
        sortValue = 1
    },
    waitingDrydock = {
        name = "waitingDrydock",
        timer = nil,
        color = {r = 255, g = 255, b = 255, a = 255},
        sortValue = 2
    },
    waitingOrderDecryptionStart = {
        name = "waitingOrderDecryptionStart",
        timer = nil,
        color = {r = 255, g = 255, b = 255, a = 255},
        sortValue = 3
    },
    waitingOrderDecryptionEnd = {
        name = "waitingOrderDecryptionEnd",
        timer = nil,
        color = {r = 255, g = 255, b = 255, a = 255},
        sortValue = 4
    },
    waitingItem = {
        name = "waitingItem",
        timer = (60 * 60 * 60 * 6),
        color = {r = 255, g = 255, b = 255, a = 255},
        sortValue = 5
    },
    waitingCustomerDepart = {
        name = "waitingCustomerDepart",
        timer = (60 * 60 * 1),
        color = {r = 0, g = 255, b = 0, a = 255},
        sortValue = 0
    },
    orderFailed = {
        name = "orderFailed",
        timer = (60 * 60 * 5),
        color = {r = 255, g = 0, b = 0, a = 255},
        sortValue = -1
    }
}
StaticData.Orders.timeBonus = {
    [(60 * 60 * 30)] = {modifierPercent = 10, guiColor = {r = 0, g = 255, b = 0, a = 255}},
    [(60 * 60 * 60 * 2)] = {modifierPercent = 0, guiColor = {r = 255, g = 255, b = 0, a = 255}},
    [(60 * 60 * 60 * 4)] = {modifierPercent = -10, guiColor = {r = 255, g = 130, b = 0, a = 255}},
    [(60 * 60 * 60 * 6)] = {modifierPercent = -20, guiColor = {r = 255, g = 0, b = 0, a = 255}}
}
StaticData.Orders.shipParts = {
    ["wills_spaceship_repair-hull_component"] = {
        name = "wills_spaceship_repair-hull_component",
        value = 325000,
        chance = 0.1687,
        multiplePerOrder = {
            {items = 1, chance = 0.6},
            {items = 2, chance = 0.3},
            {items = 3, chance = 0.1}
        }
    },
    ["wills_spaceship_repair-spaceship_thruster"] = {
        name = "wills_spaceship_repair-spaceship_thruster",
        value = 80000,
        chance = 0.1054,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-fuel_cell"] = {
        name = "wills_spaceship_repair-fuel_cell",
        value = 450000,
        chance = 0.1246,
        multiplePerOrder = {
            {items = 1, chance = 0.6},
            {items = 2, chance = 0.3},
            {items = 3, chance = 0.1}
        }
    },
    ["wills_spaceship_repair-protection_field"] = {
        name = "wills_spaceship_repair-protection_field",
        value = 575000,
        chance = 0.0962,
        multiplePerOrder = {
            {items = 1, chance = 0.6},
            {items = 2, chance = 0.3},
            {items = 3, chance = 0.1}
        }
    },
    ["wills_spaceship_repair-fusion_reactor"] = {
        name = "wills_spaceship_repair-fusion_reactor",
        value = 1254000,
        chance = 0.0668,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-habitation"] = {
        name = "wills_spaceship_repair-habitation",
        value = 450000,
        chance = 0.1218,
        multiplePerOrder = {
            {items = 1, chance = 0.6},
            {items = 2, chance = 0.3},
            {items = 3, chance = 0.1}
        }
    },
    ["wills_spaceship_repair-life_support"] = {
        name = "wills_spaceship_repair-life_support",
        value = 780000,
        chance = 0.1068,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-command_center"] = {
        name = "wills_spaceship_repair-command_center",
        value = 1130000,
        chance = 0.0734,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-astrometrics"] = {
        name = "wills_spaceship_repair-astrometrics",
        value = 840000,
        chance = 0.0991,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-ftl_propulsion_system"] = {
        name = "wills_spaceship_repair-ftl_propulsion_system",
        value = 2236000,
        chance = 0.0367,
        multiplePerOrder = false
    }
}
Utils.NormalisedChanceList(StaticData.Orders.shipParts, "chance")

StaticData.Financials = {}
StaticData.Financials.coinCapsules = {
    ["wills_spaceship_repair-wooden_coin_chest_delivery_capsule"] = {
        name = "wills_spaceship_repair-wooden_coin_chest_delivery_capsule",
        value = 1000
    },
    ["wills_spaceship_repair-iron_coin_chest_delivery_capsule"] = {
        name = "wills_spaceship_repair-iron_coin_chest_delivery_capsule",
        value = 25000
    },
    ["wills_spaceship_repair-steel_coin_chest_delivery_capsule"] = {
        name = "wills_spaceship_repair-steel_coin_chest_delivery_capsule",
        value = 500000
    }
}

return StaticData
