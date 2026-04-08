-- Copyright © 2025 [Jonathan Dowland], all rights reserved.
-- Distributed under the GNU General Public License, version 3.
-- See LICENSE.

local M = {}
M.root = "/"

local preferredSuffix = function()
  local suf = ".md"
  local suffixes = vim.opt.suffixesadd:get()
  if #(suffixes) > 0 then
    suf = suffixes[1]
  end
  return suf
end

local D = require("nvim-µwiki.dates")
D.suffix = preferredSuffix
M.todayDatePage = function() D.todayDatePage(root) end
M.nextDatePage  = D.nextDatePage
M.prevDatePage  = D.prevDatePage

M.setup = function(config)
  root = config['root']
  return M
end

M.reportNodeAtCursor = function()
  return M.reportNode(vim.treesitter.get_node({lang="markdown_inline"}), 5)
end

M.reportNode = function(node, depth)
  if depth == 0 then
    vim.print("reportNode: reached max recursion depth, aborting")
    return nil
  end

  -- XXX: does this resolve the occasional breakage?
  local buf    = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(buf)
  if not parser:is_valid() then
    parser:parse()
  end

  -- if the Wiki extension is enabled, this might match: [[test]]
  if node:type() == "link_destination" then           --   ^^^^
    node = node:parent()
  end -- fall through

  -- if the Wiki extension is enabled, this might match: [[test]]
  if node:type() == "wiki_link" then                  -- ^^    ^^
    node = node:named_child(0)
    return vim.treesitter.get_node_text(node, buf)
  end

  --                  [[test]]
  --    cursor is here ^ or ^
  if node:type() == "shortcut_link" then
    node = node:named_child(0)
  end -- fall through

  --                  [[test]]
  --  cursor is in here ^^^^
  if node:type() == "link_text" then
    return vim.treesitter.get_node_text(node, buf)

  elseif node:type() == "inline" then
    local line      = vim.api.nvim_get_current_line()
    local win       = vim.api.nvim_get_current_win()
    local row1,col0 = unpack(vim.api.nvim_win_get_cursor(win))
    local row0,col1 = row1 - 1, col0 + 1

    -- cursor is here >[[test]], retry on next column
    -- Hit recursion depth limit on this character
    if "[[" == string.sub(line, col1,col1+1) then
      vim.print("recursing at "..row1..","..col1+1)
      return M.reportNode(vim.treesitter.get_node({
        lang="markdown_inline", pos={row0, col0+1}}), depth-1)

    -- [[test]]< cursor is here, retry on previous column
    -- Hit recursion depth limit on this character
    elseif "]]" == string.sub(line, col1-1,col1) then
      vim.print("recursing at "..row1..","..col1-1)
      return M.reportNode(vim.treesitter.get_node({
        lang="markdown_inline", pos={row0, col0-1}}), depth-1)
    end
  end
  return nil
end

M.followWikiLink = function()
  local base = M.reportNodeAtCursor()
  if not base then
    return false
  end

  local suffix= preferredSuffix()
  local fname = vim.api.nvim_eval("expand('%:h').'/"..base.."'.'"..suffix.."'")
  local bufnr = vim.api.nvim_get_current_buf()
  local from  = vim.fn.getpos(".")
  local stack = vim.fn.gettagstack()
  from[1] = bufnr
  stack.items = {{
    bufnr   = bufnr,
    tagname = base,
    from    = from,
    matchnr = 1,
  }}

  vim.cmd.edit({ args = { fname } })

  -- XXX was the above successful? If not, would we abort here?
  if 0 == vim.fn.settagstack(vim.api.nvim_get_current_win(), stack, 't') then
    return true
  end
  return false
end

M.nextWikiLink = function()
  vim.fn.search("[[")
end

M.prevWikiLink = function()
  vim.fn.search("[[", "b")--backwards
end

M.decorateWord = function()
  vim.api.nvim_exec2('normal! diw', {})
  local word = vim.fn.getreg('-')
  vim.api.nvim_exec2('normal! i[['..word..']]', {})
end

M.maybeFollowWikiLink = function()
  if M.followWikiLink() then
    return true
  end
  M.decorateWord()
end

return M
