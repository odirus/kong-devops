local BasePlugin = require "kong.plugins.base_plugin"
local phaseAccess = require "kong.plugins.maintenance.phase.access"

local pluginName = "maintenance"
local MaintenanceHandler = BasePlugin:extend()

-- 定义优先级
MaintenanceHandler.PRIORITY = 100001

-- 初始化插件
function MaintenanceHandler:new()
    MaintenanceHandler.super.new(self, pluginName)
end

-- kong access phase
function MaintenanceHandler:access(config)
    MaintenanceHandler.super.access(self)
    phaseAccess.execute(config)
end

return MaintenanceHandler
