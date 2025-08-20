/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.11-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: dumb_dog
-- ------------------------------------------------------
-- Server version	10.6.22-MariaDB-deb11

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
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses` (
  `id` varchar(36) NOT NULL,
  `address_line_1` varchar(255) NOT NULL,
  `address_line_2` varchar(255) DEFAULT NULL,
  `city` varchar(255) NOT NULL,
  `county` varchar(255) NOT NULL,
  `postcode` varchar(255) NOT NULL,
  `country_id` varchar(36) NOT NULL,
  `tags` text DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_addresses_address_line_1_IDX` (`address_line_1`) USING BTREE,
  KEY `order_addresses_address_line_2_IDX` (`address_line_2`) USING BTREE,
  KEY `order_addresses_city_IDX` (`city`) USING BTREE,
  KEY `order_addresses_country_IDX` (`country_id`) USING BTREE,
  KEY `order_addresses_county_IDX` (`county`) USING BTREE,
  KEY `order_addresses_created_at_IDX` (`created_at`) USING BTREE,
  KEY `order_addresses_created_by_IDX` (`created_by`) USING BTREE,
  KEY `order_addresses_deleted_at_IDX` (`deleted_at`) USING BTREE,
  KEY `order_addresses_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `order_addresses_postcode_IDX` (`postcode`) USING BTREE,
  KEY `order_addresses_updated_at_IDX` (`updated_at`) USING BTREE,
  KEY `order_addresses_updated_by_IDX` (`updated_by`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_apps`
--

