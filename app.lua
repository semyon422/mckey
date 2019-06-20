local lapis = require("lapis")
local db = require("lapis.db")
local http = require("lapis.nginx.http")
local etlua = require("etlua")
local bcrypt = require("bcrypt")

local app = lapis.Application()
app:enable("etlua")
app.layout = require("views.layout")

app:post("/", function(self)
	local key, keyid, username, realname, password, password_crypt
	
	if self.params.key then
		key = self.params.key
	else
		return "Wrong password"
	end
	
	if self.params.username and self.params.username:match("[a-zA-Z0-9_]+") then
		realname = self.params.username
		username = realname:lower()
	else
		return "Wrong username"
	end
	
	if self.params.password and self.params.password:match("[!-~]+") then
		password = self.params.password
		password_crypt = bcrypt.digest(password, 5)
	else
		return "Wrong password"
	end
	
	if not self.params.confirmpassword or self.params.confirmpassword ~= self.params.password then
		return "Wrong password confirmation"
	end
	
	local result = db.query(("SELECT * FROM `keys` WHERE `key` = '%s'"):format(key))
	if #result > 0 then
		local row = result[1]
		if row.username ~= "" then
			return "This key have already used"
		else
			keyid = row.id
		end
	else
		return "Wrong key"
	end
	
	local result = db.query(("SELECT `id` FROM `authme` WHERE `username` = '%s'"):format(username))
	if #result == 0 then
		db.query(("UPDATE `keys` SET `username` = '%s' WHERE `id` = %s"):format(username, keyid))
		db.query(("INSERT INTO `authme` (`username`, `realname`, `password`) VALUES ('%s', '%s', '%s')"):format(username, realname, password_crypt))
		
		return "Registration complete"
	else
		return "This username have already registered"
	end
end)

app:get("/", function(self)
	return {[[
	<!DOCTYPE HTML>
	<html lang="en">
		<head>
			<meta charset="UTF-8">
			<title>registration page</title>
		</head>
		<body>
			username: 3-16 symbols | [a-zA-Z0-9_]*
			<br>
			password: 5-30 symbols | [!-~]* (all visible ASCII)
			<br>
			key: a code which you need to create account
			<form action="/" method="post">
				<input required name="username" placeholder="username" type="text" size="64" maxlength="16">
				<br>
				<input required name="password" placeholder="password" type="password" size="64" maxlength="16">
				<br>
				<input required name="confirmpassword" placeholder="password confirmation" type="password" size="64" maxlength="16">
				<br>
				<input required name="key" placeholder="key" type="password" size="64" maxlength="64">
				<br>
				<input type="submit" name="submit" value="submit">
			</form>
		</body>
	</html>
	]]}
end)

return app