local M = {}
local util = require('compile._util')

local defaults = {
  ratio = 0.8,
}

M._state = {}

M.setup = function(opts)
  local buf = vim.api.nvim_create_buf(true, true)

  if opts then
    vim.tbl_deep_extend('keep', opts, defaults)
  else
    opts = defaults
  end

  M._state = {
    buf = buf,
    window = nil,
    ratio = opts.ratio,
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
        { 'finished at ' .. require('os').date(), 'exit-code: ' .. code, 'signal: ' .. signal, '===' }
      )
    end
  )

  util.buf_append(M._state.buf, { require('os').date(), 'start compilation as ' .. pid })

  vim.uv.read_start(stdout, function(_, data)
    if data then
      local lines = vim.split(data, '\n')
      util.buf_append(M._state.buf, lines)
    end
  end)

  vim.uv.read_start(stderr, function(_, data)
    if data then
      local lines = vim.split(data, '\n')
      util.buf_append(M._state.buf, lines)
    end
  end)
end

M.close = function()
  if M._state.window then
    vim.api.nvim_win_close(M._state.window, true)
    M._state.window = nil
  end
end

M.show = function()
  M._state.window = util.open_float(M._state.ratio, M._state.buf)
end

return M
