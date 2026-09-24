function id.main_menu()
    local quit_func = 'quit'
    local wid = 6
    local hei = 1
    local conf = { align = "cm" }

    local buttons = {
        {
            n = G.UIT.R,
            config = id(conf):with({padding = 0.1}),
            nodes = {
                UIBox_button { id = 'main_menu_play', button = not G.SETTINGS.tutorial_complete and "start_run" or "setup_run", colour = G.C.BLUE, minw = wid/2, minh = hei, label = { localize('b_play_cap') }, scale = text_scale, col = true },
                UIBox_button { id = 'main_menu_quick_play', button = "idQuickPlay", colour = darken(G.C.BLUE, 0.2), minw = wid/2, minh = hei, label = { "Quick Play" }, scale = text_scale, col = true },
            },
        },
        {
            n = G.UIT.R,
            config = conf,
            nodes = {
                UIBox_button { button = 'options', colour = G.C.ORANGE, minw = wid, minh = hei, label = { localize('b_options_cap') }, scale = text_scale, col = true },
            }
        },
        {
            n = G.UIT.R,
            config = conf,
            nodes = {
                UIBox_button { id = 'collection_button', button = "your_collection", colour = G.C.PALE_GREEN, minw = wid, minh = hei, label = { localize('b_collection_cap') }, scale = text_scale, col = true },
            },
        },
        G.F_QUIT_BUTTON and {
            n = G.UIT.R,
            config = conf,
            nodes = {
                UIBox_button { button = quit_func, colour = G.C.RED, minw = wid, minh = hei, label = { localize('b_quit_cap') }, scale = text_scale, col = true }
            },
        } or nil,
        {
            n = G.UIT.R,
            config = conf,
            nodes = {
                UIBox_button{ id = "mods_button", button = "mods_button", colour = SMODS.mod_button_alert and SMODS.Gradients.warning_bg or G.C.BOOSTER, minw = wid, minh = hei, col = true, label = { localize('b_mods_cap') }, scale = text_scale }
            },
        },

    }

    local t = {
        n = G.UIT.ROOT,
        config = { align = "cm", colour = G.C.CLEAR },
        nodes = {
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.2 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0.1, r = 0.1, minw = wid * 1.2, minh = hei * #buttons * 1.2, emboss = 0.1, colour = G.C.L_BLACK },
                        nodes = buttons
                    },
                }
            },
        }
    }
    return t
end

id.hook("set_main_menu_UI", function(original)
    G.MAIN_MENU_UI = UIBox {
        definition = id.main_menu(),
        config = { align = "tri", offset = { x = -14, y = 3 }, major = G.ROOM_ATTACH, bond = 'Weak' }
    }
    G.MAIN_MENU_UI:align_to_major()
    ease_value(G.title_top.T, "x", 4)
    -- G.title_top.T.x = G.title_top.T.x + 4

    G.CONTROLLER:snap_to { node = G.MAIN_MENU_UI:get_UIE_by_ID('main_menu_play') }
end)
