function id.recursive_read_directory(dir, main)
    -- returns every file in a directory
    if main == nil then
        main = true
    end
    local items = NFS.getDirectoryItemsInfo(dir)
    local dirs = id.where(items, function(k, t) return t.type == "directory" end)
    items = id.where(items, function(k, t) return t.type ~= "directory" end)

    for _, idir in pairs(dirs) do
        local ind_items = id.recursive_read_directory(dir .. idir.name .. "/", false)
        id.foreach(ind_items, function(item)
            item.name = idir.name .. "/" .. item.name
            table.insert(items, item)
        end)
    end

    if not main then
        return items -- we are done here
    end

    for k,v in pairs(items) do
        items[k] = dir .. v.name
    end
    return items
end

function id.reload_everything()
    -- Holy Fuck
    local all_files = id.recursive_read_directory(require("lovely").mod_dir .. "/")
    all_files = id.where(all_files, function(k,filename) return filename:sub(-4) == ".lua" end)
    all_files = id.remove_holes(all_files)
    -- print(all_files)
    local extracted = {}
    for _,file in pairs(all_files) do
        pcall(load(NFS.read(file), nil, nil, {SMODS = {Joker = function(joker)
            table.insert(extracted, joker)
        end}}))
    end
    print(extracted)
end
