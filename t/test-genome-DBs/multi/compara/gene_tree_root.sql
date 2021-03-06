-- MySQL dump 10.13  Distrib 5.1.61, for redhat-linux-gnu (x86_64)
--
-- Host: mysql-eg-enaprod.ebi.ac.uk    Database: ensembl_compara_family_test
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
-- Table structure for table `gene_tree_root`
--

DROP TABLE IF EXISTS `gene_tree_root`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gene_tree_root` (
  `root_id` int(10) unsigned NOT NULL,
  `member_type` enum('protein','ncrna') NOT NULL,
  `tree_type` enum('clusterset','supertree','tree') NOT NULL,
  `clusterset_id` varchar(20) NOT NULL DEFAULT 'default',
  `method_link_species_set_id` int(10) unsigned NOT NULL,
  `gene_align_id` int(10) unsigned DEFAULT NULL,
  `ref_root_id` int(10) unsigned DEFAULT NULL,
  `stable_id` varchar(40) DEFAULT NULL,
  `version` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`root_id`),
  UNIQUE KEY `stable_id` (`stable_id`),
  KEY `method_link_species_set_id` (`method_link_species_set_id`),
  KEY `gene_align_id` (`gene_align_id`),
  KEY `ref_root_id` (`ref_root_id`),
  KEY `tree_type` (`tree_type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 CHECKSUM=1;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-09-02 11:17:22
