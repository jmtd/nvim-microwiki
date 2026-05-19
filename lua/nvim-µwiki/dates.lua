-- Copyright © 2026 [Jonathan Dowland], all rights reserved.
-- Distributed under the GNU General Public License, version 3.
-- See LICENSE.

local M = {}

M.suffix = function()
  return ".mdwn"
end

local tsFromBasename = function()
  local basename = vim.fs.basename(vim.fn.expand('%'))
  return vim.fn.strptime("%Y-%m-%d", basename)
end

M.otherDatePage = function(warp)
  local ts = tsFromBasename()
  if ts then
    local nextday = vim.fn.strftime("%Y-%m-%d", warp(ts))
    local dname = vim.fs.dirname(vim.fn.expand('%'))
    local fname = vim.fs.joinpath(dname, nextday) .. M.suffix()
    vim.cmd.edit({ args = { fname } })
  end
end

local daySecs = 60*60*24

M.nextDatePage = function() M.otherDatePage(function(ts) return ts + daySecs end) end
M.prevDatePage = function() M.otherDatePage(function(ts) return ts - daySecs end) end

M.todayDatePage = function()
  local fname = vim.fs.normalize(vim.fs.joinpath(
    vim.uv.cwd(), os.date("%Y-%m-%d") .. M.suffix()))
  vim.cmd.edit({ args = { fname } })
end

M.nextWeekDayPage = function()
  local ts = tsFromBasename()
  if ts then
    local skip = 1
    if "5" == vim.fn.strftime("%u", ts) -- Friday
    then
      skip = 3
    end
    M.otherDatePage(function(ts) return ts + (skip*daySecs) end)
  end
end

M.prevWeekDayPage = function()
  local ts = tsFromBasename()
  if ts then
    local skip = 1
    if "1" == vim.fn.strftime("%u", ts) -- Monday
    then
      skip = 3
    end
    M.otherDatePage(function(ts) return ts - (skip*daySecs) end)
  end
end

return M
