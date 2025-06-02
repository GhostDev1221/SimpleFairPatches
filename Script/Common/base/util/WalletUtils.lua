---
--- Created by Jimmy.
--- DateTime: 2017/12/12 0012 17:01
---

WalletUtils = {}

function WalletUtils:addCoinMappings(coinMapping)
    for i, v in pairs(coinMapping) do
        HostApi.addCoinMapping(v.coinId, v.itemId)
    end
end

return WalletUtils
