vim.api.nvim_create_user_command("RemoveOriginal", function()
  local target_dir = "/tmp/RecentlyDeleted"
  vim.fn.mkdir(target_dir, "p")

  -- Directory of the current buffer's file
  local buf_path = vim.api.nvim_buf_get_name(0)
  if buf_path == "" then
    vim.notify("RemoveOriginal: current buffer has no file path", vim.log.levels.WARN)
    return
  end
  local buf_dir = vim.fn.fnamemodify(buf_path, ":p:h")

  -- Find files in that directory whose names start with _Q
  local pattern = buf_dir .. "/_Q*"
  local matches = vim.fn.glob(pattern, false, true)

  if #matches == 0 then
    vim.notify(("RemoveOriginal: no _Q* files in %s"):format(buf_dir), vim.log.levels.INFO)
    return
  end

  local moved, failed = 0, {}

  for _, src in ipairs(matches) do
    if vim.fn.isdirectory(src) == 0 then
      local base = vim.fn.fnamemodify(src, ":t")
      local dest = target_dir .. "/" .. base

      -- Avoid overwriting in /tmp/RecentlyDeleted
      if vim.loop.fs_stat(dest) then
        local stamp = os.date("%Y%m%d-%H%M%S")
        dest = target_dir .. "/" .. base .. "." .. stamp
        local i = 1
        while vim.loop.fs_stat(dest) do
          i = i + 1
          dest = target_dir .. "/" .. base .. "." .. stamp .. "." .. i
        end
      end

      local ok, err = vim.loop.fs_rename(src, dest)
      if ok then
        moved = moved + 1
      else
        table.insert(failed, string.format("%s (%s)", src, err or "unknown error"))
      end
    end
  end

  if #failed == 0 then
    vim.notify(("RemoveOriginal: moved %d file(s) to %s"):format(moved, target_dir), vim.log.levels.INFO)
  else
    vim.notify(
      ("RemoveOriginal: moved %d, failed %d:\n- %s"):format(moved, #failed, table.concat(failed, "\n- ")),
      vim.log.levels.WARN
    )
  end
end, { desc = "Move _Q* files in the current buffer's directory to /tmp/RecentlyDeleted" })

