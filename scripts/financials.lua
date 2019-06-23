local Financials = {}

function Financials.OnStartup()
    global.Financials = global.Financials or {}
    global.Financials.profitMade = global.Financials.profitMade or 0
    global.Financials.profitTarget = global.Financials.profitTarget or 0
    global.Financials.bankruptcyLimit = global.Financials.bankruptcyLimit or 0
    global.Financials.dividendsPaid = global.Financials.dividendsPaid or 0
    global.Financials.dividendsTotal = global.Financials.dividendsTotal or 0
    global.Financials.wagesPaid = global.Financials.wagesPaid or 0
    global.Financials.wagesTotal = global.Financials.wagesTotal or 0

    Financials.OnLoad()
end

function Financials.OnLoad()
end

return Financials
