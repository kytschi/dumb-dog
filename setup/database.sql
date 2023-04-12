--
-- Table structure for table `pages`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pages` (
  `id` varchar(36) NOT NULL,
  `template_id` varchar(36) NOT NULL,
  `url` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `content` text DEFAULT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'live',
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
-- Table structure for table `templates`
--

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
