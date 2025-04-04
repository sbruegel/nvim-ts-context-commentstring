local M = {}

---A commentstring configuration that includes both single and multi-line
---comments. The fields can be anything and they will be retrievable with the
---`key` option to `update_commentstring`.
---@class ts_context_commentstring.CommentConfigMultiple
---@field __default string Single-line commentstring
---@field __multiline string Multi-line commentstring

---Commentstring configuration can either be a string (a single commenting
---style) or a table specifying multiple styles.
---@alias ts_context_commentstring.CommentConfig string | ts_context_commentstring.CommentConfigMultiple

---The comment configuration for a language.
---@alias ts_context_commentstring.LanguageConfig ts_context_commentstring.CommentConfig | table<string, ts_context_commentstring.CommentConfig>

---Configuration of the languages to commentstring configs.
---
---The configuration object keys should be **treesitter** languages, NOT
---filetypes or file extensions.
---
---You can get the treesitter language for the current file by running this
---command:
---`:=vim.treesitter.get_parser():lang()`
---
---Or the injected language for a specific location:
---`:=vim.treesitter.get_parser():language_for_range({ line, col, line, col }):lang())`
---
---@alias ts_context_commentstring.LanguagesConfig table<string, ts_context_commentstring.LanguageConfig>

---@class ts_context_commentstring.CommentaryConfig
---@field Commentary string | false | nil
---@field CommentaryLine string | false | nil
---@field ChangeCommentary string | false | nil
---@field CommentaryUndo string | false | nil

---@alias ts_context_commentstring.CustomCalculation fun(node: TSNode|nil, language_tree: vim.treesitter.LanguageTree|nil): string

---@class ts_context_commentstring.Config
---@field enable_autocmd? boolean
---@field custom_calculation? ts_context_commentstring.CustomCalculation
---@field languages? ts_context_commentstring.LanguagesConfig
---@field not_nested_languages? table<string, boolean>
---@field config? ts_context_commentstring.LanguagesConfig
---@field commentary_integration? ts_context_commentstring.CommentaryConfig

---@type ts_context_commentstring.Config
M.config = {
  -- Whether to update the `commentstring` on the `CursorHold` autocmd
  enable_autocmd = true,

  -- Custom logic for calculating the commentstring.
  custom_calculation = nil,

  -- Keybindings to use for the commentary.nvim integration
  commentary_integration = {
    Commentary = 'gc',
    CommentaryLine = 'gcc',
    ChangeCommentary = 'cgc',
    CommentaryUndo = 'gcu',
  },

  languages = {
    -- Languages that have a single comment style
    astro = '<!-- %s -->',
    c = '/* %s */',
    cpp = { __default = '// %s', __multiline = '/* %s */' },
    css = '/* %s */',
    cue = '// %s',
    gleam = '// %s',
    glimmer = '{{! %s }}',
    go = { __default = '// %s', __multiline = '/* %s */' },
    graphql = '# %s',
    haskell = '-- %s',
    handlebars = '{{! %s }}',
    hcl = { __default = '# %s', __multiline = '/* %s */' },
    html = '<!-- %s -->',
    htmldjango = { __default = '{# %s #}', __multiline = '{% comment %} %s {% endcomment %}' },
    ini = '; %s',
    less = { __default = '// %s', __multiline = '/* %s */' },
    lua = { __default = '-- %s', __multiline = '--[[ %s ]]' },
    nix = { __default = '# %s', __multiline = '/* %s */' },
    php = { __default = '// %s', __multiline = '/* %s */' },
    python = { __default = '# %s', __multiline = '""" %s """' },
    rego = '# %s',
    rescript = { __default = '// %s', __multiline = '/* %s */' },
    scss = { __default = '// %s', __multiline = '/* %s */' },
    sh = '# %s',
    bash = '# %s',
    solidity = { __default = '// %s', __multiline = '/* %s */' },
    sql = '-- %s',
    svelte = '<!-- %s -->',
    terraform = { __default = '# %s', __multiline = '/* %s */' },
    twig = '{# %s #}',
    typescript = { __default = '// %s', __multiline = '/* %s */' },
    typst = { __default = '// %s', __multiline = '/* %s */' },
    vim = '" %s',
    vue = '<!-- %s -->',
    zsh = '# %s',
    kotlin = { __default = '// %s', __multiline = '/* %s */' },
    roc = '# %s',

    -- Languages that can have multiple types of comments
    tsx = {
      __default = '// %s',
      __multiline = '/* %s */',
      jsx_element = '{/* %s */}',
      jsx_fragment = '{/* %s */}',
      jsx_attribute = { __default = '// %s', __multiline = '/* %s */' },
      comment = { __default = '// %s', __multiline = '/* %s */' },
      call_expression = { __default = '// %s', __multiline = '/* %s */' },
      statement_block = { __default = '// %s', __multiline = '/* %s */' },
      spread_element = { __default = '// %s', __multiline = '/* %s */' },
    },
    templ = {
      __default = '// %s',
      component_block = '<!-- %s -->',
    },
  },

  not_nested_languages = {
    -- Languages at which nesting stops
    htmldjango = true,
  },

  ---@deprecated Use the languages configuration instead!
  config = {},
}

M.config.languages.javascript = M.config.languages.tsx

---@param config? ts_context_commentstring.Config
function M.update(config)
  M.config = vim.tbl_deep_extend('force', M.config, config or {})
end

---@return boolean
function M.is_autocmd_enabled()
  if vim.g.loaded_commentary == 1 then
    return false
  end

  local enable_autocmd = M.config.enable_autocmd
  if enable_autocmd == nil then
    return true
  end

  return enable_autocmd
end

---@return ts_context_commentstring.LanguagesConfig
function M.get_languages_config()
  return vim.tbl_deep_extend('force', M.config.languages or {}, M.config.config or {})
end

return M
