-- First, register the callback with your LSP config. This minimal config shows
-- what that looks like.
local nvim_lsp = require('nvim_lsp')
nvim_lsp.dartls.setup{
  init_options = {
    outline = true,
  },
  callbacks = {
    -- get_callback can be called with or without arguments
    ['dart/textDocument/publishOutline'] = require('lsp_extensions.dart.outline').get_callback(),
  },
}

-- Next, when you want to actually show the outline, you will need to call one
-- of the display methods (either loclist() or custom().
require('lsp_extensions.dart.outline').loclist({})

-- If you want to handle the display yourself you can use the `custom()` function.
require('lsp_extensions.dart.outline').custom({}, function(items) print(items) end)

-- The outline categorizes the entries by `kind`s. By default, the outline will
-- Prefix each entry with it's kind. However, if you prefer to define your own
-- prefixes you can do that by passing `kind_prefixes` into the opts. If you
-- pair this with a patched [Nerdfont](https://www.nerdfonts.com/) you can
-- define a very custom experience. You can define a function that looks like:
DART_SHOW_OUTLINE = function()
    require('lsp_extensions.dart.outline').loclist({kind_prefixes={
        CLASS = "",
        CLASS_TYPE_ALIAS = "",
        COMPILATION_UNIT = "ﴒ",
        CONSTRUCTOR = "",
        CONSTRUCTOR_INVOCATION = "",
        ENUM = "טּ",
        ENUM_CONSTANT = "יּ",
        EXTENSION = "",
        FIELD = "ﬧ",
        FILE = "",
        FUNCTION = "",
        FUNCTION_INVOCATION = "",
        FUNCTION_TYPE_ALIAS = "",
        GETTER = "",
        LABEL = "",
        LIBRARY = "",
        LOCAL_VARIABLE = "",
        METHOD = "",
        MIXIN = "ﭚ",
        PARAMETER = "",
        PREFIX = "並",
        SETTER = "",
        TOP_LEVEL_VARIABLE = "ﬢ",
        TYPE_PARAMETER = "",
        UNIT_TEST_GROUP = "﬽",
        UNIT_TEST_TEST = "",
        UNKNOWN = "",
    }})
end

-- And then call it from neovim with :lua DART_SHOW_OUTLINE()

