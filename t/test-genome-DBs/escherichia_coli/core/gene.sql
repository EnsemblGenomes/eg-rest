-- MySQL dump 10.14  Distrib 5.5.33a-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: test_escherichia_coli_core_21_74_1
-- ------------------------------------------------------
-- Server version	5.5.33a-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `gene`
--

DROP TABLE IF EXISTS `gene`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gene` (
  `gene_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `biotype` varchar(40) NOT NULL,
  `analysis_id` smallint(5) unsigned NOT NULL,
  `seq_region_id` int(10) unsigned NOT NULL,
  `seq_region_start` int(10) unsigned NOT NULL,
  `seq_region_end` int(10) unsigned NOT NULL,
  `seq_region_strand` tinyint(2) NOT NULL,
  `display_xref_id` int(10) unsigned DEFAULT NULL,
  `source` varchar(20) NOT NULL,
  `status` enum('KNOWN','NOVEL','PUTATIVE','PREDICTED','KNOWN_BY_PROJECTION','UNKNOWN','ANNOTATED') DEFAULT NULL,
  `description` text,
  `is_current` tinyint(1) NOT NULL DEFAULT '1',
  `canonical_transcript_id` int(10) unsigned NOT NULL,
  `stable_id` varchar(128) DEFAULT NULL,
  `version` smallint(5) unsigned NOT NULL DEFAULT '1',
  `created_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`gene_id`),
  KEY `seq_region_idx` (`seq_region_id`,`seq_region_start`),
  KEY `xref_id_index` (`display_xref_id`),
  KEY `analysis_idx` (`analysis_id`),
  KEY `stable_id_idx` (`stable_id`,`version`),
  KEY `canonical_transcript_id_idx` (`canonical_transcript_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3668 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-11-05 20:27:36
