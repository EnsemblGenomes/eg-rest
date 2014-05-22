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
-- Table structure for table `member`
--

DROP TABLE IF EXISTS `member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member` (
  `member_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stable_id` varchar(128) NOT NULL,
  `version` int(10) DEFAULT '0',
  `source_name` enum('ENSEMBLGENE','ENSEMBLPEP','Uniprot/SPTREMBL','Uniprot/SWISSPROT','ENSEMBLTRANS','EXTERNALCDS') NOT NULL,
  `taxon_id` int(10) unsigned NOT NULL,
  `genome_db_id` int(10) unsigned DEFAULT NULL,
  `sequence_id` int(10) unsigned DEFAULT NULL,
  `gene_member_id` int(10) unsigned DEFAULT NULL,
  `canonical_member_id` int(10) unsigned DEFAULT NULL,
  `description` text,
  `chr_name` char(40) DEFAULT NULL,
  `chr_start` int(10) DEFAULT NULL,
  `chr_end` int(10) DEFAULT NULL,
  `chr_strand` tinyint(1) NOT NULL,
  `display_label` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`member_id`),
  UNIQUE KEY `source_stable_id` (`stable_id`,`source_name`),
  KEY `taxon_id` (`taxon_id`),
  KEY `stable_id` (`stable_id`),
  KEY `source_name` (`source_name`),
  KEY `sequence_id` (`sequence_id`),
  KEY `gene_member_id` (`gene_member_id`),
  KEY `canonical_member_id` (`canonical_member_id`),
  KEY `gdb_name_start_end` (`genome_db_id`,`chr_name`,`chr_start`,`chr_end`)
) ENGINE=MyISAM AUTO_INCREMENT=12757725 DEFAULT CHARSET=latin1 MAX_ROWS=100000000 CHECKSUM=1;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-05-22 14:39:54
