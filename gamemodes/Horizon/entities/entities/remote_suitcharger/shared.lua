ENT.Type = "anim"ENT.Base = "hzn_consumer_ent" ENT.PrintName		= "Remote Suitcharger"ENT.Author			= "Bynari"ENT.AutomaticFrameAdvance = true-- item descriptionlocal desc = {}	desc[1] = "Remote Suitcharger"	desc[2] = "----------------------"	desc[3] = "This device replenishes your suits"	desc[4] = "resources within a short range."	desc[5] = ""	desc[6] = "Consumes ENERGY, AIR & COOLANT"	desc[7] = "(depending on what is supplied)"	desc[8] = "Required resources:"	desc[9] = ""	desc[10] = "[100] Morphite"	desc[11] = "[100] Nocxium"	desc[12] = "[0] Isogen"-- production requirementslocal req = {}	req.Morphite = 100	req.Nocxium = 100	req.Isogen = 0-- factory entrylocal Entry = {}	Entry.DisplayName = ENT.PrintName	Entry.Description = desc	Entry.ClassName = "remote_suitcharger"	Entry.BuildTime = 10	Entry.Costs = req	-- register entry with gamemodeGAMEMODE:RegisterFactoryEntry( Entry )