local compile = require('compile')

vim.api.nvim_create_user_command('Compile', compile.compile, {})
vim.api.nvim_create_user_command('CompileClose', compile.close, {})
vim.api.nvim_create_user_command('CompileShow', compile.show, {})
