Zombies = { "zombie", "zombie", "zombie", "zombie" }
SniperTimings = { 60, 120, 180 }
SniperKillCount = {}

RetailiateBlasphemy = function()
    powerproxy = Actor.Create("powerproxy.parabombs", false, { Owner = creeps })
    powerproxy.SendAirstrike(wpChurch.CenterPosition, false, Facing.West)
    powerproxy.Destroy()
end

LetDogsOut = function()
    dog1 = Actor.Create("dog", true, { Location = wpDogTrees.Location, Owner = creeps })
    dog1.Stance = "AttackAnything"
    dog1.Hunt()
    if not DogCabin.IsDead then
        dog2 = Actor.Create("dog", true, { Location = wpDogCabin.Location, Owner = creeps })
        dog2.Stance = "AttackAnything"
        dog2.Hunt()
    end
    if not DogHouse.IsDead then
        dog3 = Actor.Create("dog", true, { Location = wpDogHouse.Location, Owner = creeps })
        dog3.Stance = "AttackAnything"
        dog3.Hunt()
    end
end

InitiateZombieApocalipse = function()
    Utils.Do(Zombies, function(zombie)
        local z = Actor.Create(zombie, true, { Location = wpZombiesSpawn.Location, Owner = creeps })
        z.Move(wpZombies.Location)
        z.Stance = "AttackAnything"
        z.Hunt()
    end)
end

WakeUpAntInMine = function()
    local ant = Actor.Create("ant", true, { Location = wpMineAnt.Location, Owner = creeps })
    ant.Stance = "AttackAnything"
    ant.Hunt()
end

SendSniper = function()
    local start = Map.CenterOfCell(CPos.New(31, 0)) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
    local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = creeps, Facing = (Map.CenterOfCell(wpSummit.Location) - start).Facing })

    local sniper = Actor.Create("sniper", false, { Owner = creeps })
    sniper.Stance = "AttackAnything"
    transport.LoadPassenger(sniper)

    transport.Paradrop(wpSummit.Location)

    Trigger.OnKilled(sniper, function(self, killer)
        local killCount = SniperKillCount[killer.Owner.Name]
        if killCount == nil then
            SniperKillCount[killer.Owner.Name] = 1
        elseif killCount > 4 then
            SniperKillCount[killer.Owner.Name] = 3
            GiftSniper(killer.Owner)
        else
            SniperKillCount[killer.Owner.Name] = killCount + 1
        end

        Trigger.AfterDelay(DateTime.Seconds(Utils.Random(SniperTimings)), function()
            SendSniper()
        end)
    end)
end

GiftSniper = function(owner)
    local start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
    local barr = owner.GetActorsByType("barr")[1]
    local tent = owner.GetActorsByType("tent")[1]
    local target = nil
    if barr then
        target = barr
    elseif tent then
        target = tent
    end

    if target then
        local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = owner, Facing = (Map.CenterOfCell(target.Location) - start).Facing })
        local sniper = Actor.Create("sniper", false, { Owner = owner })
        transport.LoadPassenger(sniper)
        transport.Paradrop(target.Location)
    end
end

WorldLoaded = function()
    creeps = Player.GetPlayer("Creeps")
    players = Player.GetPlayers(function(player)
        return player.IsNonCombatant or player.IsBot
    end)

    Trigger.OnKilled(Church, function()
        RetailiateBlasphemy()
    end)

    Trigger.OnKilled(OilPump, function()
        Trigger.AfterDelay(DateTime.Seconds(2), InitiateZombieApocalipse)
    end)

    Trigger.OnKilled(DogKeeper, function()
        LetDogsOut()
    end)

    Trigger.OnKilled(MineBarrel, function()
        Trigger.AfterDelay(DateTime.Seconds(1), WakeUpAntInMine)
    end)

    Trigger.OnKilled(Refugee, function()
        SendSniper()
    end)
end
