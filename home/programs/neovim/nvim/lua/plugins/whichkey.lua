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
            })
            wk.add({
                { "<leader>w", "<cmd>update!<CR>", desc = "Save" },
                { "<leader>q", "<cmd>quit<CR>", desc = "Quit" },
                { "<leader>b", group = "+Buffer" },
                { "<leader>f", group = "+Find" },
                { "<leader>c", group = "+Code" },
                { "<leader>g", group = "+Git" },
                { "<leader>l", group = "+Latex" },
                { "<leader>t", group = "+Trouble" },
                { "<leader>o", group = "+Obsidian" },
            })
        end,
    },
}
