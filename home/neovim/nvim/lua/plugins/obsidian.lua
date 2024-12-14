return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = false,
    -- ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    event = {
        "BufReadPre " .. vim.fn.expand("~") .. "/vault/personal/**.md",
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("obsidian").setup({
            workspaces = {
                {
                    name = "personal",
                    path = "~/vault/personal",
                },
                -- {
                --     name = "no-vault",
                --     path = function()
                --         -- alternatively use the CWD:
                --         -- return assert(vim.fn.getcwd())
                --         return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
                --     end,
                --     overrides = {
                --         notes_subdir = vim.NIL,  -- have to use 'vim.NIL' instead of 'nil'
                --         new_notes_location = "current_dir",
                --         templates = {
                --             subdir = vim.NIL,
                --         },
                --         disable_frontmatter = true,
                --     },
                -- },
            },
            templates = {
                subdir = "Templates",
                date_format = "%Y-%m-%d",
                time_format = "%H:%M",
                substitutions = {
                    ["date:dddd, D. MMMM YYYY"] = function()
                        return os.date("%A, %d. %B %Y", os.time())
                    end,
                },
            },
            daily_notes = {
                folder = "Journal/Daily/",
                date_format = "%Y-%m-%d",
                -- alias_format = "%B %-d, %Y",
                template = "daily template.md",
            },
            completion = {
                -- Set to false to disable completion.
                nvim_cmp = true,
                -- Trigger completion at 2 chars.
                min_chars = 1,
            },
            follow_url_func = function(url)
                vim.fn.jobstart({ "xdg-open", url })
            end,
        })
        vim.keymap.set({ "n", "i" }, "<C-g>", function()
            return require("obsidian").util.toggle_checkbox()
        end)
        vim.keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<CR>", { silent = true })
        vim.keymap.set("n", "gf", "<cmd>ObsidianFollowLink<CR>", { silent = true })
        vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianToday<CR>", { silent = true })
    end,
}
