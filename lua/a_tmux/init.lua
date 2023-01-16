local M = {}

local options = {
    format = "'#{pane_active}:#{pane_id}'",
    pane = {
        height = 20,
        orientation = 'v'
    }
}

local function pane_options()
    return '-l' ..options.pane.height .. "% -" .. options.pane.orientation
end

local function tmux_command(cmd, opts)
    opts = opts or ''
    return vim.fn.system('tmux ' .. cmd .. ' ' .. opts)
end

local function active_pane(panes_list)
    local current_id = 0
    _ = string.gsub(panes_list, "(%d):%%(%d)", function (active, id)
        if active == "1" then
            current_id = id
        end
    end)
    return current_id
end

local function current_pane()
    local views = tmux_command('list-panes', "-F " .. options.format )
    return active_pane(views)
end

local function add_pane(id)
    local t = {
        id = id,
        height = options.pane.height
    }
    table.insert(M._nvim_panes, t)
end

M._nvim_panes = {}

M.new_pane = function ()
    if vim.fn.exists("$TMUX") == 1 then
        local _ = current_pane()
        tmux_command('split-window', pane_options())
        local a = tmux_command('display', "-p '#{pane_id}'")
        add_pane(string.match(a, "%d+"))
    else
        vim.cmd([[
        :FloatermToggle
        ]])
    end
end

-- TODO: Check this id table
M.close_pane = function ()
    local panes =  M._nvim_panes
    for _, pane in pairs(panes) do
        tmux_command('kill-pane', '-t %'.. pane.id)
    end
end

M.toggle_pane = function ()
    if next(M._nvim_panes) == nil then
        M.new_pane()
    else
        for _, pane in ipairs(M._nvim_panes) do
            if pane.height == 20 then
                pane.height = 0
            else
                tmux_command('select-pane', '-t %' .. pane.id)
                pane.height = 20
            end
            local args = '-t %' .. pane.id .. ' -y ' .. pane.height .. '%'
            tmux_command('resize-pane', args)
        end
    end
end

return M
