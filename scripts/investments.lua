local Investments = {}
local Commands = require("utility/commands")
local Events = require("utility/events")
local Logging = require("utility/logging")
local Constants = require("constants")
local Utils = require("utility/utils")

--[[
    global.Investments.investmentsTable = {
        {
            index = int,
            investorName = string,
            investmentTick = int,
            investmentAmount = int,
            dividend = int,
            interestAcquired = float,
            paid = float,
            paidTick = int,
            owed = float,
            maturityTick = int
        }
    }
]]
local hourTicks = 60 * 60 * 60

function Investments.OnStartup()
    global.Investments = {}
    global.Investments.investmentsTable = {}
    global.Investments.dividendsmultiplier = global.Investments.dividendsmultiplier or 0
    global.Investments.cashmultiplier = global.Investments.cashmultiplier or 0
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
    Commands.Register("wills_spaceship_repair-write_investment_data", {"api-description.wills_spaceship_repair-write_investment_data"}, Investments.WriteOutTableCommand, false)
end

--TODO: some setting changes need to update exisitng data.
function Investments.UpdateSetting(event)
    local settingName
    if event ~= nil then
        settingName = event.setting
    end
    if settingName == "wills_spaceship_repair-investment_dividend_multiplier" or settingName == nil then
        global.Investments.dividendsmultiplier = tonumber(settings.global["wills_spaceship_repair-investment_dividend_multiplier"].value)
    end
    if settingName == "wills_spaceship_repair-investment_cash_multiplier" or settingName == nil then
        global.Investments.cashmultiplier = tonumber(settings.global["wills_spaceship_repair-investment_cash_multiplier"].value)
    end
    if settingName == "wills_spaceship_repair-investment_maturity_minutes" or settingName == nil then
        global.Investments.maturityTicks = tonumber(settings.global["wills_spaceship_repair-investment_maturity_minutes"].value) * 60 * 60
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
    local dividend = math.floor(investorAmount * global.Investments.dividendsmultiplier)
    local maturityTick = tick + global.Investments.maturityTicks
    local instantCash = math.floor(investorAmount * global.Investments.cashmultiplier)
    local investment = {
        index = investmentIndex,
        investorName = investorName,
        investmentTick = tick,
        investmentAmount = investorAmount,
        instantCash = instantCash,
        dividend = dividend,
        interestAcquired = 0,
        paid = 0,
        paidTick = "",
        owed = dividend,
        maturityTick = maturityTick
    }
    global.Investments.investmentsTable[investmentIndex] = investment
    global.Investments.dividendsTotal = global.Investments.dividendsTotal + dividend
    Events.ScheduleEvent(maturityTick, "Investments.AddInterest", investmentIndex)
    game.print({"message.wills_spaceship_repair-investment_added", investorName, investorAmount})

    local coinCount = instantCash
    coinCount = coinCount - global.Market.coinBoxEntity.insert({name = "coin", count = coinCount})
    if coinCount > 0 then
        global.Market.coinBoxEntity.surface.spill_item_stack(global.Market.coinBoxEntity.position, {name = "coin", count = coinCount}, true, nil, true)
    end
end

function Investments.PayInvestors(amount)
    Logging.Log("PayInvestors start: " .. amount)
    Logging.Log("Start: " .. Utils.TableContentsToJSON(global.Investments.investmentsTable))
    local tick = game.tick
    local outstandingInvestments = {}
    for _, investment in ipairs(global.Investments.investmentsTable) do
        if investment.owed > 0 then
            table.insert(outstandingInvestments, investment)
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
            investment.paidTick = tick
            Events.RemoveScheduledEvent("Investments.AddInterest", investment.index)
        end
        investment.paid = investment.paid + given
        if amount == 0 then
            break
        end
    end
    Logging.Log("End: " .. Utils.TableContentsToJSON(global.Investments.investmentsTable))
    Logging.Log("PayInvestors end: " .. amount)
    return amount
end

function Investments.InvestorsIndexSortedByMaturityTime(investmentA, investmentB)
    if investmentA.maturityTick < investmentB.maturityTick then
        return true
    else
        return false
    end
end

function Investments.AddInterest(event)
    local tick = event.tick
    local investmentIndex = event.instanceId
    local investment = global.Investments.investmentsTable[investmentIndex]
    local interest = investment.owed * global.Investments.hourlyInterestRate
    investment.interestAcquired = investment.interestAcquired + interest
    investment.owed = investment.owed + interest
    Events.ScheduleEvent(tick + hourTicks, "Investments.AddInterest", investmentIndex)
end

function Investments.WriteOutTableCommand(commandData)
    local player = game.get_player(commandData.player_index)
    game.write_file(Constants.ModName .. "-investments_table.json", Utils.TableContentsToJSON(global.Investments.investmentsTable), false, player.index)
    player.print({"message.wills_spaceship_repair-investments_table_written"})
end

return Investments
