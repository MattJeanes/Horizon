ENT.Type = "anim"ENT.Base = "hzn_production_ent" ENT.PrintName		= "Fusion Reactor"ENT.Author			= "Bynari"	-- item descriptionlocal desc = {}	desc[1] = "Fusion Reactor"	desc[2] = "----------------------"	desc[3] = "Fueled by hydrogen, this device generates large amounts of energy."	desc[4] = "Be sure to supply the reactor with coolant."	desc[5] = ""	desc[6] = "Consumes HYDROGEN & COOLANT, produces ENERGY"	desc[7] = ""	desc[8] = "Required resources:"	desc[9] = ""	desc[10] = "[100] Morphite"	desc[11] = "[100] Nocxium"	desc[12] = "[0] Isogen"-- production requirementslocal req = {}	req.Morphite = 100	req.Nocxium = 100	req.Isogen = 0-- factory entrylocal Entry = {}	Entry.DisplayName = ENT.PrintName	Entry.Description = desc	Entry.ClassName = "fusion_reactor"	Entry.BuildTime = 10	Entry.Costs = req	-- register entry with gamemodeGAMEMODE:RegisterFactoryEntry( Entry )