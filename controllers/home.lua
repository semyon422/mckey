local users = require("models.users")
local keys = require("models.keys")

local home = {}

home.GET = function(self)
	self.title = "Registration page"
	self.message = ""
	return {render = true}
end

home.POST = function(self)
	self.title = "Registration page"

	local keyEntry = keys:find({key = self.params.key})

	if not keyEntry or keyEntry.username ~= "" then
		self.message = "Wrong key"
		return {render = true}
	end

	local user, message = users:register(self.params.username, self.params.password)

	if not user then
		self.message = message
		return {render = true}
	end

	keys:register(self.params.key, self.params.username)

	self.message = "Success"
	return {render = true}
end

return home
