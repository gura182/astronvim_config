return {
  "rebelot/heirline.nvim",
  event = "BufEnter",
  opts = function()
    local status = require "astronvim.utils.status"
    return {
      opts = {
        disable_winbar_cb = function(args)
          return not require("astronvim.utils.buffer").is_valid(args.buf)
            or status.condition.buffer_matches({
              buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
              filetype = { "NvimTree", "neo%-tree", "dashboard", "Outline", "aerial" },
            }, args.buf)
        end,
      },
      statusline = { -- statusline
        -- default highlight for the entire statusline
          hl = { fg = "fg", bg = "bg" },
          -- each element following is a component in astronvim.utils.status module

          -- add the vim mode component
          status.component.mode {
            -- enable mode text with padding as well as an icon before it
            mode_text = { icon = { kind = "VimIcon", padding = { right = 1, left = 1 } } },
            -- surround the component with a separators
            surround = {
              -- it's a left element, so use the left separator
              separator = "left",
              -- set the color of the surrounding based on the current mode using astronvim.utils.status module
              color = function() return { main = status.hl.mode_bg(), right = "blank_bg" } end,
            },
          },
          -- we want an empty space here so we can use the component builder to make a new section with just an empty string
          status.component.builder {
            { provider = "" },
            -- define the surrounding separator and colors to be used inside of the component
            -- and the color to the right of the separated out section
            surround = { separator = "left", color = { main = "blank_bg", right = "file_info_bg" } },
          },
          -- add a section for the currently opened file information
          status.component.file_info {
            -- enable the file_icon and disable the highlighting based on filetype
            file_icon = { padding = { left = 0 } },
            filename = { fallback = "Empty" },
            -- add padding
            padding = { right = 1 },
            -- define the section separator
            surround = { separator = "left", condition = false },
          },
          -- add a component for the current git branch if it exists and use no separator for the sections
          status.component.git_branch { surround = { separator = "none" } },
          -- add a component for the current git diff if it exists and use no separator for the sections
          -- status.component.git_diff { padding = { left = 1 }, surround = { separator = "none" } },
          status.component.git_diff(),
          -- fill the rest of the statusline
          -- the elements after this will appear in the middle of the statusline
          status.component.fill(),
          -- add a component to display if the LSP is loading, disable showing running client names, and use no separator
          status.component.lsp { lsp_client_names = false, surround = { separator = "none", color = "bg" } },
          -- fill the rest of the statusline
          -- the elements after this will appear on the right of the statusline
          status.component.fill(),
          -- add a component for the current diagnostics if it exists and use the right separator for the section
          status.component.diagnostics { surround = { separator = "right" } },
          -- add a component to display LSP clients, disable showing LSP progress, and use the right separator
          status.component.lsp { lsp_progress = false, surround = { separator = "right" } },
          -- NvChad has some nice icons to go along with information, so we can create a parent component to do this
          -- all of the children of this table will be treated together as a single component
          {
            -- define a simple component where the provider is just a folder icon
            status.component.builder {
              -- astronvim.get_icon gets the user interface icon for a closed folder with a space after it
              { provider = require("astronvim.utils").get_icon "FolderClosed" },
              -- add padding after icon
              padding = { right = 1 },
              -- set the foreground color to be used for the icon
              hl = { fg = "bg" },
              -- use the right separator and define the background color
              surround = { separator = "right", color = "folder_icon_bg" },
            },
            -- add a file information component and only show the current working directory name
            status.component.file_info {
              -- we only want filename to be used and we can change the fname
              -- function to get the current working directory name
              filename = { fname = function(nr) return vim.fn.getcwd(nr) end, padding = { left = 1 } },
              -- disable all other elements of the file_info component
              file_icon = false,
              file_modified = false,
              file_read_only = false,
              -- use no separator for this part but define a background color
              surround = { separator = "none", color = "file_info_bg", condition = false },
            },
          },
          -- the final component of the NvChad statusline is the navigation section
          -- this is very similar to the previous current working directory section with the icon
          { -- make nav section with icon border
            -- define a custom component with just a file icon
            status.component.builder {
              { provider = require("astronvim.utils").get_icon "ScrollText" },
              -- add padding after icon
              padding = { right = 1 },
              -- set the icon foreground
              hl = { fg = "bg" },
              -- use the right separator and define the background color
              -- as well as the color to the left of the separator
              surround = { separator = "right", color = { main = "nav_icon_bg", left = "file_info_bg" } },
            },
            -- add a navigation component and just display the percentage of progress in the file
            status.component.nav {
              -- add some padding for the percentage provider
              percentage = { padding = { right = 1 } },
              -- disable all other providers
              ruler = false,
              scrollbar = false,
              -- use no separator and define the background color
              surround = { separator = "none", color = "file_info_bg" },
            },
          },
      },
      winbar = { -- winbar
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        fallthrough = false,
        {
          condition = function() return not status.condition.is_active() end,
          status.component.separated_path(),
          status.component.file_info {
            file_icon = { hl = status.hl.file_icon "winbar", padding = { left = 0 } },
            file_modified = false,
            file_read_only = false,
            hl = status.hl.get_attributes("winbarnc", true),
            surround = false,
            update = "BufEnter",
          },
        },
        status.component.breadcrumbs { hl = status.hl.get_attributes("winbar", true) },
      },
      tabline = { -- bufferline
        { -- file tree padding
          condition = function(self)
            self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
            return status.condition.buffer_matches(
              { filetype = { "aerial", "dapui_.", "dap-repl", "neo%-tree", "NvimTree", "edgy" } },
              vim.api.nvim_win_get_buf(self.winid)
            )
          end,
          provider = function(self) return string.rep(" ", vim.api.nvim_win_get_width(self.winid) + 1) end,
          hl = { bg = "tabline_bg" },
        },
        status.heirline.make_buflist(status.component.tabline_file_info()), -- component for each buffer tab
        status.component.fill { hl = { bg = "tabline_bg" } }, -- fill the rest of the tabline with background color
        { -- tab list
          condition = function() return #vim.api.nvim_list_tabpages() >= 2 end, -- only show tabs if there are more than one
          status.heirline.make_tablist { -- component for each tab
            provider = status.provider.tabnr(),
            hl = function(self) return status.hl.get_attributes(status.heirline.tab_type(self, "tab"), true) end,
          },
          { -- close button for current tab
            provider = status.provider.close_button { kind = "TabClose", padding = { left = 1, right = 1 } },
            hl = status.hl.get_attributes("tab_close", true),
            on_click = {
              callback = function() require("astronvim.utils.buffer").close_tab() end,
              name = "heirline_tabline_close_tab_callback",
            },
          },
        },
      },
      statuscolumn = vim.fn.has "nvim-0.9" == 1 and {
        status.component.foldcolumn(),
        status.component.fill(),
        status.component.numbercolumn(),
        status.component.signcolumn(),
      } or nil,
    }
  end,
  config = require "plugins.configs.heirline",
}
