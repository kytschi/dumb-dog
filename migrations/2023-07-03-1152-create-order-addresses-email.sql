ALTER TABLE order_addresses ADD email varchar(255) NULL;
ALTER TABLE order_addresses CHANGE email email varchar(255) NULL AFTER name;
CREATE INDEX order_addresses_email_IDX USING BTREE ON order_addresses (email);