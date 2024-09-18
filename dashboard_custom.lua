-- ~/.config/nvim/lua/custom/dashboard_custom.lua

local api = vim.api
local buffer = nil
local window = nil

local M = {}

local original_guicursor

-- Function to get the current background color
local function get_background_color()
  local hl = vim.api.nvim_get_hl_by_name('Normal', true)
  local bg_color = hl.bg or 'NONE'
  return bg_color
end

--     background:                  #1a1c06; //#D0D0D0;
--     background-alt:              #000000; //#E9E9E9;
--     foreground:                  #c0caf5; //#161616;
--     selected:                    #ff9e64; //#BEBEBE;
--     active:                      #999999;
--     urgent:                      #808080;

-- Function to set highlight groups
local function set_highlight_groups()
  local bg_color = get_background_color()

  vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = '#c0caf5', bold = true })
  vim.api.nvim_set_hl(0, 'DashboardOption', { fg = '#999999' })
  vim.api.nvim_set_hl(0, 'DashboardShortcut', { fg = '#ff9e64', bold = true })
  vim.api.nvim_set_hl(0, 'DashboardBackground', { bg = bg_color })
  vim.api.nvim_set_hl(0, 'DashboardIcon', { fg = '#ff9e64' })
end

--cursor functions :)
local function HideMouse()
  original_guicursor = vim.o.guicursor
  vim.opt.guicursor = 'a:block-Cursor/lCursor-blinkon0'
  vim.cmd 'hi Cursor blend=100'
end

local function RestoreMouse()
  if original_guicursor then
    vim.opt.guicursor = original_guicursor
    original_guicursor = nil
  else
    vim.opt.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20'
  end
  vim.cmd 'hi Cursor blend=0'
end

--close the dashord "and clean up" (a bit of help from ai)
local function CleanupAfterClosing()
  if window and api.nvim_win_is_valid(window) then
    api.nvim_win_close(window, true)
  end
  if buffer and api.nvim_buf_is_valid(buffer) then
    api.nvim_buf_delete(buffer, { force = true })
  end
  window = nil
  buffer = nil
  vim.api.nvim_del_augroup_by_name 'DashboardAutoClose'

  --again some cursor stuff the name is self explainetory
  RestoreMouse()
end

--auto close the menu when "something is happned" like mouse click buffer enter and stuff,
--uses the above function named 'close_dashboard_and_clean_up'

local function AutoClose()
  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'CmdlineEnter', 'CmdwinEnter' }, {
    group = vim.api.nvim_create_augroup('DashboardAutoClose', { clear = true }),
    callback = CleanupAfterClosing,
  })
end

vim.api.nvim_create_autocmd({
  'WinEnter',
  'FileType',
  'BufWinEnter',
  'CmdlineEnter',
  'CmdwinEnter',
  'FocusGained',
  'VimResized',
  'TabEnter',
  'TermOpen',
}, {
  group = vim.api.nvim_create_augroup('DashboardAutoClose', { clear = true }),
  callback = function(ev)
    if ev.buf ~= buffer then
      CleanupAfterClosing()
    end
  end,
})

local function MouseClickBehavior()
  if buffer and api.nvim_get_current_buf() ~= buffer then
    CleanupAfterClosing()
  end
end

vim.on_key(function(key)
  if key == vim.api.nvim_replace_termcodes('<LeftMouse>', true, false, true) then
    vim.schedule(MouseClickBehavior)
  end
end)

--the name
local function CloseDashboard()
  if window and api.nvim_win_is_valid(window) then
    api.nvim_win_close(window, true)
  end
  if buffer and api.nvim_buf_is_valid(buffer) then
    api.nvim_buf_delete(buffer, { force = true })
  end
  window = nil
  buffer = nil
  RestoreMouse()
end

