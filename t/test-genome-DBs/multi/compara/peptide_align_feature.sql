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
-- Table structure for table `peptide_align_feature`
--

DROP TABLE IF EXISTS `peptide_align_feature`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `peptide_align_feature` (
  `peptide_align_feature_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `qmember_id` int(10) unsigned NOT NULL,
  `hmember_id` int(10) unsigned NOT NULL,
  `qgenome_db_id` int(10) unsigned NOT NULL,
  `hgenome_db_id` int(10) unsigned NOT NULL,
  `qstart` int(10) NOT NULL DEFAULT '0',
  `qend` int(10) NOT NULL DEFAULT '0',
  `hstart` int(11) NOT NULL DEFAULT '0',
  `hend` int(11) NOT NULL DEFAULT '0',
  `score` double(16,4) NOT NULL DEFAULT '0.0000',
  `evalue` double DEFAULT NULL,
  `align_length` int(10) DEFAULT NULL,
  `identical_matches` int(10) DEFAULT NULL,
  `perc_ident` int(10) DEFAULT NULL,
  `positive_matches` int(10) DEFAULT NULL,
  `perc_pos` int(10) DEFAULT NULL,
  `hit_rank` int(10) DEFAULT NULL,
  `cigar_line` mediumtext,
  PRIMARY KEY (`peptide_align_feature_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 MAX_ROWS=100000000 AVG_ROW_LENGTH=133 CHECKSUM=1;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-05-22 14:40:02
