AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

function ENT:OnRemove()
end

function ENT:PreEntityCopy()
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
end

function ENT:LinkDupes(entA, entB)
end

function ENT:Think()
	-- update status baloon, and discard excess resources
	self:netUpdate()
end

function ENT:netUpdate()
	net.Start( "netEntityInfo" )
		net.WriteEntity( self )
		net.WriteTable( {} )
	net.Broadcast()
end