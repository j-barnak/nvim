local M = {}

local MARKS = {
  TODO  = "<!-- ANKI:TODO -->",
  DOING = "<!-- ANKI:DOING -->",
  DONE  = "<!-- ANKI:DONE -->",
}

local function trim_right(s)
  return (s:gsub("%s+$", ""))
end

local function strip_any_mark(line)
  -- remove any existing ANKI marker (and surrounding whitespace)
  line = line:gsub("%s*<!%-%-%s*ANKI:%u+%s*%-%->%s*$", "")
  return trim_right(line)
end

local function set_mark_on_current_line(mark)
  local buf = 0
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""

  line = strip_any_mark(line)

  if mark and mark ~= "" then
    line = line .. " " .. mark
  end

  vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { line })
end

local function clear_all_marks_in_buffer()
  local buf = 0
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, line in ipairs(lines) do
    lines[i] = strip_any_mark(line)
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

vim.api.nvim_create_user_command("AnkiMarkTodo",  function() set_mark_on_current_line(MARKS.TODO)  end, {})
vim.api.nvim_create_user_command("AnkiMarkDoing", function() set_mark_on_current_line(MARKS.DOING) end, {})
vim.api.nvim_create_user_command("AnkiMarkDone",  function() set_mark_on_current_line(MARKS.DONE)  end, {})
vim.api.nvim_create_user_command("AnkiUnmark",    function() set_mark_on_current_line("")         end, {})
vim.api.nvim_create_user_command("AnkiClearMarks", function() clear_all_marks_in_buffer() end, {})

vim.keymap.set("n", "<leader>at", "<cmd>AnkiMarkTodo<CR>",  { silent = true, desc = "Mark TODO" })
vim.keymap.set("n", "<leader>ad", "<cmd>AnkiMarkDoing<CR>", { silent = true, desc = "Mark DOING" })
vim.keymap.set("n", "<leader>aD", "<cmd>AnkiMarkDone<CR>",  { silent = true, desc = "Mark DONE" })
vim.keymap.set("n", "<leader>au", "<cmd>AnkiUnmark<CR>",    { silent = true, desc = "Remove mark (line)" })
vim.keymap.set("n", "<leader>aC", "<cmd>AnkiClearMarks<CR>",{ silent = true, desc = "Clear all marks" })

return M

