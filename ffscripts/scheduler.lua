local FF = FiendFolio

-- clear pending routines when game ends
local PendingRoutines = {}

function FF.schedule(func, fireCondition, callback, name, ...)
    if callback then
        if fireCondition and type(fireCondition) == 'number' then
            local numFires = fireCondition
            fireCondition = function()
                numFires = numFires - 1
                return numFires <= 0
            end
        end

        local function nextCB()
            if fireCondition and not fireCondition() then
                return
            end

            FF.schedule(func, nil, nil, name)
            FF:RemoveCallback(callback, nextCB)
        end
        FF:AddCallback(callback, nextCB, ...)
        return
    end

    if name then
        PendingRoutines[name] = PendingRoutines[name] or {}
        table.insert(PendingRoutines[name], func)
        return
    end

    local co = coroutine.wrap(func)
    local params = co()
    if params then
        FF.schedule(co, table.unpack(params))
    end

    if PendingRoutines[name] then
        for _, routine in pairs(PendingRoutines[name]) do
            FF.schedule(routine)
        end
        PendingRoutines[name] = nil
    end
end