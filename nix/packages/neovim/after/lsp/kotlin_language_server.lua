return {
  init_options = {
    storagePath = vim.fn.stdpath('cache') .. '/kotlin-language-server',
  },
  before_init = function(params)
    local root = params.rootPath
    if root then
      local src = root .. '/src'
      if vim.fn.isdirectory(src) == 1 then
        params.workspaceFolders = { { name = 'src', uri = vim.uri_from_fname(src) } }
      end
    end
  end,
}
