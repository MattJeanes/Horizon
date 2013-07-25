GM.Name		= "Horizon"
GM.Author	= "Bynari"
GM.Email	= ""
GM.Website  = ""

include("./player_class/player_horizon.lua")

DeriveGamemode( "sandbox" )

function GM:Initialize()

end

function commas(num)

  assert (type (num) == "number" or type (num) == "string")
  
  local result = ""
  local sign, before, after =
    string.match (tostring (num), "^([%+%-]?)(%d*)(%.?.*)$")

  while string.len (before) > 3 do
    result = "," .. string.sub (before, -3, -1) .. result
    before = string.sub (before, 1, -4)
  end

  return sign .. before .. result .. after

end

function ActiveB2S(bool)
	if bool then
		return "Running..."
	else
		return "Stopped"
	end
end


local ClassTable = ClassTable or {}

function GM:IsHznClass(name)
	return table.HasValue(ClassTable, name)
end

//Add class name to list of valid Horizon entitys.
//We do this for it to be an easy check on spawning entitys that do not have IsHZN set yet.
function GM:AddClassName(name)
	if GM:IsHznClass(name) then return end
	table.insert(ClassTable, name)
end


GM:AddClassName('air_compressor')
GM:AddClassName('air_tank')
GM:AddClassName('coolant_compressor')
GM:AddClassName('coolant_tank')
GM:AddClassName('energy_cell')
GM:AddClassName('factory_crate')
GM:AddClassName('fusion_reactor')
GM:AddClassName('gravity_generator')
GM:AddClassName('goundwater_extractor')
GM:AddClassName('horizon_base_ent')
GM:AddClassName('hydrogen_coolant')
GM:AddClassName('hydrogen_tank')
GM:AddClassName('hzn_brush_environment')
GM:AddClassName('hzn_environment')
GM:AddClassName('hzn_factory')
GM:AddClassName('lg_asteroid')
GM:AddClassName('link_hub')
GM:AddClassName('med_asteroid')
GM:AddClassName('mineral_crate')
GM:AddClassName('mining_drill')
GM:AddClassName('mining_laer')
GM:AddClassName('morphite_ore')
GM:AddClassName('nocxium_ore')
GM:AddClassName('ore_silo')
GM:AddClassName('remote_suitcharger')
GM:AddClassName('sm_asteroid')
GM:AddClassName('solar_panel')
GM:AddClassName('suit_recharger')
GM:AddClassName('water_pump')
GM:AddClassName('water_splitter')
GM:AddClassName('water_tank')
