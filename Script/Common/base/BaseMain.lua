---
--- Created by Jimmy.
--- DateTime: 2018/10/9 0009 15:02
---
require "base.util.EngineUtil"
require "base.listener.HttpListener"
require "base.listener.BaseListener"
require "base.define.BlockID"
require "base.define.ItemID"
require "base.define.PotionID"
require "base.define.PotionItemID"
require "base.define.ScoreID"
require "base.ReportManager"
require "base.RewardManager"

HttpListener:init()
BaseListener:init()

BaseMain = {}
BaseMain.GameType = "g1001"

function BaseMain:setGameType(GameType)
    self.GameType = GameType
    ReportManager:setGameType(self.GameType)
    RewardManager:setGameType(self.GameType)
    HostApi.setServerGameType(GameType)
end

function BaseMain:getGameType()
    return self.GameType
end

return BaseMain