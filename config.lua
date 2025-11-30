-- Configuration for bldr_crafting
-- Define crafting stations and recipes here.  Crafting stations are
-- locations in the world where players can interact to craft items.
-- Recipes define the inputs, outputs, XP reward and crafting time.

Config = {}

-- Crafting stations: define where players can craft.  Each entry
-- includes coordinates and a label for the interaction menu.
Config.CraftingStations = {
    -- Weed processing station
    {
        coords = vector3(1038.3, -3205.68, -38.28),
        label  = 'Weed Processing',
        category = 'weed',
        requiredLevel = 0,
        icon = 'fas fa-leaf'
    },
    -- Cocaine processing station
    {
        coords = vector3(1389.68, 3609.22, 38.89),
        label  = 'Cocaine Processing',
        category = 'cocaine',
        requiredLevel = 2,
        icon = 'fas fa-prescription-bottle'
    },
    -- Heroin processing station
    {
        coords = vector3(-1143.63, 4939.35, 222.33),
        label  = 'Heroin Processing',
        category = 'heroin',
        requiredLevel = 4,
        icon = 'fas fa-syringe'
    },
    -- General crafting bench (new addition)
    {
        coords = vector3(713.5, -975.2, 30.4),
        label = 'General Crafting Bench',
        category = 'general',
        requiredLevel = 0,
        icon = 'fas fa-tools'
    }
}

-- Crafting categories for better organization
Config.Categories = {
    weed = { label = 'Cannabis Products', color = 'green' },
    cocaine = { label = 'Coca Products', color = 'white' },
    heroin = { label = 'Opium Products', color = 'brown' },
    general = { label = 'General Crafting & Electronics', color = 'blue' }
}

