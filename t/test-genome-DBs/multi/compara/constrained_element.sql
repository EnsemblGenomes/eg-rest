-- MySQL dump 10.13  Distrib 5.1.61, for redhat-linux-gnu (x86_64)
--
-- Host: mysql-eg-devel-1.ebi.ac.uk    Database: test_ensembl_compara_bacteria_22_75
-- ------------------------------------------------------
-- Server version	5.5.36-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `constrained_element`
--

DROP TABLE IF EXISTS `constrained_element`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `constrained_element` (
  `constrained_element_id` bigint(20) unsigned NOT NULL,
  `dnafrag_id` bigint(20) unsigned NOT NULL,
  `dnafrag_start` int(12) unsigned NOT NULL,
  `dnafrag_end` int(12) unsigned NOT NULL,
  `dnafrag_strand` int(2) DEFAULT NULL,
  `method_link_species_set_id` int(10) unsigned NOT NULL,
  `p_value` double DEFAULT NULL,
  `score` double NOT NULL DEFAULT '0',
  KEY `dnafrag_id` (`dnafrag_id`),
  KEY `constrained_element_id_idx` (`constrained_element_id`),
  KEY `mlssid_idx` (`method_link_species_set_id`),
  KEY `mlssid_dfId_dfStart_dfEnd_idx` (`method_link_species_set_id`,`dnafrag_id`,`dnafrag_start`,`dnafrag_end`),
  KEY `mlssid_dfId_idx` (`method_link_species_set_id`,`dnafrag_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 CHECKSUM=1;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-05-22 14:39:53
