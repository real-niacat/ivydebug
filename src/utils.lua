function id.clear()
    for _, c in pairs(G.jokers.cards) do
        c:start_dissolve()
    end
    for _, c in pairs(G.consumeables.cards) do
        c:start_dissolve()
    end
end

function id.foreach(entries, func)
    for k, v in pairs(entries) do
        entries[k] = func(v) or v
    end
end

-- allows for returning custom functions
function id.alias(name)
    for k, _ in pairs(G.P_CENTERS) do
        if name == k then
            return function(i)
                i = i or 1
                local rs = {}
                for _ = 1, i do
                    table.insert(rs, SMODS.add_card({ key = k }))
                end
                return #rs == 1 and rs[1] or rs
            end
        end
    end
end

function id.change_card(args)
    return function(card_s)
        if #card_s > 0 then
            for _, c in pairs(card_s) do
                SMODS.change_base(c, args.suit, args.rank)
                if args.ability then c:set_ability(args.ability) end
                if args.edition then c:set_edition(args.edition) end
            end
            return card_s
        else
            SMODS.change_base(card_s, args.suit, args.rank)
            if args.ability then card_s:set_ability(args.ability) end
            if args.edition then card_s:set_edition(args.edition) end
            return card_s
        end
    end
end

function id.delayed(delay, func)
    return function(...)
        local args = { ... }
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = delay,
            func = function()
                local ret = func(unpack(args))
                if ret == false then return ret end
                return true
            end
        }))
    end
end

function id.where(tab, func)
    local new = {}
    for k, v in pairs(tab) do
        if func(k, v) then
            new[k] = v
        end
    end
    return new
end

function id.remove_holes(list)
    local keys = {}
    for i,_ in pairs(list) do
        table.insert(keys, i)
    end
    table.sort(keys, function (a, b)
        return a < b
    end)
    local newlist = {}
    for i,v in ipairs(keys) do
        newlist[i] = list[v]
    end
    return newlist
end

function id.satr(search)
    local attributes = {}
    for k, v in pairs(SMODS.Attributes) do
        table.insert(attributes, v.key)
    end
    return id.where(attributes, function(_, v) return string.find(v, search) end)
end

function id.contains(haystack, needle)
    for k,v in pairs(haystack) do
        if v == needle then
            return true
        end
    end
end

function id.trav(starting_table, matches, call)
    local found = {}
    local seen_tables = {}
    local to_search = {starting_table or _G}

    while #to_search > 0 do
        local cur = to_search[1]
        for k,v in pairs(cur) do
            if type(v) == "table" and not seen_tables[v] then
                table.insert(to_search, v)
                seen_tables[v] = true
            end
            if matches(k, v, cur) then
                local ret = (call or function() end)(k, v, cur)
                if ret then
                    cur[k] = ret
                end
                table.insert(found, v)
            end
        end
        table.remove(to_search, 1)
    end

    return found
end

id.scan_data = {}

function id.begin_scan(scope, match)
    match = match or function() return true end

    local matches = {}
    id.trav(scope, match, function(k, v, cur)
        table.insert(matches, {
            key = k,
            initial_value = v,
            parent_table = cur,
        })
    end)

    id.scan_data = {
        matches = matches,
    }
    id.print_scan()
end

function id.scan_assert(assertion)
    id.scan_data.matches = id.trav(id.scan_data.matches, assertion)
    id.print_scan()
end

function id.print_scan()
    local matches = id.scan_data.matches
    print("Found " .. #matches .. " matches to given scan.")
    print(string.rep("-", 20))
    for k,v in ipairs(matches) do
        print("Key:", v.key, "|", "Value:", v.parent_table[v.key])
    end
end