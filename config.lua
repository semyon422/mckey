local config = require("lapis.config")
config("development", {
	port = 8099,
	mysql = {
		host = "127.0.0.1",
		user = "username",
		password = "password",
		database = "minecraft"
	}
})
