data:extend(
    {
        {
            name = "wills_spaceship_repair-investment_dividend_multiplier",
            type = "double-setting",
            default_value = 10,
            minimum_value = 0,
            setting_type = "runtime-global",
            order = "1001"
        },
        {
            name = "wills_spaceship_repair-investment_cash_multiplier",
            type = "double-setting",
            default_value = 1,
            minimum_value = 0,
            setting_type = "runtime-global",
            order = "1002"
        },
        {
            name = "wills_spaceship_repair-investment_maturity_minutes",
            type = "int-setting",
            default_value = 300,
            minimum_value = 0,
            setting_type = "runtime-global",
            order = "1003"
        },
        {
            name = "wills_spaceship_repair-matured_investment_dividend_hourly_interest",
            type = "double-setting",
            default_value = 2,
            minimum_value = 0,
            setting_type = "runtime-global",
            order = "1004"
        },
        {
            name = "wills_spaceship_repair-workforce_minute_wage",
            type = "int-setting",
            default_value = 10,
            minimum_value = 0,
            setting_type = "runtime-global",
            order = "1005"
        },
        {
            name = "wills_spaceship_repair-starting_debt_ceiling",
            type = "int-setting",
            default_value = 1000000,
            minimum_value = 0,
            setting_type = "runtime-global",
            order = "1006"
        },
        {
            name = "wills_spaceship_repair-profit_target",
            type = "int-setting",
            default_value = 50000,
            minimum_value = 0,
            setting_type = "runtime-global",
            order = "1007"
        },
        {
            name = "wills_spaceship_repair-profit_label",
            type = "string-setting",
            default_value = "Profit",
            setting_type = "runtime-global",
            order = "1008"
        },
        {
            name = "wills_spaceship_repair-primary_player_name",
            type = "string-setting",
            default_value = "YOUR NAME HERE",
            setting_type = "runtime-global",
            order = "1009"
        },
        {
            name = "wills_spaceship_repair-item_delivery_pod_size_cash_values",
            type = "string-setting",
            default_value = '[ {"coinCost":0, "shipSize":"tiny", "radius":150}, {"coinCost":500, "shipSize":"small", "radius":100}, {"coinCost":1000, "shipSize":"medium", "radius":75}, {"coinCost":2500, "shipSize":"large", "radius":50}, {"coinCost":3000, "shipSize":"modular", "radius":50}, {"coinCost":500, "shipSize":"modular-part"} ]',
            allow_blank = true,
            setting_type = "runtime-global",
            order = "1010"
        }
    }
)