-- Recipes: specify what players need to craft items.  The keys are
-- recipe identifiers used internally; the values contain a human
-- readable label, a table of input items and amounts, a table of
-- output items and amounts, the XP reward and the craft time in
-- milliseconds.
Config.Recipes = {
    weed_bag = {
        label     = 'Bag of Weed',
        description = 'Process loose weed into sellable bags',
        category  = 'weed',
        inputs    = { weed = 5 },
        outputs   = { weed_bag = 1 },
        xp        = 5,
        time      = 5000,
        level     = 0,
        blueprint = nil, -- no blueprint required
        difficulty = 'easy',
        moneyReward = 50
    },
    weed_joint = {
        label     = 'Weed Joint',
        description = 'Roll weed into smokable joints',
        category  = 'weed',
        inputs    = { weed = 2, paper = 1 },
        outputs   = { weed_joint = 1 },
        xp        = 3,
        time      = 3000,
        level     = 1,
        blueprint = 'weed_joint_bp', -- blueprint item required
        difficulty = 'easy',
        moneyReward = 30
    },
    cocaine_bag = {
        label     = 'Bag of Cocaine',
        description = 'Package cocaine for distribution',
        category  = 'cocaine',
        inputs    = { cocaine = 5 },
        outputs   = { cocaine_bag = 1 },
        xp        = 8,
        time      = 7000,
        level     = 2,
        blueprint = 'cocaine_bag_bp', -- blueprint required
        difficulty = 'medium',
        moneyReward = 100
    },
    heroin_syringe = {
        label     = 'Heroin Syringe',
        description = 'Prepare heroin for injection',
        category  = 'heroin',
        inputs    = { heroin = 3, syringe = 1 },
        outputs   = { heroin_syringe = 1 },
        xp        = 12,
        time      = 8000,
        level     = 4,
        blueprint = 'heroin_syringe_bp',
        difficulty = 'hard',
        moneyReward = 150
    },
    -- General crafting recipes
    lockpick = {
        label     = 'Lockpick',
        description = 'Craft a basic lockpick tool',
        category  = 'general',
        inputs    = { metalscrap = 2, plastic = 1 },
        outputs   = { lockpick = 1 },
        xp        = 2,
        time      = 4000,
        level     = 0,
        blueprint = nil,
        difficulty = 'easy',
        moneyReward = 25
    },
    -- 🔧 ADVANCED ELECTRONICS
    copper_wire = {
        label = 'Copper Wire',
        description = 'High-quality copper wire for electronics',
        category = 'general',
        inputs = { copper = 3, rubber = 1 },
        outputs = { copper_wire = 5 },
        xp = 5,
        time = 6000,
        level = 2,
        blueprint = nil,
        difficulty = 'easy',
        moneyReward = 40,
        toolRequired = 'basic_hammer',
        toolDurabilityLoss = 1
    },
    circuit_board = {
        label = 'Circuit Board',
        description = 'Advanced electronic circuit board',
        category = 'general',
        inputs = { copper_wire = 3, silicon = 2, plastic = 2 },
        outputs = { circuit_board = 1 },
        xp = 15,
        time = 12000,
        level = 5,
        blueprint = 'circuit_board_bp',
        difficulty = 'medium',
        moneyReward = 120,
        toolRequired = 'precision_cutter',
        toolDurabilityLoss = 2,
        stationUpgrade = 'quality_level1'
    },
    advanced_gadget = {
        label = 'Advanced Electronic Gadget',
        description = 'Cutting-edge electronic device',
        category = 'general',
        inputs = { circuit_board = 2, battery = 1, metalscrap = 3 },
        outputs = { advanced_gadget = 1 },
        xp = 35,
        time = 20000,
        level = 10,
        blueprint = 'advanced_gadget_bp',
        difficulty = 'hard',
        moneyReward = 300,
        toolRequired = 'laser_welder',
        toolDurabilityLoss = 3,
        chainStep = 'electronics'
    },
    -- ⚔️ ADVANCED WEAPONS
    metal_frame = {
        label = 'Weapon Frame',
        description = 'Precision-crafted metal frame',
        category = 'general',
        inputs = { steel = 4, aluminum = 2 },
        outputs = { metal_frame = 1 },
        xp = 20,
        time = 15000,
        level = 8,
        blueprint = 'metal_frame_bp',
        difficulty = 'medium',
        moneyReward = 200,
        specialStation = 'weapon_forge'
    },
    trigger_mechanism = {
        label = 'Trigger Mechanism',
        description = 'Precise trigger assembly',
        category = 'general',
        inputs = { spring_steel = 2, precision_parts = 3 },
        outputs = { trigger_mechanism = 1 },
        xp = 25,
        time = 18000,
        level = 10,
        blueprint = 'trigger_mechanism_bp',
        difficulty = 'hard',
        moneyReward = 250,
        specialStation = 'weapon_forge',
        masteryCategory = 'weapons'
    },
    -- 🧪 CHEMISTRY
    chemical_compound = {
        label = 'Chemical Compound',
        description = 'Experimental chemical mixture',
        category = 'general',
        inputs = { chemical_a = 2, chemical_b = 1, catalyst = 1 },
        outputs = { chemical_compound = 3 },
        xp = 30,
        time = 25000,
        level = 12,
        blueprint = 'chemistry_advanced_bp',
        difficulty = 'hard',
        moneyReward = 400,
        specialStation = 'chemical_lab',
        dangerLevel = 'high', -- new safety mechanic
        explosionChance = 0.05 -- 5% chance of accident
    },
    -- 🏭 AUTOMATION COMPONENTS
    servo_motor = {
        label = 'Servo Motor',
        description = 'Precision servo motor for automation',
        category = 'general',
        inputs = { motor_core = 1, copper_wire = 5, magnet = 2 },
        outputs = { servo_motor = 1 },
        xp = 40,
        time = 30000,
        level = 15,
        blueprint = 'servo_motor_bp',
        difficulty = 'hard',
        moneyReward = 500,
        batchCraftingEnabled = true,
        maxBatchSize = 3
    }
}

-- Difficulty settings affect skill check parameters
Config.Difficulty = {
    easy = { area = 60, speed = {3, 5}, attempts = 3 },
    medium = { area = 40, speed = {5, 8}, attempts = 2 },
    hard = { area = 25, speed = {7, 10}, attempts = 1 }
}

-- UI Settings
Config.UI = {
    showLevelRequirements = true,
    showMissingIngredients = true,
    showXPRewards = true,
    enableRecipeSearch = true,
    enableCategoryFilter = true
}

-- 🔧 ADVANCED CRAFTING SYSTEMS

-- 🏭 Crafting Station Upgrades
Config.StationUpgrades = {
    efficiency = {
        level1 = { speedMultiplier = 1.1, cost = 2500, requirement = 'advanced_tools' },
        level2 = { speedMultiplier = 1.25, cost = 7500, requirement = 'precision_machinery' },
        level3 = { speedMultiplier = 1.5, cost = 15000, requirement = 'automation_kit' }
    },
    quality = {
        level1 = { qualityBonus = 0.1, cost = 3000, requirement = 'quality_control_kit' },
        level2 = { qualityBonus = 0.25, cost = 8000, requirement = 'master_crafting_set' },
        level3 = { qualityBonus = 0.4, cost = 20000, requirement = 'legendary_workshop' }
    },
    capacity = {
        level1 = { batchMultiplier = 2, cost = 5000, requirement = 'expansion_module' },
        level2 = { batchMultiplier = 3, cost = 12000, requirement = 'industrial_upgrade' },
        level3 = { batchMultiplier = 5, cost = 25000, requirement = 'factory_automation' }
    }
}

-- 🔬 Blueprint Discovery System
Config.Blueprints = {
    enabled = true,
    discoveryMethods = {
        research = {
            enabled = true,
            researchPoints = 50, -- points needed per blueprint
            researchTime = 30000, -- 30 seconds per research attempt
            successChance = 0.3 -- 30% success rate
        },
        exploration = {
            enabled = true,
            locations = {
                { coords = vector3(2441.2, 4968.5, 51.7), blueprint = 'advanced_lockpick', rarity = 'rare' },
                { coords = vector3(1946.8, 3815.2, 33.1), blueprint = 'explosive_device', rarity = 'epic' },
                { coords = vector3(713.5, -975.2, 31.4), blueprint = 'master_key', rarity = 'legendary' }
            }
        },
        trading = {
            enabled = true,
            npcTraders = {
                {
                    coords = vector3(1692.62, 3584.85, 35.62),
                    name = 'Marcus the Engineer',
                    blueprints = { 'electronic_kit', 'servo_motor', 'circuit_board' }
                }
            }
        }
    }
}

-- ⚒️ Tool Durability System
Config.Tools = {
    durabilityEnabled = true,
    tools = {
        basic_hammer = { durability = 100, repairCost = 25, repairItem = 'metalscrap' },
        precision_cutter = { durability = 75, repairCost = 50, repairItem = 'advanced_components' },
        laser_welder = { durability = 200, repairCost = 100, repairItem = 'energy_cell' },
        molecular_assembler = { durability = 500, repairCost = 500, repairItem = 'quantum_core' }
    },
    durabilityLoss = {
        easy = 1,    -- durability lost per craft
        medium = 2,
        hard = 3
    }
}

-- 📦 Batch Crafting System
Config.BatchCrafting = {
    enabled = true,
    maxBatchSize = 10, -- maximum items per batch
    timeMultiplier = 0.8, -- 20% time reduction for batches
    xpMultiplier = 1.1, -- 10% XP bonus for batch crafting
    requiredUpgrade = 'capacity_level1' -- station upgrade needed
}

-- 🔗 Multi-Step Crafting Chains
Config.CraftingChains = {
    electronics = {
        step1 = { recipe = 'copper_wire', required = 5 },
        step2 = { recipe = 'circuit_board', required = 2 },
        step3 = { recipe = 'electronic_device', required = 1 },
        finalProduct = 'advanced_gadget',
        chainBonus = 1.3 -- 30% extra yield for completing full chain
    },
    weapons = {
        step1 = { recipe = 'metal_frame', required = 1 },
        step2 = { recipe = 'trigger_mechanism', required = 1 },
        step3 = { recipe = 'barrel_assembly', required = 1 },
        finalProduct = 'custom_weapon',
        chainBonus = 1.5
    }
}

-- 🎯 Specialized Workstations
Config.SpecializedStations = {
    electronics_lab = {
        coords = vector3(2440.5, 4970.1, 46.8),
        label = 'Electronics Laboratory',
        specialization = 'electronics',
        bonuses = { speed = 1.3, quality = 1.2 },
        requiredLevel = 8,
        unlockCost = 15000
    },
    weapon_forge = {
        coords = vector3(1105.5, -2008.2, 35.8),
        label = 'Weapon Forge',
        specialization = 'weapons',
        bonuses = { durability = 1.4, damage = 1.1 },
        requiredLevel = 12,
        unlockCost = 25000
    },
    chemical_lab = {
        coords = vector3(483.2, -1531.8, 29.3),
        label = 'Chemical Laboratory',
        specialization = 'chemistry',
        bonuses = { purity = 1.3, yield = 1.15 },
        requiredLevel = 15,
        unlockCost = 40000
    }
}

-- 🏆 Mastery System
Config.Mastery = {
    enabled = true,
    categories = {
        electronics = { maxLevel = 50, xpMultiplier = 1.0 },
        weapons = { maxLevel = 50, xpMultiplier = 1.2 },
        chemistry = { maxLevel = 50, xpMultiplier = 1.5 },
        general = { maxLevel = 25, xpMultiplier = 0.8 }
    },
    milestones = {
        [10] = { unlock = 'efficiency_boost', bonus = 1.1 },
        [25] = { unlock = 'quality_mastery', bonus = 1.2 },
        [50] = { unlock = 'master_crafter', bonus = 1.5 }
    }
}