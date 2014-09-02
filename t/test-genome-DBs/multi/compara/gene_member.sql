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
-- Table structure for table `gene_member`
--

DROP TABLE IF EXISTS `gene_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gene_member` (
  `gene_member_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stable_id` varchar(128) NOT NULL,
  `version` int(10) DEFAULT '0',
  `source_name` enum('ENSEMBLGENE','EXTERNALGENE') NOT NULL,
  `taxon_id` int(10) unsigned NOT NULL,
  `genome_db_id` int(10) unsigned DEFAULT NULL,
  `canonical_member_id` int(10) unsigned DEFAULT NULL,
  `description` text,
  `dnafrag_id` bigint(20) unsigned DEFAULT NULL,
  `dnafrag_start` int(10) unsigned DEFAULT NULL,
  `dnafrag_end` int(10) unsigned DEFAULT NULL,
  `dnafrag_strand` tinyint(4) DEFAULT NULL,
  `display_label` varchar(128) DEFAULT NULL,
  `families` tinyint(1) unsigned DEFAULT '0',
  `gene_trees` tinyint(1) unsigned DEFAULT '0',
  `gene_gain_loss_trees` tinyint(1) unsigned DEFAULT '0',
  `orthologues` int(10) unsigned DEFAULT '0',
  `paralogues` int(10) unsigned DEFAULT '0',
  `homoeologues` int(10) unsigned DEFAULT '0',
  PRIMARY KEY (`gene_member_id`),
  UNIQUE KEY `stable_id` (`stable_id`),
  KEY `taxon_id` (`taxon_id`),
  KEY `genome_db_id` (`genome_db_id`),
  KEY `source_name` (`source_name`),
  KEY `canonical_member_id` (`canonical_member_id`),
  KEY `dnafrag_id_start` (`dnafrag_id`,`dnafrag_start`),
  KEY `dnafrag_id_end` (`dnafrag_id`,`dnafrag_end`)
) ENGINE=MyISAM AUTO_INCREMENT=8807637 DEFAULT CHARSET=latin1 MAX_ROWS=100000000 CHECKSUM=1;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-09-02 11:17:21
