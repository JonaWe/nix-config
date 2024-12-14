return {
    {
        "lervag/vimtex",
        config = function()
            vim.g.vimtex_view_method = "zathura"
        end,
        lazy = false,
        keys = {
            { "<leader>ll", "<cmd>VimtexCompile<cr>", "Start Live Compile" },
            { "<leader>lv", "<cmd>VimtexView<cr>", "Open PDF" },
            { "<leader>lt", "<cmd>VimtexTocToggle<cr>", "Toggle Table of Content" },
            { "<leader>le", "<cmd>VimtexErrors<cr>", "Show Errors" },
            { "<leader>lc", "<cmd>VimtexClean<cr>", "Clean" },
            { "<leader>ls", "<cmd>VimtexStop<cr>", "Stop" },
        },
    },
}
