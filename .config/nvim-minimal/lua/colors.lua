require('tokyonight').setup(
  {
    styles = {
      comments = { italic = false },
      keywords = { italic = false },
      functions = {},
      variables = {},
    },
    on_highlights = function(highlights, colors)
      highlights.Function = { fg = colors.yellow }
      highlights.CmpItemKindFunction = { fg = colors.yellow }
      highlights.NoiceCompletionItemKindFunction = { fg = colors.yellow }
      highlights.typescriptFunctionMethod = { fg = colors.yellow }
      highlights.NavicIconsFunction = { fg = colors.yellow }
      highlights["@parameter"] = { fg = colors.blue }
      highlights["@variable"] = { fg = colors.blue }
      highlights.Type = { fg = colors.teal }
    end,
  }
)

vim.cmd("colorscheme tokyonight-night")
