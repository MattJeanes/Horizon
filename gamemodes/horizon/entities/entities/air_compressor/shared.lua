ENT.Type = "anim"ENT.Base = "hzn_production_ent" ENT.PrintName		= "Air Compressor"ENT.Author			= "Bynari"ENT.AutomaticFrameAdvance = true -- item descriptionlocal desc = {}desc[1] = "Compresses air at a fixed rate (15 units per second)."desc[2] = "Requires a constant supply of energy to operate (20 units per second)."-- production requirementslocal req = {}	req["morphite"] = 0	req["nocxium"] = 0	req["isogen"] = 0	-- factory entrylocal Entry = {}	Entry.DisplayName = ENT.PrintName	Entry.Description = desc	Entry.ClassName = "air_compressor"	Entry.BuildTime = 10	Entry.Costs = req	-- register entry with gamemodeGAMEMODE:RegisterFactoryEntry( Entry )