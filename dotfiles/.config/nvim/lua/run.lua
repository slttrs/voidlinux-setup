-- ~/.config/nvim/lua/run.lua
-- Press <leader>r to save and run the current file in a terminal split.
-- Load it from init.lua with:  require("run")

local function is_csproj(name)
  return name:match("%.csproj$") or name:match("%.sln$")
end

local function build_command()
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p")
  local q = vim.fn.shellescape(file)
  local out = vim.fn.shellescape(vim.fn.expand("%:p:r"))

  if ft == "python" then
    return "python3 " .. q
  elseif ft == "c" then
    return "gcc -Wall -g " .. q .. " -o " .. out .. " && " .. out
  elseif ft == "cpp" then
    return "g++ -Wall -g " .. q .. " -o " .. out .. " && " .. out
  elseif ft == "cs" then
    -- Inside a project/solution: run the project. Otherwise: run as a single-file
    -- app (needs .NET 10+).
    local root = vim.fs.root(0, is_csproj)
    if root then
      return "dotnet run --project " .. vim.fn.shellescape(root)
    end
    return "dotnet run " .. q
  end
end

local function run_current()
  local cmd = build_command()
  if not cmd then
    vim.notify("No runner for filetype: " .. vim.bo.filetype, vim.log.levels.WARN)
    return
  end
  vim.cmd("write")
  local dir = vim.fn.expand("%:p:h")
  vim.cmd("botright 14new")
  vim.fn.jobstart(cmd, { term = true, cwd = dir })
  vim.bo.buflisted = false -- keep terminal output out of the tab bar
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>r", run_current, { desc = "Run current file" })

-- Easier exit from terminal mode (default is Ctrl+\ Ctrl+n)
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })
