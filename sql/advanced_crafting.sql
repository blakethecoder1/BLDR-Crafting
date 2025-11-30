-- Advanced Crafting System Database Migration
-- This script adds tables for enhanced crafting features

-- 🏭 Crafting Station Upgrades
CREATE TABLE IF NOT EXISTS `bldr_station_upgrades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) NOT NULL,
  `station_id` int(11) NOT NULL,
  `upgrade_type` enum('efficiency','quality','capacity') NOT NULL,
  `upgrade_level` int(11) DEFAULT 1,
  `purchase_date` timestamp DEFAULT CURRENT_TIMESTAMP,
  `upgrade_cost` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `player_station_upgrade` (`player_id`,`station_id`,`upgrade_type`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 🔬 Blueprint Discovery System
CREATE TABLE IF NOT EXISTS `bldr_blueprints` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) NOT NULL,
  `blueprint_id` varchar(100) NOT NULL,
  `discovery_method` enum('research','exploration','trading','reward') NOT NULL,
  `discovery_date` timestamp DEFAULT CURRENT_TIMESTAMP,
  `rarity` enum('common','uncommon','rare','epic','legendary') DEFAULT 'common',
  `research_points_spent` int(11) DEFAULT 0,
  `is_active` boolean DEFAULT true,
  PRIMARY KEY (`id`),
  UNIQUE KEY `player_blueprint` (`player_id`,`blueprint_id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ⚒️ Tool Durability System
CREATE TABLE IF NOT EXISTS `bldr_tools` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) NOT NULL,
  `tool_type` varchar(50) NOT NULL,
  `current_durability` int(11) NOT NULL,
  `max_durability` int(11) NOT NULL,
  `crafted_date` timestamp DEFAULT CURRENT_TIMESTAMP,
  `last_repair` timestamp DEFAULT CURRENT_TIMESTAMP,
  `total_uses` int(11) DEFAULT 0,
  `quality_modifier` decimal(3,2) DEFAULT 1.00,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 🔗 Multi-Step Crafting Progress
CREATE TABLE IF NOT EXISTS `bldr_crafting_chains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) NOT NULL,
  `chain_id` varchar(100) NOT NULL,
  `current_step` int(11) DEFAULT 1,
  `completed_steps` text DEFAULT NULL, -- JSON array
  `chain_progress` text DEFAULT NULL, -- JSON data
  `started_date` timestamp DEFAULT CURRENT_TIMESTAMP,
  `last_progress` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_completed` boolean DEFAULT false,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 🏆 Mastery System
CREATE TABLE IF NOT EXISTS `bldr_crafting_mastery` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) NOT NULL,
  `category` varchar(50) NOT NULL, -- electronics, weapons, chemistry, etc.
  `current_level` int(11) DEFAULT 1,
  `total_xp` bigint(20) DEFAULT 0,
  `milestone_rewards` text DEFAULT NULL, -- JSON array of claimed rewards
  `specializations` text DEFAULT NULL, -- JSON array of unlocked specs
  `mastery_bonuses` text DEFAULT NULL, -- JSON bonuses data
  PRIMARY KEY (`id`),
  UNIQUE KEY `player_category` (`player_id`,`category`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 📦 Batch Crafting Queue
CREATE TABLE IF NOT EXISTS `bldr_batch_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) NOT NULL,
  `recipe_key` varchar(100) NOT NULL,
  `batch_size` int(11) NOT NULL,
  `items_completed` int(11) DEFAULT 0,
  `total_time` bigint(20) NOT NULL,
  `time_remaining` bigint(20) NOT NULL,
  `started_date` timestamp DEFAULT CURRENT_TIMESTAMP,
  `station_id` int(11) DEFAULT NULL,
  `is_active` boolean DEFAULT true,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 🎯 Specialized Workstation Access
CREATE TABLE IF NOT EXISTS `bldr_workstation_access` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) NOT NULL,
  `station_type` varchar(50) NOT NULL, -- electronics_lab, weapon_forge, etc.
  `access_level` int(11) DEFAULT 1,
  `unlock_date` timestamp DEFAULT CURRENT_TIMESTAMP,
  `unlock_cost` int(11) DEFAULT 0,
  `usage_count` int(11) DEFAULT 0,
  `last_used` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `player_station` (`player_id`,`station_type`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 📈 Crafting Analytics
CREATE TABLE IF NOT EXISTS `bldr_crafting_analytics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) NOT NULL,
  `recipe_key` varchar(100) NOT NULL,
  `craft_date` timestamp DEFAULT CURRENT_TIMESTAMP,
  `quality_achieved` decimal(3,2) DEFAULT 1.00,
  `time_taken` int(11) NOT NULL,
  `xp_gained` int(11) DEFAULT 0,
  `materials_used` text DEFAULT NULL, -- JSON
  `station_type` varchar(50) DEFAULT NULL,
  `success_rate` decimal(3,2) DEFAULT 1.00,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`),
  KEY `recipe_key` (`recipe_key`),
  KEY `craft_date` (`craft_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 🔍 Research Progress
CREATE TABLE IF NOT EXISTS `bldr_research_progress` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) NOT NULL,
  `research_category` varchar(50) NOT NULL,
  `research_points` int(11) DEFAULT 0,
  `active_research` varchar(100) DEFAULT NULL,
  `research_start_time` timestamp NULL DEFAULT NULL,
  `completed_research` text DEFAULT NULL, -- JSON array
  `last_update` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `player_category` (`player_id`,`research_category`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default blueprint discoveries for testing
INSERT IGNORE INTO `bldr_blueprints` (`player_id`, `blueprint_id`, `discovery_method`, `rarity`) VALUES
('default_player', 'advanced_lockpick', 'exploration', 'rare'),
('default_player', 'circuit_board_bp', 'research', 'uncommon'),
('default_player', 'servo_motor_bp', 'trading', 'epic');

-- Insert default mastery categories
INSERT IGNORE INTO `bldr_crafting_mastery` (`player_id`, `category`, `current_level`, `total_xp`) VALUES
('default_player', 'electronics', 1, 0),
('default_player', 'weapons', 1, 0),
('default_player', 'chemistry', 1, 0),
('default_player', 'general', 1, 0);

-- Success message
SELECT 'Advanced Crafting System database migration completed successfully!' AS message;