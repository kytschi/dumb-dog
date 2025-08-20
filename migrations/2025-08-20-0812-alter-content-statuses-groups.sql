ALTER TABLE content MODIFY COLUMN tags text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL NULL;

ALTER TABLE countries MODIFY COLUMN status varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'live' NOT NULL;
ALTER TABLE currencies MODIFY COLUMN status varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'live' NOT NULL;
ALTER TABLE payment_gateways MODIFY COLUMN status varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'live' NOT NULL;
ALTER TABLE product_shipping MODIFY COLUMN status varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'live' NULL;
ALTER TABLE themes MODIFY COLUMN status varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'live' NOT NULL;

ALTER TABLE groups ADD tags TEXT NULL;
ALTER TABLE groups ADD status varchar(10) DEFAULT 'live' NOT NULL;

ALTER TABLE product_prices ADD status varchar(10) DEFAULT 'live' NOT NULL;
