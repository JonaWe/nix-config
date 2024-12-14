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
                key_labels = { ["<leader>"] = "SPC" },
                triggers = "auto",
            })
            wk.register({
                w = { "<cmd>update!<CR>", "Save" },
                q = { "<cmd>quit<CR>", "Quit" },
                b = { name = "+Buffer" },
                f = { name = "+Find" },
                c = { name = "+Code" },
                g = { name = "+Git" },
                l = { name = "+Latex" },
                t = { name = "+Trouble" },
                o = { name = "+Obsidian" },
            }, { prefix = "<leader>" })
        end,
    },
}
