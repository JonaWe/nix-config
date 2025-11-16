return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
        },
        opts = function()
            return {
                defaults = {
                    files_sorter = require("telescope.sorters").get_fzy_sorter,
                    mappings = {
                        i = {
                            ["<esc>"] = require("telescope.actions").close,
                            ["qq"] = require("telescope.actions").close,
                            ["<C-o>"] = function(prompt_bufnr)
                                local entry = require("telescope.actions.state").get_selected_entry()
                                require("telescope.actions").close(prompt_bufnr)
                                vim.fn.jobstart({"xdg-open", entry.path}, {detach = true})
                            end,
                        },
                        n = {
                            ["q"] = require("telescope.actions").close,
                            ["<C-o>"] = function(prompt_bufnr)
                                local entry = require("telescope.actions.state").get_selected_entry()
                                require("telescope.actions").close(prompt_bufnr)
                                vim.fn.jobstart({"xdg-open", entry.path}, {detach = true})
                            end,
                        },
                    },
                    file_ignore_patterns = {
                        "node_modules",
                    },
                },
                extensions = {
                    fzy_native = {
                        override_generic_sorter = false,
                        override_file_sorter = true,
                    },
                },
            }
        end,
        keys = {
            {
                "<leader>ff",
                function()
                    require("telescope.builtin").find_files()
                end,
                desc = "[F]iles",
            },
            {
                "<leader>fr",
                function()
                    require("telescope.builtin").oldfiles()
                end,
                desc = "[R]ecent",
            },
            {
                "<leader>fb",
                function()
                    require("telescope.builtin").buffers()
                end,
                desc = "[B]uffers",
            },
            {
                "<leader>fg",
                function()
                    require("telescope.builtin").live_grep()
                end,
                desc = "[G]rep",
            },
            {
                "<leader>fd",
                "<cmd>Telescope diagnostics<cr>",
                desc = "[D]iagnostics",
            },
            {
                "<leader>fc",
                function()
                    require("telescope.builtin").git_commits()
                end,
                desc = "[C]ommits",
            },
            {
                "<leader>ft",
                "<cmd>TodoTelescope<cr>",
                desc = "[T]odos",
            },
            {
                "<leader>fh",
                function()
                    require("telescope.builtin").help_tags()
                end,
                desc = "[H]elp",
            },
            {
                "<leader>fb",
                function()
                    require("telescope.builtin").git_branches()
                end,
                desc = "Git [B]ranches",
            },
            {
                "<leader><space>",
                function()
                    vim.fn.system("git rev-parse --is-inside-work-tree")
                    if vim.v.shell_error == 0 then
                        require("telescope.builtin").git_files({ prompt_title = "Project Files [GIT]" })
                    else
                        require("telescope.builtin").find_files({ prompt_title = "Project Files [FS]" })
                    end
                end,
                desc = "Find [F]iles",
            },
        },
    },
}
