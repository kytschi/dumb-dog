-- MariaDB dump 10.19  Distrib 10.5.18-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 127.0.0.1    Database: dumb_dog
-- ------------------------------------------------------
-- Server version	10.5.19-MariaDB-0+deb11u2

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
-- Table structure for table `files`
--

DROP TABLE IF EXISTS `files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `files` (
  `id` varchar(36) NOT NULL,
  `mime_type` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `filename` varchar(255) DEFAULT NULL,
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
  KEY `files_updated_by_IDX` (`updated_by`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `files`
--

LOCK TABLES `files` WRITE;
/*!40000 ALTER TABLE `files` DISABLE KEYS */;
INSERT INTO `files` VALUES ('18df064f-de00-11ed-894b-5254003f8571','image/jpeg','templates','BCl0zCjdCDBIsPfE-templates.jpg','2023-04-18 16:45:51','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 16:45:51','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),('1dd04554-de00-11ed-894b-5254003f8571','image/jpeg','themes','x0hn3LFeonn5kfI8-themes.jpg','2023-04-18 16:45:59','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 16:45:59','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),('2266f0e4-de00-11ed-894b-5254003f8571','image/jpeg','users','zJKMPofv7BQKbyfr-users.jpg','2023-04-18 16:46:07','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 16:46:07','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),('28e540da-de00-11ed-894b-5254003f8571','image/jpeg','settings','Czy8zyzRpLH0f1u7-settings.jpg','2023-04-18 16:46:18','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 16:46:18','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),('348ae9b2-ddda-11ed-89a6-5254003f8571','image/jpeg','quick menu screen','pz3hJc9bzway9LFr-quick_menu.jpg','2023-04-18 12:14:36','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 12:14:36','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),('454376c7-de00-11ed-894b-5254003f8571','image/jpeg','files','rF5JHzDmOdhbkFH5-files.jpg','2023-04-18 16:47:06','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 16:47:06','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),('d4461e51-ddd6-11ed-89a6-5254003f8571','image/jpeg','login screen','67suR5fdAMwvtOAz-login.jpg','2023-04-18 11:50:26','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 11:50:26','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),('f5550f51-ddfe-11ed-894b-5254003f8571','image/jpeg','pages','agouNu5Pgff7FFAG-pages.jpg','2023-04-18 16:37:42','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 16:37:42','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),('fcc391f8-ddfe-11ed-894b-5254003f8571','image/jpeg','edit the page','OcsrPBIEJJs2ADme-edit-page.jpg','2023-04-18 16:37:55','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 16:37:55','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,'');
/*!40000 ALTER TABLE `files` ENABLE KEYS */;
UNLOCK TABLES;

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
  `menu_item` varchar(10) DEFAULT NULL,
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
-- Dumping data for table `pages`
--

LOCK TABLES `pages` WRITE;
/*!40000 ALTER TABLE `pages` DISABLE KEYS */;
INSERT INTO `pages` VALUES ('0e0817b7-ddbe-11ed-89a6-5254003f8571','5d6c5133-d9f7-11ed-89da-5254003f8571','/help','help','<h3>Login</h3>\r\n<p>To login to <span class=\"highlight\">Dumb Dog</span> simply add <span class=\"highlight\">/dumb-dog</span> to the URL of where the <span class=\"highlight\">Dumb Dog</span> is hosted. For example https://dumb-dog.kytschi.com/dumb-dog<br></p>\r\n<p>The default logins are username: <span class=\"highlight\">dumbdog</span> and password: <span class=\"highlight\">woofwoof</span></p>\r\n<p><img src=\"/website/files/67suR5fdAMwvtOAz-login.jpg\" alt=\"login screen\"></p>\r\n<p><strong>DO NOT FORGET TO CREATE A NEW USER AND DELETE THE DEFAULT ONE OR CHANGE ITS PASSWORD!</strong></p>\r\n<h3>Navigation</h3>\r\n<p>To navigate around <span class=\"highlight\">Dumb Dog</span> you click on the <span class=\"highlight\">quick menu</span> in the top right of the screen.</p>\r\n<p><img src=\"/website/files/pz3hJc9bzway9LFr-quick_menu.jpg\" alt=\"quick menu\"></p>\r\n<h3>Templates</h3>\r\n<p>\r\nCurrently you can not upload templates via <span class=\"highlight\">Dumb Dog</span> (that might change but my fears of this are over the security) so have to upload them by hand. You place your templates in the <span class=\"hightlight\">public/website</span> and then in <span class=\"highlight\">Dumb Dog</span> you create a template entry.\r\n</p>\r\n<p>That entry simply holds a name so you known what the template is and the filename with its extension.</p>\r\n<p>You can include folder names in the filename.</p>\r\n<p><img src=\"/website/files/BCl0zCjdCDBIsPfE-templates.jpg\" alt=\"templates\"></p>\r\n\r\n<h3>Themes</h3>\r\n<p>\r\n<a href=\"/theming\">See theming</a>\r\n</p>\r\n<p><a href=\"/dumb-dog\" target=\"_blank\"></a></p><h3><a href=\"/dumb-dog\" target=\"_blank\">Have a look and a play here!</a></h3>','live','','','','header','2023-04-18 08:53:06','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 12:15:47','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),('77640251-342c-4fc9-a574-4ff81251e622','1af859c1-d967-11ed-8a12-5254003f8571','/','home','<h3>Welcome to Dumb Dog!</h3>\r\n\r\n<p><strong>So what is <span class=\"highlight\">Dumb Dog</span>?</strong></p>\r\n<p>Well its a lightweight CMS built in Zephir to run as a PHP module.</p>','live','','','','header','2023-01-29 12:50:19','77640251-342c-4fc9-a574-4ff81251e623','2023-04-17 15:40:33','00000000-0000-0000-0000-000000000000',NULL,NULL),('adbba018-dd42-11ed-8a63-5254003f8571','5d6c5133-d9f7-11ed-89da-5254003f8571','/variables','variables','<p>\n    Dumb Dog has built in variable <span class=\"highlight\">$DUMBDOG</span> that are used to access stuff like the page data. Here\'s what they are and how to use them.\n</p>\n<h3>Page</h3>\n<p><strong>$DUMBDOG-&gt;page</strong></p>\n<p>The page variable has the following properties.</p>\n<table>\n    <thead>\n        <tr>\n            <th>variable</th>\n            <th>description</th>\n            <th>usage</th>\n        </tr>\n    </thead>\n    <tbody>\n        <tr>\n            <td><strong>name</strong></td>\n            <td>The name/title of the page</td>\n            <td><strong>$DUMBDOG-&gt;page-&gt;name;</strong></td>\n        </tr>\n        <tr>\n            <td><strong>url</strong></td>\n            <td>The URL of the page</td>\n            <td><strong>$DUMBDOG-&gt;page-&gt;url;</strong></td>\n        </tr>\n        <tr>\n            <td><strong>content</strong></td>\n            <td>The page\'s content</td>\n            <td><strong>$DUMBDOG-&gt;page-&gt;content;</strong></td>\n        </tr>\n        <tr>\n            <td><strong>meta_keywords</strong></td>\n            <td>The META keywords</td>\n            <td><strong>$DUMBDOG-&gt;page-&gt;meta_keywords;</strong></td>\n        </tr>\n        <tr>\n            <td><strong>meta_description</strong></td>\n            <td>The META description</td>\n            <td><strong>$DUMBDOG-&gt;page-&gt;meta_description;</strong></td>\n        </tr>\n        <tr>\n            <td><strong>meta_author</strong></td>\n            <td>The META author</td>\n            <td><strong>$DUMBDOG-&gt;page-&gt;meta_author;</strong></td>\n        </tr>\n    </tbody>\n</table>\n<p><strong>Example</strong></p>\n<pre>\n&lt;h1&gt;&lt;?= $DUMBDOG-&gt;page-&gt;name; ?&gt;&lt;/h1&gt;\n</pre>\n<h3>Site</h3>\n<p><strong>$DUMBDOG-&gt;site</strong></p>\n<p>The site variable has the following properties.</p>\n<table>\n    <thead>\n        <tr>\n            <th>variable</th>\n            <th>description</th>\n            <th>usage</th>\n        </tr>\n    </thead>\n    <tbody>\n        <tr>\n            <td><strong>name</strong></td>\n            <td>The name of the site</td>\n            <td><strong>$DUMBDOG-&gt;site-&gt;name;</strong></td>\n        </tr>\n        <tr>\n            <td><strong>theme</strong></td>\n            <td>The current theme enabled. See <a href=\"/theming\">theming</a> for more information on themes.</td>\n            <td><strong>$DUMBDOG-&gt;site-&gt;theme;</strong></td>\n        </tr>\n        <tr>\n            <td><strong>meta_keywords</strong></td>\n            <td>The META keywords</td>\n            <td><strong>$DUMBDOG-&gt;site-&gt;meta_keywords;</strong></td>\n        </tr>\n        <tr>\n            <td><strong>meta_description</strong></td>\n            <td>The META description</td>\n            <td><strong>$DUMBDOG-&gt;site-&gt;meta_description;</strong></td>\n        </tr>\n        <tr>\n            <td><strong>meta_author</strong></td>\n            <td>The META author</td>\n            <td><strong>$DUMBDOG-&gt;site-&gt;meta_author;</strong></td>\n        </tr>\n    </tbody>\n</table>\n<p><strong>Example</strong></p>\n<pre>\n&lt;h1&gt;&lt;?= $DUMBDOG-&gt;site-&gt;name; ?&gt;&lt;/h1&gt;\n</pre>\n<h3>Pages</h3>\n<p><strong>$DUMBDOG-&gt;pages</strong></p>\n<p>The pages variable has the following properties. Pages is a handy way to get info on all live pages on Dumb Dog, especially for stuff like the sitemap page.</p>\n<table>\n    <thead>\n        <tr>\n            <th>function</th>\n            <th>description</th>\n            <th>usage</th>\n        </tr>\n    </thead>\n    <tbody>\n        <tr>\n            <td><strong>all</strong></td>\n            <td>Get all live pages.</td>\n            <td><strong>$DUMBDOG-&gt;pages-&gt;all();</strong></td>\n        </tr>\n    </tbody>\n</table>\n<p><strong>Example</strong></p>\n<pre>\n&lt;?php  $pages = $DUMBDOG-&gt;pages-&gt;all(); ?&gt;\n</pre>','live','','','','header','2023-04-17 18:09:57','00000000-0000-0000-0000-000000000000','2023-04-17 18:58:51','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),('afe5c73e-dd2e-11ed-8a63-5254003f8571','5d6c5133-d9f7-11ed-89da-5254003f8571','/installation','installation','<h3>Get it here</h3>\n<p><a href=\"https://github.com/kytschi/dumb-dog\" target=\"_blank\">https://github.com/kytschi/dumb-dog</a></p>\n<h3>Requirements</h3>\n<ul>\n<li>PHP 7+</li>\n<li>Your favourite SQL database</li>\n<li>Webserver (Nginx recommended)</li>\n</ul>\n<h3>Installation</h3>\n<p>Copy the module located in the <span class=\"highlight\">compiled</span> folder or download it to your PHP modules folder on your server.</p>\n<p><a href=\"https://github.com/kytschi/dumb-dog/blob/main/compiled\" target=\"_blank\">https://github.com/kytschi/dumb-dog/blob/main/compiled</a></p>\n<p>Now create an ini to load the module in your PHP modules ini folder.</p>\n<pre>configuration for php to enable dumb dog\nextension=dumbdog.so\n</pre>\n<p>\nYou can also just create the ini and point the <span class=\"highlight\">extension</span> to the folder with the <span class=\"highlight\">dumbdog.so</span>.</p>\n<p>\n<strong>And don\'t forget to restart your webserver!</strong></p>\n<p>If you have issues with the module you may need to compile it yourself. \nSee <a href=\"https://docs.zephir-lang.com/0.12/en/installation\" target=\"_blank\">https://docs.zephir-lang.com/0.12/en/installation</a> for more information on installing Zephir and compiling.\n</p>\n<p>Create yourself a database and run the SQL located in the setup folder.</p>\n<p>\n<a href=\"https://github.com/kytschi/dumb-dog/blob/main/setup/database.sql\" target=\"_blank\">https://github.com/kytschi/dumb-dog/blob/main/setup/database.sql</a>\n</p>\n<p>Once the database is setup and the SQL installed, go to the <span class=\"highlight\">dumbdog-example.json</span> in the root folder and copy it to a file called <span class=\"highlight\">dumbdog.json</span>. This is where you can configure <span class=\"highlight\">Dumb Dog</span>. Now set the database connection details to that of your newly created database.</p>\n\n<pre>\"database\":\n{\n        \"type\": \"mysql\",\n        \"host\": \"localhost\",\n        \"port\": \"3306\",\n        \"db\": \"dumb_dog\",\n        \"username\": \"dumbdog\",\n        \"password\": \"dumbdog\"\n}</pre>\n<p>Next point your webserver to the <span class=\"highlight\">public</span> folder of <span class=\"highlight\">Dumb Dog</span> where the <span class=\"highlight\">index.php</span> is located.</p>\n\n<p>That\'s it, now you can access <span class=\"highlight\">Dumb Dog</span> via whatever url you\'ve setup for the project by adding <span class=\"highlight\">/dumb-dog</span> to the url.</p>\n\n<p>Default login is username <span class=\"highlight\">dumbdog</span> and password is <span class=\"highlight\">woofwoof</span>.</p>\n\n<p><strong>DO NOT FORGET TO CREATE YOUR OWN USER AND DELETE THE DEFAULT ONE OR CHANGE ITS PASSWORD!</strong></p>\n\n<h3><strong>Getting started</strong></h3>\n<p>Once the module is installed and you\'ve got your webserver all setup pointing to the <span class=\"highlight\">index.php</span> your ready to start building.</p>\n<p>The front-end website is held in the <span class=\"highlight\">public&#92;website</span> folder. This is where you\'ll keep all your <span class=\"highlight\">templates</span> and your <span class=\"highlight\">themes</span>.</p>\n<p>Have a look at the <span class=\"highlight\">example</span> website in the repository to show you a way of building using <span class=\"highlight\">Dumb Dog</span>.</p>\n<h3>NOW, HAVE FUN!</h3>\n<h3>Credits</h3>\n<p>Many thanks to laimuilin18 for the art work. They make the app mate!<br>\n<a href=\"https://www.vecteezy.com/members/laimuilin18\" target=\"_blank\">https://www.vecteezy.com/members/laimuilin18</a></p>\n<p>Moon Flower font<br>\nFONT BY DENISE BENTULAN (c) 2013\n<br><a href=\"http://deathmunkey.deviantart.com\" target=\"_blank\">http://deathmunkey.deviantart.com</a></p>\n\n<p>Yummy Cupcakes font\n<br><a href=\"http://bythebutterfly.com\" target=\"_blank\">http://bythebutterfly.com</a></p>\n\n<p>Icons from<br>\n<a href=\"https://icons8.com\" target=\"_blank\">https://icons8.com</a></p>\n\n<p>Jquery<br>\n<a href=\"https://jquery.com/\" target=\"_blank\">https://jquery.com/</a></p>\n\n<p>Trumbowyg<br>\n<a href=\"https://alex-d.github.io/Trumbowyg/\" target=\"_blank\">https://alex-d.github.io/Trumbowyg/</a></p>','live','','','','header','2023-04-17 15:46:50','00000000-0000-0000-0000-000000000000','2023-04-17 17:31:45','00000000-0000-0000-0000-000000000000',NULL,NULL),('c580c158-dd56-11ed-8a63-5254003f8571','5d6c5133-d9f7-11ed-89da-5254003f8571','/theming','theming','<p>Themes are pretty easy with <span class=\"highlight\">Dumb Dog</span>. The idea is you create a theme, place it in the themes folder and then define it in the back end.</p>\r\n<p>When you want to enable that theme you just go in a turn it live.</p>\r\n<p>Themes must however follow a particular structure. Nothing too crazy but I\'ll explain.</p>\r\n<p>First you create a folder in the <span class=\"highlight\">themes</span> folder with the name you what to use for the theme.</p>\r\n<p>Next you create a CSS file, and this is important, called <span class=\"highlight\">theme.css</span>.</p>\r\n<p>Then in the back end you create a theme, making sure to set the folder name to that of the newly created theme and that\'s it. <br></p>\r\n<p><img src=\"/website/files/x0hn3LFeonn5kfI8-themes.jpg\" alt=\"Themes\"></p>\r\n<p>To switch the theme you go to <span class=\"highlight\">settings</span> and just select it from the list.</p><p><img src=\"/website/files/Czy8zyzRpLH0f1u7-settings.jpg\" alt=\"Settings\"></p>\r\n<p>Have a look at the example themes folder on the repository to get an idea of how its all laid out.</p>\r\n<p><a href=\"https://github.com/kytschi/dumb-dog/tree/main/example/themes\" target=\"_blank\">https://github.com/kytschi/dumb-dog/tree/main/example/themes</a></p>\r\n<p>To make use of that theme on the front end you simply use the <span class=\"highlight\">$DUMBDOG-&gt;site-&gt;theme;</span> variable which holds the URL for the <span class=\"highlight\">theme.css</span>.</p>','live','','','','header','2023-04-17 20:33:46','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-17 20:45:24','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),('e450a8b9-e29f-11ed-8a58-5254003f8571','5d6c5133-d9f7-11ed-89da-5254003f8571','/template-engines','Template Engines','<p><span class=\"highlight\">Dumb Dog</span> has the ability to use various template engines. Here\'s what is supported and how to enable them.</p>\r\n<p>Don\'t forget if you need it to make sure the autoload file is included in the index.php</p>\r\n<pre><code>// Include the autoload file.\r\nrequire_once \"../vendor/autoload.php\";</code></pre>\r\n\r\n<h3>Twig</h3><p>See <a href=\"https://twig.symfony.com/doc/3.x/installation.html\" target=\"_blank\">Twig installation</a> on how to install Twig into your project/website.</p><p>Now in your <span class=\"highlight\">index.php</span> define the Twig template engine and include it in <span class=\"highlight\">Dumb Dog</span>.<br></p>\r\n<pre><code>\r\n// Define the template folder for Twig.\r\n$loader = new &#92;Twig&#92;Loader&#92;FilesystemLoader(\"./website\");\r\n\r\n// Define the Twig engine.\r\n$engine = new &#92;Twig&#92;Environment(\r\n        $loader,\r\n        [\r\n            \"cache\" =&gt; \"../cache\"\r\n        ]\r\n);\r\nnew DumbDog(\"../dumbdog.json\", $engine);\r\n</code>\r\n</pre>\r\n<h3>Smarty</h3>\r\n<p>See <a href=\"https://smarty-php.github.io/smarty/4.x/getting-started/\" target=\"_blank\">Smarty installation</a> on how to install Smarty into your project/website.</p>\r\n<p>Now in your <span class=\"highlight\">index.php</span> define the Smarty template engine and include it in <span class=\"highlight\">Dumb Dog</span>.</p>\r\n<pre><code>\r\n// Include the autoload file.\r\nrequire_once \"../vendor/autoload.php\";\r\n// Define the Smarty template engine.\r\n$engine = new Smarty();\r\n// Set the Template folder.\r\n$engine-&gt;setTemplateDir(\'./website\');\r\n// Set the compile folder.\r\n$engine-&gt;setCompileDir(\'../cache\');\r\n// Set Cache folder if you like, speeds stuff up a lot.\r\n$engine-&gt;setCacheDir(\'../cache\');</code><br></pre>\r\n<h3>Volt</h3>\r\n<p>See <a href=\"https://docs.phalcon.io/4.0/en/volt\" target=\"_blank\">Phalcon installation</a> on how to install Volt into your project/website.</p>\r\n<p>Now in your <span class=\"highlight\">index.php</span> define the Volt template engine and include it in <span class=\"highlight\">Dumb Dog</span>.</p>\r\n<pre><code>$engine = new Phalcon&#92;Mvc&#92;View&#92;Engine&#92;Volt&#92;Compiler();<br>$engine-&gt;setOptions(<br>    [<br>        \'path\' =&gt; \'../cache/\'<br>    ]<br>);</code><br></pre>\r\n<h3>Blade</h3>\r\n<p>See <a href=\"https://github.com/EFTEC/BladeOne\" target=\"_blank\">Blade installation</a> on how to install Blade into your project/website.</p>\r\n<p>Now in your <span class=\"highlight\">index.php</span> define the Blade template engine and include it in <span class=\"highlight\">Dumb Dog</span>.</p>\r\n<pre><code>$engine = new eftec&#92;bladeone&#92;BladeOne(\r\n    \'./website\',\r\n    \'../cache\',\r\n    eftec&#92;bladeone&#92;BladeOne::MODE_DEBUG<br>);</code><br></pre>\r\n<h3>Plates</h3>\r\n<p>See <a href=\"https://platesphp.com/getting-started/installation/\" target=\"_self\">Plates installation</a> on how to install Plates into your project/website.</p>\r\n<p>Now in your <span class=\"highlight\">index.php</span> define the Plates template engine and include it in <span class=\"highlight\">Dumb Dog</span>.</p>\r\n<pre><code>$engine = new League&#92;Plates&#92;Engine(\'./website\');</code><br></pre>\r\n<h3>Mustache</h3>\r\n<p>See <a href=\"https://github.com/bobthecow/mustache.php\" target=\"_blank\">Mustache installation</a> on how to install Mustache into your project/website.</p>\r\n<p>Now in your <span class=\"highlight\">index.php</span> define the Mustache template engine and include it in <span class=\"highlight\">Dumb Dog</span>.</p>\r\n<pre><code> $engine = new Mustache_Engine([\r\n    \'cache\' =&gt; \'../cache\',\r\n    \'loader\' =&gt; new Mustache_Loader_FilesystemLoader(<br>         dirname(__FILE__) . \'/website\'<br>    )\r\n ]);</code><br></pre>','live',NULL,NULL,NULL,'header','2023-04-24 13:59:48','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-24 13:59:48','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,NULL),('e700753b-ddb5-11ed-89a6-5254003f8571','d7cdc951-ddb5-11ed-89a6-5254003f8571','/sitemap','sitemap','','live','','','','','2023-04-18 07:54:44','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 07:54:44','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),('f253d02f-ddb5-11ed-89a6-5254003f8571','5d6c5133-d9f7-11ed-89da-5254003f8571','/privacy','privacy','<p>If you see a cookie being used, mainly cause you\'ve logged into the back end, it\'s purely for functional use.</p><p>I also collection anonymous stats on my visitors basically to count the number of visits, if its a BOT and what browser agent.<br></p>','live','','','','','2023-04-18 07:55:03','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 07:57:59','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,'');
/*!40000 ALTER TABLE `pages` ENABLE KEYS */;
UNLOCK TABLES;

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
INSERT INTO `settings` VALUES ('dumb dog','b2d86900-d982-11ed-8a12-5254003f8571','online','A lightweight CMS written in Zephir to be run as a PHP module.','zephir, php module, cms, lightweight','Mike Welsh',NULL,'User-agent: *\r\nDisallow:');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stats`
--

