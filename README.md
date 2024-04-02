# fuzzy_wounds

<a href="https://crimson-studios.tebex.io/"><img src="https://i.imgur.com/eIvptzl.png" alt="Crimson Studios"/></a>
<a href="https://discord.gg/Kdycu4r5"><img src="https://skillicons.dev/icons?i=discord" alt="truefuzzy"/></a>

This scripts is a sophisticated pain management script designed for VORP framework on RedM. This script comprehensively tracks player injuries across various body parts, implementing a severity and bleeding system with four stages. Inspired by similar systems on FiveM, the script aims to enhance the immersive experience of roleplaying by adding realistic consequences to injuries sustained in the game.

# Features
- Detailed tracking of player injuries affecting different body parts.
- Disables the weapon wheel when shot in the right or left arm.
- Severity system with four stages to reflect the intensity of pain.
- Bleeding system to simulate the effects of wounds over time.
- Developed specifically for VORP framework on RedM.
- Easy installation process.

# Installation
- Download the fuzzy_wounds script.
- Extract the fuzzy_wounds folder into your RedM resources directory.
- Ensure fuzzy_wounds is listed in your server.cfg or resources.cfg file.
- Start or restart your RedM server.

# Usage
Once installed, the script automatically integrates into your RedM server.
Players will experience realistic pain and injury effects based on their interactions within the game world.
Server administrators can customize the severity and bleeding parameters to suit their preferred gameplay style.

### Get Player Injuries
```lua
exports['fuzzy_wounds']:GetCharsInjuries(source)
```

### Triggers to be used in items
```lua
-- SERVER SIDE EXAMPLE
TriggerClientEvent("fuzzy_wounds:FieldTreatLimbs", source) -- reduce severity to 1, can be used in medkit
TriggerClientEvent("fuzzy_wounds:ResetLimbs", source) -- reset all, can be used in medkit

TriggerClientEvent("fuzzy_wounds:UseMorphine", source, tier) -- prevents falling when shot in the leg. More tier, more timeout. Limit is 4
TriggerClientEvent("fuzzy_wounds:UseDrugs", source, tier) -- prevents screen effects, camera shake and fainting

TriggerClientEvent("fuzzy_wounds:ReduceBleed", source) -- reduces one level of bleeding with each use (you can use that o bandage item)
TriggerClientEvent("fuzzy_wounds:RemoveBleed", source) -- reduces level of bleeding to zero

-- CLIENT SIDE EXAMPLE
TriggerEvent("fuzzy_wounds:FieldTreatLimbs")
TriggerEvent("fuzzy_wounds:ResetLimbs")

TriggerEvent("fuzzy_wounds:UseMorphine", tier)
TriggerEvent("fuzzy_wounds:UseDrugs", tier)

TriggerEvent("fuzzy_wounds:ReduceBleed")
TriggerEvent("fuzzy_wounds:RemoveBleed")

```

# License
See the LICENSE file for details.
