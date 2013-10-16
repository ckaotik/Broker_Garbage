local _, BGC = ...
Broker_Garbage_Config = BGC	-- allow external access


LibStub("tekKonfig-AboutPanel").new("Broker_Garbage", "Broker_Garbage")

if InterfaceOptionsFrame:IsVisible() then
	InterfaceOptionsFrame_OpenToCategory("Broker_Garbage")
end
