ALTER TABLE notes ADD user_id varchar(36) NULL;
ALTER TABLE notes CHANGE user_id user_id varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL NULL AFTER resource_id;

ALTER TABLE notes ADD tags TEXT NULL;
ALTER TABLE notes CHANGE tags tags text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL NULL AFTER content;
