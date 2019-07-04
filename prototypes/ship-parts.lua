local Constants = require("constants")

data:extend(
    {
        {
            type = "technology",
            name = "wills_spaceship_repair-ship_parts",
            icon_size = 128,
            icon = Constants.AssetModName .. "/graphics/spacex/technology/space-casings.png",
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-hull_component"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-hull_panel"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-spaceship_thruster"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-fuel_cell"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-point_defence_ammo"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-fusion_reactor"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-point_defence_weapons"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-life_support"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-command_systems"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-main_weapon_system"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-shit_ton_of_science"
                }
            },
            prerequisites = {"wills_spaceship_repair-dry_dock-1"},
            unit = {
                count = "50000",
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"military-science-pack", 1},
                    {"chemical-science-pack", 1},
                    {"production-science-pack", 1},
                    {"utility-science-pack", 1},
                    {"space-science-pack", 1}
                },
                time = 60
            },
            order = "zzz"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-hull_component",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"wills_spaceship_repair-hull_panel", 10}
            },
            result = "wills_spaceship_repair-hull_component",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-hull_component",
            icon = Constants.AssetModName .. "/graphics/spacex/icons/habitation.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "2000"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-hull_panel",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"steel-plate", 1000},
                {"low-density-structure", 2500}
            },
            result = "wills_spaceship_repair-hull_panel",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-hull_panel",
            icon = Constants.AssetModName .. "/graphics/spacex/icons/hull-component.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "2000"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-spaceship_thruster",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"wills_spaceship_repair-hull_panel", 1},
                {"electric-engine-unit", 5000},
                {"heat-exchanger", 1000},
                {"speed-module-3", 500}
            },
            result = "wills_spaceship_repair-spaceship_thruster",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-spaceship_thruster",
            icon = Constants.AssetModName .. "/graphics/spacex/icons/space-thruster.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "2000"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-fuel_cell",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"heat-pipe", 6000},
                {"uranium-fuel-cell", 25000}
            },
            result = "wills_spaceship_repair-fuel_cell",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-fuel_cell",
            icon = Constants.AssetModName .. "/graphics/spacex/icons/fuel-cell.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "2000"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-fusion_reactor",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"processing-unit", 3000},
                {"nuclear-reactor", 350}
            },
            result = "wills_spaceship_repair-fusion_reactor",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-fusion_reactor",
            icon = Constants.AssetModName .. "/graphics/spacex/icons/fusion-reactor.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "2000"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-life_support",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"heat-exchanger", 3000},
                {"heat-pipe", 3000},
                {"lab", 3000},
                {"steam-turbine", 3000}
            },
            result = "wills_spaceship_repair-life_support",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-life_support",
            icon = Constants.AssetModName .. "/graphics/spacex/icons/life-support.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "2000"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-command_systems",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"processing-unit", 500},
                {"satellite", 250},
                {"arithmetic-combinator", 1000},
                {"decider-combinator", 1000},
                {"constant-combinator", 1000},
                {"red-wire", 1000},
                {"green-wire", 1000}
            },
            result = "wills_spaceship_repair-command_systems",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-command_systems",
            icon = Constants.AssetModName .. "/graphics/spacex/icons/command.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "2000"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-point_defence_ammo",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"uranium-rounds-magazine", 10000},
                {"explosive-rocket", 10000},
                {"cluster-grenade", 10000}
            },
            result = "wills_spaceship_repair-point_defence_ammo",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-point_defence_ammo",
            icon = "__base__/graphics/technology/weapon-shooting-speed-2.png",
            icon_size = 128,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "2000"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-point_defence_weapons",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"gun-turret", 6000},
                {"laser-turret", 6000}
            },
            result = "wills_spaceship_repair-point_defence_weapons",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-point_defence_weapons",
            icon = "__base__/graphics/technology/turrets.png",
            icon_size = 128,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "2000"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-main_weapon_system",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"artillery-turret", 750},
                {"artillery-shell", 20000}
            },
            result = "wills_spaceship_repair-main_weapon_system",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-main_weapon_system",
            icon = "__base__/graphics/technology/artillery.png",
            icon_size = 128,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "2000"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-shit_ton_of_science",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"automation-science-pack", 10000},
                {"logistic-science-pack", 10000},
                {"military-science-pack", 10000},
                {"chemical-science-pack", 10000},
                {"production-science-pack", 10000},
                {"utility-science-pack", 10000},
                {"space-science-pack", 10000}
            },
            result = "wills_spaceship_repair-shit_ton_of_science",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-shit_ton_of_science",
            icon = Constants.AssetModName .. "/graphics/icons/all_science.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "2000"
        }
    }
)
