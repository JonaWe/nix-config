-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = "*",
})


local disable_dir = vim.fn.expand('$HOME/vault') .. '/*'

vim.api.nvim_create_autocmd({"LspAttach"}, {
  pattern = disable_dir,
  callback = function (args)
    if not args['data'] or not args.data['client_id'] then return end

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.name == 'copilot' then
      vim.lsp.stop_client(client.id, true)
    end
  end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function ()
        -- TODO: highlight the line
        vim.keymap.set("n", "j", "j<cr><c-w>p", { buffer = true, silent = true })
        vim.keymap.set("n", "k", "k<cr><c-w>p", { buffer = true, silent = true })
    end
})

-- overwrite default find file behavior inside of obsidian vaults
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "/home/jona/vault/personal/*",
    callback = function()
        vim.keymap.set(
            "n",
            "<leader><space>",
            "<cmd>ObsidianSearch<cr>",
            { silent = true, desc = "Search Obsidian Vault" }
        )
    end,
})

--create auto command to set wrap on for markdown, latex and other different kinds of text files in the buffer
vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "markdown",
        "latex",
        "text",
    },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = false
    end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd("FocusGained", { command = "checktime" })

-- Go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPre", {
    pattern = "*",
    callback = function()
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "<buffer>",
            once = true,
            callback = function()
                vim.cmd(
                    [[if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif]]
                )
            end,
        })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.diagnostic.config({ virtual_text = false })
    end,
})

-- windows to close
vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "OverseerForm",
        "OverseerList",
        "floggraph",
        "fugitive",
        "git",
        "help",
        "lspinfo",
        "man",
        "neotest-output",
        "neotest-summary",
        "qf",
        "query",
        "spectre_panel",
        "startuptime",
        "toggleterm",
        "tsplayground",
        "vim",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

-- show cursor line only in active window
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
    callback = function()
        local ok, cl = pcall(vim.api.nvim_win_get_var, 0, "auto-cursorline")
        if ok and cl then
            vim.wo.cursorline = true
            vim.api.nvim_win_del_var(0, "auto-cursorline")
        end
    end,
})
vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
    callback = function()
        local cl = vim.wo.cursorline
        if cl then
            vim.api.nvim_win_set_var(0, "auto-cursorline", cl)
            vim.wo.cursorline = false
        end
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local function map(mode, key, cmd, desc)
            vim.keymap.set(mode, key, cmd, { buffer = ev.buf, desc = desc })
        end

        map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
        map("n", "gd", vim.lsp.buf.definition, "Goto Defenition")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "gi", "<cmd>Telescope lsp_implementations<cr>", "Goto Implementation")
        map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
        map({ "n", "v" }, "<space>ca", require("actions-preview").code_actions, "Code Actions")
        map("n", "gr", "<cmd>Telescope lsp_references<cr>", "References")
        map({ "n", "v" }, "<leader>cf", function()
            require("conform").format({
                bufnr = ev.buf,
                timeout_ms = 2000,
                lsp_fallback = true,
            })
        end, "Format")
    end,
})
