ENT.Type = "anim"ENT.Base = "hzn_production_ent" ENT.PrintName		= "Groundwater Extractor"ENT.Author			= "Bynari"-- item descriptionlocal desc = {}	desc[1] = "Extracts water from surfaces at a fixed rate (15 units per second)."	desc[2] = "Requires a constant amount of energy (60 units per second) and must remain on the ground in order to function."-- production requirementslocal req = {}	req["morphite"] = 100	req["nocxium"] = 100	req["isogen"] = 0-- factory entrylocal Entry = {}	Entry.DisplayName = ENT.PrintName	Entry.Description = desc	Entry.ClassName = "groundwater_extractor"	Entry.BuildTime = 10	Entry.Costs = req	-- register entry with gamemodeif GAMEMODE:GetGameDescription() == "Horizon" then	GAMEMODE:RegisterFactoryEntry( Entry )end