local kong = kong
local lapis = require "lapis"

local _M = {}

function _M.execute(config)
    local app = lapis.Application()
    app:enable("etlua")

    function app:handle_404()
        self.message = config.message
        return { status = 200, render = "maintenance/down" }
    end

    lapis.serve(app)
end

return _M