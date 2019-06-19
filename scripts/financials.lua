local Financials = {}

function Financials.OnStartup()
    global.bankBalance = global.bankBalance or 0
    global.profitTarget = global.profitTarget or 0
    global.bankruptcyLimit = global.bankruptcyLimit or 0
    global.dividendsPaid = global.dividendsPaid or 0
    global.dividendsTotal = global.dividendsTotal or 0
    global.wagesPaid = global.wagesPaid or 0
    global.wagesTotal = global.wagesTotal or 0

    Financials.OnLoad()
end

function Financials.OnLoad()
end

return Financials
