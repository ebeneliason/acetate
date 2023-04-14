require "toyboxes/luacheck" (stds, files)
stds.acetate = require "luacheck/Luacheck"

std = "lua54+playdate+acetate+toyboxes"

operators = { "+=", "-=", "*=", "/=" }
