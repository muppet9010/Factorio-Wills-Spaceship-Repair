local OrderAudit, SlotStates = {}
local Commands = require("utility/commands")
local Constants = require("constants")
local Utils = require("utility/utils")
local Events = require("utility/events")

function OrderAudit.CreateGlobals()
    global.Orders.orderAuditTable = global.Orders.orderAuditTable or {}
    global.Orders.orderAuditMap = global.Orders.orderAuditMap or {}
end

function OrderAudit.OnLoad()
    SlotStates = global.StaticData.Orders.slotStates
    Commands.Register("wills_spaceship_repair-write_order_data", {"api-description.wills_spaceship_repair-write_order_data"}, OrderAudit.WriteOutTableCommand, false)
    Events.RegisterHandler("Orders.OrderSlotUpdated", "OrderAudit.OrderUpdated", OrderAudit.OrderUpdated)
end

function OrderAudit.OrderUpdated(event)
    local order = event.order
    if global.Orders.orderAuditMap[order.index] == nil then
        OrderAudit.LogNewOrder(order)
    else
        OrderAudit.LogUpdateOrder(order)
    end
end

--TODO: where is the item in the output?
function OrderAudit.LogNewOrder(order)
    local auditIndex = #global.Orders.orderAuditTable + 1
    global.Orders.orderAuditTable[auditIndex] = {
        orderSlot = order.index,
        auditIndex = auditIndex,
        item = order.item,
        itemCountNeeded = order.itemCountNeeded,
        startTime = order.startTime,
        endedTime = "",
        stateName = order.stateName
    }
    global.Orders.orderAuditMap[order.index] = auditIndex
end

--TODOL this is based on old startTime update process
function OrderAudit.LogUpdateOrder(order)
    if order.stateName == SlotStates.orderFailed.name or order.stateName == SlotStates.waitingCustomerDepart.name then
        local auditIndex = global.Orders.orderAuditMap[order.index]
        local auditOrder = global.Orders.orderAuditTable[auditIndex]
        auditOrder.endedTime = order.startTime
        auditOrder.stateName = order.stateName
        global.Orders.orderAuditMap[order.index] = nil
    end
end

function OrderAudit.WriteOutTableCommand(commandData)
    local player = game.get_player(commandData.player_index)
    game.write_file(Constants.ModName .. "-all_orders_table.json", Utils.TableContentsToJSON(global.Orders.orderAuditTable), false, player.index)
    player.print({"message.wills_spaceship_repair-order_audit_table_written"})
end

return OrderAudit
