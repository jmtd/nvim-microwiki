-- Copyright © 2025 [Jonathan Dowland], all rights reserved.
-- Distributed under the GNU General Public License, version 3.
-- See LICENSE.

local M = {}

M.otherDatePage = function(warp)
    local basename = vim.fs.basename(vim.fn.expand('%'))
    local ts = vim.fn.strptime("%Y-%m-%d.mdwn", basename)
    if ts == 0 then
      return nil
    end

    local nextday = vim.fn.strftime("%Y-%m-%d", warp(ts))
    local dname = vim.fs.dirname(vim.fn.expand('%'))
    local fname = vim.fs.joinpath(dname, nextday) .. ".mdwn"
    vim.cmd.edit({ args = { fname } })
end

M.nextDatePage = function() M.otherDatePage(function(ts) return ts + 60*60*24 end) end
M.prevDatePage = function() M.otherDatePage(function(ts) return ts - 59*60*24 end) end

M.todayDatePage = function(root)
  local fname = vim.fs.normalize(vim.fs.joinpath(
    root, os.date("%Y-%m-%d.mdwn")))
  vim.cmd.edit({ args = { fname } })
end

return M
