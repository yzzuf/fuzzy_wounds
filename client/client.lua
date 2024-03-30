local isBleeding = 0
local advanceBleedTimer = 0
local blackoutTimer = 0

local onMorphine = 0
local wasOnMorphine = false

local onDrugs = 0
local wasOnDrugs = false

local legCount = 0
local armcount = 0
local headCount = 0

local playerHealth = nil
local playerArmour = nil

local screenEffects = false

local MovementRate = {
    0.98,
    0.96,
    0.94,
    0.92,
}

local injured = {}

function IsInjuryCausingLimp()
    for k, v in pairs(Config.BodyParts) do
        if v.causeLimp and v.isDamaged then
            return true
        end
    end

    return false
end

function IsInjuredOrBleeding()
    if isBleeding > 0 then
        return true
    else
        for k, v in pairs(Config.BodyParts) do
            if v.isDamaged then
                return true
            end
        end
    end

    return false
end

function GetDamagingWeapon(ped)
    for k, v in pairs(Config.weapons) do
        if HasPedGotWeapon(ped, k, false) then
            ClearEntityLastDamageEntity(ped)
            return v
        end
    end

    return nil
end

function ProcessRunStuff(ped)
    screenEffect(ped)

    if IsInjuryCausingLimp() and not (onMorphine > 0)  then

        local level = 0
        for k, v in pairs(injured) do
            if v.severity > level then
                level = v.severity
            end
        end

        SetPedMoveRateOverride(ped, MovementRate[level])

        if wasOnMorphine then
            SetPedToRagdoll(PlayerPedId(), 1500, 2000, 3, true, true, false)
            wasOnMorphine = false

            TriggerEvent('vorp:Tip', Config.Language.notGood, 4000)
        end
    else

        SetPedMoveRateOverride(ped, 1.0)

        if not wasOnMorphine and (onMorphine > 0) then 
            wasOnMorphine = true 
        end

        if onMorphine > 0 then
            onMorphine = onMorphine - 1
        end
    end
end

Citizen.CreateThread(function()
    while true do
        for k, v in pairs(injured) do
            if (v.part == 'RARM' and v.severity >= 1) or (v.part == 'LARM' and v.severity >= 1) then
                -- disable weapon wheel if right arm or left arm injuried
            end
        end
        Citizen.Wait(0)
    end
end)

function ProcessDamage(ped)
    if not IsEntityDead(ped) or not (onDrugs > 0) then
        for k, v in pairs(injured) do
            if (v.part == 'LLEG' and v.severity >= 1) or (v.part == 'RLEG' and v.severity >= 1) or (v.part == 'LFOOT' and v.severity >= 2) or (v.part == 'RFOOT' and v.severity >= 2) then
                if legCount >= 15 then
                    if not IsPedRagdoll(ped) and IsPedOnFoot(ped) then
                        local chance = math.random(100)
                        if (IsPedRunning(ped) or IsPedSprinting(ped)) then
                            if chance <= 50 then
                                TriggerEvent('vorp:Tip', Config.Language.difficultyToRun, 4000)
                                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) 
                                SetPedToRagdollWithFall(PlayerPedId(), 1500, 2000, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                            end
                        else
                            if chance <= 15 then
                                TriggerEvent('vorp:Tip', Config.Language.difficultyToWalk, 4000)
                                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) 
                                SetPedToRagdollWithFall(PlayerPedId(), 1500, 2000, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                            end
                        end
                    end
                    legCount = 0
                else
                    legCount = legCount + 1
                end
            elseif (v.part == 'LARM' and v.severity >= 1) or (v.part == 'LHAND' and v.severity >= 1) or (v.part == 'LFINGER' and v.severity >= 2) or (v.part == 'RARM' and v.severity >= 1) or (v.part == 'RHAND' and v.severity >= 1) or (v.part == 'RFINGER' and v.severity >= 2) then
                if armcount >= 30 then
                    local chance = math.random(100)

                    armcount = 0
                else
                    armcount = armcount + 1
                end
            elseif (v.part == 'HEAD' and v.severity >= 2) then
                if headCount >= 30 then
                    local chance = math.random(100)

                    if chance <= 15 then
                        TriggerEvent("vorp:Tip", Config.Language.fainted, 4000)
                        
                        DoScreenFadeOut(100)
                        while not IsScreenFadedOut() do
                            Citizen.Wait(0)
                        end

                        if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) 
                            SetPedToRagdoll(ped, 5000, 1, 2)
                        end

                        Citizen.Wait(5000)
                        DoScreenFadeIn(250)
                    end
                    headCount = 0
                else
                    headCount = headCount + 1
                end
            end
        end

        if wasOnDrugs then
            SetPedToRagdoll(PlayerPedId(), 1500, 2000, 3, true, true, false)
            wasOnDrugs = false

            TriggerEvent('vorp:Tip', Config.Language.notGood, 4000)
        end
    else
        onDrugs = onDrugs - 1

        if not wasOnDrugs then
            wasOnDrugs = true
        end
    end
