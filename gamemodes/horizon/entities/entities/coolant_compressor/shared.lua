ENT.Type = "anim"ENT.Base = "hzn_production_ent" ENT.PrintName		= "Coolant Compressor"ENT.Author			= "Bynari"ENT.AutomaticFrameAdvance = true-- item descriptionlocal desc = {}desc[1] = "Compresses coolant at a fixed rate (15 units per second)."desc[2] = "Requires a constant supply of energy to operate (60 units per second)."		self:RegisterConsumedResource( "energy", 60)	self:RegisterProducedResource( "coolant", 15)-- production requirementslocal req = {}	req["morphite"] = 0	req["nocxium"] = 0	req["isogen"] = 0	-- factory entrylocal Entry = {}	Entry.DisplayName = ENT.PrintName	Entry.Description = desc	Entry.ClassName = "coolant_compressor"	Entry.BuildTime = 10	Entry.Costs = req	-- register entry with gamemodeGAMEMODE:RegisterFactoryEntry( Entry )