local lapis = require("lapis")
local bcrypt = require("bcrypt")
local Model = require("lapis.db.model").Model

local User_keys = Model:extend("user_keys")
local Users = Model:extend("authme")

local app = lapis.Application()
app:enable("etlua")
app.layout = require("views.layout")

app:get("index", "/", function(self)
	return {render = true}
end)

app:post("index", "/", function(self)
	local params = self.params

	local user_key = User_keys:find({key = params.key})
	if not user_key then
		return {redirect_to = self:url_for("index", {}, {message = "Key not found"})}
	end

	local username = params.username
	if not username or not username:match("[a-zA-Z0-9_]+") then
		return {redirect_to = self:url_for("index", {}, {message = "Wrong username"})}
	end

	local password = params.password
	if not password or not password:match("[!-~]+") then
		return {redirect_to = self:url_for("index", {}, {message = "Wrong password"})}
	end

	local new_user = {username = username:lower()}
	local user = Users:find(new_user)
	if user then
		return {redirect_to = self:url_for("index", {}, {message = "This username have already registered"})}
	end

	new_user.realname = username
	new_user.password = bcrypt.digest(password, 10)
	user = Users:create(new_user)
	user_key:delete()

	return {redirect_to = self:url_for("index", {}, {message = "Success"})}
end)

return app