end

function CheckDamage(ped, bone, weapon)
    if weapon == nil then return end

    if Config.parts[bone] ~= nil then
        if not Config.BodyParts[Config.parts[bone]].isDamaged then
            Config.BodyParts[Config.parts[bone]].isDamaged = true
            Config.BodyParts[Config.parts[bone]].severity = 1

            TriggerEvent("vorp:Tip", Config.Language.youAreWith.." "..Config.WoundStates[Config.BodyParts[Config.parts[bone]].severity].." "..Config.BodyParts[Config.parts[bone]].label, 4000)

            if weapon == Config.WeaponClasses['SMALL_CALIBER'] or weapon == Config.WeaponClasses['MEDIUM_CALIBER'] or weapon == Config.WeaponClasses['CUTTING'] or weapon == Config.WeaponClasses['WILDLIFE'] or weapon == Config.WeaponClasses['OTHER'] or weapon == Config.WeaponClasses['LIGHT_IMPACT'] then
                if isBleeding < 4 then
                    isBleeding = tonumber(isBleeding) + 1
                end
            elseif weapon == Config.WeaponClasses['HIGH_CALIBER'] or weapon == Config.WeaponClasses['HEAVY_IMPACT'] or weapon == Config.WeaponClasses['SHOTGUN'] or weapon == Config.WeaponClasses['EXPLOSIVE'] then
                if isBleeding < 3 then
                    isBleeding = tonumber(isBleeding) + 2
                elseif isBleeding < 4 then
                    isBleeding = tonumber(isBleeding) + 1
                end
            end

            table.insert(injured, {
                part = Config.parts[bone],
                label = Config.BodyParts[Config.parts[bone]].label,
                severity = Config.BodyParts[Config.parts[bone]].severity
            })

            TriggerServerEvent('fuzzy_wounds:SyncWounds', {
                limbs = Config.BodyParts,
                isBleeding = tonumber(isBleeding)
            })
        else
            if weapon == Config.WeaponClasses['SMALL_CALIBER'] or weapon == Config.WeaponClasses['MEDIUM_CALIBER'] or weapon == Config.WeaponClasses['CUTTING'] or weapon == Config.WeaponClasses['WILDLIFE'] or weapon == Config.WeaponClasses['OTHER'] or weapon == Config.WeaponClasses['LIGHT_IMPACT'] then
                if isBleeding < 4 then
                    isBleeding = tonumber(isBleeding) + 1
                end
            elseif weapon == Config.WeaponClasses['HIGH_CALIBER'] or weapon == Config.WeaponClasses['HEAVY_IMPACT'] or weapon == Config.WeaponClasses['SHOTGUN'] or weapon == Config.WeaponClasses['EXPLOSIVE'] then
                if isBleeding < 3 then
                    isBleeding = tonumber(isBleeding) + 2
                elseif isBleeding < 4 then
                    isBleeding = tonumber(isBleeding) + 1
                end
            end

            if Config.BodyParts[Config.parts[bone]].severity < 4 then
                Config.BodyParts[Config.parts[bone]].severity = Config.BodyParts[Config.parts[bone]].severity + 1
                TriggerServerEvent('fuzzy_wounds:SyncWounds', {
                    limbs = Config.BodyParts,
                    isBleeding = tonumber(isBleeding)
                })

                for k, v in pairs(injured) do
                    if v.parts == Config.parts[bone] then
                        v.severity = Config.BodyParts[Config.parts[bone]].severity
                    end
                end
            else

            end
        end
    end
end

RegisterNetEvent('fuzzy_wounds:SyncBleed')
AddEventHandler('fuzzy_wounds:SyncBleed', function(bleedStatus)
    isBleeding = tonumber(bleedStatus)
end)

RegisterNetEvent('fuzzy_wounds:FieldTreatLimbs')
AddEventHandler('fuzzy_wounds:FieldTreatLimbs', function()
    for k, v in pairs(Config.BodyParts) do
        v.isDamaged = false
        v.severity = 1
    end

    for k, v in pairs(injured) do
        if v.parts == Config.parts[bone] then
            v.severity = Config.BodyParts[Config.parts[bone]].severity
        end
    end
end)

RegisterNetEvent('fuzzy_wounds:ResetLimbs')
AddEventHandler('fuzzy_wounds:ResetLimbs', function()
    for k, v in pairs(Config.BodyParts) do
        v.isDamaged = false
        v.severity = 0
    end

    injured = {}
end)

RegisterNetEvent('fuzzy_wounds:ReduceBleed')
AddEventHandler('fuzzy_wounds:ReduceBleed', function()
    if isBleeding > 0 then -- use on bandage item to reduce bleeding state
        isBleeding = tonumber(isBleeding) - 1
    end
end)

