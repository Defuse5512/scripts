local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;

local RunService = game:GetService("RunService");

local Game; do
    Game = { };
    Game.Magnitude = 15;

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

    function Game.InRange(Character, OtherCharacter)
        if not Character.PrimaryPart or not OtherCharacter.PrimaryPart then
            return false;
        end;

        return (Character.PrimaryPart.Position - OtherCharacter.PrimaryPart.Position).Magnitude <= Game.Magnitude;
    end;

    table.freeze(Game);
end;

do
    local OldNamecall;
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local NamecallMethod = getnamecallmethod();

        if checkcaller() then
            return OldNamecall(self, ...);
        end;

        if NamecallMethod == "ChangeState" then
            local State = ...;

            if State == Enum.HumanoidStateType.Physics then
                return;
            end;
        elseif NamecallMethod == "ApplyImpulse" then
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

    for _, Player in Players:GetPlayers() do
        if Player == LocalPlayer then
            continue;
        end;

        local OtherCharacter = Player.Character;
        local OtherHumanoid = OtherCharacter and OtherCharacter:FindFirstChildOfClass("Humanoid");

        if not OtherCharacter or not OtherHumanoid then
            continue;
        end;

        if Game.InRange(Character, OtherCharacter) then
            Game.FireHit(OtherHumanoid);
        end;
    end;
end);
