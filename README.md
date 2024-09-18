# Custom_nvim_dashboard
My customised dashboard

![image](https://github.com/user-attachments/assets/f5cf0d99-a7f4-46d8-a05b-35cfe0f90459)

Installation
To set up this dashboard, follow the steps below:

Clone the repository to your Neovim configuration directory:

```bash
git clone https://github.com/Harshit-Dhanwalkar/Custom_nvim_dashboard.git ~/.config/nvim/lua/custom/dashboard_custom.lua.
```
Install the required Neovim plugins using your preferred plugin manager, e.g., lazy.nvim or packer.nvim.
The add the following lines in you nvim `~/.config/nvim/init.lua`

Customize the dashboard by editing the configuration files in `~/.config/nvim/lua/custom/dashboard_custom.lua`.
```lua
-- custom dashboard setup
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    require('custom.dashboard_custom').toggle_dashboard(300, 300)
  end,
})
```
Reload Neovim to see the changes.

Key Functionalities
Startup Screen
The dashboard displays a custom startup screen that shows useful information such as:

Recent projects
Favorite shortcuts for commonly used files
Quick access to the file explorer or terminal
You can easily add more widgets or modify the layout by editing the dashboard's Lua configuration.
