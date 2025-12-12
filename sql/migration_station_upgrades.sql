-- Database migration for Crafting Station Upgrades
-- Run this file to add crafting station upgrade tracking

CREATE TABLE IF NOT EXISTS `bldr_crafting_stations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `station_id` int(11) NOT NULL,
  `owner_license` varchar(60) DEFAULT NULL,
  `upgrade_level` int(11) DEFAULT 1,
  `upgrades` longtext DEFAULT '{}',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `station_id` (`station_id`),
  KEY `owner_license` (`owner_license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Index for faster queries
CREATE INDEX idx_station_owner ON bldr_crafting_stations(station_id, owner_license);
