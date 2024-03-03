local M = {}

M.buf_append = function(buf, lines)
  vim.schedule(function()
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
  end)
end

M.open_float = function(ratio, buf)
  if not ratio then
    ratio = 0.8
  end

  local width = vim.api.nvim_win_get_width(0)
  local height = vim.api.nvim_win_get_height(0)

  return vim.api.nvim_open_win(buf, true, {
    width = require('math').floor(width * ratio),
    height = require('math').floor(height * ratio),
    relative = 'editor',
    row = 0.5 * height - height * ratio / 2,
    col = 0.5 * width - width * ratio / 2,
    style = 'minimal',
    border = 'single',
  })
end

M.command = function()
  local saved = vim.g.COMPILE_COMMANDS_CUSTOM or ''
  if saved == '' then
    saved = '{}'
  end
  local saved_table = vim.json.decode(saved)
  local command = saved_table[vim.fn.getcwd(0)] or ''

  command = vim.fn.input({
    prompt = 'compile command: ',
    default = command,
    cancelreturn = false,
  })

  if not command then
    print('compiling aborted')
    return
  else
    saved_table[vim.fn.getcwd(0)] = command
    vim.g.COMPILE_COMMANDS_CUSTOM = vim.json.encode(saved_table)
  end

  return command
end

M.scroll_down = function(buf, win)
  vim.schedule(function()
    local lines = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_win_set_cursor(win, { lines, 0 })
  end)
end

return M
