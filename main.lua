vim.api.nvim_set_hl(0, 'RaindropBackground', { bg = '#303030' })

local raindrops = {}
_G.raindrop_schedule = {}
local function create_raindrop(raindrop_config)
  local raindrop_lines = {}

  for y = 0, raindrop_config.height do
    local raindrop_line = vim.api.nvim_open_win(0, false, {
      relative = 'editor',
      width = raindrop_config.width,
      height = 1,
      col = vim.api.nvim_win_get_option(0, 'numberwidth') + raindrop_config.x,
      row = raindrop_config.y + y - vim.fn.line('w0'),
      style = 'minimal',
      focusable = false,
      zindex = 100,
    })

    vim.api.nvim_win_set_option(raindrop_line, 'signcolumn', 'no')
    vim.api.nvim_win_set_option(raindrop_line, 'wrap', false)
    vim.api.nvim_win_set_option(raindrop_line, 'winhighlight', 'Normal:RaindropBackground')
    vim.api.nvim_win_set_option(raindrop_line, 'virtualedit', 'all')
    vim.api.nvim_win_set_cursor(raindrop_line, { math.min(raindrop_config.y + y + raindrop_config.vy, vim.api.nvim_win_get_height(0)), raindrop_config.x + 1 + raindrop_config.vx })

    table.insert(raindrop_lines, raindrop_line)
  end

  for _, raindrop_line in pairs(raindrop_lines) do
    _G.raindrop_schedule[raindrop_line] = vim.schedule_wrap(function()
      vim.defer_fn(function()
        local current = vim.api.nvim_win_get_option(raindrop_line, 'winblend')
        vim.api.nvim_win_set_option(raindrop_line, 'winblend', current + math.floor(math.max(1, current / 10)))
        if vim.api.nvim_win_get_option(raindrop_line, 'winblend') >= 100 then
          vim.api.nvim_win_close(raindrop_line, true)
          _G.raindrop_schedule[raindrop_line] = nil
        else
          _G.raindrop_schedule[raindrop_line]()
        end
      end, 50)
    end)

    _G.raindrop_schedule[raindrop_line]()
  end

  table.insert(raindrops, raindrop_lines)
end

local win_width = vim.api.nvim_win_get_width(0)
local win_height = vim.api.nvim_win_get_height(0)
local function raindrop_once()
  local raindrop_config = {
    min_x = 5,
    max_x = win_width - 5,
    min_y = 5,
    max_y = win_height - 5,
    min_width = 1,
    max_width = 3,
    min_height = 1,
    max_height = 3,
    vx = -1,
    vy = -1,
  }

  local x = math.random(raindrop_config.min_x, raindrop_config.max_x)
  local y = math.random(vim.fn.line('w0') + raindrop_config.min_y, vim.fn.line('w0') + raindrop_config.max_y)
  y = math.min(y, vim.fn.line('$'))
  local width = math.random(raindrop_config.min_width, raindrop_config.max_width)
  local height = math.random(raindrop_config.min_height, raindrop_config.max_height)
  local vx = raindrop_config.vx
  local vy = raindrop_config.vy
  create_raindrop({
    x = x,
    y = y,
    width = width,
    height = height,
    vx = vx,
    vy = vy
  })
end

local function rain()
  _G.rain_schedule = vim.schedule_wrap(function()
    vim.defer_fn(function()
      raindrop_once()
      _G.rain_schedule()
    end, math.random(100, 260))
  end)

  _G.rain_schedule()
end

rain()
