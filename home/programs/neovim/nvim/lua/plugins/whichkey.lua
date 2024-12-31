return {
    {
        "folke/which-key.nvim",
        dependencies = {
            "mrjones2014/legendary.nvim",
        },
        config = function()
            local wk = require("which-key")
            wk.setup({
                show_help = true,
                plugins = { spelling = true },
                replace = { ["<leader>"] = "SPC" },
                triggers = "auto",
            })
            wk.register({
                w = { "<cmd>update!<CR>", "Save" },
                q = { "<cmd>quit<CR>", "Quit" },
                b = { group = "+Buffer" },
                f = { group = "+Find" },
                c = { group = "+Code" },
                g = { group = "+Git" },
                l = { group = "+Latex" },
                t = { group = "+Trouble" },
                o = { group = "+Obsidian" },
            }, { prefix = "<leader>" })
        end,
    },
}
