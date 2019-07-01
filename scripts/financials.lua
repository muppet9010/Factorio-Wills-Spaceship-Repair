local Financials = {}
local Events = require("utility/events")
local Investments = require("scripts/investments")
--local Logging = require("utility/logging")

Financials.coinCapsules = {
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

function Financials.OnStartup()
    global.Financials = global.Financials or {}
    global.Financials.profitMade = global.Financials.profitMade or 0
    global.Financials.profitTarget = global.Financials.profitTarget or 0
    global.Financials.bankruptcyLimit = global.Financials.bankruptcyLimit or 0
    global.Financials.wagesPaid = global.Financials.wagesPaid or 0
    global.Financials.wagesTotal = global.Financials.wagesTotal or 0
    global.Financials.workforceMinuteWage = global.Financials.workforceMinuteWage or 0
    global.Financials.startingDebtCeiling = global.Financials.startingDebtCeiling or 0
    global.Financials.profitTarget = global.Financials.profitTarget or 0

    Events.ScheduleEvent(3600, "Financials.AddWages")

    Financials.UpdateSetting(nil)
    Financials.OnLoad()
end

function Financials.OnLoad()
    Events.RegisterHandler(defines.events.on_rocket_launched, "Financials", Financials.OnRocketLaunched)
    Events.RegisterScheduledEventType("Financials.AddWages", Financials.AddWages)
    Events.RegisterHandler(defines.events.on_runtime_mod_setting_changed, "Financials", Financials.UpdateSetting)
end

function Financials.UpdateSetting(event)
    local settingName
    if event ~= nil then
        settingName = event.setting
    end
    if settingName == "wills_spaceship_repair-workforce_minute_wage" or settingName == nil then
        global.Financials.workforceMinuteWage = tonumber(settings.global["wills_spaceship_repair-workforce_minute_wage"].value)
    end
    if settingName == "wills_spaceship_repair-starting_debt_ceiling" or settingName == nil then
        global.Financials.startingDebtCeiling = tonumber(settings.global["wills_spaceship_repair-starting_debt_ceiling"].value)
        Financials.UpdateBankruptcyLimit()
    end
    if settingName == "wills_spaceship_repair-profit_target" or settingName == nil then
        global.Financials.profitTarget = tonumber(settings.global["wills_spaceship_repair-profit_target"].value)
    end
end

function Financials.OnRocketLaunched(event)
    local rocket = event.rocket
    for name in pairs(rocket.get_inventory(defines.inventory.rocket).get_contents()) do
        if Financials.coinCapsules[name] ~= nil then
            Financials.CoinCapsuleLaunched(name)
        end
    end
end

function Financials.CoinCapsuleLaunched(name)
    local capsuleValue = Financials.coinCapsules[name].value
    global.playerForce.item_production_statistics.on_flow("coin", -capsuleValue)

    local wagesOwed = global.Financials.wagesTotal - global.Financials.wagesPaid
    if wagesOwed > 0 then
        local valueToWages
        if wagesOwed > capsuleValue then
            valueToWages = capsuleValue
        else
            valueToWages = wagesOwed
        end
        global.Financials.wagesPaid = global.Financials.wagesPaid + valueToWages
        capsuleValue = capsuleValue - valueToWages
    end
    if capsuleValue == 0 then
        return
    end

    capsuleValue = Investments.PayInvestors(capsuleValue)
    if capsuleValue == 0 then
        return
    end

    global.Financials.profitMade = global.Financials.profitMade + capsuleValue
end

function Financials.AddWages(event)
    Events.ScheduleEvent(event.tick + 3600, "Financials.AddWages")
    local workforceCount = #game.connected_players - 1
    if workforceCount < 1 then
        return
    end
    global.Financials.wagesTotal = global.Financials.wagesTotal + math.floor(workforceCount * global.Financials.workforceMinuteWage)
end

function Financials.UpdateBankruptcyLimit()
    local limit = global.Financials.startingDebtCeiling
    for _, investment in pairs(global.Investments.investmentsTable) do
        limit = limit + investment.dividend
    end
    global.Financials.bankruptcyLimit = limit
end

return Financials