RegisterNetEvent('fuzzy_wounds:RemoveBleed')
AddEventHandler('fuzzy_wounds:RemoveBleed', function()
    isBleeding = 0
end)

RegisterNetEvent('fuzzy_wounds:UseMorphine')
AddEventHandler('fuzzy_wounds:UseMorphine', function(tier)
    if tier < 4 then
        onMorphine = 90 * tier
    end

    TriggerEvent("vorp:Tip", Config.Language.temporaryWound, 4000)
end)


function screenEffect(ped)
    if Config.UseScreenEffects then
        if not IsPedDeadOrDying(ped) and isBleeding >= 3 then
            screenEffects = true
        else
            if screenEffects then
                AnimpostfxStop("PlayerHealthPoor")
                screenEffects = false
            end
        end
    end
end

RegisterNetEvent('fuzzy_wounds:UseDrugs')
AddEventHandler('fuzzy_wounds:UseDrugs', function(tier)
    if tier < 4 then -- more tier, more timeout.
        onDrugs = 180 * tier
    end

    TriggerEvent("vorp:TipRight", Config.bodyFailIgnore, 4000)
end)  
    
Citizen.CreateThread(function()
    local player = PlayerPedId()

	while true do

		if not IsEntityDead(player) and not (#injured == 0) then
			if #injured > 0 then
				local str = ''

				if #injured > 1 and #injured < 3 then
					for k, v in pairs(injured) do
						str = Config.Language.youAreWith.." "..Config.WoundStates[v.severity].." "..v.label
						if k < #injured then
							str = str .. ' | '
						end
					end
				elseif #injured > 2 then
					str = Config.Language.multipleWounds
				else
					str = Config.Language.youAreWith.." "..Config.WoundStates[injured[1].severity].." "..injured[1].label
				end

                TriggerEvent('vorp:Tip', str, 4000)

			end

			if isBleeding > 0 then
				if blackoutTimer >= 10 then
                    TriggerEvent("vorp:Tip", Config.Language.suddenlyFaited, 4000)
	
					DoScreenFadeOut(500)
					while not IsScreenFadedOut() do
						Citizen.Wait(0)
					end
			
					if not IsPedRagdoll(player) and IsPedOnFoot(player) and not IsPedSwimming(player) then
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) 
						SetPedToRagdollWithFall(PlayerPedId(), 10000, 12000, 1, GetEntityForwardVector(player), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
					end
			
					Citizen.Wait(5000)
					DoScreenFadeIn(500)
					blackoutTimer = 0
				end
			
                TriggerEvent("vorp:Tip", Config.Language.youAreWith.." ".. Config.BleedingStates[isBleeding], 4000)

                local bleedDamage = tonumber(isBleeding) * 4
                ApplyDamageToPed(player, bleedDamage, false)
                playerHealth = playerHealth - bleedDamage
				blackoutTimer = blackoutTimer + 1
				advanceBleedTimer = advanceBleedTimer + 1
			
				if advanceBleedTimer >= 10 then
					if isBleeding < 4 then
						isBleeding = tonumber(isBleeding) + 1
					end
					advanceBleedTimer = 0
				end
			end
		end

		Citizen.Wait(30000)
	end
end)

Citizen.CreateThread(function()
    local player = PlayerPedId()
    while true do
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)

        if not playerHealth then
            playerHealth = health
        end

        if player ~= ped then
            player = ped
            playerHealth = health
        end

        local healthDamaged = (playerHealth ~= health and health < playerHealth) -- Players health was damaged
        
        if healthDamaged then
            local hit, bone = GetPedLastDamageBone(player)
            local bodypart = Config.parts[bone]

            if hit and bodypart ~= 'NONE' then
                local checkDamage = true
                local weapon = GetDamagingWeapon(player)
                if weapon ~= nil then
                    if weapon ~= Config.WeaponClasses['LIGHT_IMPACT'] then
                        AnimpostfxPlay("PlayerHealthCrackpot")
                    end
                    
                    if Config.UseScreenEffects then
                        if isBleeding >= 3 and not screenEffects then
                            screenEffects = true
                            AnimpostfxPlay("PlayerHealthPoor")
                        end
                    end

                    if (bodypart == 'SPINE' or bodypart == 'LOWER_BODY') and weapon <= Config.WeaponClasses['LIGHT_IMPACT'] and weapon ~= Config.WeaponClasses['NOTHING'] then
                        checkDamage = false
                    end

                    if checkDamage then
                        CheckDamage(player, bone, weapon)
                    end
                end
            end
        end

        playerHealth = health

        Citizen.Wait(321)

		ProcessRunStuff(player)
		Citizen.Wait(321)

		ProcessDamage(player)
		Citizen.Wait(321)
	end
end)