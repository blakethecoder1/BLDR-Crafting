# BLDR Crafting

**Version:** 1.0.0  
**Author:** blakethepet  
**Framework:** QBCore  
**Database:** oxmysql

## 📋 Description

`bldr_crafting` is a comprehensive crafting system that allows players to process raw materials into refined products. Features multiple crafting stations, blueprint unlocks, level requirements, and progression through the BLDR Core leveling system.

Perfect for servers wanting to add depth to their economy with item processing and crafting mechanics.

## ✨ Features

- **Multiple Crafting Stations** - Specialized stations across the map
- **Recipe System** - Extensive crafting recipes with requirements
- **Blueprint System** - Unlock advanced recipes through progression
- **Level Requirements** - Gate content behind player levels
- **Progress Bars** - Visual crafting progress with animations
- **XP & Money Rewards** - Earn XP and bonus money for crafting
- **Category System** - Organized recipes by type
- **Quality System** - Crafting difficulty affects success
- **Police Alerts** - Risk-reward for illegal crafting
- **Interactive UI** - Clean, modern crafting interface
- **qb-target Integration** - Smooth interaction system

## 🔨 Crafting Categories

### Cannabis Products (Green)
- Weed Bags
- Weed Joints
- Advanced cannabis items

### Coca Products (White)
- Cocaine Bags
- Refined cocaine products

### Opium Products (Brown)
- Heroin Syringes
- Processed heroin items

### General Crafting (Blue)
- Tools and electronics
- Miscellaneous items

## 📦 Dependencies

### Required
- **bldr_core** - Core progression and XP system ⚠️ **REQUIRED**
- **qb-core** - QBCore Framework
- **qb-target** - Interaction system
- **oxmysql** - Database connector

### Optional
- **qb-progressbar** or **ox_lib** - Progress bars during crafting
- **qb-inventory** - For item metadata support

## 💾 Installation

### 1. Install Dependencies

**IMPORTANT:** Install `bldr_core` first! This resource will not work without it.

```cfg
# In your server.cfg - ORDER MATTERS!
ensure bldr_core          # Install this FIRST
ensure qb-core
ensure qb-target
ensure oxmysql
ensure bldr_crafting      # Install after bldr_core
```

### 2. Database Setup

No additional database tables required - uses `bldr_core` database.

### 3. Add Items to Shared

Add these items to your `qb-core/shared/items.lua`:

```lua
-- Raw Materials
['weed'] = {
    ['name'] = 'weed',
    ['label'] = 'Weed',
    ['weight'] = 100,
    ['type'] = 'item',
    ['image'] = 'weed.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = 'Raw cannabis plant'
},
['cocaine'] = {
    ['name'] = 'cocaine',
    ['label'] = 'Cocaine',
    ['weight'] = 100,
    ['type'] = 'item',
    ['image'] = 'cocaine.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = 'Raw cocaine'
},
['heroin'] = {
    ['name'] = 'heroin',
    ['label'] = 'Heroin',
    ['weight'] = 100,
    ['type'] = 'item',
    ['image'] = 'heroin.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = 'Raw heroin'
},
['paper'] = {
    ['name'] = 'paper',
    ['label'] = 'Rolling Papers',
    ['weight'] = 10,
    ['type'] = 'item',
    ['image'] = 'rolling_paper.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'Papers for rolling'
},

-- Crafted Products
['weed_bag'] = {
    ['name'] = 'weed_bag',
    ['label'] = 'Bag of Weed',
    ['weight'] = 150,
    ['type'] = 'item',
    ['image'] = 'weed_bag.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = 'Packaged weed ready to sell'
},
['weed_joint'] = {
    ['name'] = 'weed_joint',
    ['label'] = 'Weed Joint',
    ['weight'] = 50,
    ['type'] = 'item',
    ['image'] = 'weed_joint.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = 'A rolled joint'
},
['cocaine_bag'] = {
    ['name'] = 'cocaine_bag',
    ['label'] = 'Bag of Cocaine',
    ['weight'] = 150,
    ['type'] = 'item',
    ['image'] = 'cocaine_bag.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = 'Packaged cocaine'
},
['heroin_syringe'] = {
    ['name'] = 'heroin_syringe',
    ['label'] = 'Heroin Syringe',
    ['weight'] = 100,
    ['type'] = 'item',
    ['image'] = 'heroin_syringe.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = 'Ready to inject'
},

-- Blueprints
['weed_joint_bp'] = {
    ['name'] = 'weed_joint_bp',
    ['label'] = 'Joint Rolling Blueprint',
    ['weight'] = 10,
    ['type'] = 'item',
    ['image'] = 'blueprint.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'Blueprint for rolling joints'
},
['cocaine_bag_bp'] = {
    ['name'] = 'cocaine_bag_bp',
    ['label'] = 'Cocaine Packaging Blueprint',
    ['weight'] = 10,
    ['type'] = 'item',
    ['image'] = 'blueprint.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'Blueprint for packaging cocaine'
},
['heroin_syringe_bp'] = {
    ['name'] = 'heroin_syringe_bp',
    ['label'] = 'Syringe Prep Blueprint',
    ['weight'] = 10,
    ['type'] = 'item',
    ['image'] = 'blueprint.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'Blueprint for preparing syringes'
},
```

