local OrderAudit, SlotStates = {}
local Commands = require("utility/commands")
local Constants = require("constants")
local Utils = require("utility/utils")
local Events = require("utility/events")

function OrderAudit.CreateGlobals()
    global.Orders.orderAuditTable = global.Orders.orderAuditTable or {}
end

function OrderAudit.OnLoad()
    SlotStates = global.StaticData.Orders.slotStates
    Commands.Register("wills_spaceship_repair-write_order_data", {"api-description.wills_spaceship_repair-write_order_data"}, OrderAudit.WriteOutTableCommand, false)
    Events.RegisterHandler("Orders.OrderSlotUpdated", "OrderAudit.LogOrder", OrderAudit.LogOrder)

    Commands.Register("fixit", nil, OrderAudit.FixIt, false)
end

function OrderAudit.FixIt()
    local currentOrderId = 0
    for i, auditOrder in ipairs(global.Orders.orderAuditTable) do
        if auditOrder.endedTime == "" then
            global.Orders.orderAuditTable[i] = "bob"
        else
            currentOrderId = currentOrderId + 1
            auditOrder.orderId = currentOrderId
            auditOrder.auditIndex = nil
        end
    end

    for i = 1, #global.Orders.orderAuditTable do
        if global.Orders.orderAuditTable[i] ~= nil and global.Orders.orderAuditTable[i] == "bob" then
            table.remove(global.Orders.orderAuditTable, i)
        end
    end
    for i = 1, #global.Orders.orderAuditTable do
        if global.Orders.orderAuditTable[i] ~= nil and global.Orders.orderAuditTable[i] == "bob" then
            table.remove(global.Orders.orderAuditTable, i)
        end
    end

    for orderSlotIndex, auditIndex in ipairs(global.Orders.orderAuditMap) do
        local order = global.Orders.orderSlots[orderSlotIndex]
        order.orderId = auditIndex
    end

    local newOrderAuditTable = {}
    for _, auditOrder in ipairs(global.Orders.orderAuditTable) do
        newOrderAuditTable[auditOrder.orderId] = {
            orderId = auditOrder.orderId,
            orderSlot = auditOrder.orderSlot,
            item = auditOrder.item,
            itemCountNeeded = auditOrder.itemCountNeeded,
            itemCountDone = auditOrder.itemCountNeeded,
            startTime = auditOrder.startTime,
            endedTime = auditOrder.endedTime,
            stateName = auditOrder.stateName
        }
    end
    global.Orders.orderAuditTable = newOrderAuditTable

    global.Orders.currentOrderId = currentOrderId
    global.Orders.orderAuditMap = nil
end

function OrderAudit.LogOrder(event)
    local order = event.order
    if order.orderId == nil then
        return
    end
    if global.Orders.orderAuditTable[order.orderId] == nil then
        global.Orders.orderAuditTable[order.orderId] = {
            orderId = order.orderId,
            orderSlot = order.index,
            item = order.item,
            itemCountNeeded = order.itemCountNeeded,
            itemCountDone = 0,
            startTime = order.startTime,
            endedTime = "",
            stateName = order.stateName
        }
    elseif order.stateName == SlotStates.waitingItem.name then
        local auditOrder = global.Orders.orderAuditTable[order.orderId]
        auditOrder.itemCountDone = order.itemCountDone
    elseif order.stateName == SlotStates.orderFailed.name or order.stateName == SlotStates.waitingCustomerDepart.name then
        local auditOrder = global.Orders.orderAuditTable[order.orderId]
        auditOrder.itemCountDone = order.itemCountDone
        auditOrder.endedTime = order.startTime
        auditOrder.stateName = order.stateName
    end
end

function OrderAudit.WriteOutTableCommand(commandData)
    local player = game.get_player(commandData.player_index)
    game.write_file(Constants.ModName .. "-all_orders_table.json", Utils.TableContentsToJSON(global.Orders.orderAuditTable), false, player.index)
    player.print({"message.wills_spaceship_repair-order_audit_table_written"})
end

return OrderAudit
