local Events = require("utility/events")
local Utils = require("utility/utils")
local RecruitWorkforce = require("scripts/recruit-workforce")
local Investments = require("scripts/investments")
local Orders = require("scripts/orders")
local Financials = require("scripts/financials")
local Gui = require("scripts/gui")
local Market = require("scripts/market")
local Map = require("scripts/map")

local function SetTestData()
    global.Financials.profitMade = 0
    global.Financials.profitTarget = 50000
    global.Financials.bankruptcyLimit = 1500000
    global.Financials.dividendsPaid = 150000
    global.Financials.dividendsTotal = 500000
    global.Financials.wagesPaid = 3000
    global.Financials.wagesTotal = 6500

    global.Orders.orderSlots[1] = {index = 1, state = Orders.slotStates.waitingItem, item = "wills_spaceship_repair-hull_component", itemCountNeeded = 2, itemCountDone = 1, startTime = 0, nextDeadlineTime = (60 * 60 * 30)}
    global.Orders.orderSlots[2] = {index = 2, state = Orders.slotStates.waitingCustomerDepart, item = nil, itemCountNeeded = nil, itemCountDone = nil, startTime = nil, nextDeadlineTime = (60 * 15)}
    global.Orders.orderSlots[3] = {index = 3, state = Orders.slotStates.waitingDrydock, item = nil, itemCountNeeded = nil, itemCountDone = nil, startTime = nil, nextDeadlineTime = nil}
end

local function OnStartup()
    global.surface = game.surfaces[1]
    global.playerForce = game.forces[1]
    global.playerForce.research_queue_enabled = true
    Utils.DisableIntroMessage()
    Utils.DisableWinOnRocket()
    RecruitWorkforce.OnStartup()
    Financials.OnStartup()
    Investments.OnStartup()
    Orders.OnStartup()
    Market.OnStartup()
    Map.OnStartup()

    Gui.OnStartup()

    --SetTestData()
end

local function OnLoad()
    Utils.DisableSiloScript()
    RecruitWorkforce.OnLoad()
    Financials.OnLoad()
    Investments.OnLoad()
    Orders.OnLoad()
    Market.OnLoad()
    Map.OnLoad()

    Gui.OnLoad()
end

script.on_init(OnStartup)
script.on_configuration_changed(OnStartup)
script.on_load(OnLoad)
Events.RegisterEvent(defines.events.on_runtime_mod_setting_changed)
Events.RegisterEvent(defines.events.on_rocket_launched)
Events.RegisterEvent(defines.events.on_research_finished)
Events.RegisterEvent(defines.events.on_research_started)
Events.RegisterEvent(defines.events.on_player_joined_game)
Events.RegisterEvent(defines.events.on_chunk_generated)
Events.RegisterEvent(defines.events.on_entity_died)
Events.RegisterEvent(defines.events.script_raised_destroy)
Events.RegisterScheduler()
