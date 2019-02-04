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

RadarDominance = function(player)
    Media.Debug("Rader domination by " .. player.Name)
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0  -- iterator variable
    local iter = function ()  -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
    end
    return iter
  end

CheckDomeDominance = function()
    -- determine new domeminee
    local maxCount = 0
    for player, count in pairsByKeys(NewPlayerDomes) do
        Media.Debug(player .. ': ' .. count)
    end
end

CheckDomeCount = function()
    Media.Debug("checking " .. DomeCount)
    local MaxCount = 0
    local MaxPlayer = nil
    Utils.Do(players, function(player)
        local actors = player.GetActorsByType("dome")
        local count = tablelength(actors)
        NewPlayerDomes[player.InternalName] = count
        if MaxCount < count then
            MaxCount = count
            MaxPlayer = player
        end
    end)

    CheckDomeDominance()

    if MaxCount > DomeCount then
        RadarDominance(MaxPlayer)
    end

    if MaxCount > 1 then DomeCount = MaxCount end
    Trigger.AfterDelay(DateTime.Seconds(3), CheckDomeCount)
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

    Trigger.AfterDelay(DateTime.Seconds(20), function()
        Media.Debug("Checking for Construction Yards...")
        ConstructionYards = Utils.Where(Map.ActorsInWorld, function(self)
            return self.Type == "dome"
        end)
        Utils.Do(ConstructionYards, function(actor)
            local player = actor.Owner
            Media.Debug(actor.Type .. " owned by " .. player.Name)
        end)
    end)

    Trigger.AfterDelay(DateTime.Seconds(6), CheckDomeCount)
end

ticked = 0
Tick = function()
    -- ticked = ticked + 1
end