DROP TABLE IF EXISTS `api_apps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_apps` (
  `id` varchar(36) NOT NULL,
  `api_key` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` mediumtext DEFAULT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'active',
  `tags` text DEFAULT NULL,
  `last_used_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointments` (
  `id` varchar(36) NOT NULL,
  `content_id` varchar(36) NOT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `lead_id` varchar(36) DEFAULT NULL,
  `with_email` varchar(255) DEFAULT NULL,
  `with_number` varchar(255) DEFAULT NULL,
  `on_date` datetime NOT NULL,
  `appointment_length` varchar(10) DEFAULT NULL,
  `free_slot` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `appointments_on_date_IDX` (`on_date`) USING BTREE,
  KEY `appointments_user_id_IDX` (`user_id`) USING BTREE,
  KEY `appointments_with_email_IDX` (`with_email`) USING BTREE,
  KEY `appointments_with_number_IDX` (`with_number`) USING BTREE,
  KEY `appointments_free_slot_IDX` (`free_slot`) USING BTREE,
  KEY `appointments_appointment_length_IDX` (`appointment_length`) USING BTREE,
  KEY `appointments_content_id_IDX` (`content_id`) USING BTREE,
  KEY `appointments_lead_id_IDX` (`lead_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
INSERT INTO `appointments` VALUES
('56fe2f46-d408-11ee-8ddc-5254007f44a4','ea619c3e-23e7-4658-a9a7-47610ba83ec9',NULL,NULL,NULL,NULL,'2024-02-25 09:00:00','1',0),
('b18db0e2-d413-11ee-8ddc-5254007f44a4','7675eb04-a7eb-4764-8f8a-544e687ad58a','89c759f3-da4b-11ed-89f5-5254003f8571','8881d16d-6622-4d4d-85f8-4b87d4a6869c',NULL,NULL,'2024-02-25 16:00:00','1',0),
('e1bdf2e8-791a-11f0-8652-5254004829bf','8c18d19a-8dd9-4d85-8891-42bc66d42969',NULL,NULL,NULL,NULL,'2025-08-14 16:00:00','1',0);
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comments` (
  `id` varchar(36) NOT NULL,
  `content_id` varchar(36) DEFAULT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `content` text NOT NULL,
  `reviewed` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `comments_created_at_IDX` (`created_at`) USING BTREE,
  KEY `comments_created_by_IDX` (`created_by`) USING BTREE,
  KEY `comments_deleted_at_IDX` (`deleted_at`) USING BTREE,
  KEY `comments_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `comments_name_IDX` (`name`) USING BTREE,
  KEY `comments_page_id_IDX` (`content_id`) USING BTREE,
  KEY `comments_updated_at_IDX` (`updated_at`) USING BTREE,
  KEY `comments_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `comments_user_id_IDX` (`user_id`) USING BTREE,
  KEY `comments_reviewed_IDX` (`reviewed`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `companies`
--

DROP TABLE IF EXISTS `companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `companies` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `contact_id` varchar(36) DEFAULT NULL,
  `address_id` varchar(36) DEFAULT NULL,
  `tags` text DEFAULT NULL,
  `created_by` varchar(36) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `companies_name_IDX` (`name`) USING BTREE,
  KEY `companies_contact_id_IDX` (`contact_id`) USING BTREE,
  KEY `companies_address_id_IDX` (`address_id`) USING BTREE,
  KEY `companies_created_by_IDX` (`created_by`) USING BTREE,
  KEY `companies_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `companies_deleted_by_IDX` (`deleted_by`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `companies`
--

LOCK TABLES `companies` WRITE;
/*!40000 ALTER TABLE `companies` DISABLE KEYS */;
/*!40000 ALTER TABLE `companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contacts`
--

DROP TABLE IF EXISTS `contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `contacts` (
  `id` varchar(36) NOT NULL,
  `company_id` varchar(36) DEFAULT NULL,
  `title` varchar(50) DEFAULT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `position` varchar(255) DEFAULT NULL,
  `tags` text DEFAULT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'live',
  `created_by` varchar(36) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_created_by_IDX` (`created_by`) USING BTREE,
  KEY `customer_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `customer_email_IDX` (`email`) USING BTREE,
  KEY `customer_first_name_IDX` (`first_name`) USING BTREE,
  KEY `customer_last_name_IDX` (`last_name`) USING BTREE,
  KEY `customer_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `contacts_company_id_IDX` (`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contacts`
--

LOCK TABLES `contacts` WRITE;
/*!40000 ALTER TABLE `contacts` DISABLE KEYS */;
INSERT INTO `contacts` VALUES
('45ab4b88-1780-48af-be8d-359820727508',NULL,'','JPkKDcHpvJ7FQH3ilL3Dqw==::e6b8535946e99f8ab4e490a546ec9fba','MHAiVOdunU8H9MnrUAxzJA==::8ab80aea19cd052495bb015081f2051d','vaSo5xXDq3vMdM07ltkOS5r9BRak/6XA5e1RopS5Ics=::13109401db21764e6c3bb0ed5ebaa099','','','','','live','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-19 13:13:16','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-20 06:54:44',NULL,NULL);
/*!40000 ALTER TABLE `contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content`
--

DROP TABLE IF EXISTS `content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `content` (
  `id` varchar(36) NOT NULL,
  `template_id` varchar(36) DEFAULT NULL,
  `parent_id` varchar(36) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `sub_title` varchar(255) DEFAULT NULL,
  `slogan` text DEFAULT NULL,
  `content` text DEFAULT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'live',
  `meta_keywords` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `meta_author` varchar(255) DEFAULT NULL,
  `menu_item` varchar(10) DEFAULT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'page',
  `event_on` datetime DEFAULT NULL,
  `event_length` varchar(10) DEFAULT NULL,
  `tags` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `author` varchar(255) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `featured` tinyint(1) DEFAULT 0,
  `sort` int(11) DEFAULT 0,
  `sitemap_include` tinyint(1) NOT NULL DEFAULT 1,
  `public_facing` tinyint(1) DEFAULT 1,
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
  KEY `pages_template_id_IDX` (`template_id`) USING BTREE,
  KEY `pages_parent_id_IDX` (`parent_id`) USING BTREE,
  KEY `pages_meta_keywords_IDX` (`meta_keywords`) USING BTREE,
  KEY `pages_meta_author_IDX` (`meta_author`) USING BTREE,
  KEY `pages_menu_item_IDX` (`menu_item`) USING BTREE,
  KEY `pages_type_IDX` (`type`) USING BTREE,
  KEY `pages_event_on_IDX` (`event_on`) USING BTREE,
  KEY `pages_event_length_IDX` (`event_length`) USING BTREE,
  KEY `content_sort_IDX` (`sort`) USING BTREE,
  KEY `content_featured_IDX` (`featured`) USING BTREE,
  KEY `content_sitemap_include_IDX` (`sitemap_include`) USING BTREE,
  KEY `content_public_facing_IDX` (`public_facing`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content`
--

LOCK TABLES `content` WRITE;
/*!40000 ALTER TABLE `content` DISABLE KEYS */;
INSERT INTO `content` VALUES
('050f2c37-ccda-4d3c-b085-fabba38006c9','5d6c5133-d9f7-11ed-89da-5254003f8571','','/test-product-3','test product 3','test product 3','','','','live','','','',NULL,'product',NULL,NULL,'',NULL,NULL,0,0,1,1,'2025-08-16 11:21:46','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-16 11:21:46','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('1221eecd-e897-4ead-970a-63499afe0cda','5d6c5133-d9f7-11ed-89da-5254003f8571','','/installation','installation','Installation','','','<p><strong>Requirements</strong></p>\r\n<ul>\r\n<li>PHP 7+</li>\r\n<li>Your favourite SQL database</li>\r\n<li>Webserver (Nginx recommended)</li>\r\n</ul>\r\n\r\n<p><strong>Installation</strong><br></p><p>Download or clone the repository.</p>\r\n<p>Copy the module located in the <strong>compiled</strong> folder to your PHP modules folder on your server.</p>\r\n<pre><code>https://github.com/kytschi/dumb-dog/blob/main/compiled</code></pre>\r\n\r\n<p>Now create an ini to load the module in your PHP modules ini folder.</p>\r\n<pre><code>; configuration for php to enable dumb dog\r\nextension=dumbdog.so</code></pre>\r\n<p>You can also just create the ini and point the <strong>extension</strong> to the folder with the <strong>dumbdog.so</strong>.</p>\r\n<p><strong>And don\'t forget to restart your webserver.</strong></p>\r\n\r\n<p>If you have issues with the module you may need to compile it yourself. </p>\r\n<p>See <strong>https://docs.zephir-lang.com/0.12/en/installation</strong> for more information on installing Zephir-lang and compiling.</p>\r\n\r\n<p>Create yourself a database and run the SQL located in the setup folder.</p>\r\n<pre><code>https://github.com/kytschi/dumb-dog/blob/main/setup/database.sql</code></pre>\r\n\r\n<p>Once the database is setup and the SQL installed, go to the <strong>.dumbdog-example.json</strong> in the root folder and copy it to a file called <strong>.dumbdog.json</strong>. This is where you can configure Dumb Dog. Now set the database connection details to that of your newly created database.</p>\r\n\r\n<pre><code>\"database\":\r\n{\r\n    \"type\": \"mysql\",\r\n    \"host\": \"localhost\",\r\n    \"port\": \"3306\",\r\n    \"db\": \"dumb_dog\",\r\n    \"username\": \"dumb_dog\",\r\n    \"password\": \"password\"\r\n}\r\n</code></pre>\r\n\r\n<p>Generate a random key for the encryption part of Dumb Dog, can use a command like the following and save that to the <strong>encryption</strong> variable in the <strong>dumbdog.json</strong> file.</p>\r\n\r\n<pre><code>openssl rand -base64 32</code></pre>\r\n\r\n<p>Next point your webserver to the <strong>public</strong> folder of Dumb Dog where the <strong>index.php</strong> is located.</p>\r\n<p>Make sure that the <strong>public/website/files</strong> folder has permission to write to by your webserver\'s user. This folder is used to store any files you upload via Dumb Dog.</p>\r\n\r\n<p><strong>NOTE</strong></p>\r\n\r\n<p>If your using a template engine please make sure that the <strong>cache</strong> folder has write permissions by the webserver user.</p>\r\n\r\n<p>That\'s it, now you can access Dumb Dog via whatever url you\'ve setup for the project by adding <strong>/dumb-dog</strong> to the url.</p>\r\n\r\n<p>Default login is username <strong>dumbdog</strong> and password is <strong>woofwoof</strong>.</p>\r\n\r\n<p><strong>DONT FORGET TO CREATE YOUR OWN USER AND DELETE THE DEFAULT ONE OR CHANGE ITS PASSWORD!</strong></p>','live','','','',NULL,'page',NULL,NULL,'',NULL,NULL,0,0,1,1,'2024-07-13 12:38:18','89c759f3-da4b-11ed-89f5-5254003f8571','2024-07-13 13:38:18','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('186aca40-c673-493a-9932-6b6d56396980',NULL,'','','header','header','',NULL,NULL,'live',NULL,NULL,NULL,NULL,'menu',NULL,NULL,'[{\"value\":\"header\"}]',NULL,NULL,0,0,0,1,'2024-03-01 21:14:49','89c759f3-da4b-11ed-89f5-5254003f8571','2024-07-11 18:58:56','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('25b614da-932a-45d7-bc08-30d25eb04e5c',NULL,'186aca40-c673-493a-9932-6b6d56396980','','templates','templates','Learn about the template building and support',NULL,NULL,'live',NULL,NULL,NULL,NULL,'menu-item',NULL,NULL,NULL,NULL,NULL,0,3,0,1,'2024-07-05 15:23:24','89c759f3-da4b-11ed-89f5-5254003f8571','2024-07-05 15:23:24','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('403f0523-2830-4d70-97d4-00910abb3209','5d6c5133-d9f7-11ed-89da-5254003f8571','','/help','help','Help','','','<p><strong>Updating</strong></p>\r\n<p>Either git pull, clone or download the latest from the repo to keep Dumb Dog up to date.</p><p><strong>Migrations</strong></p>\r\n<p>To update the database with the latest migrations, simply run <strong>migrations.sh</strong> in the <strong>migrations</strong> this from your terminal and any new migrations will be executed.</p>\r\n\r\n<p>You can run the <strong>migrations.sh</strong> from any location just make sure to pass in the <strong>.dumbdog.json</strong> config file.</p><pre><code>sh DUMB_DOG_FOLDER/migrations/migrations.sh DUMB_DOG_FOLDER/.dumbdog.json<br><br><br></code></pre>\r\n\r\n<p><strong>More information</strong></p><p>You can view the source code for this website in the <strong>example</strong> folder of the project repository to help you get going with Dumb Dog.</p>','live','','','',NULL,'page',NULL,NULL,'[{\"value\":\"help page\"}]',NULL,NULL,0,0,1,1,'2024-07-13 13:14:59','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-12 11:31:35','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('412cc034-9a06-4b24-b0e2-1bbd79ff9d3a',NULL,NULL,NULL,'Menu test 2','Menu test 2',NULL,NULL,NULL,'live',NULL,NULL,NULL,NULL,'menu',NULL,NULL,'',NULL,NULL,0,0,0,1,'2025-08-17 19:52:30','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-17 20:08:11','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('509d25d3-8840-41b1-914a-36234d3e8f2a',NULL,NULL,NULL,'Social test 2','Social test 2',NULL,NULL,NULL,'live',NULL,NULL,NULL,NULL,'social',NULL,NULL,'',NULL,NULL,0,0,0,0,'2025-08-18 08:18:21','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-18 08:46:17','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('50dbd1a9-b1c7-49c4-b7f2-34c9adea9270','5d6c5133-d9f7-11ed-89da-5254003f8571','','/test-page-2','test page 2','test page 2','','','','live','','','',NULL,'page',NULL,NULL,'',NULL,NULL,0,0,0,1,'2025-08-14 10:23:30','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-15 10:23:44','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('5e8807c3-8947-4852-9e95-4b78e9caa06c',NULL,'412cc034-9a06-4b24-b0e2-1bbd79ff9d3a',NULL,'Menu test item','Menu test item',NULL,NULL,NULL,'live',NULL,NULL,NULL,NULL,'menu-item',NULL,NULL,NULL,NULL,NULL,0,0,0,1,'2025-08-17 20:25:49','00000000-0000-0000-0000-000000000000','2025-08-17 20:25:49','00000000-0000-0000-0000-000000000000',NULL,NULL),
('70193ff8-f40b-45e5-be48-be24702ef3e3','5d6c5133-d9f7-11ed-89da-5254003f8571','','/test-product-2','test product 2','test product 2','','','','live','','','',NULL,'product',NULL,NULL,'',NULL,NULL,0,0,1,1,'2025-08-16 10:58:06','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-16 10:58:06','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('707866dc-7028-4896-bf93-8d2037d664ee',NULL,'186aca40-c673-493a-9932-6b6d56396980','','installation','installation','How do I install this puppy?',NULL,NULL,'live',NULL,NULL,NULL,NULL,'menu-item',NULL,NULL,NULL,NULL,NULL,0,2,0,1,'2024-07-05 15:20:25','89c759f3-da4b-11ed-89f5-5254003f8571','2024-07-05 15:20:25','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('74cfe3e9-856c-4cda-ab3f-4505ce5d97cb','5d6c5133-d9f7-11ed-89da-5254003f8571','','/templates','templates','Templates','','','<p>Dumb Dog does support some of the major templating engines out there should you want to use one. Personally I\'d just stick with PHP \"templates\" over using an engine as it\'s much much faster. But people love to complicate things ;-)</p>\r\n\r\n<p>&nbsp;</p>\r\n<p><strong>Twig</strong></p>\r\n\r\n<p>See <a href=\"https://twig.symfony.com/doc/3.x/installation.html\" target=\"_blank\">Twig installation</a> on how to install Twig into your project/website.</p>\r\n\r\n<p>Now in your index.php define the Twig template engine and include it in Dumb Dog.</p>\r\n\r\n<pre><code>// Include the autoload file.\r\nrequire_once \"../vendor/autoload.php\";\r\n\r\n// Define the template folder for Twig.\r\n$loader = new &#92;Twig&#92;Loader&#92;FilesystemLoader(\"./website\");\r\n\r\n// Define the Twig engine.\r\n$engine = new &#92;Twig&#92;Environment(\r\n        $loader,\r\n        [\r\n            \"cache\" =&gt; \"../cache\"\r\n        ]\r\n);\r\n</code></pre>\r\n\r\n<p>&nbsp;</p>\r\n<p><strong>Smarty</strong></p>\r\n\r\n<p>See <a href=\"https://smarty-php.github.io/smarty/4.x/getting-started/\" target=\"_blank\">Smarty installation</a> on how to install Smarty into your project/website.</p>\r\n\r\n<p>Now in your index.php define the Smarty template engine and include it in Dumb Dog.</p>\r\n\r\n<pre><code>// Include the autoload file.\r\nrequire_once \"../vendor/autoload.php\";\r\n// Define the Smarty template engine.\r\n$engine = new Smarty();\r\n// Set the Template folder.\r\n$engine-&gt;setTemplateDir(\'./website\');\r\n// Set the compile folder.\r\n$engine-&gt;setCompileDir(\'../cache\');\r\n// Set Cache folder if you like, speeds stuff up a lot.\r\n$engine-&gt;setCacheDir(\'../cache\');\r\n</code></pre>\r\n\r\n<p>&nbsp;</p>\r\n<p><strong>Volt</strong></p>\r\n\r\n<p>See <a href=\"https://docs.phalcon.io/4.0/en/volt\" target=\"_blank\">Phalcon installation</a> on how to install Volt into your project/website.</p>\r\n\r\n<p>Now in your index.php define the Volt template engine and include it in Dumb Dog.</p>\r\n<pre><code>$engine = new Phalcon&#92;Mvc&#92;View&#92;Engine&#92;Volt&#92;Compiler();\r\n$engine-&gt;setOptions(\r\n    [\r\n        \'path\' =&gt; \'../cache/\'\r\n    ]\r\n);\r\n</code></pre>\r\n\r\n<p>&nbsp;</p>\r\n<p><strong>Blade</strong></p>\r\n\r\n<p>See <a href=\"https://github.com/EFTEC/BladeOne\" target=\"_blank\">Blade installation</a> on how to install Blade into your project/website.</p>\r\n\r\n<p>Now in your index.php define the Blade template engine and include it in Dumb Dog.</p>\r\n<pre><code>$engine = new eftec&#92;bladeone&#92;BladeOne(\r\n    \'./website\',\r\n    \'../cache\',\r\n    eftec&#92;bladeone&#92;BladeOne::MODE_DEBUG\r\n);\r\n</code></pre>\r\n\r\n<p>&nbsp;</p>\r\n<p><strong>Plates</strong></p>\r\n\r\n<p>See <a href=\"https://platesphp.com/getting-started/installation/\" target=\"_blank\">Plates installation</a> on how to install Plates into your project/website.</p>\r\n\r\n<p>Now in your index.php define the Plates template engine and include it in Dumb Dog.</p>\r\n<pre><code>$engine = new League&#92;Plates&#92;Engine(\'./website\');\r\n</code></pre>\r\n\r\n<p>&nbsp;</p>\r\n<p><strong>Mustache</strong></p>\r\n\r\n<p>See <a href=\"https://github.com/bobthecow/mustache.php\" target=\"_blank\">Mustache installation</a> on how to install Mustache into your project/website.</p>\r\n\r\n<p>Now in your index.php define the Mustache template engine and include it in Dumb Dog.</p>\r\n<pre><code>$engine = new Mustache_Engine([\r\n    \'cache\' =&gt; \'../cache\',\r\n    \'loader\' =&gt; new Mustache_Loader_FilesystemLoader(\r\n        dirname(__FILE__) . \'/website\'\r\n    )\r\n]);\r\n</code></pre>','live','','','',NULL,'page',NULL,NULL,'',NULL,NULL,0,0,1,1,'2024-07-13 13:28:46','89c759f3-da4b-11ed-89f5-5254003f8571','2024-07-13 14:28:46','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('7675eb04-a7eb-4764-8f8a-544e687ad58a','5d6c5133-d9f7-11ed-89da-5254003f8571',NULL,'/appointment-with-mike-welsh','Appointment with Mike Welsh','','','','','live','','','',NULL,'appointment',NULL,NULL,'',NULL,NULL,0,0,0,0,'2024-02-25 19:25:54','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-14 14:39:51','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('76c4d628-6b0a-4c94-be3b-fb3060b14f18',NULL,NULL,NULL,'Love this company','','',NULL,'','live',NULL,NULL,NULL,NULL,'review',NULL,NULL,'',NULL,NULL,0,0,0,0,'2024-02-24 22:06:25','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-18 11:36:22','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('7746fe15-e517-4387-90b2-73a31a7019e1','5d6c5133-d9f7-11ed-89da-5254003f8571',NULL,'/test-blog-2','test blog 2','test blog 2',NULL,NULL,NULL,'live',NULL,NULL,NULL,NULL,'blog',NULL,NULL,NULL,NULL,NULL,0,0,0,0,'2025-08-15 08:14:34','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-15 08:22:04','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('77640251-342c-4fc9-a574-4ff81251e622','1af859c1-d967-11ed-8a12-5254003f8571','','/','home','Ello there!','Dumb dog','','<p><em><strong>The dumbest dog on the CMS block you\'ll ever see!</strong></em></p><p><strong>What is Dumb Dog?</strong></p><p>Dumb Dog is a CMS written in Zephir-lang with some JavaScript to run as a PHP module. It is self-contained, fast and compact.<br></p>','live','','','','header','page',NULL,NULL,'',NULL,NULL,0,0,1,1,'2024-07-13 12:13:24','77640251-342c-4fc9-a574-4ff81251e623','2024-07-13 13:13:24','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('7f1272c6-ae05-48e6-bced-1941565c7897','5d6c5133-d9f7-11ed-89da-5254003f8571',NULL,'/test-page-cat-2','test page cat 2','test page cat 2',NULL,NULL,NULL,'live',NULL,NULL,NULL,NULL,'page-category',NULL,NULL,NULL,NULL,NULL,0,0,0,0,'2025-08-15 08:38:54','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-15 08:40:27','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('81fd8977-ed95-4b8d-9922-1b12e33e4282',NULL,NULL,'https://linkedin.com','LinkedIn','','',NULL,'','offline',NULL,NULL,NULL,NULL,'social',NULL,NULL,'',NULL,NULL,0,0,0,1,'2024-02-24 22:43:51','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-24 22:53:05','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('845cd30f-41f1-46f0-9b7a-dfa5b095c42b',NULL,'412cc034-9a06-4b24-b0e2-1bbd79ff9d3a',NULL,'Menu test item2','Menu test item2',NULL,NULL,NULL,'live',NULL,NULL,NULL,NULL,'menu-item',NULL,NULL,NULL,NULL,NULL,0,0,0,1,'2025-08-17 20:31:44','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-18 07:33:29','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('8b0210d3-099c-4348-afae-1984e4e31537',NULL,'186aca40-c673-493a-9932-6b6d56396980','','template engines','Template engines','What kind of template engines can I use?',NULL,NULL,'live',NULL,NULL,NULL,NULL,'menu-item',NULL,NULL,NULL,NULL,NULL,0,4,0,1,'2024-07-05 15:44:39','89c759f3-da4b-11ed-89f5-5254003f8571','2024-07-11 18:58:20','89c759f3-da4b-11ed-89f5-5254003f8571','2024-07-11 18:58:20','89c759f3-da4b-11ed-89f5-5254003f8571'),
('8c18d19a-8dd9-4d85-8891-42bc66d42969','5d6c5133-d9f7-11ed-89da-5254003f8571',NULL,'/appointments/test2','test2','','','','','live','','','',NULL,'appointment',NULL,NULL,'',NULL,NULL,0,0,0,0,'2025-08-14 15:28:01','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-17 08:27:50','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('95f03986-6a67-46d4-88e2-6b75c0e594ab','5d6c5133-d9f7-11ed-89da-5254003f8571','','/theming','theming','Theming','','','','live','','','',NULL,'page',NULL,NULL,'',NULL,NULL,0,0,1,1,'2024-07-11 17:56:21','89c759f3-da4b-11ed-89f5-5254003f8571','2024-07-11 18:56:21','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('982d171d-39c8-4927-8de5-04f444259840',NULL,NULL,NULL,'Review test 2','Review test 2',NULL,NULL,NULL,'live',NULL,NULL,NULL,NULL,'review',NULL,NULL,'',NULL,NULL,0,0,0,0,'2025-08-18 12:00:00','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-19 07:11:49','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('a6b88e7a-de19-40ce-9ed7-d38c19017e4d',NULL,'','','footer','footer','',NULL,NULL,'live',NULL,NULL,NULL,NULL,'menu',NULL,NULL,'[{\"value\":\"footer\"}]',NULL,NULL,0,0,0,1,'2024-03-01 21:15:00','89c759f3-da4b-11ed-89f5-5254003f8571','2024-03-01 21:17:57','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('aa46fc42-9779-41b1-a832-5ad73dc93b8c','5d6c5133-d9f7-11ed-89da-5254003f8571','','/product-test-1','Product test 1','Product test 1','','','Product test','live','','','',NULL,'product',NULL,NULL,'',NULL,NULL,0,0,0,1,'2025-08-16 12:01:08','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-17 08:36:15','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('bf08256f-8df7-4131-ba63-3ad2acc0cb06',NULL,'186aca40-c673-493a-9932-6b6d56396980','','theming','Theming','How to change the look and feel Dumb Dog',NULL,NULL,'live',NULL,NULL,NULL,NULL,'menu-item',NULL,NULL,NULL,NULL,NULL,0,4,0,1,'2024-07-05 15:45:08','89c759f3-da4b-11ed-89f5-5254003f8571','2024-07-05 15:45:08','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('cffaf2eb-81de-4116-ad8b-3ff1db635787','5d6c5133-d9f7-11ed-89da-5254003f8571',NULL,'/test-blog-cat-2','test blog cat 2','test blog cat 2',NULL,NULL,NULL,'live',NULL,NULL,NULL,NULL,'blog-category',NULL,NULL,NULL,NULL,NULL,0,0,0,0,'2025-08-15 08:30:49','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-15 08:32:01','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('d0a0bc19-02a4-4fe0-bf80-26a56e3300a8',NULL,'a6b88e7a-de19-40ce-9ed7-d38c19017e4d','#contact-us','contact','Contact us','',NULL,NULL,'live',NULL,NULL,NULL,NULL,'menu-item',NULL,NULL,NULL,NULL,NULL,0,0,0,1,'2024-03-01 21:15:08','89c759f3-da4b-11ed-89f5-5254003f8571','2024-03-01 21:15:08','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('d8788655-a189-4a53-8cf7-b3f3a3d5c558',NULL,'186aca40-c673-493a-9932-6b6d56396980','','home','Home','Home Jeeves!',NULL,NULL,'live',NULL,NULL,NULL,NULL,'menu-item',NULL,NULL,NULL,NULL,NULL,0,0,0,1,'2024-07-05 15:18:34','89c759f3-da4b-11ed-89f5-5254003f8571','2024-07-05 15:18:34','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('dea6a3d9-833e-4f41-bbe1-ab4fb35ec2e3',NULL,'186aca40-c673-493a-9932-6b6d56396980','','help','Help','I need a little help',NULL,NULL,'live',NULL,NULL,NULL,NULL,'menu-item',NULL,NULL,NULL,NULL,NULL,0,1,0,1,'2024-03-01 21:15:52','89c759f3-da4b-11ed-89f5-5254003f8571','2024-03-01 21:15:52','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('e700753b-ddb5-11ed-89a6-5254003f8571','d7cdc951-ddb5-11ed-89a6-5254003f8571','','/sitemap','sitemap','Sitemap','','','','live','','','','','page',NULL,NULL,'',NULL,NULL,0,0,0,1,'2024-07-07 11:12:37','89c759f3-da4b-11ed-89f5-5254003f8571','2024-07-07 12:12:37','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),
('ea619c3e-23e7-4658-a9a7-47610ba83ec9','5d6c5133-d9f7-11ed-89da-5254003f8571',NULL,'/book-a-call','book a call','','','','','live','','','',NULL,'appointment',NULL,NULL,'',NULL,NULL,0,0,0,0,'2024-02-25 18:04:37','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-25 18:04:37','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('f253d02f-ddb5-11ed-89a6-5254003f8571','5d6c5133-d9f7-11ed-89da-5254003f8571','','/privacy','privacy','Privacy','','','<p>If you see a cookie being used, mainly cause you\'ve logged into the back end, it\'s purely for functional use.</p><p>I also collection anonymous stats on my visitors basically to count the number of visits, if its a BOT and what browser agent.<br></p>','live','','','','','page',NULL,NULL,'',NULL,NULL,0,0,1,1,'2024-07-13 12:59:23','89c759f3-da4b-11ed-89f5-5254003f8571','2024-07-13 13:59:23','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),
('fee34c33-2018-4c80-947f-6b6fe8882df6','5d6c5133-d9f7-11ed-89da-5254003f8571','','/test-product','test product','test product','','','','live','','','',NULL,'product',NULL,NULL,'',NULL,NULL,0,0,1,1,'2025-08-16 10:17:26','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-16 10:19:13','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('fefe2670-2700-4f56-a305-3fbea34cefd2',NULL,NULL,NULL,'Menu test','Menu test',NULL,NULL,NULL,'live',NULL,NULL,NULL,NULL,'menu',NULL,NULL,NULL,NULL,NULL,0,0,0,1,'2025-08-17 19:49:07','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-17 19:49:07','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL);
/*!40000 ALTER TABLE `content` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_stacks`
--

DROP TABLE IF EXISTS `content_stacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_stacks` (
  `id` varchar(36) NOT NULL,
  `content_id` varchar(36) DEFAULT NULL,
  `content_stack_id` varchar(36) DEFAULT NULL,
  `template_id` varchar(36) DEFAULT NULL,
  `sort` int(11) DEFAULT 0,
  `name` varchar(255) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `sub_title` varchar(255) DEFAULT NULL,
  `content` text DEFAULT NULL,
  `tags` varchar(100) DEFAULT NULL,
  `created_by` varchar(36) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `content_stacks_content_id_IDX` (`content_id`) USING BTREE,
  KEY `content_stacks_content_stack_id_IDX` (`content_stack_id`) USING BTREE,
  KEY `content_stacks_created_by_IDX` (`created_by`) USING BTREE,
  KEY `content_stacks_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `content_stacks_updated_by_IDX` (`updated_by`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_stacks`
--

LOCK TABLES `content_stacks` WRITE;
/*!40000 ALTER TABLE `content_stacks` DISABLE KEYS */;
INSERT INTO `content_stacks` VALUES
('37e917a0-abbd-4197-a6c6-d7f3cf78a1c1','50dbd1a9-b1c7-49c4-b7f2-34c9adea9270',NULL,'d7cdc951-ddb5-11ed-89a6-5254003f8572',0,'test stack','test stack','','<p>Testing the stack</p>','','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-15 09:29:00','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-18 07:32:43',NULL,NULL);
/*!40000 ALTER TABLE `content_stacks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `countries` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `code` varchar(5) NOT NULL,
  `status` varchar(10) DEFAULT 'live',
  `is_default` tinyint(1) DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` varchar(36) NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
  `updated_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_by` varchar(36) NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
  `deleted_by` varchar(36) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `countries`
--

LOCK TABLES `countries` WRITE;
/*!40000 ALTER TABLE `countries` DISABLE KEYS */;
INSERT INTO `countries` VALUES
('bff02ac0-1b7a-47d0-81a7-ac7113f30a4f','United Kingdom','UK','live',1,'2025-08-16 11:46:07','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-20 07:58:02','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL);
/*!40000 ALTER TABLE `countries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currencies`
--

DROP TABLE IF EXISTS `currencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `currencies` (
  `id` varchar(36) NOT NULL,
  `name` varchar(100) NOT NULL,
  `title` varchar(255) NOT NULL,
  `symbol` varchar(100) NOT NULL,
  `exchange_rate` float(10,5) NOT NULL,
  `exchange_rate_safety_buffer` float(10,2) DEFAULT 0.00,
  `locale_code` varchar(5) DEFAULT 'en_GB',
  `is_default` tinyint(1) DEFAULT 0,
  `status` varchar(10) NOT NULL DEFAULT 'live',
  `created_by` varchar(36) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `currencies_created_at_IDX` (`created_at`) USING BTREE,
  KEY `currencies_created_by_IDX` (`created_by`) USING BTREE,
  KEY `currencies_exchange_rate_IDX` (`exchange_rate`) USING BTREE,
  KEY `currencies_name_IDX` (`name`) USING BTREE,
  KEY `currencies_saftey_margin_IDX` (`exchange_rate_safety_buffer`) USING BTREE,
  KEY `currencies_status_IDX` (`status`) USING BTREE,
  KEY `currencies_symbol_IDX` (`symbol`) USING BTREE,
  KEY `currencies_updated_at_IDX` (`updated_at`) USING BTREE,
  KEY `currencies_updated_by_IDX` (`updated_by`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currencies`
--

LOCK TABLES `currencies` WRITE;
/*!40000 ALTER TABLE `currencies` DISABLE KEYS */;
INSERT INTO `currencies` VALUES
('18f0ded6-bb99-49c3-96f6-b74768eaaf6a','Sterling pounds','Sterling pounds','&pound;',1.00000,0.00,'1',1,'live','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-15 15:08:15','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-15 16:28:15',NULL,NULL);
/*!40000 ALTER TABLE `currencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` varchar(36) NOT NULL,
  `contact_id` varchar(36) NOT NULL,
  `address_id` varchar(36) DEFAULT NULL,
  `created_by` varchar(36) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_created_by_IDX` (`created_by`) USING BTREE,
  KEY `customer_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `customer_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `customers_contact_id_IDX` (`contact_id`) USING BTREE,
  KEY `customers_address_id_IDX` (`address_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `files`
--

DROP TABLE IF EXISTS `files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `files` (
  `id` varchar(36) NOT NULL,
  `resource` varchar(100) DEFAULT NULL,
  `resource_id` varchar(36) DEFAULT NULL,
  `mime_type` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `tags` text DEFAULT NULL,
  `sort` int(11) DEFAULT 0,
  `visible` tinyint(1) DEFAULT 1,
  `created_at` datetime NOT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `files_created_at_IDX` (`created_at`) USING BTREE,
  KEY `files_created_by_IDX` (`created_by`) USING BTREE,
  KEY `files_deleted_at_IDX` (`deleted_at`) USING BTREE,
  KEY `files_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `files_filename_IDX` (`filename`) USING BTREE,
  KEY `files_mime_type_IDX` (`mime_type`) USING BTREE,
  KEY `files_name_IDX` (`name`) USING BTREE,
  KEY `files_updated_at_IDX` (`updated_at`) USING BTREE,
  KEY `files_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `files_resource_id_IDX` (`resource_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `files`
--

LOCK TABLES `files` WRITE;
/*!40000 ALTER TABLE `files` DISABLE KEYS */;
INSERT INTO `files` VALUES
('0c795781-cc00-11ee-8cf3-5254007f44a4','image','cb9a9fbd-cbfe-11ee-8cf3-5254007f44a4','image/svg+xml','copy.svg','neKkgm0QersixPpf-copy.svg',NULL,'',0,1,'2024-02-15 12:45:07','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:45:07','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:45:07','89c759f3-da4b-11ed-89f5-5254003f8571'),
('0c7a7619-cc00-11ee-8cf3-5254007f44a4','image','cb9a9fbd-cbfe-11ee-8cf3-5254007f44a4','image/svg+xml','copy.svg','q1aPCwLzn9N8tAqL-copy.svg',NULL,'',0,1,'2024-02-15 12:45:07','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:45:07','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:45:07','89c759f3-da4b-11ed-89f5-5254003f8571'),
('0c7b1644-cc00-11ee-8cf3-5254007f44a4','image','cb9a9fbd-cbfe-11ee-8cf3-5254007f44a4','image/svg+xml','copy.svg','Pi8CqEFEwQ4Mlat2-copy.svg',NULL,'',0,1,'2024-02-15 12:45:07','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:45:07','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('1e46f167-cc00-11ee-8cf3-5254007f44a4','image','38f01f6c-cbff-11ee-8cf3-5254007f44a4','image/svg+xml','clipboard2-check.svg','O0pPBDrr6fMqeofG-clipboard2-check.svg',NULL,'',0,1,'2024-02-15 12:45:37','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:45:37','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:45:37','89c759f3-da4b-11ed-89f5-5254003f8571'),
('1e47bab8-cc00-11ee-8cf3-5254007f44a4','image','38f01f6c-cbff-11ee-8cf3-5254007f44a4','image/svg+xml','clipboard2-check.svg','mlrqEzpPpfdEE1u0-clipboard2-check.svg',NULL,'',0,1,'2024-02-15 12:45:37','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:45:37','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:45:37','89c759f3-da4b-11ed-89f5-5254003f8571'),
('1e48ce91-cc00-11ee-8cf3-5254007f44a4','image','38f01f6c-cbff-11ee-8cf3-5254007f44a4','image/svg+xml','clipboard2-check.svg','FECdjPkCsiJBqPn9-clipboard2-check.svg',NULL,'',0,1,'2024-02-15 12:45:37','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:45:37','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('344cfcbf-cb63-11ee-8d1f-5254007f44a4','banner-image','77640251-342c-4fc9-a574-4ff81251e622','image/webp','energy-city.png','Mq9Bxtwy5kv4vEHg-energy-city.webp',NULL,'',0,1,'2024-02-14 18:02:23','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 18:02:23','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('3765986e-cb7c-11ee-8d1f-5254007f44a4','image','ee80ddb8-cb73-11ee-8d1f-5254007f44a4','image/svg+xml','headset.svg','LwO98rokdjkeeIkH-headset.svg',NULL,'',0,1,'2024-02-14 21:01:26','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 21:01:26','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('3cef75ad-d367-11ee-8cad-5254007f44a4','image','81fd8977-ed95-4b8d-9922-1b12e33e4282','image/svg+xml','linkedin.svg','EYz0XvO8vNhn1Z9h-linkedin.svg',NULL,'',0,1,'2024-02-24 22:51:26','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-24 22:51:26','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-24 22:53:05','89c759f3-da4b-11ed-89f5-5254003f8571'),
('3fd3ddd7-cc00-11ee-8cf3-5254007f44a4','image','55b585cb-cbff-11ee-8cf3-5254007f44a4','image/svg+xml','emoji-sunglasses-fill.svg','PNgeM2QtKmtmO1EA-emoji-sunglasses-fill.svg',NULL,'',0,1,'2024-02-15 12:46:33','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:46:33','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:46:33','89c759f3-da4b-11ed-89f5-5254003f8571'),
('3fd488df-cc00-11ee-8cf3-5254007f44a4','image','55b585cb-cbff-11ee-8cf3-5254007f44a4','image/svg+xml','emoji-sunglasses-fill.svg','E6wtuetdeMz3j4sQ-emoji-sunglasses-fill.svg',NULL,'',0,1,'2024-02-15 12:46:33','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:46:33','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:46:33','89c759f3-da4b-11ed-89f5-5254003f8571'),
('3fd56d28-cc00-11ee-8cf3-5254007f44a4','image','55b585cb-cbff-11ee-8cf3-5254007f44a4','image/svg+xml','emoji-sunglasses-fill.svg','qO7RhG0Ed24cppH9-emoji-sunglasses-fill.svg',NULL,'',0,1,'2024-02-15 12:46:33','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:46:33','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('54464209-cb84-11ee-8d1f-5254007f44a4','image','11e4d3e7-cb84-11ee-8d1f-5254007f44a4','image/svg+xml','calendar2-heart-fill.svg','tRa44k3du7Nu9Nj5-calendar2-heart-fill.svg',NULL,'',0,1,'2024-02-14 21:59:30','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 21:59:30','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('77c3f926-d367-11ee-8cad-5254007f44a4','image','81fd8977-ed95-4b8d-9922-1b12e33e4282','image/svg+xml','linkedin.svg','BrYTdplwA65GJslX-linkedin.svg',NULL,'',0,1,'2024-02-24 22:53:05','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-24 22:53:05','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('7d4e86a6-cb8d-11ee-8d1f-5254007f44a4','image','51872a5d-cb8c-11ee-8d1f-5254007f44a4','image/svg+xml','emoji-laughing-fill.svg','ivtOQKKGR9fuqAz6-emoji-laughing-fill.svg',NULL,'',0,1,'2024-02-14 23:05:04','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 23:05:04','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 23:05:04','89c759f3-da4b-11ed-89f5-5254003f8571'),
('7d4fb8f3-cb8d-11ee-8d1f-5254007f44a4','image','692d5fc8-cb8c-11ee-8d1f-5254007f44a4','image/svg+xml','building-fill-check.svg','bPdHnNhioDkxNdGa-building-fill-check.svg',NULL,'',0,1,'2024-02-14 23:05:04','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 23:05:04','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 23:05:04','89c759f3-da4b-11ed-89f5-5254003f8571'),
('7d513009-cb8d-11ee-8d1f-5254007f44a4','image','51872a5d-cb8c-11ee-8d1f-5254007f44a4','image/svg+xml','emoji-laughing-fill.svg','5CRiw7jrmFBEN27w-emoji-laughing-fill.svg',NULL,'',0,1,'2024-02-14 23:05:04','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 23:05:04','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('7d51cfd0-cb8d-11ee-8d1f-5254007f44a4','image','692d5fc8-cb8c-11ee-8d1f-5254007f44a4','image/svg+xml','building-fill-check.svg','0DKxr4Qp6wisiH6c-building-fill-check.svg',NULL,'',0,1,'2024-02-14 23:05:04','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 23:05:04','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('87236da3-cb83-11ee-8d1f-5254007f44a4','image','0e5496a9-cb7b-11ee-8d1f-5254007f44a4','image/svg+xml','toggles.svg','qId401xiOf0CvggF-toggles.svg',NULL,'',0,1,'2024-02-14 21:53:46','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 21:53:46','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('a096c0bf-cdb0-11ee-8dc5-5254007f44a4','profile','89c759f3-da4b-11ed-89f5-5254003f8571','image/webp','young-crop.jpg','XB5UUQ8Va34vXS16-young-crop.webp',NULL,'',0,1,'2024-02-17 16:21:38','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-17 16:21:38','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('ac8d00c9-cbff-11ee-8cf3-5254007f44a4','image','9d79f4d7-cbfe-11ee-8cf3-5254007f44a4','image/webp','compare.png','F2CpGhhxpf9C7kme-compare.webp',NULL,'',0,1,'2024-02-15 12:42:26','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 12:42:26','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('b2da8146-cbf5-11ee-8cf3-5254007f44a4','image','faa0f7a3-0fcb-45b5-b54f-bd97aeefa89f','image/svg+xml','linkedin.svg','7DmnnPKil3FbcszP-linkedin.svg',NULL,'',0,1,'2024-02-15 11:31:02','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-15 11:31:02','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('ed7f74ed-cb8c-11ee-8d1f-5254007f44a4','image','2db1c4fb-cb8c-11ee-8d1f-5254007f44a4','image/svg+xml','fire.svg','ml2PQ0ko3xBBLeBR-fire.svg',NULL,'',0,1,'2024-02-14 23:01:03','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 23:01:03','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 23:01:03','89c759f3-da4b-11ed-89f5-5254003f8571'),
('ed8096cc-cb8c-11ee-8d1f-5254007f44a4','image','51872a5d-cb8c-11ee-8d1f-5254007f44a4','image/svg+xml','building-fill-check.svg','or3rcueftwn46MJd-building-fill-check.svg',NULL,'',0,1,'2024-02-14 23:01:03','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 23:01:03','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 23:05:04','89c759f3-da4b-11ed-89f5-5254003f8571'),
('ed81bc01-cb8c-11ee-8d1f-5254007f44a4','image','2db1c4fb-cb8c-11ee-8d1f-5254007f44a4','image/svg+xml','fire.svg','exx3apkwlnaDy6Bv-fire.svg',NULL,'',0,1,'2024-02-14 23:01:03','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 23:01:03','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
('ed82b8f1-cb8c-11ee-8d1f-5254007f44a4','image','51872a5d-cb8c-11ee-8d1f-5254007f44a4','image/svg+xml','building-fill-check.svg','7Qc2GvndewgP1Il0-building-fill-check.svg',NULL,'',0,1,'2024-02-14 23:01:03','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 23:01:03','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 23:05:04','89c759f3-da4b-11ed-89f5-5254003f8571'),
('ef88daab-cb83-11ee-8d1f-5254007f44a4','image','a53ea35e-cb83-11ee-8d1f-5254007f44a4','image/svg+xml','recycle.svg','tnnzOxC68Rvaqy9L-recycle.svg',NULL,'',0,1,'2024-02-14 21:56:41','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-14 21:56:41','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL);
/*!40000 ALTER TABLE `files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `groups` (
  `id` varchar(36) NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `tags` text DEFAULT NULL,
  `status` varchar(10) DEFAULT 'live',
  `created_by` varchar(36) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `groups_created_by_IDX` (`created_by`) USING BTREE,
  KEY `groups_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `groups_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `groups_slug_IDX` (`slug`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groups`
--

LOCK TABLES `groups` WRITE;
/*!40000 ALTER TABLE `groups` DISABLE KEYS */;
INSERT INTO `groups` VALUES
('89c759f3-da4b-11ed-89f5-5254003f8572','Custom','custom',NULL,'live','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-13 23:35:48','89c759f3-da4b-11ed-89f5-5254003f8571','2024-12-28 16:11:49',NULL,NULL),
/*!40000 ALTER TABLE `groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leads`
--

DROP TABLE IF EXISTS `leads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `leads` (
  `id` varchar(36) NOT NULL,
  `contact_id` varchar(36) NOT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `ranking` varchar(10) NOT NULL DEFAULT 'ok',
  `created_by` varchar(36) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `leads_contact_id_IDX` (`contact_id`) USING BTREE,
  KEY `leads_user_id_IDX` (`user_id`) USING BTREE,
  KEY `leads_created_by_IDX` (`created_by`) USING BTREE,
  KEY `leads_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `leads_deleted_by_IDX` (`deleted_by`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leads`
--

LOCK TABLES `leads` WRITE;
/*!40000 ALTER TABLE `leads` DISABLE KEYS */;
INSERT INTO `leads` VALUES
('45ab4b88-1780-48af-be8d-359820727508','45ab4b88-1780-48af-be8d-359820727508','','ok','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-19 13:13:16','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-20 07:14:16',NULL,NULL);
/*!40000 ALTER TABLE `leads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menus`
--

DROP TABLE IF EXISTS `menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `menus` (
  `id` varchar(36) NOT NULL,
  `content_id` varchar(36) DEFAULT NULL,
  `link_to` varchar(36) DEFAULT NULL,
  `new_window` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `content_stacks_content_id_IDX` (`content_id`) USING BTREE,
  KEY `menus_link_to_IDX` (`link_to`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menus`
--

LOCK TABLES `menus` WRITE;
/*!40000 ALTER TABLE `menus` DISABLE KEYS */;
INSERT INTO `menus` VALUES
('1b4e6dcd-3add-11ef-86f5-5254004829bf','8b0210d3-099c-4348-afae-1984e4e31537','',0),
('238eb00c-3ada-11ef-86f5-5254004829bf','25b614da-932a-45d7-bc08-30d25eb04e5c','74cfe3e9-856c-4cda-ab3f-4505ce5d97cb',0),
('2c9b04ba-3add-11ef-86f5-5254004829bf','bf08256f-8df7-4131-ba63-3ad2acc0cb06','95f03986-6a67-46d4-88e2-6b75c0e594ab',0),
('48dc9ab9-7b9a-11f0-8652-5254004829bf',NULL,NULL,0),
('53e2357c-7b9b-11f0-8652-5254004829bf','412cc034-9a06-4b24-b0e2-1bbd79ff9d3a',NULL,0),
('767fddce-3ad9-11ef-86f5-5254004829bf','d8788655-a189-4a53-8cf7-b3f3a3d5c558','77640251-342c-4fc9-a574-4ff81251e622',0),
('b8fd546a-3ad9-11ef-86f5-5254004829bf','707866dc-7028-4896-bf93-8d2037d664ee','1221eecd-e897-4ead-970a-63499afe0cda',0),
('bce196c6-d810-11ee-8e1a-5254007f44a4','186aca40-c673-493a-9932-6b6d56396980','',0),
('c39e18e1-d810-11ee-8e1a-5254007f44a4','a6b88e7a-de19-40ce-9ed7-d38c19017e4d','',0),
('c84b755a-d810-11ee-8e1a-5254007f44a4','d0a0bc19-02a4-4fe0-bf80-26a56e3300a8','',0),
('cf1903be-7ba0-11f0-8652-5254004829bf','845cd30f-41f1-46f0-9b7a-dfa5b095c42b',NULL,0),
('e26fc1ac-d810-11ee-8e1a-5254007f44a4','dea6a3d9-833e-4f41-bbe1-ab4fb35ec2e3','403f0523-2830-4d70-97d4-00910abb3209',0),
('fb353be1-7b9f-11f0-8652-5254004829bf','5e8807c3-8947-4852-9e95-4b78e9caa06c',NULL,0);
/*!40000 ALTER TABLE `menus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` varchar(36) NOT NULL,
  `contact_id` varchar(36) NOT NULL,
  `parent_id` varchar(36) DEFAULT NULL,
  `lead_id` varchar(36) DEFAULT NULL,
  `subject` varchar(255) NOT NULL,
  `message` text DEFAULT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'unread',
  `tags` text DEFAULT NULL,
  `type` varchar(10) DEFAULT 'inbox',
  `created_at` datetime NOT NULL,
  `created_by` varchar(36) DEFAULT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `messages_created_at_IDX` (`created_at`) USING BTREE,
  KEY `messages_created_by_IDX` (`created_by`) USING BTREE,
  KEY `messages_deleted_at_IDX` (`deleted_at`) USING BTREE,
  KEY `messages_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `messages_parent_id_IDX` (`parent_id`) USING BTREE,
  KEY `messages_status_IDX` (`status`) USING BTREE,
  KEY `messages_subject_IDX` (`subject`) USING BTREE,
  KEY `messages_updated_at_IDX` (`updated_at`) USING BTREE,
  KEY `messages_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `messages_contact_id_IDX` (`contact_id`) USING BTREE,
  KEY `messages_lead_id_IDX` (`lead_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES
('9578c588-ce45-11ee-8d4d-5254007f44a4','bb20212a-b47b-4dc3-b719-b4ce58a7edec',NULL,'8881d16d-6622-4d4d-85f8-4b87d4a6869c','lajDA6gL3QFy2/SHGQFtk24dZRu3YrRxBxMaiJHRRzM=::852187c1adaf87b56d68ec40ab3dd555','Jh6DN6X8GfbCCUjawL/7Xg==::9a1c628f7fc2ea3170cd9df6b3a7053e','unread',NULL,'inbox','2024-02-18 10:07:55','00000000-0000-0000-0000-000000000000','2024-12-28 14:38:47','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL);
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES
(1,'2023-06-19-1004-create-migrations.sql','2023-07-01 13:15:54'),
(2,'2023-06-19-1128-update-tags.sql','2023-07-01 13:16:37'),
(3,'2023-07-03-1049-create-order-addresses.sql','2023-07-20 11:16:33'),
(4,'2023-07-03-1152-create-order-addresses-email.sql','2023-07-20 11:16:33'),
(5,'2023-07-03-1430-create-order-addresses-email-not-null.sql','2023-07-20 11:16:33'),
(6,'2023-07-20-1052-drop-orders.sql','2023-07-20 11:16:33'),
(7,'2023-07-20-1053-drop-order-addresses.sql','2023-07-20 11:16:33'),
(8,'2023-07-20-1054-drop-order-products.sql','2023-07-20 11:16:33'),
(9,'2023-07-20-1111-alter-pages-remove-products.sql','2023-07-20 11:16:33'),
(10,'2024-12-26-1432-alter-themes-default.sql','2024-12-26 18:12:51'),
(11,'2024-12-28-1440-alter-groups-add-status.sql','2024-12-28 14:41:45');
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notes`
--

DROP TABLE IF EXISTS `notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `notes` (
  `id` varchar(36) NOT NULL,
  `resource_id` varchar(36) DEFAULT NULL,
  `content` text NOT NULL,
  `created_by` varchar(36) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notes_created_by_IDX` (`created_by`) USING BTREE,
  KEY `notes_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `notes_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `notes_resource_id_IDX` (`resource_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notes`
--

LOCK TABLES `notes` WRITE;
/*!40000 ALTER TABLE `notes` DISABLE KEYS */;
INSERT INTO `notes` VALUES
('72b637cc-ceae-11ee-8c73-5254007f44a4','8881d16d-6622-4d4d-85f8-4b87d4a6869c','m4gte4dOOt1/IDOe8d89GA==::5f97e25a722e4f73f83d41de0879f4f5','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-18 22:38:33','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-18 22:38:33','89c759f3-da4b-11ed-89f5-5254003f8571','2024-02-19 21:03:34');
/*!40000 ALTER TABLE `notes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `old_urls`
--

DROP TABLE IF EXISTS `old_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `old_urls` (
  `id` varchar(36) NOT NULL,
  `content_id` varchar(36) NOT NULL,
  `url` varchar(255) NOT NULL,
  `created_by` varchar(36) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `old_urls_content_id_IDX` (`content_id`) USING BTREE,
  KEY `old_urls_created_by_IDX` (`created_by`) USING BTREE,
  KEY `old_urls_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `old_urls_old_url_IDX` (`url`) USING BTREE,
  KEY `old_urls_updated_by_IDX` (`updated_by`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `old_urls`
--

LOCK TABLES `old_urls` WRITE;
/*!40000 ALTER TABLE `old_urls` DISABLE KEYS */;
/*!40000 ALTER TABLE `old_urls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_addresses`
--

DROP TABLE IF EXISTS `order_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_addresses` (
  `id` varchar(36) NOT NULL,
  `order_id` varchar(36) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `address_line_1` varchar(255) NOT NULL,
  `address_line_2` varchar(255) DEFAULT NULL,
  `city` varchar(255) NOT NULL,
  `county` varchar(255) NOT NULL,
  `postcode` varchar(255) NOT NULL,
  `country` varchar(255) NOT NULL,
  `type` varchar(10) NOT NULL DEFAULT 'billing',
  `created_at` datetime NOT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_addresses_UN` (`order_id`,`type`),
  KEY `order_addresses_address_line_1_IDX` (`address_line_1`) USING BTREE,
  KEY `order_addresses_address_line_2_IDX` (`address_line_2`) USING BTREE,
  KEY `order_addresses_city_IDX` (`city`) USING BTREE,
  KEY `order_addresses_country_IDX` (`country`) USING BTREE,
  KEY `order_addresses_county_IDX` (`county`) USING BTREE,
  KEY `order_addresses_created_at_IDX` (`created_at`) USING BTREE,
  KEY `order_addresses_created_by_IDX` (`created_by`) USING BTREE,
  KEY `order_addresses_deleted_at_IDX` (`deleted_at`) USING BTREE,
  KEY `order_addresses_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `order_addresses_email_IDX` (`email`) USING BTREE,
  KEY `order_addresses_last_name_IDX` (`last_name`) USING BTREE,
  KEY `order_addresses_name_IDX` (`first_name`) USING BTREE,
  KEY `order_addresses_order_id_IDX` (`order_id`) USING BTREE,
  KEY `order_addresses_postcode_IDX` (`postcode`) USING BTREE,
  KEY `order_addresses_type_IDX` (`type`) USING BTREE,
  KEY `order_addresses_updated_at_IDX` (`updated_at`) USING BTREE,
  KEY `order_addresses_updated_by_IDX` (`updated_by`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_addresses`
--

LOCK TABLES `order_addresses` WRITE;
/*!40000 ALTER TABLE `order_addresses` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_products`
--

DROP TABLE IF EXISTS `order_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_products` (
  `id` varchar(36) NOT NULL,
  `order_id` varchar(36) NOT NULL,
  `product_id` varchar(36) NOT NULL,
  `currency_id` varchar(36) NOT NULL,
  `tax_id` varchar(36) DEFAULT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `price` float NOT NULL DEFAULT 0,
  `sub_total` float(10,2) NOT NULL DEFAULT 0.00,
  `sub_total_tax` float(10,2) NOT NULL DEFAULT 0.00,
  `total` float(10,2) NOT NULL DEFAULT 0.00,
  `created_at` datetime NOT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_products_created_at_IDX` (`created_at`) USING BTREE,
  KEY `order_products_created_by_IDX` (`created_by`) USING BTREE,
  KEY `order_products_currency_id_IDX` (`currency_id`) USING BTREE,
  KEY `order_products_deleted_at_IDX` (`deleted_at`) USING BTREE,
  KEY `order_products_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `order_products_order_id_IDX` (`order_id`) USING BTREE,
  KEY `order_products_price_IDX` (`price`) USING BTREE,
  KEY `order_products_product_id_IDX` (`product_id`) USING BTREE,
  KEY `order_products_quantity_IDX` (`quantity`) USING BTREE,
  KEY `order_products_sub_total_IDX` (`sub_total`) USING BTREE,
  KEY `order_products_sub_total_tax_IDX` (`sub_total_tax`) USING BTREE,
  KEY `order_products_tax_id_IDX` (`tax_id`) USING BTREE,
  KEY `order_products_total_IDX` (`total`) USING BTREE,
  KEY `order_products_updated_at_IDX` (`updated_at`) USING BTREE,
  KEY `order_products_updated_by_IDX` (`updated_by`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_products`
--

LOCK TABLES `order_products` WRITE;
/*!40000 ALTER TABLE `order_products` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` varchar(36) NOT NULL,
  `customer_id` varchar(36) DEFAULT NULL,
  `currency_id` varchar(36) NOT NULL,
  `tax_id` varchar(36) DEFAULT NULL,
  `payment_gateway_id` varchar(36) DEFAULT NULL,
  `order_number` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `sub_total` float(10,2) NOT NULL DEFAULT 0.00,
  `sub_total_tax` float(10,2) NOT NULL DEFAULT 0.00,
  `total` float(10,2) NOT NULL DEFAULT 0.00,
  `status` varchar(20) NOT NULL DEFAULT 'basket',
  `payment_id` varchar(255) DEFAULT NULL,
  `payment_type` varchar(50) DEFAULT NULL,
  `payment_at` datetime DEFAULT NULL,
  `saved_for_later` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `orders_UN` (`saved_for_later`),
  KEY `orders_created_at_IDX` (`created_at`) USING BTREE,
  KEY `orders_created_by_IDX` (`created_by`) USING BTREE,
  KEY `orders_currency_id_IDX` (`currency_id`) USING BTREE,
  KEY `orders_deleted_at_IDX` (`deleted_at`) USING BTREE,
  KEY `orders_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `orders_order_number_IDX` (`order_number`) USING BTREE,
  KEY `orders_payment_at_IDX` (`payment_at`) USING BTREE,
  KEY `orders_payment_gateway_id_IDX` (`payment_gateway_id`) USING BTREE,
  KEY `orders_payment_id_IDX` (`payment_id`) USING BTREE,
  KEY `orders_payment_type_IDX` (`payment_type`) USING BTREE,
  KEY `orders_quantity_IDX` (`quantity`) USING BTREE,
  KEY `orders_saved_for_later_IDX` (`saved_for_later`) USING BTREE,
  KEY `orders_status_IDX` (`status`) USING BTREE,
  KEY `orders_sub_total_IDX` (`sub_total`) USING BTREE,
  KEY `orders_sub_total_tax_IDX` (`sub_total_tax`) USING BTREE,
  KEY `orders_tax_id_IDX` (`tax_id`) USING BTREE,
  KEY `orders_total_IDX` (`total`) USING BTREE,
  KEY `orders_updated_at_IDX` (`updated_at`) USING BTREE,
  KEY `orders_updated_by_IDX` (`updated_by`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_gateways`
--

DROP TABLE IF EXISTS `payment_gateways`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_gateways` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `type` varchar(20) NOT NULL,
  `description` varchar(255) NOT NULL,
  `is_default` tinyint(1) DEFAULT 0,
  `public_api_key` text DEFAULT NULL,
  `private_api_key` text DEFAULT NULL,
  `tags` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'live',
  `created_at` datetime NOT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `payment_gateways_created_by_IDX` (`created_by`) USING BTREE,
  KEY `payment_gateways_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `payment_gateways_is_default_IDX` (`is_default`) USING BTREE,
  KEY `payment_gateways_status_IDX` (`status`) USING BTREE,
  KEY `payment_gateways_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `phoenix_payment_gateways_slug_IDX` (`type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_gateways`
--

LOCK TABLES `payment_gateways` WRITE;
/*!40000 ALTER TABLE `payment_gateways` DISABLE KEYS */;
INSERT INTO `payment_gateways` VALUES
('d6c2f9f0-9ab5-449c-a890-016ad207424c','Stripe','Stripe','stripe','Stripe payment gateway',1,'','',NULL,'live','2025-08-19 07:49:18','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-19 09:13:52','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL);
/*!40000 ALTER TABLE `payment_gateways` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_prices`
--

DROP TABLE IF EXISTS `product_prices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_prices` (
  `id` varchar(36) NOT NULL,
  `product_id` varchar(36) NOT NULL,
  `currency_id` varchar(36) DEFAULT NULL,
  `tax_id` varchar(36) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `price` float(10,2) NOT NULL DEFAULT 1.00,
  `offer_price` float(10,2) DEFAULT 0.00,
  `status` varchar(10) NOT NULL DEFAULT 'live',
  `created_by` varchar(36) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_prices_currency_id_IDX` (`currency_id`) USING BTREE,
  KEY `product_prices_product_id_IDX` (`product_id`) USING BTREE,
  KEY `product_prices_tax_id_IDX` (`tax_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_prices`
--

LOCK TABLES `product_prices` WRITE;
/*!40000 ALTER TABLE `product_prices` DISABLE KEYS */;
INSERT INTO `product_prices` VALUES
('13049ee3-7a82-11f0-8652-5254004829bf','e888d00a-b1a0-47f0-9745-d7f99f2f8bf9',NULL,NULL,'Price2',100.00,0.00,'live','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-16 10:19:13','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-16 10:19:13',NULL,NULL),
('4fd394ef-7a90-11f0-8652-5254004829bf','ef825ab5-b3c6-4f2f-ab60-2d0f2de011e1','18f0ded6-bb99-49c3-96f6-b74768eaaf6a','','Standard price',100.00,0.00,'live','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-16 12:01:08','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-17 08:36:15',NULL,NULL),
('d0007f78-7a8a-11f0-8652-5254004829bf','aeae2942-6a51-488d-ac1a-21f33cb3791b','18f0ded6-bb99-49c3-96f6-b74768eaaf6a','','Standard price',100.00,0.00,'live','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-16 11:21:46','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-16 11:21:46',NULL,NULL),
('d39df0cf-7a81-11f0-8652-5254004829bf','e888d00a-b1a0-47f0-9745-d7f99f2f8bf9','18f0ded6-bb99-49c3-96f6-b74768eaaf6a','','Standard price',100.00,0.00,'live','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-16 10:17:26','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-16 10:17:26',NULL,NULL);
/*!40000 ALTER TABLE `product_prices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_shipping`
--

DROP TABLE IF EXISTS `product_shipping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_shipping` (
  `id` varchar(36) NOT NULL,
  `product_id` varchar(36) NOT NULL,
  `country_id` varchar(36) DEFAULT NULL,
  `currency_id` varchar(36) DEFAULT NULL,
  `tax_id` varchar(36) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `price` float(10,2) NOT NULL DEFAULT 1.00,
  `status` varchar(10) DEFAULT 'live',
  `created_by` varchar(36) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_prices_currency_id_IDX` (`country_id`) USING BTREE,
  KEY `product_prices_product_id_IDX` (`product_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_shipping`
--

LOCK TABLES `product_shipping` WRITE;
/*!40000 ALTER TABLE `product_shipping` DISABLE KEYS */;
INSERT INTO `product_shipping` VALUES
('4fd4d9fc-7a90-11f0-8652-5254004829bf','ef825ab5-b3c6-4f2f-ab60-2d0f2de011e1','bff02ac0-1b7a-47d0-81a7-ac7113f30a4f','18f0ded6-bb99-49c3-96f6-b74768eaaf6a','','Standard shipping',10.99,'live','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-16 12:01:08','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-17 08:36:15',NULL,NULL),
('d000aba0-7a8a-11f0-8652-5254004829bf','aeae2942-6a51-488d-ac1a-21f33cb3791b','','18f0ded6-bb99-49c3-96f6-b74768eaaf6a','','DPD Shipping',10.99,'live','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-16 11:21:46','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-16 11:21:46',NULL,NULL);
/*!40000 ALTER TABLE `product_shipping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` varchar(36) NOT NULL,
  `content_id` varchar(36) NOT NULL,
  `code` varchar(255) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 1,
  `on_offer` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES
('aeae2942-6a51-488d-ac1a-21f33cb3791b','050f2c37-ccda-4d3c-b085-fabba38006c9','test product 3',1,0),
('ce6d2eb0-9520-4ff2-b9e1-e3af9da65e39','70193ff8-f40b-45e5-be48-be24702ef3e3','',0,0),
('e888d00a-b1a0-47f0-9745-d7f99f2f8bf9','fee34c33-2018-4c80-947f-6b6fe8882df6','test product',12,NULL),
('ef825ab5-b3c6-4f2f-ab60-2d0f2de011e1','aa46fc42-9779-41b1-a832-5ad73dc93b8c','product-test-1',100,1);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `id` varchar(36) NOT NULL,
  `content_id` varchar(36) NOT NULL,
  `score` int(11) NOT NULL DEFAULT 5,
  `author` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reviews_content_id_IDX` (`content_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
INSERT INTO `reviews` VALUES
('4634d328-7c22-11f0-8652-5254004829bf','93bb6b3e-816e-4138-a2bd-42fc98f1bf0f',1,'Mike'),
('7c8e141b-7c22-11f0-8652-5254004829bf','982d171d-39c8-4927-8de5-04f444259840',3,'Mike'),
('f346fc35-d360-11ee-8cad-5254007f44a4','76c4d628-6b0a-4c94-be3b-fb3060b14f18',4,'');
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `name` varchar(255) NOT NULL,
  `domain` varchar(255) NOT NULL,
  `theme_id` varchar(36) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'online',
  `meta_description` text DEFAULT NULL,
  `meta_keywords` varchar(255) DEFAULT NULL,
  `meta_author` varchar(255) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `phone` varchar(100) DEFAULT NULL,
  `robots_txt` text DEFAULT NULL,
  `offline_title` varchar(255) DEFAULT NULL,
  `offline_content` text DEFAULT NULL,
  `humans_txt` text DEFAULT NULL,
  `address` tinytext DEFAULT NULL,
  `last_update` datetime DEFAULT NULL,
  PRIMARY KEY (`name`),
  KEY `settings_name_IDX` (`name`) USING BTREE,
  KEY `settings_theme_id_IDX` (`theme_id`) USING BTREE,
  KEY `settings_status_IDX` (`status`) USING BTREE,
  KEY `settings_meta_keywords_IDX` (`meta_keywords`) USING BTREE,
  KEY `settings_meta_author_IDX` (`meta_author`) USING BTREE,
  KEY `settings_contact_email_IDX` (`contact_email`) USING BTREE,
  KEY `settings_robots_txt_IDX` (`robots_txt`(768)) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES
('Dumb Dog','https://dd.kytschi.com','b2d86900-d982-11ed-8a12-5254003f8571','online','A lightweight CMS written in Zephir to be run as a PHP module.','zephir, php module, cms, lightweight','Mike Welsh','hello@kytschi.com','+44 0123456','User-agent: *\r\nDisallow:','','',NULL,NULL,'2025-08-20 07:55:21');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stats`
--

DROP TABLE IF EXISTS `stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stats` (
  `id` varchar(36) NOT NULL,
  `page_id` varchar(36) NOT NULL,
  `visitor` varchar(100) NOT NULL,
  `referer` varchar(255) DEFAULT NULL,
  `bot` varchar(255) DEFAULT NULL,
  `agent` tinytext DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `stats_bot_IDX` (`bot`) USING BTREE,
  KEY `stats_created_at_IDX` (`created_at`) USING BTREE,
  KEY `stats_referer_IDX` (`referer`) USING BTREE,
  KEY `stats_resource_id_IDX` (`page_id`) USING BTREE,
  KEY `stats_visitor_IDX` (`visitor`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `taxes`
--

DROP TABLE IF EXISTS `taxes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `taxes` (
  `id` varchar(36) NOT NULL,
  `name` varchar(100) NOT NULL,
  `title` varchar(255) NOT NULL,
  `tax_rate` float(10,5) NOT NULL,
  `tax_rate_type` varchar(10) NOT NULL DEFAULT 'percentage',
  `is_default` tinyint(1) DEFAULT 0,
  `status` varchar(10) NOT NULL DEFAULT 'live',
  `created_by` varchar(36) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `currencies_created_at_IDX` (`created_at`) USING BTREE,
  KEY `currencies_created_by_IDX` (`created_by`) USING BTREE,
  KEY `currencies_exchange_rate_IDX` (`tax_rate`) USING BTREE,
  KEY `currencies_name_IDX` (`name`) USING BTREE,
  KEY `currencies_status_IDX` (`status`) USING BTREE,
  KEY `currencies_updated_at_IDX` (`updated_at`) USING BTREE,
  KEY `currencies_updated_by_IDX` (`updated_by`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxes`
--

LOCK TABLES `taxes` WRITE;
/*!40000 ALTER TABLE `taxes` DISABLE KEYS */;
INSERT INTO `taxes` VALUES
('7cf6c338-6202-402e-8222-db2736e18406','VAT','Value added tax',20.00000,'percentage',1,'live','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-17 09:01:10','89c759f3-da4b-11ed-89f5-5254003f8571','2025-08-17 11:25:34',NULL,NULL);
/*!40000 ALTER TABLE `taxes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `templates`
--

DROP TABLE IF EXISTS `templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `templates` (
  `id` varchar(36) NOT NULL,
  `type` varchar(100) DEFAULT 'page',
  `name` varchar(255) NOT NULL,
  `file` varchar(255) NOT NULL,
  `is_default` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `templates_created_at_IDX` (`created_at`) USING BTREE,
  KEY `templates_created_by_IDX` (`created_by`) USING BTREE,
  KEY `templates_default_IDX` (`is_default`) USING BTREE,
  KEY `templates_deleted_at_IDX` (`deleted_at`) USING BTREE,
  KEY `templates_deleted_by_IDX` (`deleted_by`) USING BTREE,
  KEY `templates_id_IDX` (`id`) USING BTREE,
  KEY `templates_name_IDX` (`name`) USING BTREE,
  KEY `templates_updated_at_IDX` (`updated_at`) USING BTREE,
  KEY `templates_updated_by_IDX` (`updated_by`) USING BTREE,
  KEY `templates_file_IDX` (`file`) USING BTREE,
  KEY `templates_type_IDX` (`type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `templates`
--

LOCK TABLES `templates` WRITE;
/*!40000 ALTER TABLE `templates` DISABLE KEYS */;
INSERT INTO `templates` VALUES
('1af859c1-d967-11ed-8a12-5254003f8571','page','homepage','home.php',0,'2023-04-12 20:20:38','00000000-0000-0000-0000-000000000000','2023-04-13 13:15:37','00000000-0000-0000-0000-000000000000',NULL,NULL),
('2c040918-e2a4-11ed-8a58-5254003f8571','page','twig page','twig/page.html',0,'2023-04-24 14:30:26','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-24 14:39:21','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),
('5d6c5133-d9f7-11ed-89da-5254003f8571','page','page','page.php',1,'2023-04-13 13:33:17','00000000-0000-0000-0000-000000000000','2023-04-17 12:42:03','00000000-0000-0000-0000-000000000000',NULL,NULL),
('d7cdc951-ddb5-11ed-89a6-5254003f8571','page','sitemap','sitemap.php',0,'2023-04-18 07:54:19','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 07:54:19','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),
('d7cdc951-ddb5-11ed-89a6-5254003f8572','content-stack','four square with text','stacks/four_square_text.php',0,'2023-04-18 07:54:19','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 07:54:19','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),
('d7cdc951-ddb5-11ed-89a6-5254003f8573','content-stack','horizontal column','stacks/horiz_column.php',0,'2023-04-18 07:54:19','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 07:54:19','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),
('d7cdc951-ddb5-11ed-89a6-5254003f8574','content-stack','image box with text','stacks/image_box_text.php',0,'2023-04-18 07:54:19','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 07:54:19','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,'');
/*!40000 ALTER TABLE `templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `themes`
--

DROP TABLE IF EXISTS `themes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `themes` (
  `id` varchar(36) NOT NULL,
  `is_default` tinyint(1) DEFAULT 0,
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
  KEY `themes_default_IDX` (`is_default`) USING BTREE,
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
-- Dumping data for table `themes`
--

LOCK TABLES `themes` WRITE;
/*!40000 ALTER TABLE `themes` DISABLE KEYS */;
INSERT INTO `themes` VALUES
('b2d86900-d982-11ed-8a12-5254003f8571',1,'default','default','active',NULL,NULL,0,'2023-04-12 23:38:09','00000000-0000-0000-0000-000000000000','2024-12-26 14:57:13','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),
/*!40000 ALTER TABLE `themes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` varchar(36) NOT NULL,
  `group_id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `nickname` varchar(255) DEFAULT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'active',
  `file` varchar(255) DEFAULT NULL,
  `tags` text DEFAULT NULL,
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
INSERT INTO `users` VALUES
('89c759f3-da4b-11ed-89f5-5254003f8571','00000000-0000-0000-0000-000000000001','dumbdog','$2y$10$hv7daGztxRPzlN71oHyF8OntAtchU6p/lp8tpV6qTQSl1339QO4nC','Doggie','active',NULL,NULL,'2023-04-13 23:35:48','00000000-0000-0000-0000-000000000000','2025-08-19 13:16:58','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'dumb_dog'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-08-20  8:01:56