## 🔧 Configuration

### Crafting Stations

```lua
Config.CraftingStations = {
    {
        coords = vector3(1038.3, -3205.68, -38.28),
        label = 'Weed Processing',
        category = 'weed',
        requiredLevel = 0,
        icon = 'fas fa-leaf'
    },
    {
        coords = vector3(1389.68, 3609.22, 38.89),
        label = 'Cocaine Processing',
        category = 'cocaine',
        requiredLevel = 2,
        icon = 'fas fa-prescription-bottle'
    },
    -- Add more stations...
}
```

### Recipe Configuration

```lua
Config.Recipes = {
    weed_bag = {
        label = 'Bag of Weed',
        description = 'Process loose weed into sellable bags',
        category = 'weed',
        inputs = { weed = 5 },            -- Requires 5 weed
        outputs = { weed_bag = 1 },       -- Produces 1 bag
        xp = 5,                           -- XP reward
        time = 5000,                      -- 5 seconds
        level = 0,                        -- Required level
        blueprint = nil,                  -- No blueprint needed
        difficulty = 'easy',              -- Difficulty level
        moneyReward = 50                  -- Bonus money
    },
    weed_joint = {
        label = 'Weed Joint',
        inputs = { weed = 2, paper = 1 },
        outputs = { weed_joint = 1 },
        xp = 3,
        time = 3000,
        level = 1,
        blueprint = 'weed_joint_bp',     -- Blueprint required
        difficulty = 'easy',
        moneyReward = 30
    },
    -- Add more recipes...
}
```

## 🎮 How to Use

### For Players

1. **Find a Crafting Station** - Locate stations around the map
2. **Check Requirements** - Ensure you have the required level
3. **Gather Materials** - Collect the input items needed
4. **Unlock Blueprints** - Obtain blueprints for advanced recipes
5. **Craft Items** - Interact with the station using qb-target
6. **Select Recipe** - Choose what you want to craft
7. **Wait for Completion** - Watch the progress bar
8. **Collect Rewards** - Receive items, XP, and money bonuses

### Blueprint Unlocks

Blueprints are automatically awarded when you reach certain levels:
- **Level 1** - Basic crafting recipes unlocked
- **Level 2** - Weed Joint Blueprint
- **Level 4** - Cocaine Bag Blueprint
- **Level 6** - Advanced recipes

## 📍 Default Station Locations

### Weed Processing (Level 0)
- **Underground Lab**
  - Coordinates: (1038.3, -3205.68, -38.28)
  - Process cannabis products
  - Low police alert risk

### Cocaine Processing (Level 2)
- **Sandy Shores Lab**
  - Coordinates: (1389.68, 3609.22, 38.89)
  - Process coca products
  - Medium police alert risk

### Heroin Processing (Level 4)
- **Mount Chiliad Lab**
  - Coordinates: (-1143.63, 4939.35, 222.33)
  - Process opium products
  - High police alert risk

### General Crafting (Level 0)
- **Downtown Workshop**
  - Coordinates: (713.5, -975.2, 30.4)
  - Craft tools and electronics
  - No police alerts

## 📜 Recipe List

### Weed Category

| Recipe | Inputs | Outputs | Level | Blueprint | Time | XP |
|--------|--------|---------|-------|-----------|------|-----|
| Weed Bag | 5x Weed | 1x Weed Bag | 0 | None | 5s | 5 |
| Weed Joint | 2x Weed, 1x Paper | 1x Joint | 1 | weed_joint_bp | 3s | 3 |

### Cocaine Category

| Recipe | Inputs | Outputs | Level | Blueprint | Time | XP |
|--------|--------|---------|-------|-----------|------|-----|
| Cocaine Bag | 5x Cocaine | 1x Cocaine Bag | 2 | cocaine_bag_bp | 7s | 8 |

### Heroin Category

