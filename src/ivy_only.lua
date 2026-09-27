local http = require("SMODS.https")
local json = require("json")
function id.sendWebhookMessage(content)
    local url = love.filesystem.read("ivy_webhook.txt")
    local data = {
        method = "POST",
        data = json.encode({ content = content }),
        headers = {
            ["Content-Type"] = "application/json"
        }
    }
    print(data)
    if http then
        return http.request(url, data)
    end
end

id.hook_before("love.errorhandler", function()
    local crashes = to_number(love.filesystem.read("ivy_crashes.txt") or 0)
    crashes = crashes + 1
    love.filesystem.write("ivy_crashes.txt", crashes)
    id.sendWebhookMessage("Ivy's Balatro has crashed again. This makes " .. crashes .. " total crashes.")
end)

_save_issue_tables = {}
id.hook_before("save_run", function()
    id.trav(G.GAME, function(k, v, from)
        local t = type(v)
        return (not (is_number(v) or t == "string" or t == "table" or t == "boolean")) or
        (t == "table" and t.is and t:is(Object))
    end, function(k, v, cur)
        print(cur, k, v)
        table.insert(_save_issue_tables, {
            tab = cur,
            key = k,
            value = v,
        })
        print("!!!!!!!!!!!!!! this is CAUSING SAVE ISSUES")
    end, function(k, v)
        return not getmetatable(v)
    end)
    id.reveal_save_issues()
end)

function id.reveal_save_issues()
    if #_save_issue_tables == 0 then
        return
    end
    id.trav(G.GAME, function(k, v)
        for i, vv in ipairs(_save_issue_tables) do
            if vv.tab == v then
                return true
            end
        end
    end, function(k, v, cur)
        print(k, v)
        cur.revealed = true
        print("i found it for you! it's here! looking up in the tree...")
        if cur ~= _G then
            table.insert(_save_issue_tables, {
                tab = v,
                key = k,
            })
        else
            print("i've found this save issue's home address! kill it girl!")
        end
    end)
    local _new = {}
    for _,v in ipairs(_save_issue_tables) do
        if not v.tab.revealed then
            table.insert(_new,v)
        end
    end
    _save_issue_tables = _new
    id.reveal_save_issues()
end
