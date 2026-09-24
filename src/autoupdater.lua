function id.update_from_github(mod_id, redir)
    local path = SMODS.Mods[mod_id].path
    local mods_path = require("lovely").mod_dir
    local folder_name = string.sub(path, #mods_path+2, #path-1)

    os.execute("cd " .. mods_path .. " && rmdir " .. folder_name .. " /S /q && y")
    local file = io.popen("cd " .. mods_path .. " && git clone https://github.com/" .. redir.author .. "/" .. redir.repo .. ".git")
    local out = file:read("*a")
    file:close()
    SMODS.full_restart = SMODS.full_restart + 1
end

function G.FUNCS.tryUpdateMod(e)
    local mod_id = e.config.mod_id
    if not mod_id then return end

    local path = SMODS.Mods[mod_id].path
    local downloaded_from_github = NFS.getInfo(path .. ".git")
    if not downloaded_from_github then
        local profile = G.PROFILES[G.SETTINGS.profile]
        if profile.redirects and profile.redirects[mod_id] then
            id.update_from_github(mod_id, profile.redirects[mod_id])
            return
        end
        print("Failed to update: Mod not downloaded via GitHub.")
        print("Press update button again to add GitHub redirect.")
        e.config.button = "openGithubRedirectMenu"
        return
    end
    local file = io.popen("cd " .. path .. " && git pull")
    local out = file:read("*a")
    file:close()
    if string.find(out or "", "Updat") then
        SMODS.full_restart = SMODS.full_restart + 1
    end
    print(out)
end

function G.FUNCS.tryUpdateSmods(e)
    -- this is different just because smods is funny
    -- https://github.com/Steamodded/smods.git
    local path = SMODS.path
    local downloaded_from_github = NFS.getInfo(path .. ".git")
    if not downloaded_from_github then
        id.update_from_github("Steamodded", {author = "Steamodded", repo = "smods"})
        return
    end
    local file = io.popen("cd " .. path .. " && git pull")
    local out = file:read("*a")
    file:close()
    if string.find(out or "", "Updat") then
        SMODS.full_restart = SMODS.full_restart + 1
    end
    print(out)
end

function G.FUNCS.submitGithubRedirect(e)
    local mod_id = e.config.mod_id
    if not mod_id then return end

    local author, repo = G.redirect_author, G.redirect_repo
    G.redirect_author = ""
    G.redirect_repo = ""

    if author == "" or repo == "" then
        return
    end

    local profile = G.PROFILES[G.SETTINGS.profile]
    profile.redirects = profile.redirects or {}
    profile.redirects[mod_id] = {author = author, repo = repo}
    G.FUNCS.mods_button()
end

function G.FUNCS.openGithubRedirectMenu(e)
    local mod_id = e.config.mod_id
    if not mod_id then return end

    e.config.button = "tryUpdateMod"

    G.redirect_author = ""
    G.redirect_repo = ""
    G.FUNCS.overlay_menu {
        definition = {
            n = G.UIT.ROOT,
            config = {align = "cm", colour = G.C.JOKER_GREY, padding = 0.05},
            nodes = {
                {
                    n = G.UIT.C,
                    config = {padding = 0.3, colour = G.C.GREY},
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = {padding = 0.05},
                            nodes = {
                                create_text_input({
                                    prompt_text = "Author",
                                    ref_table = G,
                                    ref_value = "redirect_author"
                                })
                            },
                        },
                        {
                            n = G.UIT.R,
                            config = {padding = 0.05},
                            nodes = {
                                create_text_input({
                                    prompt_text = "Repository",
                                    ref_table = G,
                                    ref_value = "redirect_repo",
                                })
                            },
                        },
                        {
                            n = G.UIT.R,
                            config = {colour = G.C.FILTER, button = "submitGithubRedirect", mod_id = mod_id, r = 0.05, shadow = true, align = "cm"},
                            nodes = {
                                {
                                    n = G.UIT.T,
                                    config = {text = "Submit", scale = 0.5},
                                },
                            },
                        },
                    },
                },
            }
        },
    }
end