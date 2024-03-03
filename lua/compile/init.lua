local M = {}
local util = require('compile._util')

local defaults = {
  ratio = 0.8,
  type = 'float',
  direction = 'right',
}

M._state = {}

M.setup = function(opts)
  local buf = vim.api.nvim_create_buf(true, true)

  if opts then
    opts = vim.tbl_deep_extend('keep', opts, defaults)
  else
    opts = defaults
  end

  M._state = {
    buf = buf,
    window = nil,
    ratio = opts.ratio,
    type = opts.type,
    direction = opts.direction,
  }
end

M.compile = function()
  M.show()

  local command = util.command()

  local stdout = vim.uv.new_pipe()
  local stderr = vim.uv.new_pipe()

  local _, pid = vim.uv.spawn(
    'sh',
    { args = {
      '-c',
      command,
    }, stdio = { nil, stdout, stderr } },
    function(code, signal)
      util.buf_append(
        M._state.buf,
        { 'finished at ' .. require('os').date(), 'exit-code: ' .. code, 'signal: ' .. signal, '', '-----', '' }
      )
    end
  )

  util.buf_append(M._state.buf, { require('os').date(), 'start compilation as ' .. pid, '' })

  local function update(_, data)
    if data then
      local lines = vim.split(data, '\n')
      util.buf_append(M._state.buf, lines)
      util.scroll_down(M._state.buf, M._state.window)
    end
  end

  vim.uv.read_start(stdout, update)
  vim.uv.read_start(stderr, update)
end

M.close = function()
  if M._state.window then
    pcall(vim.api.nvim_win_close, M._state.window, true)
    M._state.window = nil
  end
end

M.show = function()
  M.close()
  if M._state.type == 'float' then
    M._state.window = util.open_float(M._state.ratio, M._state.buf)
  elseif M._state.type == 'split' then
    M._state.window = vim.api.nvim_open_win(M._state.buf, true, { split = M._state.direction })
  end
end

return M
