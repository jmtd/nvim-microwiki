-- Copyright © 2026 [Jonathan Dowland], all rights reserved.
-- Distributed under the GNU General Public License, version 3.
-- See LICENSE.

-- stub log module, to match a subset of the API of
-- https://github.com/tjdevries/vlog.nvim

local M = {}

M.trace = function() end
M.debug = function() end
M.info  = function() end
M.warn  = function() end
M.error = function() end
M.fatal = function() end

return M
