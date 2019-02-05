Zombies = { "zombie", "zombie", "zombie", "zombie" }
ConstructionYards = {}
PlayerDomes = {}
DomeCount = 0
DomeThreshold = 1
NewPlayerDomes = {}

RetailiateBlasphemy = function()
    powerproxy = Actor.Create("powerproxy.parabombs", false, { Owner = creeps })
	powerproxy.SendAirstrike(wpChurch.CenterPosition, false, Facing.West)
    powerproxy.Destroy()
end

LetDogsOut = function()
    dog1 = Actor.Create("dog", true, { Location = wpDogTrees.Location, Owner = creeps })
    dog1.Hunt()
    if not DogCabin.IsDead then
        dog2 = Actor.Create("dog", true, { Location = wpDogCabin.Location, Owner = creeps })
        dog2.Hunt()
    end
    if not DogHouse.IsDead then
        dog3 = Actor.Create("dog", true, { Location = wpDogHouse.Location, Owner = creeps })
        dog3.Hunt()
    end
end

InitiateZombieApocalipse = function()
    Utils.Do(Zombies, function(zombie)
        local z = Actor.Create(zombie, true, { Location = wpZombiesSpawn.Location, Owner = creeps })
        z.Move(wpZombies.Location)
        z.Hunt()
    end)
end

WakeUpAntInMine = function()
    local ant = Actor.Create("ant", true, { Location = wpMineAnt.Location, Owner = creeps })
    ant.Hunt()
end

SendSniper = function()
	local start = Map.CenterOfCell(CPos.New(31, 0)) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = creeps, Facing = (Map.CenterOfCell(wpSummit.Location) - start).Facing })

    local a = Actor.Create("sniper", false, { Owner = creeps })
    transport.LoadPassenger(a)
    
    Trigger.OnPassengerExited(transport, function(t, p)
        Trigger.OnIdle(p, p.Hunt)
    end)

	transport.Paradrop(wpSummit.Location)
    
    Trigger.OnKilled(a, function()
        Trigger.AfterDelay(DateTime.Seconds(5), function()
            SendSniper()
        end)
    end)
end

WorldLoaded = function()
    creeps = Player.GetPlayer("Creeps")
    players = Player.GetPlayers(function(player)
        return player.IsLocalPlayer or player.IsBot
    end)
    Utils.Do(players, function(player)
        PlayerDomes[player.InternalName] = 0
    end)

    Utils.Do(players, function(player)
        Media.Debug(player.Name)
    end)

    Media.Debug("Start to panic... please.")

    Trigger.AfterDelay(DateTime.Seconds(5), function()
        Media.Debug("Still panicing?")
    end)

    Trigger.OnKilled(Church, function()
        Media.Debug("Thou shall not destroy religion.")
        RetailiateBlasphemy()
    end)

    Trigger.OnKilled(OilPump, function()
        Media.Debug("Oil pump destroyed.")
        InitiateZombieApocalipse()
    end)

    Trigger.OnKilled(DogKeeper, function()
        Media.Debug("Dog keeper killed.")
        LetDogsOut()
    end)

    Trigger.OnKilled(MineBarrel, function()
    Media.Debug("Wakes up ant.")
        WakeUpAntInMine()
    end)

    Trigger.OnKilled(Refugee, function()
        SendSniper()
    end)
end

ticked = 0
Tick = function()
    -- ticked = ticked + 1
end
