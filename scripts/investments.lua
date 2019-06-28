local Investments = {}
local Commands = require("utility/commands")
local Events = require("utility/events")
local Logging = require("utility/logging")

--[[
    global.Investments.investmentsTable = {
        {
            index = int,
            investorName = string,
            investmentTick = int,
            investmentAmount = int,
            dividend = int,
            interestAcquired = float,
            payed = float,
            owed = float,
            maturityTick = int
        }
    }
]]
local hourTicks = 60 * 60 * 60

function Investments.OnStartup()
    global.Investments = {}
    global.Investments.investmentsTable = {}
    global.Investments.dividendsMultiplyer = global.Investments.dividendsMultiplyer or 0
    global.Investments.cashMultiplyer = global.Investments.cashMultiplyer or 0
    global.Investments.maturityTicks = global.Investments.maturityTicks or 0
    global.Investments.hourlyInterestRate = global.Investments.hourlyInterestRate or 0
    global.Investments.dividendsPaid = global.Investments.dividendsPaid or 0
    global.Investments.dividendsTotal = global.Investments.dividendsTotal or 0

    Investments.UpdateSetting(nil)
    Investments.OnLoad()
end

function Investments.OnLoad()
    Commands.Register("wills_spaceship_repair-add_investment", {"api-description.wills_spaceship_repair-add_investment"}, Investments.AddInvestmentCommand, true)
    Events.RegisterHandler(defines.events.on_runtime_mod_setting_changed, "Investments", Investments.UpdateSetting)
    Events.RegisterScheduledEventType("Investments.AddInterest", Investments.AddInterest)
end

function Investments.UpdateSetting(settingName)
    if settingName == "wills_spaceship_repair-investment_dividend_multiplyer" or settingName == nil then
        global.Investments.dividendsMultiplyer = tonumber(settings.global["wills_spaceship_repair-investment_dividend_multiplyer"].value)
    end
    if settingName == "wills_spaceship_repair-investment_cash_multiplyer" or settingName == nil then
        global.Investments.cashMultiplyer = tonumber(settings.global["wills_spaceship_repair-investment_cash_multiplyer"].value)
    end
    if settingName == "wills_spaceship_repair-investment_maturity_minutes" or settingName == nil then
        global.Investments.maturityTicks = tonumber(settings.global["wills_spaceship_repair-investment_maturity_minutes"].value) * 60 --TODO: removed a *60 to test
    end
    if settingName == "wills_spaceship_repair-matured_investment_dividend_hourly_interest" or settingName == nil then
        global.Investments.hourlyInterestRate = tonumber(settings.global["wills_spaceship_repair-matured_investment_dividend_hourly_interest"].value) / 100
    end
end

function Investments.AddInvestmentCommand(command)
    local tick = command.tick
    local args = Commands.GetArgumentsFromCommand(command.parameter)
    local investorName = args[1]
    if investorName == nil or investorName == "" then
        game.print("Investor name can not be blank in Add Investor command arguments: " .. command.parameter)
        return
    end
    local investorAmount = args[2]
    if investorAmount == nil or investorAmount == "" then
        game.print("Investor amount can not be blank in Add Investor command arguments: " .. command.parameter)
        return
    end
    investorAmount = tonumber(investorAmount)
    if investorAmount == nil or math.floor(investorAmount) ~= investorAmount then
        game.print("Investor amount must be a whole number for Add Investor command arguments: " .. command.parameter)
        return
    end
    if args[3] ~= nil then
        game.print("Too many arguments to command Add Investor: " .. command.parameter)
        return
    end

    local investmentIndex = #global.Investments.investmentsTable + 1
    local dividend = investorAmount * global.Investments.dividendsMultiplyer
    local investment = {
        index = investmentIndex,
        investorName = investorName,
        investmentTick = tick,
        investmentAmount = investorAmount,
        dividend = dividend,
        interestAcquired = 0,
        payed = 0,
        owed = dividend,
        maturityTick = tick + global.Investments.maturityTicks
    }
    global.Investments.investmentsTable[investmentIndex] = investment
    global.Investments.dividendsTotal = global.Investments.dividendsTotal + dividend
    Events.ScheduleEvent(tick + global.Investments.maturityTicks, "Investments.AddInterest", investmentIndex)
    game.print({"message.wills_spaceship_repair-investment_added", investorName, investorAmount})
    --TODO pay the instant cash
    Logging.Log(serpent.block(global.Investments.investmentsTable))
end

--TODO: not tested yet
function Investments.PayInvestors(amount)
    local outstandingInvestments = {}
    for _, investment in ipairs(global.Investments.investmentsTable) do
        if investment.owed > 0 then
            table.insert(outstandingInvestments, investment.index)
        end
    end
    table.sort(outstandingInvestments, Investments.InvestorsIndexSortedByMaturityTime)
    for _, investment in ipairs(outstandingInvestments) do
        local given = amount
        if amount > investment.owed then
            given = investment.owed
        end
        amount = amount - given
        investment.owed = investment.owed - given
        if investment.owed == 0 then
            Events.RemoveScheduledEvent("Investments.AddInterest", investment.index)
        end
        investment.payed = investment.payed + given
        if amount == 0 then
            break
        end
    end
    return amount
end

function Investments.InvestorsIndexSortedByMaturityTime(a, b)
    local tick = game.tick
    if (a.maturityTick - tick) < (b.maturityTick - tick) then
        return true
    else
        return false
    end
end

function Investments.AddInterest(event)
    Logging.Log(serpent.block(event))
    local tick = event.tick
    local investmentIndex = event.instanceId
    local investment = global.Investments.investmentsTable[investmentIndex]
    local interest = investment.owed * global.Investments.hourlyInterestRate
    investment.interestAcquired = investment.interestAcquired + interest
    investment.owed = investment.owed + interest
    Events.ScheduleEvent(tick + hourTicks, "Investments.AddInterest", investmentIndex)
    Logging.Log(serpent.block(global.Investments.investmentsTable))
end

return Investments
