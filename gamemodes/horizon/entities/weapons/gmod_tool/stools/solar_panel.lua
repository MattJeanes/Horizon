TOOL.Category = "Generators"
TOOL.Name = "Solar Panel"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Tab = "Horizon"
TOOL.ClientConVar[ "weldToTarget" ] = "0";

if ( CLIENT ) then
    language.Add( "Tool.solar_panel.name", "Solar Panel" );
    language.Add( "Tool.solar_panel.desc", "Generates energy from light" );
	language.Add( "Tool.solar_panel.0", "Left Click to place panel" );
end

local entityModel = "models/solar_panel.mdl"


function TOOL:LeftClick( trace )

if ( not trace.HitPos ) then return false; end
	
	if ( trace.Entity:IsPlayer() ) then return false; end
	
	if ( SERVER and not util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false; end
	
	if ( CLIENT ) then return true; end

	local ply = self:GetOwner();
	local weldToTarget = self:GetClientNumber( "weldToTarget" ) == 1;
	local Ang = trace.HitNormal:Angle();
	Ang.pitch = Ang.pitch + 90
	
	
	local createdEntity = ents.Create( "solar_panel" )
		if ( not createdEntity:IsValid() ) then return false; end

		createdEntity:SetAngles( Ang );			
		createdEntity:Spawn();
		
	

	local min = createdEntity:OBBMins();
	createdEntity:SetPos( trace.HitPos - trace.HitNormal * min.z );
	
	if ( trace.Entity:IsValid() or trace.Entity:IsWorld() ) then
		if weldToTarget then
			local const = constraint.Weld( createdEntity, trace.Entity, trace.PhysicsBone, 0, 0 );
		end
	end

	undo.Create( "solar_panel" );
		undo.AddEntity( createdEntity );
		undo.AddEntity( const );
		undo.SetPlayer( ply );
		undo.SetCustomUndoText("Undone Solar Panel")
	undo.Finish();

	ply:AddCleanup( "solar panels", createdEntity );

	return true;
end

function TOOL:UpdateGhost( ent, player )
	if ( not ent or not ent:IsValid() ) then return; end

	local tr = util.GetPlayerTrace( player, player:GetAimVector() );
	local trace = util.TraceLine( tr );

	if ( not trace.Hit or trace.Entity:IsPlayer() or trace.Entity:GetClass() == "solar_panel" ) then
		ent:SetNoDraw( true );
		return;
	end

	local Ang = trace.HitNormal:Angle();
	Ang.pitch = Ang.pitch + 90 - self:GetClientNumber( "angleoffset" );

	local min = ent:OBBMins();
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z );
	ent:SetAngles( Ang );
		
	ent:SetNoDraw( false );
end

function TOOL.BuildCPanel( panel )
	 
	panel:AddControl("CheckBox", {
	    Label = "Weld To Target",
	    Command = "solar_panel_weldToTarget"
	})
		
end

function TOOL:Think()
	if ( not self.GhostEntity or not self.GhostEntity:IsValid() or self.GhostEntity:GetModel() ~= entityModel ) then
		self:MakeGhostEntity( entityModel, Vector( 0, 0, 0 ), Angle( 0, 0, 0) );
	end

	self:UpdateGhost( self.GhostEntity, self:GetOwner() );
end




