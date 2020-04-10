local Model = require("lapis.db.model").Model

local keys = Model:extend("keys")

keys.register = function(self, key, username)
	local keyEntry = self:find({key = key})
	keyEntry.username = username
	keyEntry:update("username")
end

return keys
