local Model = require("lapis.db.model").Model
local bcrypt = require("bcrypt")

local users = Model:extend("authme")

users.register = function(self, username, password)
	local realname, digest
	
	if username and username:match("[a-zA-Z0-9_]+") then
		realname = username
		username = realname:lower()
	else
		return nil, "Wrong username"
	end
	
	if password and password:match("[!-~]+") then
		password = password
		digest = bcrypt.digest(password, 5)
	else
		return nil, "Wrong password"
	end

	local user = self:find({username = username})
	if user then
		return nil, "This username have already registered"
	end

	self:create({
		username = username,
		realname = realname,
		password = digest
	})

	local user = self:find({username = username})

	return user, "Registration complete"
end

return users
