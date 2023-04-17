/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pages` (
  `id` varchar(36) NOT NULL,
  `template_id` varchar(36) NOT NULL,
  `url` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `content` text DEFAULT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'live',
  `meta_keywords` varchar(255) DEFAULT NULL,
  `meta_description` tinytext DEFAULT NULL,
  `meta_author` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pages_id_IDX` (`id`) USING BTREE,
  KEY `pages_url_IDX` (`url`) USING BTREE,
  KEY `pages_title_IDX` (`name`) USING BTREE,
  KEY `pages_status_IDX` (`status`) USING BTREE,
  KEY `pages_created_at_IDX` (`created_at`) USING BTREE,
  KEY `pages_created_by_IDX` (`created_by`) USING BTREE,
  KEY `pages_updated_at_IDX` (`updated_at`) USING BTREE,
  KEY `pages_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `pages_deleted_at_IDX` (`deleted_at`) USING BTREE,
  KEY `pages_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `pages_template_id_IDX` (`template_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `settings` (
  `name` varchar(255) NOT NULL,
  `theme_id` varchar(36) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'online',
  `meta_description` tinytext DEFAULT NULL,
  `meta_keywords` varchar(255) DEFAULT NULL,
  `meta_author` varchar(255) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `robots_txt` text DEFAULT NULL,
  PRIMARY KEY (`name`),
  KEY `settings_name_IDX` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES ('dumb dog','b2d86900-d982-11ed-8a12-5254003f8571','online','','','',NULL,NULL);
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `templates`
--

DROP TABLE IF EXISTS `templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `templates` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `file` varchar(255) NOT NULL,
  `default` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `templates_created_at_IDX` (`created_at`) USING BTREE,
  KEY `templates_created_by_IDX` (`created_by`) USING BTREE,
  KEY `templates_default_IDX` (`default`) USING BTREE,
  KEY `templates_deleted_at_IDX` (`deleted_at`) USING BTREE,
  KEY `templates_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `templates_id_IDX` (`id`) USING BTREE,
  KEY `templates_name_IDX` (`name`) USING BTREE,
  KEY `templates_updated_at_IDX` (`updated_at`) USING BTREE,
  KEY `templates_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `templates_file_IDX` (`file`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `themes`
--

DROP TABLE IF EXISTS `themes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `themes` (
  `id` varchar(36) NOT NULL,
  `default` tinyint(1) DEFAULT 0,
  `name` varchar(255) NOT NULL,
  `folder` varchar(255) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'active',
  `active_from` date DEFAULT NULL,
  `active_to` date DEFAULT NULL,
  `annual` tinyint(1) DEFAULT 0,
  `created_at` datetime NOT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `themes_created_at_IDX` (`created_at`) USING BTREE,
  KEY `themes_created_by_IDX` (`created_by`) USING BTREE,
  KEY `themes_default_IDX` (`default`) USING BTREE,
  KEY `themes_deleted_at_IDX` (`deleted_at`) USING BTREE,
  KEY `themes_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `themes_folder_IDX` (`folder`) USING BTREE,
  KEY `themes_id_IDX` (`id`) USING BTREE,
  KEY `themes_name_IDX` (`name`) USING BTREE,
  KEY `themes_status_IDX` (`status`) USING BTREE,
  KEY `themes_updated_at_IDX` (`updated_at`) USING BTREE,
  KEY `themes_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `themes_active_from_IDX` (`active_from`) USING BTREE,
  KEY `themes_active_to_IDX` (`active_to`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `nickname` varchar(255) DEFAULT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `users_username_IDX` (`name`) USING BTREE,
  KEY `users_password_IDX` (`password`) USING BTREE,
  KEY `users_nickname_IDX` (`nickname`) USING BTREE,
  KEY `users_status_IDX` (`status`) USING BTREE,
  KEY `users_created_at_IDX` (`created_at`) USING BTREE,
  KEY `users_created_by_IDX` (`created_by`) USING BTREE,
  KEY `users_updated_at_IDX` (`updated_at`) USING BTREE,
  KEY `users_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `users_deleted_at_IDX` (`deleted_at`) USING BTREE,
  KEY `users_deleted_by_IDX` (`deleted_by`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('89c759f3-da4b-11ed-89f5-5254003f8571','dumbdog','$2y$10$hv7daGztxRPzlN71oHyF8OntAtchU6p/lp8tpV6qTQSl1339QO4nC','Doggie','active','2023-04-13 23:35:48','00000000-0000-0000-0000-000000000000','2023-04-17 10:25:20','00000000-0000-0000-0000-000000000000',NULL,NULL),('caaa3c62-dd06-11ed-8a63-5254003f8571','test','$2y$10$p2l.CkE1bGQlymZzqEMgOuxZIk48KY9fm86Mh.3O0v.uRVb4MUR9m','test','active','2023-04-17 11:01:15','00000000-0000-0000-0000-000000000000','2023-04-17 11:45:28','00000000-0000-0000-0000-000000000000','2023-04-17 11:45:28','00000000-0000-0000-0000-000000000000');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
