require('syuq.base')
require('syuq.highlights')
require('syuq.maps')
require('syuq.plugins')

local has = vim.fn.has
local is_mac = has "macunix"
local is_win = has "win32"
local is_wsl = has "wsl"

if is_mac then
  require('syuq.macos')
end
if is_win then
  require('syuq.windows')
end
if is_wsl then
  require('syuq.wsl')
end
if vim.g.neovide then
  require('syuq.neovide')
end
