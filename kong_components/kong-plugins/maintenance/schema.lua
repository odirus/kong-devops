local typedefs = require "kong.db.schema.typedefs"

return {
    name = "maintenance",
    fields = {
        { protocols = typedefs.protocols_http },
        { config = {
            type = "record",
            fields = {
                { message = { type = "string", default = "系统维护中，请稍后再试" }, },
            },
        },
        },
    }
}