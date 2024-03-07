local vim, api = vim, vim.api
local M = {
  go = { 'go run ', 'ginkgo test -v -count=1 -tags=integration ' },
  lua = { 'lua ' },
}

function M.run_command()
  local cmd = nil
  local file_type = vim.fn.expand('%:e')
  local file_name = vim.fn.expand('%:p')
  if file_type == 'go' then
    if file_name:match('_test') then
      cmd = M[file_type][2]
    else
      cmd = M[file_type][1]
    end
  else
    cmd = M[file_type][1]
  end
  local output_list = vim.fn.split(vim.fn.system(cmd .. file_name), '\n')
  for _, v in ipairs(output_list) do
    print(v)
  end
end

local function load_env_file()
  local env_file = require('core.global').home .. '/.env'
  local env_contents = {}
  if vim.fn.filereadable(env_file) ~= 1 then
    print('.env file does not exist')
    return
  end
  local contents = vim.fn.readfile(env_file)
  for _, item in pairs(contents) do
    local line_content = vim.fn.split(item, '=')
    env_contents[line_content[1]] = line_content[2]
  end
  return env_contents
end

function M.blameVirtualText()
  local fname = vim.fn.expand('%')
  if not vim.fn.filereadable(fname) then
    return
  end
  if vim.fn.system('git rev-parse --show-toplevel'):find('fatal') then
    return
  end

  local ns_id = api.nvim_create_namespace('GitLens')
  api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

  local line = api.nvim_win_get_cursor(0)
  local blame = vim.fn.system(string.format('git blame -c -L %d,%d %s', line[1], line[1], fname))
  if vim.v.shell_error > 0 then
    return
  end
  local hash = vim.split(blame, '%s')[1]
  if hash == '00000000' then
    return
  end

  local cmd = string.format('git show %s ', hash) .. "--format=' : %an | %ar | %s'"
  local text = vim.fn.system(cmd)
  text = vim.split(text, '\n')[1]
  if text:find('fatal') then
    return
  end

  api.nvim_buf_set_virtual_text(0, ns_id, line[1] - 1, { { text, 'GitLens' } }, {})
  api.nvim_command('highlight! link GitLens Comment')
end

function M.clearBlameVirtualText()
  local ns_id = api.nvim_create_namespace('GitLens')
  api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

function M.convertPathToPercentString(path)
    -- Check the operating system
    local isWindows =require('core.global').is_windows

    -- Windows paths
    if isWindows then
        path = path:gsub("\\", "%%")
        path = path:gsub("^([a-zA-Z]):", "%1%%")
    end
    path = path:gsub("^/", ""):gsub("/", "%%")
    -- remove trailing empty line e.g. \n \n\r
    path = path:gsub("%s*$", "")
    lprint(path)
    return path
end

return M
