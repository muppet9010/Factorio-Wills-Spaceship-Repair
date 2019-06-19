local Constants = require("constants")

data:extend(
    {
        {
            type = "technology",
            name = "wills_spaceship_repair-recruit_workforce_member-1",
            icon_size = 114,
            icon = Constants.AssetModName .. "/graphics/technology/recruit-workforce-member.png",
            prerequisites = {},
            unit = {
                count_formula = "5000",
                ingredients = {
                    {"automation-science-pack", 1}
                },
                time = 60
            },
            upgrade = true,
            max_level = 1,
            order = "zzz"
        },
        {
            type = "technology",
            name = "wills_spaceship_repair-recruit_workforce_member-2",
            icon_size = 114,
            icon = Constants.AssetModName .. "/graphics/technology/recruit-workforce-member.png",
            prerequisites = {"logistic-science-pack", "wills_spaceship_repair-recruit_workforce_member-1"},
            unit = {
                count_formula = "5000",
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1}
                },
                time = 60
            },
            upgrade = true,
            max_level = 2,
            order = "zzz"
        },
        {
            type = "technology",
            name = "wills_spaceship_repair-recruit_workforce_member-3",
            icon_size = 114,
            icon = Constants.AssetModName .. "/graphics/technology/recruit-workforce-member.png",
            prerequisites = {"wills_spaceship_repair-recruit_workforce_member-2", "military-science-pack"},
            unit = {
                count_formula = "5000",
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"military-science-pack", 1}
                },
                time = 60
            },
            upgrade = true,
            max_level = 3,
            order = "zzz"
        },
        {
            type = "technology",
            name = "wills_spaceship_repair-recruit_workforce_member-4",
            icon_size = 114,
            icon = Constants.AssetModName .. "/graphics/technology/recruit-workforce-member.png",
            prerequisites = {"wills_spaceship_repair-recruit_workforce_member-3", "chemical-science-pack"},
            unit = {
                count_formula = "5000",
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"military-science-pack", 1},
                    {"chemical-science-pack", 1}
                },
                time = 60
            },
            upgrade = true,
            max_level = 4,
            order = "zzz"
        },
        {
            type = "technology",
            name = "wills_spaceship_repair-recruit_workforce_member-5",
            icon_size = 114,
            icon = Constants.AssetModName .. "/graphics/technology/recruit-workforce-member.png",
            prerequisites = {"wills_spaceship_repair-recruit_workforce_member-4", "production-science-pack"},
            unit = {
                count_formula = "5000",
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"military-science-pack", 1},
                    {"chemical-science-pack", 1},
                    {"production-science-pack", 1}
                },
                time = 60
            },
            upgrade = true,
            max_level = 5,
            order = "zzz"
        },
        {
            type = "technology",
            name = "wills_spaceship_repair-recruit_workforce_member-6",
            icon_size = 114,
            icon = Constants.AssetModName .. "/graphics/technology/recruit-workforce-member.png",
            prerequisites = {"wills_spaceship_repair-recruit_workforce_member-5", "utility-science-pack"},
            unit = {
                count_formula = "5000",
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"military-science-pack", 1},
                    {"chemical-science-pack", 1},
                    {"production-science-pack", 1},
                    {"utility-science-pack", 1}
                },
                time = 60
            },
            upgrade = true,
            max_level = 6,
            order = "zzz"
        },
        {
            type = "technology",
            name = "wills_spaceship_repair-recruit_workforce_member-7",
            icon_size = 114,
            icon = Constants.AssetModName .. "/graphics/technology/recruit-workforce-member.png",
            prerequisites = {"wills_spaceship_repair-recruit_workforce_member-6", "space-science-pack"},
            unit = {
                count_formula = "(2^(L-6))*2500",
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
            max_level = "9",
            order = "zzz"
        }
    }
)
