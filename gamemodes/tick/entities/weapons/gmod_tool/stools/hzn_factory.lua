TOOL.Category = "Mining"
TOOL.Name = "Equipment Replicator"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Tab = "Horizon"
TOOL.ClientConVar[ "weldToTarget" ] = "0";

if ( CLIENT ) then
    language.Add( "Tool.hzn_factory.name", "Equipment Replicator" );
    language.Add( "Tool.hzn_factory.desc", "Used to craft advanced equipment" );
	language.Add( "Tool.hzn_factory.0", "Left Click to place replicator" );
end

local entityModel = "models/hzn_factory.mdl"

function TOOL:LeftClick( trace )
	if ( not trace.HitPos ) then return false end
	if ( trace.Entity:IsPlayer() ) then return false end
	if ( CLIENT ) then return true end
	if ( not util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	-- create ent
	local createdEntity = ents.Create( "hzn_factory" )
	-- adjust angles
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	createdEntity:SetAngles( Ang )
	-- adjust position
	local min = createdEntity:OBBMins()
	createdEntity:SetPos( trace.HitPos - trace.HitNormal * min.z )
	-- check if valid
	if not createdEntity:IsValid() then
		createdEntity:Remove()
		return false
	else
		createdEntity:Spawn()
	end
	-- weld to target
	local weldToTarget = self:GetClientNumber( "weldToTarget" ) == 1
	local const = nil
	if ( ( trace.Entity:IsValid() or trace.Entity:IsWorld() ) and weldToTarget ) then
		const = constraint.Weld( createdEntity, trace.Entity, trace.PhysicsBone, 0, 0 )
	end
	-- add undo information
	local ply = self:GetOwner()
	undo.Create( "hzn_factory" )
		undo.AddEntity( createdEntity )
		undo.AddEntity( const )
		undo.SetPlayer( ply )
		undo.SetCustomUndoText("Undone Equipment Replicator")
	undo.Finish()
	ply:AddCleanup( "equipment replicators", createdEntity )
	return true
end

function TOOL:UpdateGhost( ent, player )
	if ( not ent or not ent:IsValid() ) then return end
	local tr = util.GetPlayerTrace( player, player:GetAimVector() );
	local trace = util.TraceLine( tr );
	if ( not trace.Hit or trace.Entity:IsPlayer() or trace.Entity:GetClass() == "hzn_factory" ) then
		ent:SetNoDraw( true )
		return
	end
	-- adjust angle
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90 - self:GetClientNumber( "angleoffset" )
	ent:SetAngles( Ang )
	-- adjust position
	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	ent:SetNoDraw( false )
end

function TOOL.BuildCPanel( panel )
	panel:AddControl("CheckBox", {
	    Label = "Weld To Target",
	    Command = "hzn_factory_weldToTarget"
	})
end

function TOOL:Think()
	if ( not self.GhostEntity or not self.GhostEntity:IsValid() or self.GhostEntity:GetModel() ~= entityModel ) then
		self:MakeGhostEntity( entityModel, Vector( 0, 0, 0 ), Angle( 0, 0, 0) )
	end
	self:UpdateGhost( self.GhostEntity, self:GetOwner() )
end




