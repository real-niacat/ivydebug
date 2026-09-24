---@type table
id = {}

id.hooks = {}

function id.ref_hook(ref_table, ref_value, func, hook_id)
    local original_function_object = ref_table[ref_value] or function() end
    if hook_id then
        id.hooks[hook_id] = true
    end
    ref_table[ref_value] = function(...)
        local id = id.hooks[hook_id]
        if id ~= nil and not id then
            return original_function_object(...)
        else
            return func(original_function_object, ...)
        end
    end
end

function id.disable_hook(hook_id)
    if id.hooks[hook_id] ~= nil then
        id.hooks[hook_id] = false
    end
end

function id.enable_hook(hook_id)
    if id.hooks[hook_id] ~= nil then
        id.hooks[hook_id] = true
    end
end

---@param func_path string String that defines where to find the function. e.g. "Game.main_menu"
---@param func function Function to replace the given function with. Takes in the args of (original_function, ...) where ... is the args of the original function
function id.hook(func_path, func, hook_id)
    local arr = {}
    for string in string.gmatch(func_path, "([^.]+)") do
        table.insert(arr, string)
    end
    local current_entry = _G
    local final_func = nil
    local stop = false
    for _, entry in pairs(arr) do
        if entry == "*" then
            stop = true
        end
        if not stop then
            local next_entry = current_entry[entry]
            if type(next_entry) == "function" then
                final_func = entry
            else
                current_entry = next_entry
            end
        end
    end
    if stop then
        for k, v in pairs(current_entry) do
            if type(v) == "function" then
                id.ref_hook(current_entry, k, func, hook_id)
            end
        end
    end
    id.ref_hook(current_entry, final_func, func, hook_id)
end

-- Same as `id.hook` but it does not allow for modifying return values, and simply runs code *before* the hooked function
function id.hook_before(func_path, func, hook_id)
    id.hook(func_path, function(original, ...)
        func(original, ...)
        return original(...)
    end, hook_id)
end

-- Same as `id.hook` but it does not allow for modifying return values, and simply runs code *after* the hooked function
function id.hook_after(func_path, func, hook_id)
    id.hook(func_path, function(original, ...)
        local ret = original(...)
        func(original, ...)
        return ret
    end, hook_id)
end

-- Alias to id.hook_after
function id.inject(func_path, func, hook_id)
    return id.hook_after(func_path, func, hook_id)
end

function id.tamper(func_path, func, hook_id)
    id.hook(func_path, function(original, ...)
        local args = {func(...)}
        return original(unpack(args))
    end, hook_id)
end

function id.pipe(func_path, func, hook_id)
    id.hook(func_path, function(original, ...)
        local ret = { original(...) }
        func(unpack(ret))
        return unpack(ret)
    end, hook_id)
end

function G.FUNCS.idQuickPlay(e)
    G.FUNCS.run_select_quick_start(true)
end

SMODS.Keybind {
    key = "itdoesntfuckingmatter",
    key_pressed = "d",
    action = function()
        for _, v in pairs(SMODS.Mods) do
            if v.can_load and v.path then
                SMODS.handle_loc_file(v.path)
            end
        end
        return init_localization()
    end
}

SMODS.Keybind {
    key = "itstilldoesntreallymatterdoesit",
    key_pressed = "f",
    action = function()
        print("Reloading everything i can!")
        id.reload_everything()
    end
}
assert(SMODS.load_file("src/utils.lua"))()
assert(SMODS.load_file("src/ui.lua"))()
assert(SMODS.load_file("src/autoupdater.lua"))()
assert(SMODS.load_file("src/hotreloading.lua"))()
assert(SMODS.load_file("src/ivy_table.lua"))()


-- for i=1,10 do
--     SMODS.ScreenShader { 
--         key = "screen" .. i,
--         path = "screen.fs",
--         order = 99,
--         send_vars = function(self)
--             return {
--                 iTime             = G.TIMERS.REAL+i,
--                 resolution        = {love.graphics.getWidth(), love.graphics.getHeight()},
--                 matrix_intensity  = G.matrix_intensity or 0,
--                 matrix_lines      = G.matrix_lines or 30,
--                 block_size        = G.block_size or 8,
--                 block_offset      = G.block_offset or 10,
--                 block_probability = G.block_probability or 0.2,
--                 matrix_color      = G.matrix_colour or {0.2, 1, 0.2, 0},
--             }
--         end
--     }
-- end

local _id = id

id = {}
setmetatable(id, {
    __index = function(t, k)
        local rg = rawget(_id, k)
        if rg == nil then
            local new = _id.alias(k)
            if new then return new() end
        end
        return rg
    end,
    __newindex = function(t, k, v)
        local rg = rawget(_id, k)
        if rg == nil then
            local new = _id.alias(k)
            if new then return new(v) end
        end
        return rg
    end,
    __call = function (t, ...)
        local args = {...}
        if ((args[1] and type(args[1]) == "table") or not args[1]) and not getmetatable(args[1]) then
            args[1] = args[1] or {}
            setmetatable(args[1], id.ivy_table)
            args[1]:init()
            return args[1]
        end
    end
})

rid = {}
setmetatable(rid, {
    __index = function(t, k)
        local rg = rawget(_id, k)
        if rg == nil then
            local new = _id.alias(k)
            return new
        end
        return rg
    end,
})

-- todo:
-- split into more files
-- sideways main menu gui (left-oriented)
-- condensed mods list 