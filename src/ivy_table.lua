id.ivy_table = {}

function id.ivy_table.__index(t, k)
    local raw = rawget(id.ivy_table, k)
    local getters = rawget(t, "__getters")
    local indexed = getters and rawget(getters, k)
    return (indexed and indexed(t, k)) or raw
end

function id.ivy_table:init()
    self.__getters = {}
end

function id.ivy_table:getter(key, func)
    self.__getters[key] = func
    return self
end

function id.ivy_table:where(func)
    local is_arraylike = #self ~= 0
    local new = {}
    for k, v in pairs(self) do
        if func(k, v) then
            if is_arraylike then
                table.insert(new, v)
            else
                new[k] = v
            end
        end
    end
    return id(new)
end

function id.ivy_table:contains(value)
    for k,v in pairs(self) do
        if v == value then
            return true
        end
    end
end

function id.ivy_table:foreach(func)
    local results = id({})
    for k, v in pairs(self) do
        results[k] = func(v) or v
    end
    return results
end

function id.ivy_table:copy()
    local new = id({})
    for k,v in pairs(self) do
        new[k] = v
    end
    return new
end

function id.ivy_table:repeat_vals(times)
    assert(#self ~= 0, "For a table to repeat without undefined order behavior it must be array-like.")
    local original = self:copy()
    for i=1,times do
        for i,v in ipairs(original) do
            table.insert(self, v)
        end
    end
    return self
end

function id.ivy_table:populate(func, limit)
    local last_ret = 0
    local i = 0
    while last_ret ~= nil and i < limit do
        i = i + 1
        last_ret = func(i)
        if last_ret ~= nil then
            table.insert(self, last_ret)
        end
    end
    return self
end

function id.ivy_table:with(oth)
    local copy = self:copy()
    for k,v in pairs(oth) do
        copy[k] = v
    end
    return copy
end