| Recipe | Inputs | Outputs | Level | Blueprint | Time | XP |
|--------|--------|---------|-------|-----------|------|-----|
| Heroin Syringe | 3x Heroin | 1x Syringe | 4 | heroin_syringe_bp | 6s | 12 |

## 🚨 Police Alert System

Certain recipes trigger police alerts with configurable chances:

```lua
-- In server/main.lua
local policeChances = {
    weed_bag = 0.10,      -- 10% chance
    weed_joint = 0.20,    -- 20% chance
    cocaine_bag = 0.50    -- 50% chance
}
```

When triggered:
- Police receive notifications
- Location is marked (if dispatch integrated)
- Higher risk = higher rewards

## 🛠️ Admin Commands

### `/grantblueprint <player_id> <blueprint_name>`
Grant a specific blueprint to a player.

```
/grantblueprint 1 weed_joint_bp
```

### `/craftingdebug`
Toggle debug mode to see crafting information in console.

### `/resetcrafting <player_id>`
Reset a player's crafting data (admin only).

## 🔐 Permissions

Admin commands require permission through bldr_core:
- QBCore 'god' or 'admin' permission
- ACE permission: `bldr.admin`
- License whitelist in bldr_core config

## 💰 Money & XP System

### XP Rewards
- Automatically awarded via bldr_core
- Scale with recipe difficulty
- Level up unlocks new recipes

### Money Bonuses
- Base payment for crafted items
- Level bonuses from bldr_core
- Quality bonuses for difficult recipes

### Example Rewards

```lua
-- Crafting a Weed Bag (Level 0)
Base Money: $50
Level 0 Bonus: $0
Total: $50 + 5 XP

-- Crafting Cocaine Bag (Level 2)
Base Money: $100
Level 2 Bonus: $100
Total: $200 + 8 XP
```

## 💻 For Developers

### Server Events

```lua
-- Start crafting
TriggerServerEvent('bldr_crafting:startCraft', recipeId)

-- Cancel crafting
TriggerServerEvent('bldr_crafting:cancelCraft')

-- Grant blueprint
TriggerServerEvent('bldr_crafting:grantBlueprint', playerId, blueprintItem)
```

### Client Events

```lua
-- Open crafting UI
TriggerEvent('bldr_crafting:clientOpenStation', { stationId = 1 })

-- Update UI
TriggerEvent('bldr_crafting:updateUI', recipes, inventory)
```

### Callbacks

```lua
-- Get player level
QBCore.Functions.TriggerCallback('bldr_crafting:getPlayerLevel', function(level)
    print('Player level:', level)
end)

-- Get inventory
QBCore.Functions.TriggerCallback('bldr_crafting:getInventory', function(inventory)
    print('Inventory:', json.encode(inventory))
end)
```

## 🐛 Troubleshooting

### Can't Craft Items
- ✅ Verify bldr_core is installed and started
- ✅ Check you have required level
- ✅ Ensure you have all input materials
- ✅ Check if blueprint is required and owned

### No XP Gain
- ✅ Ensure bldr_core is running
- ✅ Check console for errors
- ✅ Verify XP values in config

### Station Not Appearing
- ✅ Verify qb-target is installed
- ✅ Check console for errors on resource start
- ✅ Confirm coordinates are correct

### UI Issues
- ✅ Check if ox_lib or qb-menu is installed
- ✅ Clear cache and restart client
- ✅ Verify HTML files are present

## 📊 Performance

- Optimized recipe lookups
- Cached core exports
- Efficient inventory checks
- Minimal client-server communication
- Progress state management

## 🔄 Integration with Other BLDR Scripts

### bldr_farming
Use farmed crops as crafting inputs:
- Harvest weed → Craft weed bags/joints
- Harvest coca → Craft cocaine products
- Harvest poppy → Craft heroin items

### bldr-drugs
Sell crafted items through the drug dealing system for maximum profit.

### bldr_core
- Shared XP and leveling system
- Automatic blueprint unlocks at level milestones
- Consistent money rewards with level bonuses

## 📝 License

Copyright (c) 2024-2025 Blakethepet, Negan, and BLDR CHAT

See LICENSE file for full terms. Personal use allowed, commercial use requires permission.

## 🤝 Support

For issues or questions:
1. Verify bldr_core is installed and running
2. Check server console for errors
3. Enable debug mode: `/craftingdebug`
4. Review recipe configurations

## 📈 Version History

### 1.0.0
- Initial release
- Multiple crafting stations
- Blueprint system
- Level-gated recipes
- XP and money rewards
- Police alert integration
- Category organization
