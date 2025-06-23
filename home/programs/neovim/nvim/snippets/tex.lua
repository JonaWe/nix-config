-- Abbreviations used in this article and the LuaSnip docs
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local line_begin = require("luasnip.extras.expand_conditions").line_begin

local in_mathzone = function()
    -- The `in_mathzone` function requires the VimTeX plugin
    return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

return {
    s(
        { trig = "hr", dscr = "The hyperref package's href{}{} command (for url links)" },
        fmta([[\href{<>}{<>}]], {
            i(1, "url"),
            i(2, "display name"),
        })
    ),
}, {
    s("/a", t("\\alpha "), { condition = in_mathzone }),
    s("/b", t("\\beta "), { condition = in_mathzone }),
    s("/g", t("\\gamma "), { condition = in_mathzone }),
    s("/it", t("\\item ")),
    s("/bf", fmta("\\textbf{<>}", {i(1)})),
    s("/if", fmta("\\textit{<>}", {i(1)})),
    s("/tf", fmta("\\texttt{<>}", {i(1)})),
    s(
        "se",
        fmta(
            [[
        \section{<>}

    ]],
            { i(1) }
        ),
        { condition = line_begin }
    ),
    s(
        "ss",
        fmta(
            [[
        \subsection{<>}

    ]],
            { i(1) }
        ),
        { condition = line_begin }
    ),
    s(
        { trig = "sq", dscr = "Creates a sqrt" },
        fmta(
            [[
            \sqrt{<>}
            ]],
            { i(1) }
        ),
        { condition = in_mathzone } -- `condition` option passed in the snippet `opts` table
    ),
    s(
        { trig = "fr", dscr = "Creates a fraction" },
        fmta(
            [[
            \frac{<>}{<>} 
            ]],
            { i(1), i(2) }
        ),
        { condition = in_mathzone } -- `condition` option passed in the snippet `opts` table
    ),
    s(
        { trig = "fa", dscr = "Creates a flalign environment" },
        fmta(
            [[
            \begin{flalign*}
                <>
            \end{flalign*}

            ]],
            { i(0) }
        ),
        { condition = line_begin }
    ),
    s(
        { trig = "ena", dscr = "Creates a enumerate environment" },
        fmta(
            [[
            \begin{enumerate}[label=\alph*)]
                <>
            \end{enumerate}

            ]],
            { i(0) }
        ),
        { condition = line_begin }
    ),
    s(
        { trig = "enum", dscr = "Creates a enumerate environment" },
        fmta(
            [[
            \begin{enumerate}
                <>
            \end{enumerate}

            ]],
            { i(0) }
        ),
        { condition = line_begin }
    ),
    s(
        { trig = "env", dscr = "Creates a latex environment" },
        fmta(
            [[
            \begin{<>}
                <>
            \end{<>}

            ]],
            {
                i(1),
                i(2),
                rep(1), -- this node repeats insert node i(1)
            }
        ),
        { condition = line_begin }
    ),
    s(
        { trig = "fig", dscr = "Creates a latex figure environment" },
        fmta(
            [[
            \begin{figure}
                <>
            \end{figure

            ]],
            {
                i(1),
            }
        ),
        { condition = line_begin }
    ),
    s(
        { trig = "doc", dscr = "Creates the skeleton for a latex file" },
        fmta(
            [[
            \documentclass[a4,german]{article}
            \usepackage{graphicx}
            \usepackage{amsmath}
            \usepackage{enumitem}
            \usepackage[utf8]{inputenc}
            \usepackage[T1]{fontenc}
            \usepackage{textcomp}
            \usepackage{gensymb}

            \title{<>}
            \author{<>}
            \date{<>}

            \begin{document}

            \maketitle

            <>

            \end{document}
            ]],
            {
                i(1),
                i(2),
                i(3),
                i(4),
            }
        ),
        { condition = line_begin }
    ),
}
