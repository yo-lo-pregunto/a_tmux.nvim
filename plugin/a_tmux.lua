if vim.g.a_tmux_loaded == 1 then
    return
end
vim.g.a_tmux_loaded = 1

vim.api.nvim_create_augroup("ATmuxAuGroup", {})

vim.api.nvim_create_autocmd("VimLeave", {
    callback = function ()
        require('a_tmux').close_pane()
    end
})

vim.api.nvim_create_user_command("ATmuxNewPane", function ()
        require('a_tmux').new_pane()
    end, {})

vim.api.nvim_create_user_command("ATmuxTogglePane", function ()
        require('a_tmux').toggle_pane()
    end, {})

-- TODO Create a 'ATmuxClosePane' whith complition
-- TODO resize vertical
