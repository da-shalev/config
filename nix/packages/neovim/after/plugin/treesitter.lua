vim.api.nvim_create_autocmd('FileType', {
  callback = function(event)
    local bufnr = event.buf
    local buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr })
    local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })

    if buftype ~= '' or filetype == '' then
      return
    end

    local parser_name = vim.treesitter.language.get_lang(filetype)
    if not parser_name then
      return
    end
    local parser_started = pcall(vim.treesitter.start, bufnr, parser_name)
    if not parser_started then
      return
    end
  end,
})
