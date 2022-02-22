local schema = require("lapis.db.schema")

local db = {}

local options = {
	engine = "InnoDB",
	charset = "utf8mb4 COLLATE=utf8mb4_unicode_ci"
}

local user_keys = {
	{"id", schema.types.id},
	{"key", "varchar(255) NOT NULL"},
	"UNIQUE KEY `key` (`key`)",
}

function db.drop()
	schema.drop_table("user_keys")
end

function db.create()
	schema.create_table("user_keys", user_keys, options)
end

return db