DROP TABLE IF EXISTS `stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
-- Dumping data for table `stats`
--

LOCK TABLES `stats` WRITE;
/*!40000 ALTER TABLE `stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `stats` ENABLE KEYS */;
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
-- Dumping data for table `templates`
--

LOCK TABLES `templates` WRITE;
/*!40000 ALTER TABLE `templates` DISABLE KEYS */;
INSERT INTO `templates` VALUES ('1af859c1-d967-11ed-8a12-5254003f8571','homepage','home.php',0,'2023-04-12 20:20:38','00000000-0000-0000-0000-000000000000','2023-04-13 13:15:37','00000000-0000-0000-0000-000000000000',NULL,NULL),('2c040918-e2a4-11ed-8a58-5254003f8571','twig page','twig/page.html',0,'2023-04-24 14:30:26','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-24 14:39:21','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,''),('5d6c5133-d9f7-11ed-89da-5254003f8571','page','page.php',1,'2023-04-13 13:33:17','00000000-0000-0000-0000-000000000000','2023-04-17 12:42:03','00000000-0000-0000-0000-000000000000',NULL,NULL),('d7cdc951-ddb5-11ed-89a6-5254003f8571','sitemap','sitemap.php',0,'2023-04-18 07:54:19','89c759f3-da4b-11ed-89f5-5254003f8571','2023-04-18 07:54:19','89c759f3-da4b-11ed-89f5-5254003f8571',NULL,'');
/*!40000 ALTER TABLE `templates` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `themes`
--

LOCK TABLES `themes` WRITE;
/*!40000 ALTER TABLE `themes` DISABLE KEYS */;
INSERT INTO `themes` VALUES ('b2d86900-d982-11ed-8a12-5254003f8571',1,'default','default','active',NULL,NULL,0,'2023-04-12 23:38:09','00000000-0000-0000-0000-000000000000','2023-04-17 12:46:43','00000000-0000-0000-0000-000000000000',NULL,NULL);
/*!40000 ALTER TABLE `themes` ENABLE KEYS */;
UNLOCK TABLES;

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
INSERT INTO `users` VALUES ('89c759f3-da4b-11ed-89f5-5254003f8571','dumbdog','$2y$10$hv7daGztxRPzlN71oHyF8OntAtchU6p/lp8tpV6qTQSl1339QO4nC','Doggie','active','2023-04-13 23:35:48','00000000-0000-0000-0000-000000000000','2023-04-17 10:25:20','00000000-0000-0000-0000-000000000000',NULL,NULL);
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

-- Dump completed on 2023-05-01 16:01:40
