ENT.Type = "anim"ENT.Base = "hzn_production_ent" ENT.PrintName		= "Water Splitter"ENT.Author			= "Bynari"ENT.AutomaticFrameAdvance = true 	-- item descriptionlocal desc = {}	desc[1] = "Splits water into oxygen and hydrogen at a rate of (30 units per second)."-- production requirementslocal req = {}	req["morphite"] = 100	req["nocxium"] = 100	req["isogen"] = 0-- factory entrylocal Entry = {}	Entry.DisplayName = ENT.PrintName	Entry.Description = desc	Entry.ClassName = "water_splitter"	Entry.BuildTime = 10	Entry.Costs = req	-- register entry with gamemodeif GAMEMODE:GetGameDescription() == "Horizon" then	GAMEMODE:RegisterFactoryEntry( Entry )end