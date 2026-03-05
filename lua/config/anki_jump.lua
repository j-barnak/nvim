local M = {}

local function get_lines(buf)
	return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

local function find_header_line(lines, header)
	local pat = "^%s*" .. vim.pesc(header) .. "%s*$"
	for i, line in ipairs(lines) do
		if line:match(pat) then
			return i
		end
	end
	return nil
end

local function find_section_end(lines, start_i)
	for i = start_i + 1, #lines do
		if lines[i]:match("^#%s+") then
			return i - 1
		end
	end
	return #lines
end

local function jump_to(row)
	vim.api.nvim_win_set_cursor(0, { row, 0 })
end

local function parse_origin_n(line)
	local n = line:match("^%s*Origin_(%d+)%s*:%s*")
	return n and tonumber(n) or nil
end

local function parse_question_n(line)
	local n = line:match("^%s*(%d+)%..+")
	return n and tonumber(n) or nil
end

-- Matches exactly: Origin: TODO; Source: "<...>"
local function parse_todo_source(line)
	return line:match('^%s*Origin:%s*TODO%s*;%s*Source:%s*"(.-)"%s*$')
end

local function is_original_todo_line(line)
	-- In original input, TODO lines start with "#todo" (accepts indentation)
	return line:match("^%s*#todo%s+") ~= nil
end

local function strip_quote(s)
	return (s:gsub("^%s*", ""):gsub("%s*$", ""))
end

local function find_question_line_by_n(lines, qs, qe, n)
	local pat = "^%s*" .. n .. "%.%s+"
	for i = qs, qe do
		if lines[i]:match(pat) then
			return i
		end
	end
	return nil
end

local function find_first_origin_line_by_n(lines, fs, fe, n)
	local pat = "^%s*Origin_" .. n .. "%s*:%s*"
	for i = fs, fe do
		if lines[i]:match(pat) then
			return i
		end
	end
	return nil
end

local function find_first_todo_origin_by_source(lines, fs, fe, snippet)
	-- Find the first TODO-origin line whose Source exactly matches snippet
	for i = fs, fe do
		local src = parse_todo_source(lines[i])
		if src and src == snippet then
			return i
		end
	end
	return nil
end

local function find_original_todo_block_for_snippet(lines, os, oe, snippet)
	-- Find the snippet text within the Original Input section and jump to the nearest #todo above it.
	-- This is robust even if the snippet spans multiple lines: we search for a distinctive substring.
	local needle = snippet
	-- If snippet is huge, use the first ~120 chars as an anchor to avoid slow searches.
	if #needle > 120 then
		needle = needle:sub(1, 120)
	end

	local found_line = nil
	for i = os, oe do
		if lines[i]:find(needle, 1, true) then
			found_line = i
			break
		end
	end
	if not found_line then
		return nil
	end

	-- Walk upward to find the closest #todo line
	for i = found_line, os, -1 do
		if is_original_todo_line(lines[i]) then
			return i
		end
	end

	-- If none above, still return the found snippet line as fallback
	return found_line
end

local function extract_snippet_after_todo(lines, row, os, oe)
	-- From a #todo line, collect following quote block lines starting with ">" (common in your prompts).
	-- This returns the concatenated snippet text (without leading "> ").
	local snippet_lines = {}
	for i = row + 1, oe do
		local l = lines[i]
		if l:match("^%s*>") then
			local content = l:gsub("^%s*>%s?", "")
			table.insert(snippet_lines, content)
		else
			-- stop at first non-quote line (or blank line after quotes is also a stop)
			if #snippet_lines > 0 then
				break
			end
		end
	end
	if #snippet_lines == 0 then
		return nil
	end
	return table.concat(snippet_lines, "\n")
end

function M.jump()
	local buf = 0
	local lines = get_lines(buf)
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local line = lines[row] or ""

	local flash_h = find_header_line(lines, "# Flashcards")
	local ques_h = find_header_line(lines, "# Questions")
	if not flash_h or not ques_h then
		vim.notify("Missing '# Flashcards' or '# Questions' header.", vim.log.levels.ERROR)
		return
	end

	local fs, fe = flash_h + 1, find_section_end(lines, flash_h)
	local qs, qe = ques_h + 1, find_section_end(lines, ques_h)

	-- Optional: original input section
	local orig_h = find_header_line(lines, "# Original Input")
	local os, oe
	if orig_h then
		os, oe = orig_h + 1, find_section_end(lines, orig_h)
	end

	-- 1) Origin_N -> Question N
	local on_origin = parse_origin_n(line)
	if on_origin then
		local qline = find_question_line_by_n(lines, qs, qe, on_origin)
		if not qline then
			vim.notify(("No matching question '%d.' found under # Questions."):format(on_origin), vim.log.levels.ERROR)
			return
		end
		jump_to(qline)
		return
	end

	-- 2) Question N -> Origin_N
	local on_question = parse_question_n(line)
	if on_question and row >= qs and row <= qe then
		local oline = find_first_origin_line_by_n(lines, fs, fe, on_question)
		if not oline then
			vim.notify(("No matching Origin_%d: found under # Flashcards."):format(on_question), vim.log.levels.ERROR)
			return
		end
		jump_to(oline)
		return
	end

	-- 3) Origin: TODO; Source: "<snippet>" -> jump to matching #todo in # Original Input
	local src = parse_todo_source(line)
	if src then
		if not orig_h then
			vim.notify("Found TODO card, but '# Original Input' section is missing.", vim.log.levels.ERROR)
			return
		end
		local target = find_original_todo_block_for_snippet(lines, os, oe, src)
		if not target then
			vim.notify("Could not find matching snippet under '# Original Input'.", vim.log.levels.ERROR)
			return
		end
		jump_to(target)
		return
	end

	-- 4) If cursor is on a #todo line under '# Original Input' -> jump to first TODO card matching its snippet
	if orig_h and row >= os and row <= oe and is_original_todo_line(line) then
		local snippet = extract_snippet_after_todo(lines, row, os, oe)
		if not snippet then
			vim.notify("No quoted snippet ('> ...') found under this #todo line.", vim.log.levels.ERROR)
			return
		end
		local oline = find_first_todo_origin_by_source(lines, fs, fe, snippet)
		if not oline then
			-- fallback: use an anchor substring search if exact match differs
			local anchor = snippet
			if #anchor > 120 then
				anchor = anchor:sub(1, 120)
			end
			local found = nil
			for i = fs, fe do
				local s2 = parse_todo_source(lines[i])
				if s2 and s2:find(anchor, 1, true) then
					found = i
					break
				end
			end
			if not found then
				vim.notify("No matching TODO card found for this snippet.", vim.log.levels.ERROR)
				return
			end
			jump_to(found)
			return
		end
		jump_to(oline)
		return
	end

	vim.notify(
		"Not on Origin_<N>, a numbered question line, Origin: TODO, or #todo in # Original Input.",
		vim.log.levels.WARN
	)
end

vim.api.nvim_create_user_command("AnkiJump", function()
	M.jump()
end, {})

-- Optional keymap
vim.keymap.set("n", "<leader>aj", function()
	M.jump()
end, { silent = true, desc = "AnkiJump (Origin<->Question, TODO<->Original Input)" })

return M
