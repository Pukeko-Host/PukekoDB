-- phpMyAdmin SQL Dump
-- version 4.9.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jan 27, 2020 at 08:09 PM
-- Server version: 10.3.17-MariaDB-0+deb10u1-log
-- PHP Version: 7.3.11-1~deb10u1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pukekohost`
--

-- --------------------------------------------------------

--
-- Table structure for table `game`
--

DROP DATABASE `pukekohost`;
CREATE DATABASE `pukekohost`;
USE `pukekohost`;

CREATE TABLE `game` (
  `Id` int(10) UNSIGNED NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Description` text NOT NULL,
  `Perks` varchar(1000) NOT NULL,
  `API` varchar(255) DEFAULT NULL,
  `Background` varchar(128) DEFAULT NULL,
  `Foreground` varchar(128) DEFAULT NULL,
  `Icon` varchar(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `gameserver`
--

CREATE TABLE `gameserver` (
  `Id` int(10) UNSIGNED NOT NULL,
  `GameId` int(10) UNSIGNED NOT NULL,
  `GMSId` int(10) UNSIGNED NOT NULL,
  `OwnerId` bigint(22) UNSIGNED NOT NULL,
  `Port` smallint(5) UNSIGNED NOT NULL COMMENT 'Must be unique amongst active gameservers in one gms',
  `Active` tinyint(1) NOT NULL DEFAULT 1,
  `Running` tinyint(1) NOT NULL DEFAULT 0,
  `RemainingMinutes` mediumint(9) NOT NULL DEFAULT 0 COMMENT 'Expecting at most 3 months',
  `CurrentPlayers` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `MaxPlayers` tinyint(3) UNSIGNED DEFAULT NULL,
  `LastPoll` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `gameserverport`
--

CREATE TABLE `gameserverport` (
  `GameId` int(10) UNSIGNED NOT NULL,
  `TierId` tinyint(1) UNSIGNED NOT NULL,
  `Port` smallint(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `gamesupport`
--

CREATE TABLE `gamesupport` (
  `ServerID` int(11) UNSIGNED NOT NULL,
  `GameID` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `gametier`
--

CREATE TABLE `gametier` (
  `GameId` int(10) UNSIGNED NOT NULL,
  `TierNumber` tinyint(1) UNSIGNED NOT NULL DEFAULT 1,
  `Name` varchar(20) NOT NULL,
  `Icon` varchar(255) NOT NULL,
  `TierPerks` varchar(1000) NOT NULL,
  `PriceMultiplier` float(4,2) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `gms`
--

CREATE TABLE `gms` (
  `Id` int(10) UNSIGNED NOT NULL,
  `Specs` varchar(200) NOT NULL,
  `InitRate` decimal(4,2) NOT NULL DEFAULT 0.99 COMMENT 'One time initialization fee',
  `UptimeRate` decimal(4,2) NOT NULL DEFAULT 0.05 COMMENT 'Hourly rate',
  `DomainName` varchar(64) NOT NULL,
  `IPv4` varchar(15) DEFAULT NULL COMMENT '0.0.0.0',
  `IPv6` varchar(39) DEFAULT NULL COMMENT '::1',
  `UpDown` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `transaction`
--

CREATE TABLE `transaction` (
  `Id` int(11) UNSIGNED NOT NULL,
  `UserId` bigint(22) UNSIGNED NOT NULL,
  `ServerId` int(10) UNSIGNED DEFAULT NULL,
  `PayPalId` int(11) UNSIGNED DEFAULT NULL,
  `Balance` decimal(5,2) NOT NULL COMMENT 'Maximum $999 in one transaction',
  `Comment` varchar(255) DEFAULT NULL,
  `TransactionType` enum('topup','serveruptime','serverinit','refund','other') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `DiscordId` bigint(22) UNSIGNED NOT NULL,
  `Username` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `Discriminator` smallint(4) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `game`
--
ALTER TABLE `game`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `Name` (`Name`);

--
-- Indexes for table `gameserver`
--
ALTER TABLE `gameserver`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `ServerGame` (`GameId`),
  ADD KEY `ServerGMS` (`GMSId`),
  ADD KEY `ServerOwner` (`OwnerId`);

--
-- Indexes for table `gameserverport`
--
ALTER TABLE `gameserverport`
  ADD UNIQUE KEY `GameId` (`GameId`,`TierId`,`Port`);

--
-- Indexes for table `gamesupport`
--
ALTER TABLE `gamesupport`
  ADD UNIQUE KEY `UniqueGameTier` (`ServerID`,`GameID`) USING BTREE,
  ADD KEY `SupportedGame` (`GameID`);

--
-- Indexes for table `gametier`
--
ALTER TABLE `gametier`
  ADD UNIQUE KEY `GameTier` (`GameId`,`TierNumber`);

--
-- Indexes for table `gms`
--
ALTER TABLE `gms`
  ADD PRIMARY KEY (`Id`);

--
-- Indexes for table `transaction`
--
ALTER TABLE `transaction`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `PayPalId` (`PayPalId`),
  ADD KEY `TransactionUser` (`UserId`),
  ADD KEY `TransactionServer` (`ServerId`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`DiscordId`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `game`
--
ALTER TABLE `game`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `gms`
--
ALTER TABLE `gms`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transaction`
--
ALTER TABLE `transaction`
  MODIFY `Id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `gameserver`
--
ALTER TABLE `gameserver`
  ADD CONSTRAINT `ServerGMS` FOREIGN KEY (`GMSId`) REFERENCES `gms` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `ServerGame` FOREIGN KEY (`GameId`) REFERENCES `game` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `ServerOwner` FOREIGN KEY (`OwnerId`) REFERENCES `user` (`DiscordID`) ON UPDATE CASCADE;

--
-- Constraints for table `gameserverport`
--
ALTER TABLE `gameserverport`
  ADD CONSTRAINT `Game` FOREIGN KEY (`GameId`) REFERENCES `game` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `GamePort` FOREIGN KEY (`GameId`,`TierId`) REFERENCES `gametier` (`GameId`, `TierNumber`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `gamesupport`
--
ALTER TABLE `gamesupport`
  ADD CONSTRAINT `SupportedGame` FOREIGN KEY (`GameID`) REFERENCES `game` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `SupportingServer` FOREIGN KEY (`ServerID`) REFERENCES `gms` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `gametier`
--
ALTER TABLE `gametier`
  ADD CONSTRAINT `GameTier` FOREIGN KEY (`GameId`) REFERENCES `game` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `transaction`
--
ALTER TABLE `transaction`
  ADD CONSTRAINT `TransactionServer` FOREIGN KEY (`ServerId`) REFERENCES `gameserver` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `TransactionUser` FOREIGN KEY (`UserId`) REFERENCES `user` (`DiscordID`) ON DELETE NO ACTION ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
