-- lua/config/lsp_toggle.lua
local M = {}

-- module-level state
local winid          -- current floating signature window
local prev_win       -- window we jumped from
local prev_mode      -- mode we were in ("i", "n", ...)
local prev_cursor    -- {row, col} 1-based
local ns             -- extmark namespace for safer cursor restore

-------------------------------------------------
-- 1. Toggle the signature-help popup (<C-f>)
-------------------------------------------------
function M.toggle()
  -- if already open, close & reset
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_win_close(winid, true)
    winid = nil
    return
  end

  local util, orig = vim.lsp.util, vim.lsp.util.open_floating_preview
  ns = ns or vim.api.nvim_create_namespace("sig_help_toggle")

  util.open_floating_preview = function(contents, syntax, opts, ...)
    opts = opts or {}
    opts.focusable = true

    local bufnr, w = orig(contents, syntax, opts, ...)
    winid          = w

    ----------------------------------------------------------------
    -- Map <C-g> inside the popup (once per buffer)
    ----------------------------------------------------------------
    if not vim.b[bufnr].sig_help_mapped then
      vim.keymap.set({ "n", "i" }, "<C-g>", M.leave,
        { buffer = bufnr, silent = true, nowait = true, noremap = true })
      vim.b[bufnr].sig_help_mapped = true
    end

    util.open_floating_preview = orig
    return bufnr, w
  end

  vim.lsp.buf.signature_help({ silent = true })
end

-------------------------------------------------
-- 2. Jump INTO the popup (<C-g> from Insert)
-------------------------------------------------
function M.enter()
  if winid and vim.api.nvim_win_is_valid(winid) then
    prev_win    = vim.api.nvim_get_current_win()
    prev_mode   = vim.fn.mode()
    prev_cursor = vim.api.nvim_win_get_cursor(prev_win)

    -- also set an extmark in case text around the cursor changes
    local row, col = prev_cursor[1] - 1, prev_cursor[2]
    prev_cursor = vim.api.nvim_buf_set_extmark(
      0, ns, row, col, { right_gravity = false })

    vim.api.nvim_set_current_win(winid)
    vim.cmd("stopinsert")           -- Normal mode inside popup

    -- clear winid so a second <C-f> won’t try to close the still-open win
    winid = nil
  end
end

-------------------------------------------------
-- 3. Jump BACK  (restore cursor & mode)
-------------------------------------------------
function M.leave()
  if not (prev_win and vim.api.nvim_win_is_valid(prev_win)) then
    vim.cmd("wincmd p")             -- fallback
    return
  end

  local w       = prev_win
  local mark_id = prev_cursor
  local was_ins = prev_mode and prev_mode:sub(1,1) == "i"

  vim.api.nvim_set_current_win(w)

  -- restore mode immediately (triggers InsertEnter if needed)
  if was_ins then
    vim.cmd("startinsert!")
  else
    vim.cmd("stopinsert")
  end

  -- after all InsertEnter autocmds/plugins finish, put cursor back
  vim.schedule(function()
    if not (w and vim.api.nvim_win_is_valid(w)) then return end

    local ok, pos = pcall(vim.api.nvim_buf_get_extmark_by_id,
                          0, ns, mark_id, {})
    if ok and pos and #pos == 2 then
      local row, col = pos[1] + 1, pos[2]
      -- cap column to current line length
      local line_len = #vim.fn.getline(row)
      if col > line_len then col = line_len end
      pcall(vim.api.nvim_win_set_cursor, w, { row, col })
    end

    -- clear extmark
    pcall(vim.api.nvim_buf_del_extmark, 0, ns, mark_id)
    -- reset state
    winid, prev_win, prev_mode, prev_cursor = nil, nil, nil, nil
  end)
end

return M
