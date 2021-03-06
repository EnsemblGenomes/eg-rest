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
-- Table structure for table `homology`
--

DROP TABLE IF EXISTS `homology`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `homology` (
  `homology_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `method_link_species_set_id` int(10) unsigned NOT NULL,
  `description` enum('ortholog_one2one','ortholog_one2many','ortholog_many2many','within_species_paralog','other_paralog','gene_split','between_species_paralog','alt_allele','homoeolog_one2one','homoeolog_one2many','homoeolog_many2many') DEFAULT NULL,
  `is_tree_compliant` tinyint(1) NOT NULL DEFAULT '0',
  `dn` float(10,5) DEFAULT NULL,
  `ds` float(10,5) DEFAULT NULL,
  `n` float(10,1) DEFAULT NULL,
  `s` float(10,1) DEFAULT NULL,
  `lnl` float(10,3) DEFAULT NULL,
  `species_tree_node_id` int(10) unsigned DEFAULT NULL,
  `gene_tree_node_id` int(10) unsigned DEFAULT NULL,
  `gene_tree_root_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`homology_id`),
  KEY `method_link_species_set_id` (`method_link_species_set_id`),
  KEY `species_tree_node_id` (`species_tree_node_id`),
  KEY `gene_tree_node_id` (`gene_tree_node_id`),
  KEY `gene_tree_root_id` (`gene_tree_root_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 CHECKSUM=1;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-09-02 11:17:22
