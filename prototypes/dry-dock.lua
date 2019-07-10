local Constants = require("constants")

data:extend(
    {
        {
            type = "technology",
            name = "wills_spaceship_repair-dry_dock-1",
            icon_size = 128,
            icon = Constants.AssetModName .. "/graphics/spacex/technology/space-assembly.png",
            effects = {
                {
                    type = "nothing",
                    effect_description = {"technology-effect.wills_spaceship_repair-dry_dock"}
                },
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-dry_dock"
                }
            },
            prerequisites = {"space-science-pack"},
            unit = {
                count = "10000",
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
            upgrade = true,
            max_level = 1,
            order = "zzz"
        },
        {
            type = "technology",
            name = "wills_spaceship_repair-dry_dock-2",
            icon_size = 128,
            icon = Constants.AssetModName .. "/graphics/spacex/technology/space-assembly.png",
            localised_name = {"technology-name.wills_spaceship_repair-dry_dock_increase"},
            effects = {
                {
                    type = "nothing",
                    effect_description = {"technology-effect.wills_spaceship_repair-dry_dock"}
                }
            },
            prerequisites = {"space-science-pack"},
            unit = {
                count = "10000",
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
            upgrade = true,
            max_level = "infinite",
            order = "zzz"
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-dry_dock",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"low-density-structure", 2000},
                {"solar-panel", 200},
                {"roboport", 10},
                {"processing-unit", 200},
                {"construction-robot", 200}
            },
            result = "wills_spaceship_repair-dry_dock",
            requester_paste_multiplier = 1
        },
        {
            type = "item",
            name = "wills_spaceship_repair-dry_dock",
            icon = Constants.AssetModName .. "/graphics/spacex/icons/drydock-assembly.png",
            icon_size = 32,
            subgroup = "wills_spaceship_repair",
            stack_size = 1,
            order = "1000"
        }
    }
)
