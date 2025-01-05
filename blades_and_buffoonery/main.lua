--#region Linoria
local Linoria = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/refs/heads/main/Library.lua"))();
local Window = Linoria:CreateWindow({
    Title = "Blades & Buffoonery";
    Center = true;
    AutoShow = true;
});

do -- Combat
    local Combat = Window:AddTab("Combat");

    local HitAura, Negation =
        Combat:AddLeftGroupbox("Hit Aura"),
        Combat:AddRightGroupbox("Negation");

    HitAura:AddToggle("HitAuraEnabled", { Text = "Enabled"; Default = false; });
    HitAura:AddSlider("HitAuraRange", { Text = "Range"; Rounding = 1; Default = 15; Min = 1; Max = 30; });

    Negation:AddToggle("NegateImpulse", { Text = "Impulse"; Default = false; });
    Negation:AddToggle("NegateRagdoll", { Text = "Ragdoll"; Default = false; });
end;
--#endregion

local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;

local RunService = game:GetService("RunService");

local Game; do
    Game = { };

    function Game.GetCharacter()
        return LocalPlayer.Character;
    end;

    function Game.GetTool()
        local Character = Game.GetCharacter();

        if Character then
            return Character:FindFirstChildOfClass("Tool");
        end;

        return;
    end;

    function Game.FireHit(Humanoid)
        local Tool = Game.GetTool();

        if Tool and Tool:FindFirstChild("Events") then
            Tool.Events.Hit:FireServer(Humanoid);
        end;
    end;

    function Game.InRange(Character, OtherCharacter, Magnitude)
        if not Character.PrimaryPart or not OtherCharacter.PrimaryPart then
            return false;
        end;

        return (Character.PrimaryPart.Position - OtherCharacter.PrimaryPart.Position).Magnitude <= Magnitude;
    end;
end;

do
    local OldNamecall;
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local NamecallMethod = getnamecallmethod();

        if checkcaller() then
            return OldNamecall(self, ...);
        end;

        if NamecallMethod == "ChangeState" and Toggles.NegateRagdoll.Value then
            local State = ...;

            if State == Enum.HumanoidStateType.Physics then
                return;
            end;
        elseif NamecallMethod == "ApplyImpulse" and Toggles.NegateImpulse.Value then
            return;
        end;

        return OldNamecall(self, ...);
    end);
end;

RunService.Heartbeat:Connect(function()
    local Character = Game.GetCharacter();

    if not Character then
        return;
    end;

    if Toggles.HitAuraEnabled.Value then
        for _, Player in Players:GetPlayers() do
            if Player == LocalPlayer then
                continue;
            end;

            local OtherCharacter = Player.Character;
            local OtherHumanoid = OtherCharacter and OtherCharacter:FindFirstChildOfClass("Humanoid");

            if not OtherCharacter or not OtherHumanoid then
                continue;
            end;

            if Game.InRange(Character, OtherCharacter, Options.HitAuraRange.Value) then
                Game.FireHit(OtherHumanoid);
            end;
        end;
    end;
end);
