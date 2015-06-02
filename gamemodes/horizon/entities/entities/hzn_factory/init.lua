AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

--sound effects!
util.PrecacheSound( "k_lab.teleport_malfunction_sound" )
util.PrecacheSound( "k_lab.teleport_discharge" )
util.PrecacheSound( "WeaponDissolve.Beam" )
util.PrecacheSound( "WeaponDissolve.Dissolve" )
--register models and materials
resource.AddFile( "models/hzn_factory.mdl" )
resource.AddFile( "materials/models/hzn_factory.vmt" )
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/hzn_factory.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	-- resource stuff
	self:RegisterConsumedResource( "energy", 50)
	-- crate spawning timer and id
	self.StartTime = 0
	self.CrateID = 0
	-- Build Factory inventory
	self.FactoryEntries = GAMEMODE:GetFactoryEntries()
	-- check physics
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end
	-- if invalid, remove
    self:Remove()
end

function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and caller:IsPlayer() and not caller:KeyDownLast(IN_USE) then
		if( not self.Create ) then
			umsg.Start( "hznFactoryTrigger", caller )
				umsg.String( self:GetCreationID() )
				umsg.Entity( self.Entity )
			umsg.End()
			self.Player = caller
		end
	end
end

function ENT:StartTouch( ent )
	if ent:GetClass() == "mineral_crate" then
		self.CrateID = ent:GetCreationID()
	end
end

function ENT:EndTouch(ent)
	if ent:GetClass() == "mineral_crate" then
		self.CrateID = 0
	end
end

function ENT:Dissolve(ent)
	local dissolver = ents.Create( "env_entity_dissolver" )
		dissolver:SetPos( ent:LocalToWorld( ent:OBBCenter() ) )
		dissolver:SetKeyValue( "dissolvetype", 0 )
		dissolver:Spawn()
	dissolver:Activate()
	local name = "Dissolving_" .. tostring( ent:EntIndex() ) 
	ent:SetName( name )
	dissolver:Fire( "Dissolve", name, 0 )
	self.Entity:EmitSound( "WeaponDissolve.Beam" )
	dissolver:Fire( "Kill", ent, 0.10 )
	self.Entity:EmitSound( "WeaponDissolve.Dissolve" )
	self.Entity:StopSound( "WeaponDissolve.Beam" )
end

function ENT:CheckResources( costs )
	-- check if factory is linked to a network
	if self.Link == nil then
		return false
	end
	-- check if the required resources are available
	for r, a in pairs( costs ) do
		local amount = self.Link:RetrieveResource( r, a )
		if amount < a then
			self.Link:StoreResource( r, a)
			return false
		end
		self.Link:StoreResource( r, amount )
	end
	return true
end

-- function ENT:CheckResources( costs )
	--check if factory is linked to a network
	-- if self.Link == nil then
		-- return false
	-- end
	--check if the required resources are available
	-- local Morphite = self.Link:RetrieveResource( "morphite", costs.Morphite )
	-- local Nocxium = self.Link:RetrieveResource( "nocxium", costs.Nocxium )
	-- local Isogen = self.Link:RetrieveResource( "isogen", costs.Isogen )
	-- if ( costs.Morphite <= Morphite and costs.Nocxium <= Nocxium and costs.Isogen <= Isogen ) then
		--consume resources
		-- return true
	-- end
	--put resources back
	-- self.Link:StoreResource( "morphite", Morphite)
	-- self.Link:StoreResource( "nocxium", Nocxium)
	-- self.Link:StoreResource( "isogen", Isogen)
	-- return false 	
-- end

function ENT:ConsumeRequirements( costs )
	for r, a in pairs( costs ) do
		self.Link:RetrieveResource( r, a )
	end
end

function ENT:BeginReplication( product )
	-- create the crate containing the product
	local ent = ents.Create( "factory_crate" )
		ent:SetPos( self:LocalToWorld(Vector(0,0,60)) )
		ent:SetMaterial( "models/props_combine/portalball001_sheet" )
		ent:Spawn()
		ent:SetProduct( product )
		ent:SetParent( self.Entity )
	-- emit crate assembly sound
	self.Entity:EmitSound( "k_lab.teleport_malfunction_sound" )		
	self.StartTime = CurTime()
	self.Active = true
	-- return the crate
	return ent
end

function ENT:CompleteCrate( ent )
	if ent == nil then return nil end
	ent:SetSolid( SOLID_VPHYSICS )
	ent:SetMaterial(self.Item.Material )
	ent:SetParent(nil)
	-- check physics
	local phys = ent:GetPhysicsObject()
	if ( not phys:IsValid() ) then
		ent:Remove()
		return nil
	end
	phys:EnableMotion(true)
	phys:Wake()
	-- emit crate assembly complete sound
	self.Entity:StopSound( "k_lab.teleport_malfunction_sound" )
	self.Entity:EmitSound( "k_lab.teleport_discharge" )
	self.Active = false
	-- return the finished crate
	return ent
end

function ENT:BuildItem( productName )
	local sufficient = false
	self.Item = nil
	local Entry = self.FactoryEntries[productName]
	if Entry == nil then
		return "Invalid Blueprint"
	end
	sufficient = self:CheckResources( Entry.Costs )
	if sufficient then
		self:ConsumeRequirements( Entry.Costs )
		self.Item = self:BeginReplication( Entry.ClassName )
		return "Replicating..." 
	else
		return "Insufficient Resources"
	end
end

function builditem( ply, cmd, args )
	for _, ent in pairs( ents.FindByClass( "hzn_factory" ) ) do
		if ent:GetCreationID() == tonumber( args[2] ) then
			--ent:BuildItem( args[1] )
			ply:PrintMessage( HUD_PRINTCENTER, ent:BuildItem( args[1] ) )
			return
		end
	end
end
concommand.Add( "builditem" , builditem)

function ENT:FillCrate()
	if self.CrateID == 0 then return end
	if self.Link == nil then return end
	for _, crate in pairs(ents.FindByClass("mineral_crate")) do
		if crate:GetCreationID() == self.CrateID then
			crate:AddResource( "morphite", self.Link:RetrieveResource( "morphite", crate.MaxStoredResources["morphite"] - crate.StoredResources["morphite"] ) )
			crate:AddResource( "nocxium", self.Link:RetrieveResource( "nocxium", crate.MaxStoredResources["nocxium"] - crate.StoredResources["nocxium"] ) )
			crate:AddResource( "isogen", self.Link:RetrieveResource( "isogen", crate.MaxStoredResources["isogen"] - crate.StoredResources["isogen"] ) )
			
			return
		end
	end
end

function fillcrate(ply, cmd, args)
	for _, ent in pairs(ents.FindByClass("hzn_factory")) do
		if ent:GetCreationID() == tonumber(args[1]) then
			ent:FillCrate()
			return
		end
	end
end
concommand.Add("fillcrate", fillcrate)

function ENT:CanOperate()
	return true
end

function ENT:Execute()
	if CurTime() >= ( self.StartTime + 10 ) then
		self:CompleteCrate( self.Item )
	end
end

function ENT:Failed()
	return
end