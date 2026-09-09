local max_filesize = 512 * 1024

local opt = vim.opt

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevelstart = 99

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true }),
	callback = function(args)
		local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(args.buf))
		if stats and stats.size > max_filesize then
			return
		end

		local language = vim.treesitter.language.get_lang(args.match)
		if language and vim.treesitter.language.add(language) then
			vim.treesitter.start(args.buf, language)
		end
	end,
})
