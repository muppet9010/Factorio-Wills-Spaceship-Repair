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
                    recipe = "wills_spaceship_repair-spaceship_thruster"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-fuel_cell"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-protection_field"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-fusion_reactor"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-habitation"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-life_support"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-command_center"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-astrometrics"
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-ftl_propulsion_system"
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
                {"steel-plate", 10000},
                {"low-density-structure", 25000}
            },
            result = "wills_spaceship_repair-hull_component",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-hull_component",
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
                {"processing-unit", 1000},
                {"electric-engine-unit", 1000},
                {"low-density-structure", 1000},
                {"pipe", 1000},
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
                {"steel-plate", 10000},
                {"processing-unit", 10000},
                {"low-density-structure", 10000},
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
            name = "wills_spaceship_repair-protection_field",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"energy-shield-mk2-equipment", 10000}
            },
            result = "wills_spaceship_repair-protection_field",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-protection_field",
            icon = Constants.AssetModName .. "/graphics/spacex/icons/protection-field.png",
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
                {"fusion-reactor-equipment", 200}
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
            name = "wills_spaceship_repair-habitation",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"steel-plate", 10000},
                {"plastic-bar", 50000},
                {"processing-unit", 10000},
                {"low-density-structure", 10000}
            },
            result = "wills_spaceship_repair-habitation",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-habitation",
            icon = Constants.AssetModName .. "/graphics/spacex/icons/habitation.png",
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
                {"processing-unit", 1000},
                {"low-density-structure", 1000},
                {"pipe", 2000},
                {"productivity-module-3", 500}
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
            name = "wills_spaceship_repair-command_center",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"plastic-bar", 1000},
                {"processing-unit", 500},
                {"low-density-structure", 500},
                {"productivity-module-3", 250},
                {"speed-module-3", 250},
                {"effectivity-module-3", 250}
            },
            result = "wills_spaceship_repair-command_center",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-command_center",
            icon = Constants.AssetModName .. "/graphics/spacex/icons/command.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "2000"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-astrometrics",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"processing-unit", 3000},
                {"low-density-structure", 1000},
                {"speed-module-3", 500}
            },
            result = "wills_spaceship_repair-astrometrics",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-astrometrics",
            icon = Constants.AssetModName .. "/graphics/spacex/icons/astrometrics.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "2000"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-ftl_propulsion_system",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"processing-unit", 500},
                {"low-density-structure", 100},
                {"productivity-module-3", 500},
                {"speed-module-3", 500},
                {"effectivity-module-3", 500}
            },
            result = "wills_spaceship_repair-ftl_propulsion_system",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-ftl_propulsion_system",
            icon = Constants.AssetModName .. "/graphics/spacex/icons/ftl-drive.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "2000"
        }
    }
)
