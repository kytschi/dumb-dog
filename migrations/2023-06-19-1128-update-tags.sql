ALTER TABLE files DROP INDEX files_tags_IDX;
ALTER TABLE files MODIFY COLUMN tags TEXT CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL NULL;
ALTER TABLE pages DROP INDEX pages_tags_IDX;
ALTER TABLE pages MODIFY COLUMN tags TEXT CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL NULL;