-- Function to get the current date information
local function get_date_info()
  local weekdays = { 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' }
  local months = { 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' }

  local day_of_week = weekdays[tonumber(os.date '%w') + 1]
  local day = os.date '%d'
  local month = months[tonumber(os.date '%m')]
  local year = os.date '%Y'

  return string.format('%s, %s %s %s', day_of_week, day, month, year)
end

-- Function to get system stats
local function get_system_stats()
  local handle = io.popen 'uptime -p' -- Example command to get system uptime
  local result = handle:read '*a'
  handle:close()
  return result:match '^(.-)\n' -- Clean up newline
end

-- Function to open GitHub
-- function M.open_github()
--   vim.fn.jobstart({ 'xdg-open', 'https://github.com/harshit-dhanwalkar' }, { detach = true })
-- end
-- Function to open GitHub
function M.open_github()
  local url = 'https://github.com/harshit-dhanwalkar'
  local open_cmd = nil

  if vim.fn.executable 'chromium' == 1 then
    open_cmd = { 'chromium', url }
  elseif vim.fn.executable 'brave' == 1 then
    open_cmd = { 'brave', url }
  elseif vim.fn.executable 'firefox' == 1 then
    open_cmd = { 'firefox', url }
  else
    open_cmd = { 'xdg-open', url }
  end

  vim.fn.jobstart(open_cmd, { detach = true })
end

-- Function to show 'About Me'
function M.about_me()
  print 'Harshit Prashant Dhanwalkar'
end

-- default_executive = 'telescope',
-- custom_center = {
--   { icon = '  ', desc = 'Find file          ', action = 'Telescope find_files', shortcut = 'SPC f f' },
--   { icon = '  ', desc = 'Search text        ', action = 'Telescope live_grep', shortcut = 'SPC f g' },
--   { icon = '  ', desc = 'Recent files       ', action = 'Telescope oldfiles', shortcut = 'SPC f r' },
--   { icon = '  ', desc = 'Edit config        ', action = 'edit ~/.config/nvim/init.lua', shortcut = 'SPC e e' },
--   { icon = '📦  ', desc = 'Project Dashboard  ', action = 'edit ~/projects/dashboard.md', shortcut = 'SPC p d' },
--   { icon = '  ', desc = 'Open GitHub         ', action = 'silent !xdg-open https://github.com/harshit-dhanwalkar', shortcut = 'SPC g g' },
--   { icon = '  ', desc = 'About Me!', action = 'echo "Harshit Prashant Dhanwalkar"', shortcut = 'SPC p p' },
-- },

--the nameX2
local function CreateDashboard(width_px, height_px)
  buffer = api.nvim_create_buf(false, true)

  local content = {
    '',
    [[       ██╗  ██╗ █████╗ ██████╗ ███████╗██╗  ██╗██╗████████╗  ]],
    [[       ██║  ██║██╔══██╗██╔══██╗██╔════╝██║  ██║██║╚══██╔══╝  ]],
    [[       ███████║███████║██████╔╝███████ ███████║██║   ██║     ]],
    [[       ██╔══██║██╔══██║██╔══██╗  ╚══██╗██╔══██║██║   ██║     ]],
    [[       ██║  ██║██║  ██║██║  ██║███████║██║  ██║██║   ██║     ]],
    [[       ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝     ]],
    -- [[   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
    -- [[   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
    -- [[   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
    -- [[   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
    -- [[   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
    -- [[   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
    '',
    '                           Context Menu',
    '',
    '              ┌───────┐                     ┌────┐',
    '              │  [e]  │ New file ───────────│   │',
    '              │  [f]  │ Find file ──────────│ 󰮗  │',
    '              │  [r]  │ Recent files ───────│   │',
    '              │  [s]  │ Settings ───────────│   │',
    '              │  [g]  │ NeoTree ────────────│   │',
    '              │ [gc]  │ Open .config ───────│ .  │',
    '              │ [gg]  │ Open GitHub ────────│   │', -- updated GitHub line
    '              │ [pp]  │ About Me! ──────────│   │', -- updated About Me line
    '              │[q Esc]│ Close dashboard ────│ ✗  │',
    '              └───────┘                     └────┘',
    '',
    '                  Uptime: ' .. get_system_stats(),
    '                      Date: ' .. get_date_info(),
    '',
    '                         Where is my mind? ',
  }

  -- Combine header and content
  --  local all_lines = vim.tbl_extend('force', header', content)
  local all_lines = content

  api.nvim_buf_set_lines(buffer, 0, -1, false, all_lines)

  local width = 0
  for _, line in ipairs(all_lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  width = width + 3
  local height = #all_lines + 2

  local editor_width = api.nvim_get_option 'columns'
  local editor_height = api.nvim_get_option 'lines'

  local row = math.floor((editor_height - height) / 2)
  local col = math.floor((editor_width - width) / 2)

  local ns_id = api.nvim_create_namespace 'dashboard'
  api.nvim_buf_add_highlight(buffer, ns_id, 'DashboardHeader', 0, 0, -1)

  -- -- Example positions, replace these with actual values from inspection
  -- local icon_start_col = 30 -- Start column for icons
  -- local icon_end_col = 34 -- End column for icons
  -- local option_start_col = 5 -- Start column for options
  -- local option_end_col = 26 -- End column for options
  -- local shortcut_start_col = 2 -- Start column for shortcuts
  -- local shortcut_end_col = 5 -- End column for shortcuts
  --
  -- for i = 1, #all_lines - 1 do
  --   if i > 1 and i < #all_lines - 1 then
  --     -- Highlight the icons
  --     api.nvim_buf_add_highlight(buffer, ns_id, 'DashboardIcon', i, icon_start_col, icon_end_col)
  --     -- Highlight the options
  --     api.nvim_buf_add_highlight(buffer, ns_id, 'DashboardOption', i, option_start_col, option_end_col)
  --     -- Highlight the shortcuts
  --     api.nvim_buf_add_highlight(buffer, ns_id, 'DashboardShortcut', i, shortcut_start_col, shortcut_end_col)
  --   end
  -- end

  local opts = {
    style = 'minimal',
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    border = 'single',
  }

  HideMouse()

  vim.api.nvim_create_autocmd({ 'BufLeave', 'VimLeave' }, {
    buffer = buffer,
    callback = function()
      RestoreMouse()
    end,
    once = true,
  })

  window = api.nvim_open_win(buffer, true, opts)
  vim.api.nvim_win_set_option(window, 'winhl', 'Normal:DashboardBackground')

  api.nvim_buf_set_option(buffer, 'modifiable', false)
  api.nvim_buf_set_option(buffer, 'buftype', 'nofile')
  api.nvim_buf_set_option(buffer, 'filetype', 'dashboard')

  local function set_keymap(key, action)
    api.nvim_buf_set_keymap(buffer, 'n', key, action, { silent = true, noremap = true })
  end

  set_keymap('e', ':lua require("custom.dashboard_custom").new_file()<CR>')
  set_keymap('f', ':lua require("custom.dashboard_custom").telescope_findfiles()<CR>')
  set_keymap('r', ':lua require("custom.dashboard_custom").telescope_oldfiles_in_new_tab()<CR>')
  set_keymap('s', ':Telescope find_files cwd=~/.config/nvim/<CR>')
  set_keymap('g', ':Ex<CR>')

  -- Set key mappings for 'q' and 'Esc' to close the dashboard
  set_keymap('q', ':lua require("custom.dashboard_custom").CloseDashboard()<CR>')
  set_keymap('<Esc>', ':lua require("custom.dashboard_custom").CloseDashboard()<CR>')

  set_keymap('gc', ':lua require("custom.dashboard_custom").open_config_directory()<CR>')
  -- Key mapping to open GitHub
  set_keymap('gg', ':lua require("custom.dashboard_custom").open_github()<CR>')
  -- Key mapping for "About Me!"
  set_keymap('pp', ':lua require("custom.dashboard_custom").about_me()<CR>')

  -- Center the dashboard
  -- CenterDashboard()
  AutoClose()
end

--the nameX3
local function CenterDashboard()
  if window and vim.api.nvim_win_is_valid(window) then
    local editor_width = vim.api.nvim_get_option 'columns'
    local editor_height = vim.api.nvim_get_option 'lines'
    local win_width = vim.api.nvim_win_get_width(window)
    local win_height = vim.api.nvim_win_get_height(window)

    local row = math.floor((editor_height - win_height) / 2)
    local col = math.floor((editor_width - win_width) / 2)

    vim.api.nvim_win_set_config(window, {
      relative = 'editor',
      row = row,
      col = col,
    })
  end
end

--some function for the keybinds of the menu
function M.telescope_oldfiles_in_new_tab()
  CloseDashboard()
  require('telescope.builtin').oldfiles()
end

function M.telescope_findfiles()
  CloseDashboard()
  require('telescope.builtin').find_files()
end

function M.toggle_dashboard(width_px, height_px)
  set_highlight_groups()
  if window and api.nvim_win_is_valid(window) then
    CloseDashboard()
    return false
  else
    CreateDashboard(width_px or 200, height_px or 300)
    AutoClose()
    return true
  end
end

function M.new_file()
  CloseDashboard()
  local filename = vim.fn.input 'Enter filename: '
  if filename ~= '' then
    vim.cmd('edit ' .. filename)
  end
end

function M.open_config_directory()
  M.CloseDashboard()
  vim.cmd 'Neotree ~/.config'
end

--pretty useless but i am too lazy so i made a seperate function so that i can make the close_funtion "global"
function M.CloseDashboard()
  CloseDashboard()
end

--custom commands mainly for the keybinds
vim.api.nvim_create_user_command('Dashboard', function(opts)
  local width = tonumber(opts.args:match '^(%d+)')
  local height = tonumber(opts.args:match ' (%d+)$')
  M.toggle_dashboard(width, height)
end, { nargs = '*' })

vim.api.nvim_create_user_command('CloseDashboard', M.CloseDashboard, {})

vim.api.nvim_create_autocmd('VimResized', {
  callback = CenterDashboard,
})

return M
