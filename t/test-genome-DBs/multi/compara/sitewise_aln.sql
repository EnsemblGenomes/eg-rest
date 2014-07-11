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
-- Table structure for table `sitewise_aln`
--

DROP TABLE IF EXISTS `sitewise_aln`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sitewise_aln` (
  `sitewise_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `aln_position` int(10) unsigned NOT NULL,
  `node_id` int(10) unsigned NOT NULL,
  `tree_node_id` int(10) unsigned NOT NULL,
  `omega` float(10,5) DEFAULT NULL,
  `omega_lower` float(10,5) DEFAULT NULL,
  `omega_upper` float(10,5) DEFAULT NULL,
  `optimal` float(10,5) DEFAULT NULL,
  `ncod` int(10) DEFAULT NULL,
  `threshold_on_branch_ds` float(10,5) DEFAULT NULL,
  `type` enum('single_character','random','all_gaps','constant','default','negative1','negative2','negative3','negative4','positive1','positive2','positive3','positive4','synonymous') NOT NULL,
  PRIMARY KEY (`sitewise_id`),
  UNIQUE KEY `aln_position_node_id_ds` (`aln_position`,`node_id`,`threshold_on_branch_ds`),
  KEY `tree_node_id` (`tree_node_id`),
  KEY `node_id` (`node_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 CHECKSUM=1;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-05-22 14:40:02
